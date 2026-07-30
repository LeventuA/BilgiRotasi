'use strict';

const { createHash } = require('node:crypto');

const usernamePattern = /^[a-z0-9][a-z0-9_]{2,15}$/;
const reservedPattern =
  /(admin|administrator|moderator|sistem|destek|support|zmilastudio|bilgirotasi|google|firebase)/;
const blockedPattern =
  /(amk|aq|orospu|siktir|sikik|yarrak|pic|ibne|gerizekali|salak|aptal|fuck|bitch|nigger|nazi|porn|sex)/;
const phonePattern = /(?:\d_*){7,}/;

function normalizeUsername(value) {
  return String(value ?? '')
    .trim()
    .toLocaleLowerCase('tr-TR')
    .replaceAll('ı', 'i')
    .replaceAll('ş', 's')
    .replaceAll('ğ', 'g')
    .replaceAll('ü', 'u')
    .replaceAll('ö', 'o')
    .replaceAll('ç', 'c');
}

function moderationKey(value) {
  return normalizeUsername(value)
    .replaceAll('0', 'o')
    .replaceAll('1', 'i')
    .replaceAll('3', 'e')
    .replaceAll('4', 'a')
    .replaceAll('5', 's')
    .replaceAll('7', 't')
    .replace(/[^a-z0-9]/g, '');
}

function isValidUsername(value) {
  const normalized = normalizeUsername(value);
  const key = moderationKey(normalized);
  return (
    usernamePattern.test(normalized) &&
    !phonePattern.test(normalized) &&
    !reservedPattern.test(key) &&
    !blockedPattern.test(key)
  );
}

function deletionOperationId(uid) {
  return `account-delete-${uid}`;
}

function anonymousPlayerId(uid) {
  const digest = createHash('sha256')
    .update(`bilgi-rotasi-deleted:${uid}`)
    .digest('hex')
    .slice(0, 24);
  return `deleted_${digest}`;
}

function anonymizePlayers(players, uid) {
  const anonymousId = anonymousPlayerId(uid);
  if (!Array.isArray(players)) return [];
  return players.map((player) => {
    if (!player || player.uid !== uid) return player;
    const { publicPlayerId: _removedPublicPlayerId, ...anonymousPlayer } =
      player;
    return {
      ...anonymousPlayer,
      uid: anonymousId,
      displayName: 'Silinmiş Oyuncu',
      deleted: true,
    };
  });
}

function anonymizeUidMap(values, uid) {
  if (!values || typeof values !== 'object' || Array.isArray(values)) {
    return values;
  }
  const anonymousId = anonymousPlayerId(uid);
  return Object.fromEntries(
    Object.entries(values).map(([key, value]) => [
      key === uid ? anonymousId : key,
      value,
    ]),
  );
}

module.exports = {
  anonymousPlayerId,
  anonymizePlayers,
  anonymizeUidMap,
  deletionOperationId,
  isValidUsername,
  moderationKey,
  normalizeUsername,
};
