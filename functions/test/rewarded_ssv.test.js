'use strict';

const test = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const vm = require('node:vm');

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

test('SSV signed content percent-decodes query bytes without reordering', () => {
  const source = fs.readFileSync(
    path.resolve(__dirname, '..', 'rewarded_ssv.js'),
    'utf8',
  );
  const start = source.indexOf(
    'function signedContentFromOriginalUrl(originalUrl) {',
  );
  const end = source.indexOf('\n}\n\nasync function publicKeys', start);
  assert.ok(start >= 0 && end > start);

  const functionSource = source.slice(start, end + 2);
  const signedContentFromOriginalUrl = vm.runInNewContext(`(${functionSource})`);
  const callbackUrl =
    '/rewardedSsvCallback?ad_network=5450213213286189855' +
    '&ad_unit=1234567890' +
    '&custom_data=bilgi-rotasi-ssv-verify-v1' +
    '&reward_amount=1' +
    '&reward_item=%C3%96d%C3%BCl' +
    '&timestamp=1787119784615' +
    '&transaction_id=123456789' +
    '&user_id=bilgi-rotasi-ssv-verify' +
    '&signature=MEUCIQ-test' +
    '&key_id=3335741209';

  assert.equal(
    signedContentFromOriginalUrl(callbackUrl),
    'ad_network=5450213213286189855' +
      '&ad_unit=1234567890' +
      '&custom_data=bilgi-rotasi-ssv-verify-v1' +
      '&reward_amount=1' +
      '&reward_item=Ödül' +
      '&timestamp=1787119784615' +
      '&transaction_id=123456789' +
      '&user_id=bilgi-rotasi-ssv-verify',
  );
  assert.throws(
    () =>
      signedContentFromOriginalUrl(
        '/rewardedSsvCallback?reward_item=%E0%A4%A&signature=x&key_id=1',
      ),
    /invalid-query-encoding/,
  );
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

test('SSV verify-only handshake is signed, write-free and precedes fail-closed gate', () => {
  const source = fs.readFileSync(
    path.resolve(__dirname, '..', 'rewarded_ssv.js'),
    'utf8',
  );
  const verifyStart = source.indexOf(
    'const verifyOnly = isVerifyOnlyRequest(request.query);',
  );
  const configStart = source.indexOf(
    "const config = await db.doc('server_config/rewarded').get();",
  );
  assert.ok(verifyStart >= 0 && configStart > verifyStart);

  const block = source.slice(verifyStart, configStart);
  assert.match(block, /if \(verifyOnly\)/);
  assert.match(block, /verifyCallback\(request\.originalUrl, request\.query\)/);
  assert.match(block, /status\(400\)\.send\('INVALID_SIGNATURE'\)/);
  assert.match(block, /status\(200\)\.send\('SSV_VERIFY_OK'\)/);
  assert.doesNotMatch(
    block,
    /runTransaction|collection\(|FieldValue\.increment|transaction\./,
  );

  assert.match(source, /bilgi-rotasi-ssv-verify/);
  assert.match(source, /bilgi-rotasi-ssv-verify-v1/);
});

test('normal disabled SSV path remains fail-closed after verify-only handshake', () => {
  const source = fs.readFileSync(
    path.resolve(__dirname, '..', 'rewarded_ssv.js'),
    'utf8',
  );
  const configStart = source.indexOf(
    "const config = await db.doc('server_config/rewarded').get();",
  );
  const rewardStart = source.indexOf(
    'const transactionId = String(request.query.transaction_id',
    configStart,
  );
  assert.ok(configStart >= 0 && rewardStart > configStart);

  const block = source.slice(configStart, rewardStart);
  assert.match(block, /ssvEnabled !== true/);
  assert.match(block, /status\(503\)\.send\('SSV_NOT_ENABLED'\)/);
  assert.match(block, /status\(400\)\.send\('INVALID_SIGNATURE'\)/);
});

test('SSV source enforces per-game idempotency and has no daily three-ad cap', () => {
  const source = fs.readFileSync(
    path.resolve(__dirname, '..', 'rewarded_ssv.js'),
    'utf8',
  );

  assert.match(source, /signedContentFromOriginalUrl/);
  assert.match(source, /createVerify\('SHA256'\)/);
  assert.match(source, /verifier\.update\(signedContentFromOriginalUrl/);
  assert.match(source, /verifier\.verify\(pem, base64UrlBuffer/);
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

test('production SSV deploy inventory stays limited to the three endpoints', () => {
  const source = fs.readFileSync(
    path.resolve(__dirname, '..', 'index.js'),
    'utf8',
  );
  const policy = fs.readFileSync(
    path.resolve(__dirname, '..', '..', 'docs', 'rewarded-ssv-setup.md'),
    'utf8',
  );

  assert.match(source, /require\('\.\/rewarded_ssv'\)/);
  assert.match(policy, /functions:issueRewardNonce/);
  assert.match(policy, /functions:getRewardedGameState/);
  assert.match(policy, /functions:rewardedSsvCallback/);
  assert.match(policy, /--project bilgi-rotasi-f255d/);
  assert.match(policy, /europe-west1/);
  assert.match(policy, /GOOGLE_APPLICATION_CREDENTIALS/);
  assert.match(policy, /ssvEnabled.*false/s);
  assert.doesNotMatch(policy, /firebase deploy --only functions\s+--project/);
});
