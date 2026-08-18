'use strict';

const { createVerify, randomUUID } = require('node:crypto');
const { FieldValue, Timestamp, getFirestore } = require('firebase-admin/firestore');
const { HttpsError, onCall, onRequest } = require('firebase-functions/v2/https');
const {
  decodeRewardCustomData,
  encodeRewardCustomData,
  normalizeGameId,
  rewardClaimId,
} = require('./rewarded_ssv_helpers');

const db = getFirestore();
const REGION = 'europe-west1';
const KEY_URL = 'https://www.gstatic.com/admob/reward/verifier-keys.json';
const VERIFY_ONLY_USER_ID = 'bilgi-rotasi-ssv-verify';
const VERIFY_ONLY_CUSTOM_DATA = 'bilgi-rotasi-ssv-verify-v1';
let keyCache = { loadedAt: 0, keys: new Map() };

function base64UrlBuffer(value) {
  const normalized = String(value).replaceAll('-', '+').replaceAll('_', '/');
  return Buffer.from(normalized, 'base64');
}

function signedContentFromOriginalUrl(originalUrl) {
  const query = String(originalUrl).split('?')[1] ?? '';
  const marker = '&signature=';
  const index = query.indexOf(marker);
  if (index < 0) throw new Error('missing-signature');
  return query.slice(0, index);
}

async function publicKeys() {
  if (Date.now() - keyCache.loadedAt < 24 * 60 * 60 * 1000) {
    return keyCache.keys;
  }
  const response = await fetch(KEY_URL);
  if (!response.ok) throw new Error('key-download-failed');
  const payload = await response.json();
  const keys = new Map(
    (payload.keys ?? []).map((item) => [String(item.keyId), item.pem]),
  );
  if (keys.size === 0) throw new Error('no-verifier-keys');
  keyCache = { loadedAt: Date.now(), keys };
  return keys;
}

async function verifyCallback(originalUrl, query) {
  const keys = await publicKeys();
  const pem = keys.get(String(query.key_id ?? ''));
  if (!pem) return false;
  const verifier = createVerify('SHA256');
  verifier.update(signedContentFromOriginalUrl(originalUrl), 'utf8');
  verifier.end();
  return verifier.verify(pem, base64UrlBuffer(query.signature));
}

function decodeCustomData(value) {
  return decodeRewardCustomData(value);
}

function isVerifyOnlyRequest(query) {
  return (
    String(query.user_id ?? '') === VERIFY_ONLY_USER_ID &&
    String(query.custom_data ?? '') === VERIFY_ONLY_CUSTOM_DATA
  );
}

exports.issueRewardNonce = onCall(
  { region: REGION, enforceAppCheck: false },
  async (request) => {
    const uid = request.auth?.uid;
    if (!uid) throw new HttpsError('unauthenticated', 'Oturum gerekli.');

    let gameId;
    try {
      gameId = normalizeGameId(request.data?.gameId);
    } catch (_) {
      throw new HttpsError('invalid-argument', 'Geçerli oyun kimliği gerekli.');
    }

    const nonce = randomUUID();
    await db.collection('reward_nonces').doc(nonce).create({
      uid,
      gameId,
      used: false,
      createdAt: FieldValue.serverTimestamp(),
      expiresAt: Timestamp.fromMillis(Date.now() + 15 * 60 * 1000),
    });
    const customData = encodeRewardCustomData({ uid, nonce, gameId });
    return { nonce, customData };
  },
);

exports.getRewardedGameState = onCall(
  { region: REGION, enforceAppCheck: false },
  async (request) => {
    const uid = request.auth?.uid;
    if (!uid) throw new HttpsError('unauthenticated', 'Oturum gerekli.');

    let gameId;
    try {
      gameId = normalizeGameId(request.data?.gameId);
    } catch (_) {
      throw new HttpsError('invalid-argument', 'Geçerli oyun kimliği gerekli.');
    }

    const claimId = rewardClaimId(uid, gameId);
    const claim = await db.collection('rewarded_game_claims').doc(claimId).get();
    return {
      gameId,
      claimed: claim.exists,
      rewardXp: claim.exists ? Number(claim.data()?.rewardXp ?? 0) : 0,
    };
  },
);

exports.rewardedSsvCallback = onRequest(
  { region: REGION, cors: false },
  async (request, response) => {
    try {
      const verifyOnly = isVerifyOnlyRequest(request.query);
      if (verifyOnly) {
        if (!(await verifyCallback(request.originalUrl, request.query))) {
          response.status(400).send('INVALID_SIGNATURE');
          return;
        }
        response.status(200).send('SSV_VERIFY_OK');
        return;
      }

      const config = await db.doc('server_config/rewarded').get();
      if (config.data()?.ssvEnabled !== true) {
        response.status(503).send('SSV_NOT_ENABLED');
        return;
      }
      if (!(await verifyCallback(request.originalUrl, request.query))) {
        response.status(400).send('INVALID_SIGNATURE');
        return;
      }

      const transactionId = String(request.query.transaction_id ?? '').trim();
      const custom = decodeCustomData(request.query.custom_data);
      if (
        !transactionId ||
        String(request.query.user_id ?? custom.uid) !== custom.uid
      ) {
        response.status(400).send('INVALID_REWARD');
        return;
      }

      const claimId = rewardClaimId(custom.uid, custom.gameId);
      const transactionRef = db
        .collection('rewarded_transactions')
        .doc(transactionId);
      const nonceRef = db.collection('reward_nonces').doc(custom.nonce);
      const claimRef = db.collection('rewarded_game_claims').doc(claimId);
      const userRef = db.collection('users').doc(custom.uid);

      await db.runTransaction(async (transaction) => {
        const [existing, nonce, gameClaim] = await Promise.all([
          transaction.get(transactionRef),
          transaction.get(nonceRef),
          transaction.get(claimRef),
        ]);

        // Google aynı transaction_id ile callback'i yeniden gönderebilir.
        // Önceden işlenmiş transaction yeniden XP üretmez.
        if (existing.exists) return;

        const nonceData = nonce.data() ?? {};
        const expiresAt = nonceData.expiresAt?.toMillis?.() ?? 0;
        if (
          !nonce.exists ||
          nonceData.uid !== custom.uid ||
          nonceData.gameId !== custom.gameId ||
          nonceData.used === true ||
          expiresAt < Date.now()
        ) {
          throw new Error('invalid-nonce');
        }

        // Aynı tamamlanan oyun için daha önce ödül verildiyse callback başarılı
        // kabul edilir fakat ikinci kez XP eklenmez. Nonce yine tüketilir.
        if (gameClaim.exists) {
          transaction.create(transactionRef, {
            uid: custom.uid,
            gameId: custom.gameId,
            claimId,
            rewardXp: 0,
            status: 'duplicate-game',
            createdAt: FieldValue.serverTimestamp(),
          });
          transaction.update(nonceRef, {
            used: true,
            transactionId,
            usedAt: FieldValue.serverTimestamp(),
          });
          return;
        }

        transaction.create(transactionRef, {
          uid: custom.uid,
          gameId: custom.gameId,
          claimId,
          rewardXp: 10,
          status: 'granted',
          createdAt: FieldValue.serverTimestamp(),
        });
        transaction.create(claimRef, {
          uid: custom.uid,
          gameId: custom.gameId,
          rewardXp: 10,
          transactionId,
          createdAt: FieldValue.serverTimestamp(),
        });
        transaction.update(nonceRef, {
          used: true,
          transactionId,
          usedAt: FieldValue.serverTimestamp(),
        });
        transaction.set(
          userRef,
          {
            serverRewardXp: FieldValue.increment(10),
            serverRewardUpdatedAt: FieldValue.serverTimestamp(),
          },
          { merge: true },
        );
      });
      response.status(200).send('OK');
    } catch (error) {
      response.status(400).send(`REJECTED:${error?.message ?? 'unknown'}`);
    }
  },
);

module.exports.base64UrlBuffer = base64UrlBuffer;
module.exports.decodeCustomData = decodeCustomData;
module.exports.isVerifyOnlyRequest = isVerifyOnlyRequest;
module.exports.signedContentFromOriginalUrl = signedContentFromOriginalUrl;
