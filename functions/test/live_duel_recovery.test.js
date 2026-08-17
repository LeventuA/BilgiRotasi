'use strict';

const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const test = require('node:test');
const {
  invalidMatchCancellationPatch,
  invalidQuestionIds,
} = require('../live_duel_recovery');

test('invalid match detection is deterministic and unique', () => {
  const playable = new Set(['q1', 'q2', 'q3']);
  assert.deepEqual(
    invalidQuestionIds(['q1', 'q9', 'q2', 'q9', '', null], playable),
    ['q9'],
  );
});

test('invalid match cancellation patch cannot award or deduct BR/statistics', () => {
  const timestamp = { sentinel: 'server-time' };
  const patch = invalidMatchCancellationPatch(['q1214'], timestamp);
  assert.equal(patch.status, 'cancelled');
  assert.equal(patch.resultProcessed, true);
  assert.equal(patch.completionType, 'invalid-question');
  assert.deepEqual(patch.invalidQuestionIds, ['q1214']);
  assert.equal(patch.cancelledAt, timestamp);
  for (const forbidden of [
    'scores', 'winnerUid', 'forfeitLoserUid', 'br', 'rating',
    'wins', 'losses', 'draws', 'matchesPlayed',
  ]) {
    assert.equal(Object.hasOwn(patch, forbidden), false);
  }
});

test('production repair script is fail-closed and does not write profile/results', () => {
  const source = fs.readFileSync(
    path.resolve(__dirname, '../scripts/repair_live_duel_playable_catalog.js'),
    'utf8',
  );
  assert.match(source, /APPLY_LIVE_DUEL_PLAYABLE_CATALOG_REPAIR/);
  assert.match(source, /DRY_RUN_PASS: production verisine yazılmadı/);
  assert.match(source, /q1214 kalite regresyonu yeniden üretilemedi/);
  assert.match(source, /runTransaction/);
  assert.match(source, /resultProcessed === true/);
  assert.doesNotMatch(source, /collection\('users'\)/);
  assert.doesNotMatch(source, /live_duel_leaderboard/);
  assert.doesNotMatch(source, /live_duel_results/);
});
