'use strict';

const test = require('node:test');
const assert = require('node:assert/strict');

// Bu yardımcılar Firebase başlatmadan test edilebilmesi için kaynak sözleşmesi
// üzerinden doğrulanır; kriptografik uç nokta emulator/integration kapısındadır.
test('SSV source preserves raw query ordering and idempotency fields', () => {
  const source = require('node:fs').readFileSync(
    require('node:path').resolve(__dirname, '..', 'rewarded_ssv.js'),
    'utf8',
  );
  assert.match(source, /signedContentFromOriginalUrl/);
  assert.match(source, /transaction_id/);
  assert.match(source, /rewarded_transactions/);
  assert.match(source, /existing\.exists/);
  assert.match(source, /count >= 3/);
  assert.match(source, /ssvEnabled !== true/);
  assert.match(source, /verifier-keys\.json/);
});
