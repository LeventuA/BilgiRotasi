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

test('reports are create-only and invisible to players', async () => {
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

  await assertSucceeds(setDoc(report, payload));
  await assertFails(getDoc(report));
  await assertFails(updateDoc(report, { note: 'ikinci rapor' }));
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
});
