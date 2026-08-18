'use strict';

const test = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');

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
  assert.match(source, /ssvEnabled !== true/);
});

test('normal disabled SSV path remains fail-closed', () => {
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
