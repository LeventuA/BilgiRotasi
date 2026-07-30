'use strict';

const { initializeApp } = require('firebase-admin/app');
const { getAuth } = require('firebase-admin/auth');
const { FieldValue, getFirestore } = require('firebase-admin/firestore');
const { HttpsError, onCall } = require('firebase-functions/v2/https');
const {
  anonymousPlayerId,
  anonymizePlayers,
  anonymizeUidMap,
  deletionOperationId,
  isValidUsername,
  normalizeUsername,
} = require('./safety_helpers');

initializeApp();

const db = getFirestore();

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
    const operationId = deletionOperationId(uid);
    const operation = db.collection('account_deletion_operations').doc(operationId);

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

      await operation.set(
        { stage: 'public-records', updatedAt: FieldValue.serverTimestamp() },
        { merge: true },
      );
      await Promise.all([
        db.collection('live_duel_queue').doc(uid).delete(),
        db.collection('live_duel_leaderboard').doc(uid).delete(),
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
      await getAuth().deleteUser(uid);

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

exports.adminResetUsername = onCall(
  { region: 'europe-west1', enforceAppCheck: true },
  async (request) => {
    const actorUid = requireModerator(request);
    const targetUid = String(request.data?.targetUid ?? '');
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
