'use strict';

const { initializeApp } = require('firebase-admin/app');
const { getAuth } = require('firebase-admin/auth');
const {
  FieldValue,
  Timestamp,
  getFirestore,
} = require('firebase-admin/firestore');
const { HttpsError, onCall } = require('firebase-functions/v2/https');
const { onDocumentUpdated } = require('firebase-functions/v2/firestore');
const {
  anonymousPlayerId,
  anonymizePlayers,
  anonymizeUidMap,
  deletionOperationId,
  isValidUsername,
  normalizeUsername,
  playerBlockPath,
  resolvePlayerTarget,
} = require('./safety_helpers');

initializeApp();

const db = getFirestore();

async function enforceRateLimit(uid, action, limit, windowSeconds) {
  const reference = db.collection('_rate_limits').doc(`${uid}_${action}`);
  const now = Date.now();
  await db.runTransaction(async (transaction) => {
    const snapshot = await transaction.get(reference);
    const data = snapshot.data() ?? {};
    const started = data.windowStartedAt?.toMillis?.() ?? 0;
    const open = now - started < windowSeconds * 1000;
    const count = open ? Number(data.count ?? 0) : 0;
    if (count >= limit) {
      throw new HttpsError('resource-exhausted', 'İstek sınırı aşıldı.');
    }
    transaction.set(reference, {
      uid,
      action,
      count: count + 1,
      windowStartedAt: open ? data.windowStartedAt : new Date(now),
      expiresAt: new Date(now + windowSeconds * 1000),
      updatedAt: FieldValue.serverTimestamp(),
    });
  });
}

async function resolveTargetUid(identifier) {
  const playerId = String(identifier ?? '').trim();
  if (!playerId) {
    throw new HttpsError('not-found', 'Oyuncu bulunamadı.');
  }
  if (!playerId.startsWith('p_')) return playerId;
  const directory = await db
    .collection('public_player_directory')
    .doc(playerId)
    .get();
  const uid = directory.data()?.uid;
  if (typeof uid !== 'string' || !uid) {
    throw new HttpsError('not-found', 'Oyuncu bulunamadı.');
  }
  return uid;
}

async function resolveTargetPlayer(identifier) {
  const target = await resolvePlayerTarget(identifier, {
    lookupPublicUid: async (publicPlayerId) => {
      const directory = await db
        .collection('public_player_directory')
        .doc(publicPlayerId)
        .get();
      return directory.data()?.uid;
    },
    lookupUser: async (uid) => {
      const user = await db.collection('users').doc(uid).get();
      return user.exists ? user.data() : null;
    },
  });
  if (!target) {
    throw new HttpsError('not-found', 'Oyuncu bulunamadı.');
  }
  return target;
}

function requireUser(request) {
  if (!request.auth?.uid) {
    throw new HttpsError('unauthenticated', 'Oturum açılması gerekiyor.');
  }
  return request.auth.uid;
}

function requireModerator(request) {
  const token = request.auth?.token ?? {};
  if (!request.auth?.uid || (token.admin !== true && token.moderator !== true)) {
    throw new HttpsError('permission-denied', 'Yönetici yetkisi gerekiyor.');
  }
  return request.auth.uid;
}

async function deleteQuery(query) {
  const snapshot = await query.get();
  if (snapshot.empty) return;
  const writer = db.bulkWriter();
  for (const document of snapshot.docs) writer.delete(document.ref);
  await writer.close();
}

async function anonymizeMatches(uid) {
  const anonymousId = anonymousPlayerId(uid);
  const snapshot = await db
    .collection('live_duel_matches')
    .where('playerUids', 'array-contains', uid)
    .get();
  const writer = db.bulkWriter();
  for (const document of snapshot.docs) {
    const data = document.data();
    writer.update(document.ref, {
      players: anonymizePlayers(data.players, uid),
      playerUids: (data.playerUids ?? []).map((item) =>
        item === uid ? anonymousId : item,
      ),
      scores: anonymizeUidMap(data.scores, uid),
      winnerUid: data.winnerUid === uid ? anonymousId : data.winnerUid,
      createdBy: data.createdBy === uid ? anonymousId : data.createdBy,
      processedBy: data.processedBy === uid ? anonymousId : data.processedBy,
      forfeitLoserUid:
        data.forfeitLoserUid === uid ? anonymousId : data.forfeitLoserUid,
      [`deletedParticipants.${anonymousId}`]: true,
      anonymizedAt: FieldValue.serverTimestamp(),
    });
  }
  await writer.close();
}

exports.requestAccountDeletion = onCall(
  { region: 'europe-west1', enforceAppCheck: false },
  async (request) => {
    const uid = requireUser(request);
    await enforceRateLimit(uid, 'account-delete', 3, 24 * 60 * 60);
    const operationId = deletionOperationId(uid);
    const operation = db.collection('account_deletion_operations').doc(operationId);
    const existingOperation = await operation.get();
    if (existingOperation.data()?.status === 'complete') {
      return { operationId, status: 'complete' };
    }

    await operation.set(
      {
        operationId,
        uid,
        stage: 'started',
        status: 'running',
        requestedAt: FieldValue.serverTimestamp(),
        updatedAt: FieldValue.serverTimestamp(),
      },
      { merge: true },
    );

    try {
      const userRef = db.collection('users').doc(uid);
      const user = await userRef.get();
      const username = normalizeUsername(user.data()?.username);
      const publicPlayerId = String(user.data()?.publicPlayerId ?? '');

      await operation.set(
        { stage: 'public-records', updatedAt: FieldValue.serverTimestamp() },
        { merge: true },
      );
      await Promise.all([
        db.collection('live_duel_queue').doc(uid).delete(),
        publicPlayerId
          ? db.collection('live_duel_leaderboard').doc(publicPlayerId).delete()
          : Promise.resolve(),
        publicPlayerId
          ? db.collection('public_player_directory').doc(publicPlayerId).delete()
          : Promise.resolve(),
        deleteQuery(
          db.collection('live_duel_result_claims').where('uid', '==', uid),
        ),
        deleteQuery(
          db.collection('player_reports').where('reporterUid', '==', uid),
        ),
        db.recursiveDelete(db.collection('player_blocks').doc(uid)),
      ]);
      await Promise.all([
        deleteQuery(
          db.collectionGroup('blocked').where('targetUid', '==', uid),
        ),
        deleteQuery(
          db.collection('live_duel_result_claims').where('opponentUid', '==', uid),
        ),
      ]);
      const opponentResults = await db
        .collectionGroup('live_duel_results')
        .where('opponentUid', '==', uid)
        .get();
      const resultWriter = db.bulkWriter();
      for (const result of opponentResults.docs) {
        resultWriter.update(result.ref, {
          opponentUid: anonymousPlayerId(uid),
          opponentDeleted: true,
        });
      }
      await resultWriter.close();

      const targetReports = await db
        .collection('player_reports')
        .where('targetUid', '==', uid)
        .get();
      const reportWriter = db.bulkWriter();
      for (const report of targetReports.docs) {
        reportWriter.update(report.ref, {
          targetUid: anonymousPlayerId(uid),
          targetUsername: 'silinmis_oyuncu',
          targetDeleted: true,
        });
      }
      await reportWriter.close();

      if (username) {
        const claim = db.collection('usernames').doc(username);
        await db.runTransaction(async (transaction) => {
          const snapshot = await transaction.get(claim);
          if (snapshot.data()?.uid === uid) transaction.delete(claim);
        });
      }

      await operation.set(
        { stage: 'shared-matches', updatedAt: FieldValue.serverTimestamp() },
        { merge: true },
      );
      await anonymizeMatches(uid);

      await operation.set(
        { stage: 'private-data', updatedAt: FieldValue.serverTimestamp() },
        { merge: true },
      );
      await db.recursiveDelete(userRef);

      // Authentication en son silinir; önceki aşamalar tekrar çalıştırılabilir.
      await operation.set(
        { stage: 'authentication', updatedAt: FieldValue.serverTimestamp() },
        { merge: true },
      );
      try {
        await getAuth().deleteUser(uid);
      } catch (error) {
        if (error?.code !== 'auth/user-not-found') throw error;
      }

      await operation.set(
        {
          uid: FieldValue.delete(),
          stage: 'complete',
          status: 'complete',
          completedAt: FieldValue.serverTimestamp(),
          updatedAt: FieldValue.serverTimestamp(),
        },
        { merge: true },
      );
      return { operationId, status: 'complete' };
    } catch (error) {
      await operation.set(
        {
          status: 'failed',
          errorCode: error?.code ?? 'unknown',
          updatedAt: FieldValue.serverTimestamp(),
        },
        { merge: true },
      );
      throw new HttpsError(
        'internal',
        'Hesap silme tamamlanamadı; işlem güvenle yeniden denenebilir.',
      );
    }
  },
);

exports.claimUsername = onCall(
  { region: 'europe-west1', enforceAppCheck: false },
  async (request) => {
    const uid = requireUser(request);
    await enforceRateLimit(uid, 'username-attempt', 12, 10 * 60);
    await enforceRateLimit(uid, 'username-change', 6, 24 * 60 * 60);
    const username = normalizeUsername(request.data?.username);
    if (!isValidUsername(username)) {
      throw new HttpsError('invalid-argument', 'Bu kullanıcı adı kullanılamaz.');
    }

    const userRef = db.collection('users').doc(uid);
    const preview = await userRef.get();
    if (!preview.exists) {
      throw new HttpsError('failed-precondition', 'Kullanıcı profili yok.');
    }
    const oldPreview = normalizeUsername(preview.data()?.username);
    if (!oldPreview) {
      const agreement = await userRef.collection('agreements').doc('community').get();
      if (
        !agreement.exists ||
        agreement.data()?.uid !== uid ||
        typeof agreement.data()?.textVersion !== 'string'
      ) {
        throw new HttpsError(
          'failed-precondition',
          'Kullanım koşulları ve topluluk kuralları kabul edilmelidir.',
        );
      }
    }
    if (oldPreview && oldPreview !== username) {
      const [queue, activeMatches] = await Promise.all([
        db.collection('live_duel_queue').doc(uid).get(),
        db
          .collection('live_duel_matches')
          .where('playerUids', 'array-contains', uid)
          .where('resultProcessed', '==', false)
          .limit(1)
          .get(),
      ]);
      if (queue.exists || !activeMatches.empty) {
        throw new HttpsError(
          'failed-precondition',
          'Aktif eşleştirme veya düello varken kullanıcı adı değiştirilemez.',
        );
      }
    }

    const now = Timestamp.now();
    const result = await db.runTransaction(async (transaction) => {
      const targetRef = db.collection('usernames').doc(username);
      const user = await transaction.get(userRef);
      const userData = user.data() ?? {};
      const oldUsername = normalizeUsername(userData.username);
      const oldRef =
        oldUsername && oldUsername !== username
          ? db.collection('usernames').doc(oldUsername)
          : null;
      const [target, oldClaim] = await Promise.all([
        transaction.get(targetRef),
        oldRef ? transaction.get(oldRef) : Promise.resolve(null),
      ]);
      if (target.exists && target.data()?.uid !== uid) {
        throw new HttpsError(
          'already-exists',
          'Bu kullanıcı adı başkası tarafından alınmış.',
        );
      }
      const changedAt = userData.usernameChangedAt?.toMillis?.() ?? 0;
      const firstSetAt = userData.usernameFirstSetAt?.toMillis?.() ?? 0;
      const correctionUsed = userData.usernameCorrectionUsed === true;
      const policyVersion = Number(userData.usernamePolicyVersion ?? 1);
      const initial = !oldUsername;
      const migrationCorrection =
        !initial && !correctionUsed && policyVersion < 2;
      const firstDayCorrection =
        !initial &&
        !correctionUsed &&
        firstSetAt > 0 &&
        now.toMillis() <= firstSetAt + 24 * 60 * 60 * 1000;
      const same = oldUsername === username;
      if (
        !same &&
        !initial &&
        !migrationCorrection &&
        !firstDayCorrection &&
        now.toMillis() < changedAt + 30 * 24 * 60 * 60 * 1000
      ) {
        throw new HttpsError(
          'failed-precondition',
          '30 günlük değiştirme süresi henüz dolmadı.',
        );
      }
      if (!target.exists) {
        transaction.create(targetRef, {
          uid,
          username,
          createdAt: now,
        });
      }
      if (!same || !target.exists) {
        transaction.set(
          userRef,
          {
            username,
            usernameChangedAt: same ? userData.usernameChangedAt ?? now : now,
            usernameFirstSetAt: initial
              ? now
              : userData.usernameFirstSetAt ?? now,
            usernameCorrectionUsed: initial ? false : !same || correctionUsed,
            usernamePolicyVersion: 2,
          },
          { merge: true },
        );
      }
      if (oldRef && oldClaim?.data()?.uid === uid) {
        transaction.delete(oldRef);
      }
      return {
        username,
        changedAtMillis: same && changedAt > 0 ? changedAt : now.toMillis(),
        firstSetAtMillis: initial
          ? now.toMillis()
          : firstSetAt || now.toMillis(),
        correctionUsed: initial ? false : !same || correctionUsed,
        policyVersion: 2,
      };
    });
    return result;
  },
);

exports.adminResetUsername = onCall(
  { region: 'europe-west1', enforceAppCheck: true },
  async (request) => {
    const actorUid = requireModerator(request);
    await enforceRateLimit(actorUid, 'admin-username-reset', 30, 60 * 60);
    const targetPlayerId = String(request.data?.targetUid ?? '');
    const targetUid = await resolveTargetUid(targetPlayerId);
    const newUsername = normalizeUsername(request.data?.newUsername);
    const reason = String(request.data?.reason ?? '').trim().slice(0, 300);

    if (!targetUid || !isValidUsername(newUsername) || reason.length < 5) {
      throw new HttpsError('invalid-argument', 'Geçersiz düzeltme isteği.');
    }

    const userRef = db.collection('users').doc(targetUid);
    const newClaim = db.collection('usernames').doc(newUsername);
    const auditRef = db.collection('moderation_audit').doc();

    await db.runTransaction(async (transaction) => {
      const [user, targetClaim] = await Promise.all([
        transaction.get(userRef),
        transaction.get(newClaim),
      ]);
      if (!user.exists) throw new HttpsError('not-found', 'Oyuncu bulunamadı.');
      if (targetClaim.exists && targetClaim.data().uid !== targetUid) {
        throw new HttpsError('already-exists', 'Kullanıcı adı alınmış.');
      }

      const oldUsername = normalizeUsername(user.data().username);
      transaction.set(newClaim, {
        uid: targetUid,
        username: newUsername,
        createdAt: FieldValue.serverTimestamp(),
      });
      transaction.update(userRef, {
        username: newUsername,
        usernameChangedAt: FieldValue.serverTimestamp(),
        usernameCorrectionUsed: true,
        usernamePolicyVersion: 2,
      });
      if (oldUsername && oldUsername !== newUsername) {
        transaction.delete(db.collection('usernames').doc(oldUsername));
      }
      transaction.create(auditRef, {
        actorUid,
        targetUid,
        oldUsername,
        newUsername,
        reason,
        createdAt: FieldValue.serverTimestamp(),
      });
    });

    return { status: 'complete', auditId: auditRef.id };
  },
);

exports.reportPlayer = onCall(
  { region: 'europe-west1', enforceAppCheck: false },
  async (request) => {
    const reporterUid = requireUser(request);
    await enforceRateLimit(reporterUid, 'player-report', 5, 60 * 60);
    const targetPlayerId = String(request.data?.targetUid ?? '');
    const target = await resolveTargetPlayer(targetPlayerId);
    const targetUid = target.uid;
    const targetUsername = target.username;
    const reason = String(request.data?.reason ?? '');
    const note = String(request.data?.note ?? '')
      .replace(/[\u0000-\u001f]/g, '')
      .trim()
      .slice(0, 300);
    const source = String(request.data?.source ?? '');
    const reasons = [
      'inappropriateUsername',
      'impersonation',
      'harassment',
      'cheating',
      'other',
    ];
    if (
      targetUid === reporterUid ||
      !reasons.includes(reason) ||
      !['leaderboard', 'live_duel_result'].includes(source)
    ) {
      throw new HttpsError('invalid-argument', 'Bildirim geçersiz.');
    }
    const id = `${reporterUid}_${targetUid}_${reason}`;
    const reference = db.collection('player_reports').doc(id);
    await db.runTransaction(async (transaction) => {
      const existing = await transaction.get(reference);
      if (existing.exists) {
        throw new HttpsError('already-exists', 'Bildirim daha önce alındı.');
      }
      transaction.create(reference, {
        reporterUid,
        targetUid,
        targetUsername,
        reason,
        note,
        source,
        status: 'pending',
        createdAt: FieldValue.serverTimestamp(),
        appVersion: String(request.data?.appVersion ?? ''),
      });
    });
    return { status: 'accepted', reportId: id };
  },
);

exports.setPlayerBlock = onCall(
  { region: 'europe-west1', enforceAppCheck: false },
  async (request) => {
    const ownerUid = requireUser(request);
    await enforceRateLimit(ownerUid, 'player-block', 20, 60 * 60);
    const targetPlayerId = String(request.data?.targetUid ?? '');
    const blocked = request.data?.blocked === true;
    const targetUid = await resolveTargetUid(targetPlayerId);
    if (targetUid === ownerUid) {
      throw new HttpsError('invalid-argument', 'Engel isteği geçersiz.');
    }
    const reference = db.doc(playerBlockPath(ownerUid, targetUid));
    if (!blocked) {
      await reference.delete();
      return { blocked: false };
    }
    const target = await resolveTargetPlayer(targetPlayerId);
    const targetUsername = target.username;
    await reference.set({
      ownerUid,
      targetUid,
      targetUsername,
      createdAt: FieldValue.serverTimestamp(),
      appVersion: String(request.data?.appVersion ?? ''),
    });
    return { blocked: true };
  },
);

exports.submitQuestionFeedback = onCall(
  { region: 'europe-west1', enforceAppCheck: false },
  async (request) => {
    const uid = request.auth?.uid ?? `app:${request.app?.appId ?? 'unknown'}`;
    await enforceRateLimit(uid, 'question-feedback', 5, 10 * 60);
    const payload = request.data?.payload;
    if (!payload || typeof payload !== 'object') {
      throw new HttpsError('invalid-argument', 'Geri bildirim geçersiz.');
    }
    const text = (value, maximum) =>
      String(value ?? '')
        .replace(/[\u0000-\u001f]/g, ' ')
        .trim()
        .slice(0, maximum);
    const eventId = text(payload.eventId, 180);
    if (!eventId) throw new HttpsError('invalid-argument', 'Olay kimliği yok.');
    await db.collection('question_feedback').doc(eventId).create({
      questionId: text(payload.questionId, 120),
      category: text(payload.category, 40),
      feedbackType: text(payload.feedbackType, 40),
      errorReason: text(payload.errorReason, 120),
      userNote: text(payload.userNote, 300),
      gameMode: text(payload.gameMode, 60),
      appVersion: text(payload.appVersion, 30),
      reporterUid: request.auth?.uid ?? null,
      createdAt: FieldValue.serverTimestamp(),
      status: 'pending',
    });
    return { ok: true };
  },
);

exports.syncUsernameToLeaderboard = onDocumentUpdated(
  {
    region: 'europe-west1',
    document: 'users/{uid}',
  },
  async (event) => {
    const before = event.data?.before.data() ?? {};
    const after = event.data?.after.data() ?? {};
    if (
      before.username === after.username ||
      typeof after.publicPlayerId !== 'string' ||
      typeof after.username !== 'string'
    ) {
      return;
    }
    await db
      .collection('live_duel_leaderboard')
      .doc(after.publicPlayerId)
      .set(
        {
          publicPlayerId: after.publicPlayerId,
          displayName: after.username,
          updatedAt: FieldValue.serverTimestamp(),
        },
        { merge: true },
      );
  },
);

Object.assign(exports, require('./live_duel'));
Object.assign(exports, require('./rewarded_ssv'));
