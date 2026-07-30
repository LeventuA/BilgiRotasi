'use strict';

const { randomUUID } = require('node:crypto');
const { FieldValue, Timestamp, getFirestore } = require('firebase-admin/firestore');
const { HttpsError, onCall } = require('firebase-functions/v2/https');
const { onSchedule } = require('firebase-functions/v2/scheduler');
const {
  deterministicMatchId,
  newPublicPlayerId,
  resultForScores,
  retentionCutoffs,
  safeQuestionCount,
  updatedProfile,
} = require('./duel_helpers');

const db = getFirestore();
const REGION = 'europe-west1';

function requireUid(request) {
  if (!request.auth?.uid) {
    throw new HttpsError('unauthenticated', 'Oturum açılması gerekiyor.');
  }
  return request.auth.uid;
}

async function enforceRateLimit(uid, action, limit, windowSeconds) {
  const reference = db.collection('_rate_limits').doc(`${uid}_${action}`);
  const now = Timestamp.now();
  await db.runTransaction(async (transaction) => {
    const snapshot = await transaction.get(reference);
    const data = snapshot.data() ?? {};
    const windowStartedAt = data.windowStartedAt?.toMillis?.() ?? 0;
    const stillOpen = now.toMillis() - windowStartedAt < windowSeconds * 1000;
    const count = stillOpen ? Number(data.count ?? 0) : 0;
    if (count >= limit) {
      throw new HttpsError('resource-exhausted', 'İstek sınırı aşıldı.');
    }
    transaction.set(reference, {
      uid,
      action,
      count: count + 1,
      windowStartedAt: stillOpen ? data.windowStartedAt : now,
      expiresAt: Timestamp.fromMillis(now.toMillis() + windowSeconds * 1000),
      updatedAt: now,
    });
  });
}

async function ensurePublicIdentity(uid, transaction) {
  const userRef = db.collection('users').doc(uid);
  const agreementRef = userRef.collection('agreements').doc('community');
  const [user, agreement] = await Promise.all([
    transaction.get(userRef),
    transaction.get(agreementRef),
  ]);
  if (!user.exists) throw new HttpsError('failed-precondition', 'Profil yok.');
  const legacyAccount =
    Number(user.data().usernamePolicyVersion ?? 1) < 2 ||
    user.data().usernameCorrectionUsed === true;
  const validAgreement =
    agreement.exists &&
    agreement.data().uid === uid &&
    typeof agreement.data().textVersion === 'string';
  if (!validAgreement && !legacyAccount) {
    throw new HttpsError(
      'failed-precondition',
      'Çevrimiçi topluluk kuralları kabul edilmelidir.',
    );
  }
  let publicPlayerId = user.data().publicPlayerId;
  if (typeof publicPlayerId !== 'string' || !publicPlayerId.startsWith('p_')) {
    publicPlayerId = newPublicPlayerId();
    transaction.update(userRef, { publicPlayerId });
  }
  transaction.set(
    db.collection('public_player_directory').doc(publicPlayerId),
    { uid, updatedAt: FieldValue.serverTimestamp() },
    { merge: true },
  );
  return {
    publicPlayerId,
    username: String(user.data().username ?? ''),
    profile: user.data().liveDuelProfile ?? {},
  };
}

async function blocked(firstUid, secondUid) {
  const [first, second] = await Promise.all([
    db.doc(`player_blocks/${firstUid}/blocked/${secondUid}`).get(),
    db.doc(`player_blocks/${secondUid}/blocked/${firstUid}`).get(),
  ]);
  return first.exists || second.exists;
}

exports.joinLiveDuelQueue = onCall(
  { region: REGION, enforceAppCheck: false },
  async (request) => {
    const uid = requireUid(request);
    await enforceRateLimit(uid, 'matchmaking', 12, 60);
    const questionCount = safeQuestionCount(request.data?.questionCount);
    const queueRef = db.collection('live_duel_queue').doc(uid);
    const ticketId = randomUUID();

    await db.runTransaction(async (transaction) => {
      const identity = await ensurePublicIdentity(uid, transaction);
      if (!identity.username) {
        throw new HttpsError('failed-precondition', 'Kullanıcı adı gerekli.');
      }
      const rating = Math.max(0, Number(identity.profile.rating ?? 1000));
      transaction.set(queueRef, {
        ownerUid: uid,
        publicPlayerId: identity.publicPlayerId,
        displayName: identity.username,
        rating,
        ratingBucket: Math.floor(rating / 200),
        questionCount,
        ticketId,
        status: 'waiting',
        joinedAt: FieldValue.serverTimestamp(),
        expiresAt: Timestamp.fromMillis(Date.now() + 3 * 60 * 1000),
      });
    });
    return { status: 'waiting', ticketId };
  },
);

exports.findLiveDuelMatch = onCall(
  { region: REGION, enforceAppCheck: false },
  async (request) => {
    const uid = requireUid(request);
    await enforceRateLimit(uid, 'matchmaking-search', 20, 60);
    const ownRef = db.collection('live_duel_queue').doc(uid);
    const own = await ownRef.get();
    if (!own.exists || own.data().status !== 'waiting') {
      throw new HttpsError('failed-precondition', 'Aktif kuyruk yok.');
    }

    const data = own.data();
    const buckets = [
      Math.max(0, Number(data.ratingBucket) - 1),
      Number(data.ratingBucket),
      Number(data.ratingBucket) + 1,
    ];
    const candidates = await db
      .collection('live_duel_queue')
      .where('questionCount', '==', data.questionCount)
      .where('status', '==', 'waiting')
      .where('ratingBucket', 'in', [...new Set(buckets)])
      .limit(20)
      .get();

    for (const candidate of candidates.docs) {
      if (candidate.id === uid || (await blocked(uid, candidate.id))) continue;
      const matchId = deterministicMatchId(
        data.ticketId,
        candidate.data().ticketId,
      );
      const matchRef = db.collection('live_duel_matches').doc(matchId);
      const catalog = await db.doc('live_duel_config/question_catalog').get();
      const ids = catalog.data()?.questionIds;
      if (!Array.isArray(ids) || ids.length < data.questionCount) {
        throw new HttpsError(
          'failed-precondition',
          'Sunucu soru kataloğu hazır değil.',
        );
      }
      const questionIds = ids.slice(0, data.questionCount);

      const matched = await db.runTransaction(async (transaction) => {
        const [freshOwn, freshCandidate, existingMatch] = await Promise.all([
          transaction.get(ownRef),
          transaction.get(candidate.ref),
          transaction.get(matchRef),
        ]);
        if (existingMatch.exists) return true;
        if (
          freshOwn.data()?.status !== 'waiting' ||
          freshCandidate.data()?.status !== 'waiting'
        ) {
          return false;
        }
        transaction.create(matchRef, {
          status: 'active',
          questionCount: data.questionCount,
          questionIds,
          questionSetVersion: 2,
          playerUids: [uid, candidate.id],
          players: [
            {
              uid,
              publicPlayerId: freshOwn.data().publicPlayerId,
              displayName: freshOwn.data().displayName,
              rating: freshOwn.data().rating,
            },
            {
              uid: candidate.id,
              publicPlayerId: freshCandidate.data().publicPlayerId,
              displayName: freshCandidate.data().displayName,
              rating: freshCandidate.data().rating,
            },
          ],
          resultProcessed: false,
          createdAt: FieldValue.serverTimestamp(),
          updatedAt: FieldValue.serverTimestamp(),
          expiresAt: Timestamp.fromMillis(Date.now() + 60 * 60 * 1000),
        });
        transaction.update(ownRef, { status: 'matched', matchId });
        transaction.update(candidate.ref, { status: 'matched', matchId });
        return true;
      });
      if (matched) return { status: 'matched', matchId };
    }
    return { status: 'waiting' };
  },
);

exports.cancelLiveDuelQueue = onCall(
  { region: REGION, enforceAppCheck: false },
  async (request) => {
    const uid = requireUid(request);
    const queueRef = db.collection('live_duel_queue').doc(uid);
    await db.runTransaction(async (transaction) => {
      const snapshot = await transaction.get(queueRef);
      if (!snapshot.exists) return;
      if (snapshot.data().status === 'matched') {
        throw new HttpsError(
          'failed-precondition',
          'Rakip bulunduğu için eşleştirme iptal edilemez.',
        );
      }
      transaction.delete(queueRef);
    });
    return { status: 'cancelled' };
  },
);

exports.submitLiveDuelAnswer = onCall(
  { region: REGION, enforceAppCheck: false },
  async (request) => {
    const uid = requireUid(request);
    await enforceRateLimit(uid, 'duel-answer', 90, 60);
    const matchId = String(request.data?.matchId ?? '');
    const questionId = String(request.data?.questionId ?? '');
    const selectedIndex = Number(request.data?.selectedIndex);
    if (!matchId || !questionId || !Number.isInteger(selectedIndex)) {
      throw new HttpsError('invalid-argument', 'Cevap geçersiz.');
    }
    const matchRef = db.collection('live_duel_matches').doc(matchId);
    const progressRef = matchRef.collection('progress').doc(uid);
    const answerRef = db.collection('live_duel_answer_keys').doc(questionId);

    await db.runTransaction(async (transaction) => {
      const [match, progress, answer] = await Promise.all([
        transaction.get(matchRef),
        transaction.get(progressRef),
        transaction.get(answerRef),
      ]);
      if (!match.exists || !match.data().playerUids.includes(uid)) {
        throw new HttpsError('permission-denied', 'Maça erişim yok.');
      }
      if (match.data().status !== 'active' || match.data().resultProcessed) {
        throw new HttpsError('failed-precondition', 'Maç aktif değil.');
      }
      const questionIds = match.data().questionIds ?? [];
      const answeredIds = progress.data()?.answeredQuestionIds ?? [];
      if (
        questionIds[answeredIds.length] !== questionId ||
        answeredIds.includes(questionId)
      ) {
        throw new HttpsError('already-exists', 'Soru daha önce cevaplandı.');
      }
      if (!answer.exists) {
        throw new HttpsError('failed-precondition', 'Cevap anahtarı yok.');
      }
      const optionCount = Number(answer.data().optionCount ?? 4);
      if (selectedIndex < 0 || selectedIndex >= optionCount) {
        throw new HttpsError('invalid-argument', 'Seçenek aralık dışında.');
      }
      const correct = selectedIndex === Number(answer.data().answerIndex);
      const nextAnswered = [...answeredIds, questionId];
      const correctCount =
        Number(progress.data()?.correctCount ?? progress.data()?.score ?? 0) +
        (correct ? 1 : 0);
      const finished = nextAnswered.length === questionIds.length;
      transaction.set(
        progressRef,
        {
          uid,
          score: correctCount,
          currentQuestionIndex: nextAnswered.length,
          answeredCount: nextAnswered.length,
          correctCount,
          wrongCount: nextAnswered.length - correctCount,
          answeredQuestionIds: nextAnswered,
          completed: finished,
          finished,
          lastAnswerCorrect: correct,
          lastQuestionId: questionId,
          lastSelectedOptionIndex: selectedIndex,
          finishedAt: finished ? FieldValue.serverTimestamp() : null,
          updatedAt: FieldValue.serverTimestamp(),
        },
        { merge: true },
      );
    });
    return { accepted: true };
  },
);

exports.finalizeLiveDuel = onCall(
  { region: REGION, enforceAppCheck: false },
  async (request) => {
    const callerUid = requireUid(request);
    await enforceRateLimit(callerUid, 'duel-finalize', 10, 60);
    const matchId = String(request.data?.matchId ?? '');
    const matchRef = db.collection('live_duel_matches').doc(matchId);

    return db.runTransaction(async (transaction) => {
      const match = await transaction.get(matchRef);
      const playerUids = match.data()?.playerUids ?? [];
      if (!match.exists || !playerUids.includes(callerUid)) {
        throw new HttpsError('permission-denied', 'Maça erişim yok.');
      }
      if (match.data().resultProcessed === true) {
        return { status: 'complete', alreadyProcessed: true };
      }
      const [firstProgress, secondProgress, firstUser, secondUser] =
        await Promise.all([
          transaction.get(matchRef.collection('progress').doc(playerUids[0])),
          transaction.get(matchRef.collection('progress').doc(playerUids[1])),
          transaction.get(db.collection('users').doc(playerUids[0])),
          transaction.get(db.collection('users').doc(playerUids[1])),
        ]);
      if (
        firstProgress.data()?.completed !== true ||
        secondProgress.data()?.completed !== true
      ) {
        throw new HttpsError('failed-precondition', 'İki oyuncu da bitirmedi.');
      }
      const scores = [
        Number(firstProgress.data().correctCount ?? firstProgress.data().score ?? 0),
        Number(secondProgress.data().correctCount ?? secondProgress.data().score ?? 0),
      ];
      const firstResult = resultForScores(scores[0], scores[1]);
      const secondResult =
        firstResult === 'win' ? 'loss' : firstResult === 'loss' ? 'win' : 'draw';
      const players = match.data().players;
      const firstProfile = updatedProfile(
        firstUser.data()?.liveDuelProfile,
        Number(players[1].rating ?? 1000),
        firstResult,
        {
          opponentUid: playerUids[1],
          opponentName: players[1].displayName,
          result: firstResult,
          playedAt: new Date().toISOString(),
        },
      );
      const secondProfile = updatedProfile(
        secondUser.data()?.liveDuelProfile,
        Number(players[0].rating ?? 1000),
        secondResult,
        {
          opponentUid: playerUids[0],
          opponentName: players[0].displayName,
          result: secondResult,
          playedAt: new Date().toISOString(),
        },
      );
      for (const [index, user] of [firstUser, secondUser].entries()) {
        const profile = index === 0 ? firstProfile : secondProfile;
        const previousProfile = user.data()?.liveDuelProfile ?? {};
        const player = players[index];
        const result = index === 0 ? firstResult : secondResult;
        const opponentUid = playerUids[index === 0 ? 1 : 0];
        const oldRating = Math.max(0, Number(previousProfile.rating ?? 1000));
        transaction.update(user.ref, {
          liveDuelProfile: profile,
          liveDuelProfileUpdatedAt: FieldValue.serverTimestamp(),
        });
        transaction.set(
          db.collection('live_duel_leaderboard').doc(player.publicPlayerId),
          {
            publicPlayerId: player.publicPlayerId,
            displayName: player.displayName,
            rating: profile.rating,
            matchesPlayed: profile.matchesPlayed,
            wins: profile.wins,
            losses: profile.losses,
            draws: profile.draws,
            bestWinStreak: profile.bestWinStreak,
            highestRating: profile.highestRating,
            updatedAt: FieldValue.serverTimestamp(),
          },
        );
        transaction.set(
          user.ref.collection('live_duel_results').doc(matchId),
          {
            matchId,
            uid: playerUids[index],
            opponentUid,
            result,
            oldRating,
            newRating: profile.rating,
            ratingDelta: profile.rating - oldRating,
            processedAt: FieldValue.serverTimestamp(),
            appVersion: 'server-v2',
          },
        );
      }
      const winnerUid =
        firstResult === 'draw'
          ? null
          : firstResult === 'win'
            ? playerUids[0]
            : playerUids[1];
      transaction.update(matchRef, {
        status: 'completed',
        scores: {
          [playerUids[0]]: scores[0],
          [playerUids[1]]: scores[1],
        },
        winnerUid,
        completionType: 'completed',
        forfeitLoserUid: null,
        draw: firstResult === 'draw',
        resultProcessed: true,
        completedAt: FieldValue.serverTimestamp(),
        updatedAt: FieldValue.serverTimestamp(),
      });
      transaction.delete(db.collection('live_duel_queue').doc(playerUids[0]));
      transaction.delete(db.collection('live_duel_queue').doc(playerUids[1]));
      return { status: 'complete', alreadyProcessed: false };
    });
  },
);

exports.resolveLiveDuelForfeit = onCall(
  { region: REGION, enforceAppCheck: false },
  async (request) => {
    const callerUid = requireUid(request);
    await enforceRateLimit(callerUid, 'duel-forfeit', 10, 60);
    const matchId = String(request.data?.matchId ?? '');
    if (!matchId) {
      throw new HttpsError('invalid-argument', 'Maç kimliği gerekli.');
    }
    const matchRef = db.collection('live_duel_matches').doc(matchId);
    return db.runTransaction(async (transaction) => {
      const match = await transaction.get(matchRef);
      const data = match.data() ?? {};
      const playerUids = data.playerUids ?? [];
      if (!match.exists || !playerUids.includes(callerUid)) {
        throw new HttpsError('permission-denied', 'Maça erişim yok.');
      }
      if (data.resultProcessed === true) {
        return { status: 'complete', alreadyProcessed: true };
      }
      if (playerUids.length !== 2 || new Set(playerUids).size !== 2) {
        throw new HttpsError('failed-precondition', 'Oyuncu bilgisi geçersiz.');
      }
      const presenceRefs = playerUids.map((uid) =>
        matchRef.collection('presence').doc(uid),
      );
      const progressRefs = playerUids.map((uid) =>
        matchRef.collection('progress').doc(uid),
      );
      const userRefs = playerUids.map((uid) => db.collection('users').doc(uid));
      const [firstPresence, secondPresence, firstProgress, secondProgress,
        firstUser, secondUser] = await Promise.all([
        transaction.get(presenceRefs[0]),
        transaction.get(presenceRefs[1]),
        transaction.get(progressRefs[0]),
        transaction.get(progressRefs[1]),
        transaction.get(userRefs[0]),
        transaction.get(userRefs[1]),
      ]);
      const now = Timestamp.now();
      const forfeited = [firstPresence, secondPresence]
        .map((snapshot, index) => {
          const presence = snapshot.data() ?? {};
          const explicitlyLeft =
            presence.state === 'left' && presence.leaveRequested === true;
          const graceExpired =
            presence.state === 'background' &&
            presence.connected === false &&
            presence.graceUntil?.toMillis?.() <= now.toMillis();
          return explicitlyLeft || graceExpired ? playerUids[index] : null;
        })
        .filter(Boolean);
      if (forfeited.length !== 1) return { status: 'pending' };

      const loserUid = forfeited[0];
      const winnerUid = playerUids.find((uid) => uid !== loserUid);
      const scores = [
        Number(firstProgress.data()?.correctCount ?? 0),
        Number(secondProgress.data()?.correctCount ?? 0),
      ];
      const players = data.players ?? [];
      const users = [firstUser, secondUser];
      for (const [index, user] of users.entries()) {
        if (!user.exists || !players[index]?.publicPlayerId) {
          throw new HttpsError('failed-precondition', 'Oyuncu profili eksik.');
        }
        const result = playerUids[index] === winnerUid ? 'win' : 'loss';
        const previousProfile = user.data()?.liveDuelProfile ?? {};
        const opponent = players[index === 0 ? 1 : 0];
        const profile = updatedProfile(
          previousProfile,
          Number(opponent.rating ?? 1000),
          result,
          {
            opponentUid: playerUids[index === 0 ? 1 : 0],
            opponentName: opponent.displayName,
            result,
            playedAt: new Date().toISOString(),
          },
        );
        const oldRating = Math.max(0, Number(previousProfile.rating ?? 1000));
        transaction.update(user.ref, {
          liveDuelProfile: profile,
          liveDuelProfileUpdatedAt: FieldValue.serverTimestamp(),
        });
        transaction.set(
          db.collection('live_duel_leaderboard').doc(players[index].publicPlayerId),
          {
            publicPlayerId: players[index].publicPlayerId,
            displayName: players[index].displayName,
            rating: profile.rating,
            matchesPlayed: profile.matchesPlayed,
            wins: profile.wins,
            losses: profile.losses,
            draws: profile.draws,
            bestWinStreak: profile.bestWinStreak,
            highestRating: profile.highestRating,
            updatedAt: FieldValue.serverTimestamp(),
          },
        );
        transaction.set(user.ref.collection('live_duel_results').doc(matchId), {
          matchId,
          uid: playerUids[index],
          opponentUid: playerUids[index === 0 ? 1 : 0],
          result,
          oldRating,
          newRating: profile.rating,
          ratingDelta: profile.rating - oldRating,
          processedAt: FieldValue.serverTimestamp(),
          appVersion: 'server-v2',
        });
      }
      transaction.update(matchRef, {
        status: 'completed',
        resultProcessed: true,
        resultVersion: 2,
        completionType: 'forfeit',
        forfeitLoserUid: loserUid,
        scores: {
          [playerUids[0]]: scores[0],
          [playerUids[1]]: scores[1],
        },
        winnerUid,
        draw: false,
        completedAt: FieldValue.serverTimestamp(),
        updatedAt: FieldValue.serverTimestamp(),
      });
      transaction.delete(db.collection('live_duel_queue').doc(playerUids[0]));
      transaction.delete(db.collection('live_duel_queue').doc(playerUids[1]));
      return { status: 'complete', alreadyProcessed: false };
    });
  },
);

exports.cleanupLiveDuelData = onSchedule(
  { region: REGION, schedule: 'every 60 minutes', timeZone: 'Etc/UTC' },
  async () => {
    const cutoffs = retentionCutoffs();
    const expiredQueue = await db
      .collection('live_duel_queue')
      .where('expiresAt', '<', Timestamp.now())
      .limit(500)
      .get();
    const staleMatches = await db
      .collection('live_duel_matches')
      .where('status', 'in', ['preparing', 'active'])
      .where('updatedAt', '<', Timestamp.fromDate(cutoffs.unfinishedMatch))
      .limit(200)
      .get();
    const completedMatches = await db
      .collection('live_duel_matches')
      .where(
        'completedAt',
        '<',
        Timestamp.fromDate(cutoffs.completedPersonalData),
      )
      .limit(200)
      .get();
    const staleProgress = await db
      .collectionGroup('progress')
      .where('updatedAt', '<', Timestamp.fromDate(cutoffs.progress))
      .limit(500)
      .get();
    const stalePresence = await db
      .collectionGroup('presence')
      .where('updatedAt', '<', Timestamp.fromDate(cutoffs.unfinishedMatch))
      .limit(500)
      .get();
    const staleResultClaims = await db
      .collectionGroup('live_duel_results')
      .where('processedAt', '<', Timestamp.fromDate(cutoffs.resultClaim))
      .limit(500)
      .get();
    const oldReports = await db
      .collection('player_reports')
      .where('createdAt', '<', Timestamp.fromDate(cutoffs.reportReview))
      .limit(200)
      .get();
    const writer = db.bulkWriter();
    for (const document of expiredQueue.docs) writer.delete(document.ref);
    for (const document of staleMatches.docs) {
      writer.update(document.ref, {
        status: 'expired',
        expiredAt: FieldValue.serverTimestamp(),
      });
    }
    for (const document of completedMatches.docs) {
      const data = document.data();
      if (data.personalDataAnonymized === true) continue;
      const originalPlayers = data.players ?? [];
      const players = originalPlayers.map((player) => ({
        publicPlayerId: player.publicPlayerId,
        displayName: 'Geçmiş Oyuncu',
        rating: player.rating,
      }));
      const publicScores = {};
      for (const [index, uid] of (data.playerUids ?? []).entries()) {
        const publicPlayerId = originalPlayers[index]?.publicPlayerId;
        if (publicPlayerId) {
          publicScores[publicPlayerId] = Number(data.scores?.[uid] ?? 0);
        }
      }
      const winnerIndex = (data.playerUids ?? []).indexOf(data.winnerUid);
      const loserIndex = (data.playerUids ?? []).indexOf(data.forfeitLoserUid);
      writer.update(document.ref, {
        players,
        playerUids: FieldValue.delete(),
        scores: FieldValue.delete(),
        winnerUid: FieldValue.delete(),
        forfeitLoserUid: FieldValue.delete(),
        createdBy: FieldValue.delete(),
        processedBy: FieldValue.delete(),
        publicScores,
        winnerPublicPlayerId:
          winnerIndex >= 0
            ? originalPlayers[winnerIndex]?.publicPlayerId ?? null
            : null,
        forfeitLoserPublicPlayerId:
          loserIndex >= 0
            ? originalPlayers[loserIndex]?.publicPlayerId ?? null
            : null,
        personalDataAnonymized: true,
        anonymizedAt: FieldValue.serverTimestamp(),
      });
    }
    for (const document of staleProgress.docs) writer.delete(document.ref);
    for (const document of stalePresence.docs) writer.delete(document.ref);
    for (const document of staleResultClaims.docs) writer.delete(document.ref);
    for (const document of oldReports.docs) writer.delete(document.ref);
    await writer.close();
  },
);
