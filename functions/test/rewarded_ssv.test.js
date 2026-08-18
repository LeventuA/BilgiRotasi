'use strict';

const test = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');

const {
  decodeRewardCustomData,
  encodeRewardCustomData,
  normalizeGameId,
  rewardClaimId,
} = require('../rewarded_ssv_helpers');

test('reward custom data binds uid, nonce and completed game id', () => {
  const encoded = encodeRewardCustomData({
    uid: 'user-1',
    nonce: 'nonce-1',
    gameId: 'board:game-123',
  });
  assert.deepEqual(decodeRewardCustomData(encoded), {
    uid: 'user-1',
    nonce: 'nonce-1',
    gameId: 'board:game-123',
  });
});

test('game id validation is fail-closed', () => {
  assert.equal(normalizeGameId('  duel:abc  '), 'duel:abc');
  assert.throws(() => normalizeGameId(''), /invalid-game-id/);
  assert.throws(() => normalizeGameId('x'.repeat(181)), /invalid-game-id/);
  assert.throws(() => normalizeGameId('bad\nvalue'), /invalid-game-id/);
});

test('reward claim id is stable per user and game without a daily quota', () => {
  const first = rewardClaimId('user-1', 'game-1');
  assert.equal(first, rewardClaimId('user-1', 'game-1'));
  assert.notEqual(first, rewardClaimId('user-1', 'game-2'));
  assert.notEqual(first, rewardClaimId('user-2', 'game-1'));

  const manyGames = new Set(
    Array.from({ length: 250 }, (_, index) =>
      rewardClaimId('user-1', `game-${index}`),
    ),
  );
  assert.equal(manyGames.size, 250);
});

test('rewarded game state lookup is authenticated, caller-scoped and read-only', () => {
  const source = fs.readFileSync(
    path.resolve(__dirname, '..', 'rewarded_ssv.js'),
    'utf8',
  );
  const start = source.indexOf('exports.getRewardedGameState = onCall');
  const end = source.indexOf('exports.rewardedSsvCallback = onRequest', start);
  assert.ok(start >= 0 && end > start);
  const block = source.slice(start, end);

  assert.match(block, /const uid = request\.auth\?\.uid/);
  assert.match(block, /normalizeGameId\(request\.data\?\.gameId\)/);
  assert.match(block, /rewardClaimId\(uid, gameId\)/);
  assert.match(block, /collection\('rewarded_game_claims'\)/);
  assert.match(block, /claimed: claim\.exists/);
  assert.doesNotMatch(block, /request\.data\?\.uid/);
  assert.doesNotMatch(block, /runTransaction|\.create\(|\.set\(|\.update\(/);
});

test('SSV source enforces per-game idempotency and has no daily three-ad cap', () => {
  const source = fs.readFileSync(
    path.resolve(__dirname, '..', 'rewarded_ssv.js'),
    'utf8',
  );

  assert.match(source, /signedContentFromOriginalUrl/);
  assert.match(source, /transaction_id/);
  assert.match(source, /rewarded_transactions/);
  assert.match(source, /rewarded_game_claims/);
  assert.match(source, /gameId/);
  assert.match(source, /existing\.exists/);
  assert.match(source, /gameClaim\.exists/);
  assert.match(source, /FieldValue\.increment\(10\)/);
  assert.match(source, /ssvEnabled !== true/);
  assert.match(source, /verifier-keys\.json/);

  assert.doesNotMatch(source, /rewarded_daily/);
  assert.doesNotMatch(source, /daily-limit/);
  assert.doesNotMatch(source, /count\s*>=\s*3/);
});
