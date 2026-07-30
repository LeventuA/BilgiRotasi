'use strict';

const fs = require('node:fs');
const path = require('node:path');
const test = require('node:test');
const {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
} = require('@firebase/rules-unit-testing');
const {
  doc,
  getDoc,
  getDocs,
  collection,
  serverTimestamp,
  setDoc,
  updateDoc,
} = require('firebase/firestore');

let environment;

test.before(async () => {
  environment = await initializeTestEnvironment({
    projectId: 'demo-bilgi-rotasi',
    firestore: {
      host: '127.0.0.1',
      port: 8080,
      rules: fs.readFileSync(
        path.resolve(__dirname, '..', '..', 'firestore.rules'),
        'utf8',
      ),
    },
  });
});

test.after(async () => {
  await environment.cleanup();
});

test.beforeEach(async () => {
  await environment.clearFirestore();
});

test('reports are server-only and invisible to players', async () => {
  const db = environment.authenticatedContext('reporter').firestore();
  const report = doc(
    db,
    'player_reports/reporter_target_cheating',
  );
  const payload = {
    reporterUid: 'reporter',
    targetUid: 'target',
    targetUsername: 'oyuncu_23',
    reason: 'cheating',
    note: '',
    source: 'leaderboard',
    status: 'pending',
    createdAt: serverTimestamp(),
    appVersion: '1.68.6',
  };

  await assertFails(setDoc(report, payload));
  await environment.withSecurityRulesDisabled(async (context) => {
    await setDoc(doc(context.firestore(), report.path), payload);
  });
  await assertFails(getDoc(report));
  await assertFails(updateDoc(report, { note: 'ikinci rapor' }));
});

test('BR, leaderboard, queue and match writes are server-only', async () => {
  const db = environment.authenticatedContext('player').firestore();
  await environment.withSecurityRulesDisabled(async (context) => {
    await setDoc(doc(context.firestore(), 'users/player'), {
      username: 'oyuncu_23',
      liveDuelProfile: { rating: 1000, wins: 0 },
    });
  });

  await assertFails(
    updateDoc(doc(db, 'users/player'), {
      liveDuelProfile: { rating: 9999, wins: 100 },
    }),
  );
  await assertFails(
    setDoc(doc(db, 'live_duel_leaderboard/player'), {
      rating: 9999,
    }),
  );
  await assertFails(
    setDoc(doc(db, 'live_duel_queue/player'), {
      ownerUid: 'player',
      status: 'waiting',
      questionCount: 10,
    }),
  );
  await assertFails(
    setDoc(doc(db, 'live_duel_matches/fake'), {
      playerUids: ['player', 'target'],
    }),
  );
});

test('cloud snapshot revision must advance exactly once', async () => {
  await environment.withSecurityRulesDisabled(async (context) => {
    await setDoc(doc(context.firestore(), 'users/player'), {
      snapshotJson: '{"schema":2,"values":{}}',
      snapshotValueCount: 0,
      revision: 1,
      deviceInstallationId: 'device-a',
      updatedAt: serverTimestamp(),
    });
  });
  const db = environment.authenticatedContext('player').firestore();
  const reference = doc(db, 'users/player');
  await assertSucceeds(
    updateDoc(reference, {
      snapshotJson: '{"schema":2,"values":{"a":{"type":"int","value":1}}}',
      snapshotValueCount: 1,
      revision: 2,
      deviceInstallationId: 'device-b',
      updatedAt: serverTimestamp(),
    }),
  );
  await assertFails(
    updateDoc(reference, {
      snapshotJson: '{"schema":2,"values":{}}',
      snapshotValueCount: 0,
      revision: 2,
      deviceInstallationId: 'stale-device',
      updatedAt: serverTimestamp(),
    }),
  );
});

test('only owner lists blocks; target may check the exact reverse block', async () => {
  await environment.withSecurityRulesDisabled(async (context) => {
    await setDoc(doc(context.firestore(), 'player_blocks/owner/blocked/target'), {
      ownerUid: 'owner',
      targetUid: 'target',
      targetUsername: 'oyuncu_23',
      createdAt: serverTimestamp(),
      appVersion: '1.68.6',
    });
  });

  const ownerDb = environment.authenticatedContext('owner').firestore();
  const targetDb = environment.authenticatedContext('target').firestore();
  const strangerDb = environment.authenticatedContext('stranger').firestore();
  const blockPath = 'player_blocks/owner/blocked/target';

  await assertSucceeds(
    getDocs(collection(ownerDb, 'player_blocks/owner/blocked')),
  );
  await assertSucceeds(getDoc(doc(targetDb, blockPath)));
  await assertFails(getDoc(doc(strangerDb, blockPath)));
});

test('username correction metadata cannot be forged alone', async () => {
  await environment.withSecurityRulesDisabled(async (context) => {
    await setDoc(doc(context.firestore(), 'users/player'), {
      username: 'oyuncu_23',
      usernameChangedAt: new Date(),
      usernameFirstSetAt: new Date(),
      usernameCorrectionUsed: false,
      usernamePolicyVersion: 2,
    });
  });
  const db = environment.authenticatedContext('player').firestore();

  await assertFails(
    updateDoc(doc(db, 'users/player'), {
      usernameCorrectionUsed: false,
      usernamePolicyVersion: 1,
    }),
  );
  await assertFails(
    setDoc(doc(db, 'usernames/yeni_oyuncu'), {
      uid: 'player',
      username: 'yeni_oyuncu',
      createdAt: serverTimestamp(),
    }),
  );
});

async function claimUsername(uid, username) {
  await environment.withSecurityRulesDisabled(async (context) => {
    await setDoc(doc(context.firestore(), 'usernames', username), {
      uid,
      username,
      createdAt: serverTimestamp(),
    });
  });
  const db = environment.authenticatedContext(uid).firestore();
  return setDoc(doc(db, 'users', uid), {
    username,
    usernameChangedAt: serverTimestamp(),
    usernameFirstSetAt: serverTimestamp(),
    usernameCorrectionUsed: false,
    usernamePolicyVersion: 2,
  });
}

test('ambiguous short terms are exact-only in username rules', async () => {
  await assertSucceeds(claimUsername('aquaman-user', 'aquaman'));
  await assertSucceeds(claimUsername('epic-user', 'epicoyuncu'));
  await assertSucceeds(claimUsername('nazim-user', 'nazim'));

  await assertFails(claimUsername('pic-user', 'pic'));
  await assertFails(claimUsername('nazi-user', 'nazi'));
  await assertFails(claimUsername('explicit-user', 'orospu_oyuncu'));
});
