'use strict';

const { initializeApp } = require('firebase-admin/app');
const { getFirestore } = require('firebase-admin/firestore');
const { newPublicPlayerId } = require('../duel_helpers');

initializeApp();
const db = getFirestore();
const apply = process.env.APPLY_PUBLIC_ID_MIGRATION === 'YES';

async function main() {
  const users = await db.collection('users').get();
  let planned = 0;
  for (const user of users.docs) {
    const data = user.data();
    const publicPlayerId =
      typeof data.publicPlayerId === 'string'
        ? data.publicPlayerId
        : newPublicPlayerId();
    const oldLeaderboard = await db
      .collection('live_duel_leaderboard')
      .doc(user.id)
      .get();
    planned++;
    if (!apply) {
      console.log(`DRY-RUN ${user.id} -> ${publicPlayerId}`);
      continue;
    }
    await db.runTransaction(async (transaction) => {
      transaction.set(user.ref, { publicPlayerId }, { merge: true });
      transaction.set(
        db.collection('public_player_directory').doc(publicPlayerId),
        { uid: user.id },
        { merge: true },
      );
      if (oldLeaderboard.exists) {
        const old = oldLeaderboard.data();
        transaction.set(
          db.collection('live_duel_leaderboard').doc(publicPlayerId),
          {
            publicPlayerId,
            displayName: old.displayName,
            rating: old.rating,
            matchesPlayed: old.matchesPlayed,
            wins: old.wins,
            losses: old.losses,
            draws: old.draws,
            bestWinStreak: old.bestWinStreak,
            highestRating: old.highestRating,
            updatedAt: old.updatedAt,
          },
        );
        transaction.delete(oldLeaderboard.ref);
      }
    });
  }
  console.log(`${apply ? 'APPLIED' : 'PLANNED'} ${planned} users`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
