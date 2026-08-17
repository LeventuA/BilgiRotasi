'use strict';

const { createHash } = require('node:crypto');

const MAX_GAME_ID_LENGTH = 180;

function normalizeGameId(value) {
  const gameId = String(value ?? '').trim();
  if (
    !gameId ||
    gameId.length > MAX_GAME_ID_LENGTH ||
    /[\u0000-\u001F\u007F]/u.test(gameId)
  ) {
    throw new Error('invalid-game-id');
  }
  return gameId;
}

function normalizeUid(value) {
  const uid = String(value ?? '').trim();
  if (!uid || uid.length > 160 || /[\u0000-\u001F\u007F]/u.test(uid)) {
    throw new Error('invalid-uid');
  }
  return uid;
}

function normalizeNonce(value) {
  const nonce = String(value ?? '').trim();
  if (!nonce || nonce.length > 120 || /[\u0000-\u001F\u007F]/u.test(nonce)) {
    throw new Error('invalid-nonce');
  }
  return nonce;
}

function rewardClaimId(uid, gameId) {
  const normalizedUid = normalizeUid(uid);
  const normalizedGameId = normalizeGameId(gameId);
  return createHash('sha256')
    .update(normalizedUid, 'utf8')
    .update('\0', 'utf8')
    .update(normalizedGameId, 'utf8')
    .digest('hex');
}

function encodeRewardCustomData({ uid, nonce, gameId }) {
  const payload = {
    uid: normalizeUid(uid),
    nonce: normalizeNonce(nonce),
    gameId: normalizeGameId(gameId),
  };
  return Buffer.from(JSON.stringify(payload), 'utf8').toString('base64url');
}

function decodeRewardCustomData(value) {
  let parsed;
  try {
    parsed = JSON.parse(
      Buffer.from(String(value ?? ''), 'base64url').toString('utf8'),
    );
  } catch (_) {
    throw new Error('invalid-custom-data');
  }
  if (!parsed || typeof parsed !== 'object' || Array.isArray(parsed)) {
    throw new Error('invalid-custom-data');
  }
  try {
    return {
      uid: normalizeUid(parsed.uid),
      nonce: normalizeNonce(parsed.nonce),
      gameId: normalizeGameId(parsed.gameId),
    };
  } catch (_) {
    throw new Error('invalid-custom-data');
  }
}

module.exports = {
  MAX_GAME_ID_LENGTH,
  decodeRewardCustomData,
  encodeRewardCustomData,
  normalizeGameId,
  rewardClaimId,
};
