'use strict';

const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const test = require('node:test');

const duel = fs.readFileSync(
  path.resolve(__dirname, '..', 'live_duel.js'),
  'utf8',
);
const account = fs.readFileSync(
  path.resolve(__dirname, '..', 'index.js'),
  'utf8',
);

test('matchmaking requires agreement and server-only identity', () => {
  assert.match(duel, /collection\('agreements'\)\.doc\('community'\)/);
  assert.match(duel, /ensurePublicIdentity/);
  assert.match(duel, /blocked\(uid, candidate\.id\)/);
  assert.match(duel, /deterministicMatchId/);
});

test('answers are ordered, bounded and checked against private keys', () => {
  assert.match(duel, /questionIds\[answeredIds\.length\] !== questionId/);
  assert.match(duel, /live_duel_answer_keys/);
  assert.match(duel, /selectedIndex >= optionCount/);
  assert.match(duel, /answeredIds\.includes\(questionId\)/);
});

test('normal and forfeit finalization are idempotent server awards', () => {
  assert.match(duel, /exports\.finalizeLiveDuel/);
  assert.match(duel, /exports\.resolveLiveDuelForfeit/);
  assert.match(duel, /resultProcessed === true/);
  assert.match(duel, /live_duel_results/);
  assert.match(duel, /live_duel_leaderboard/);
});

test('retention removes UID score keys and stale claims', () => {
  assert.match(duel, /scores: FieldValue\.delete\(\)/);
  assert.match(duel, /winnerUid: FieldValue\.delete\(\)/);
  assert.match(duel, /publicScores/);
  assert.match(duel, /staleResultClaims/);
});

test('account deletion removes private public-id mapping', () => {
  assert.match(account, /public_player_directory/);
  assert.match(account, /live_duel_leaderboard'\)\.doc\(publicPlayerId\)/);
  assert.match(account, /collectionGroup\('live_duel_results'\)/);
});

test('reports and blocks resolve public ids to authoritative users', () => {
  assert.match(account, /resolveTargetPlayer\(targetPlayerId\)/);
  assert.match(account, /const targetUsername = target\.username/);
  assert.match(account, /playerBlockPath\(ownerUid, targetUid\)/);
  assert.match(account, /if \(!blocked\)[\s\S]*?reference\.delete\(\)/);
  const reportSource =
    account.match(/exports\.reportPlayer[\s\S]*?exports\.setPlayerBlock/)?.[0] ??
    '';
  assert.doesNotMatch(reportSource, /isValidUsername\(targetUsername\)/);
});

test('matchmaking checks real uid block document paths', () => {
  assert.match(
    duel,
    /player_blocks\/\$\{firstUid\}\/blocked\/\$\{secondUid\}/,
  );
  assert.match(duel, /blocked\(uid, candidate\.id\)/);
});
