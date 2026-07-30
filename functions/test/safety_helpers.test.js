'use strict';

const test = require('node:test');
const assert = require('node:assert/strict');
const {
  anonymousPlayerId,
  anonymizePlayers,
  deletionOperationId,
  isValidUsername,
  normalizeUsername,
} = require('../safety_helpers');

test('Turkish display names normalize without email data', () => {
  assert.equal(normalizeUsername('İPEK'), 'ipek');
  assert.equal(normalizeUsername('İrem'), 'irem');
  assert.equal(normalizeUsername('IŞIL'), 'isil');
  assert.equal(normalizeUsername('Şule'), 'sule');
});

test('moderation rejects impersonation and simple leetspeak', () => {
  assert.equal(isValidUsername('oyuncu_23'), true);
  assert.equal(isValidUsername('aquaman'), true);
  assert.equal(isValidUsername('epicoyuncu'), true);
  assert.equal(isValidUsername('nazim'), true);
  assert.equal(isValidUsername('adm1n'), false);
  assert.equal(isValidUsername('destek_ekibi'), false);
  assert.equal(isValidUsername('pic'), false);
  assert.equal(isValidUsername('nazi'), false);
  assert.equal(isValidUsername('or0spu'), false);
  assert.equal(isValidUsername('s1ktir'), false);
});

test('account deletion operation is stable and idempotent', () => {
  assert.equal(deletionOperationId('uid-1'), 'account-delete-uid-1');
  assert.equal(deletionOperationId('uid-1'), deletionOperationId('uid-1'));
});

test('shared match keeps opponent and anonymizes deleted player', () => {
  const players = anonymizePlayers(
    [
      { uid: 'deleted', displayName: 'Old name', score: 8 },
      { uid: 'opponent', displayName: 'Opponent', score: 10 },
    ],
    'deleted',
  );
  assert.deepEqual(players[0], {
    uid: anonymousPlayerId('deleted'),
    displayName: 'Silinmiş Oyuncu',
    score: 8,
    deleted: true,
  });
  assert.equal(players[1].uid, 'opponent');
});
