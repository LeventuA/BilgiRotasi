'use strict';

const { createVerify, randomUUID } = require('node:crypto');
const { FieldValue, Timestamp, getFirestore } = require('firebase-admin/firestore');
const { HttpsError, onCall, onRequest } = require('firebase-functions/v2/https');

const db = getFirestore();
const REGION = 'europe-west1';
const KEY_URL = 'https://www.gstatic.com/admob/reward/verifier-keys.json';
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
  const parsed = JSON.parse(base64UrlBuffer(value).toString('utf8'));
  if (
    !parsed ||
    typeof parsed.uid !== 'string' ||
    typeof parsed.nonce !== 'string'
  ) {
    throw new Error('invalid-custom-data');
  }
  return parsed;
}

exports.issueRewardNonce = onCall(
  { region: REGION, enforceAppCheck: false },
  async (request) => {
    const uid = request.auth?.uid;
    if (!uid) throw new HttpsError('unauthenticated', 'Oturum gerekli.');
    const nonce = randomUUID();
    await db.collection('reward_nonces').doc(nonce).create({
      uid,
      used: false,
      createdAt: FieldValue.serverTimestamp(),
      expiresAt: Timestamp.fromMillis(Date.now() + 15 * 60 * 1000),
    });
    const customData = Buffer.from(JSON.stringify({ uid, nonce }), 'utf8')
      .toString('base64url');
    return { nonce, customData };
  },
);

exports.rewardedSsvCallback = onRequest(
  { region: REGION, cors: false },
  async (request, response) => {
    try {
      const config = await db.doc('server_config/rewarded').get();
      if (config.data()?.ssvEnabled !== true) {
        response.status(503).send('SSV_NOT_ENABLED');
        return;
      }
      if (!(await verifyCallback(request.originalUrl, request.query))) {
        response.status(400).send('INVALID_SIGNATURE');
        return;
      }
      const transactionId = String(request.query.transaction_id ?? '');
      const custom = decodeCustomData(request.query.custom_data);
      if (
        !transactionId ||
        String(request.query.user_id ?? custom.uid) !== custom.uid
      ) {
        response.status(400).send('INVALID_REWARD');
        return;
      }
      const transactionRef = db
        .collection('rewarded_transactions')
        .doc(transactionId);
      const nonceRef = db.collection('reward_nonces').doc(custom.nonce);
      const userRef = db.collection('users').doc(custom.uid);
      const day = new Date().toISOString().slice(0, 10);
      const dailyRef = userRef.collection('rewarded_daily').doc(day);

      await db.runTransaction(async (transaction) => {
        const [existing, nonce, daily] = await Promise.all([
          transaction.get(transactionRef),
          transaction.get(nonceRef),
          transaction.get(dailyRef),
        ]);
        if (existing.exists) return;
        if (
          !nonce.exists ||
          nonce.data().uid !== custom.uid ||
          nonce.data().used === true ||
          nonce.data().expiresAt.toMillis() < Date.now()
        ) {
          throw new Error('invalid-nonce');
        }
        const count = Number(daily.data()?.count ?? 0);
        if (count >= 3) throw new Error('daily-limit');
        transaction.create(transactionRef, {
          uid: custom.uid,
          rewardXp: 10,
          createdAt: FieldValue.serverTimestamp(),
        });
        transaction.update(nonceRef, {
          used: true,
          transactionId,
          usedAt: FieldValue.serverTimestamp(),
        });
        transaction.set(
          dailyRef,
          {
            count: count + 1,
            xp: Number(daily.data()?.xp ?? 0) + 10,
            updatedAt: FieldValue.serverTimestamp(),
          },
          { merge: true },
        );
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
module.exports.signedContentFromOriginalUrl = signedContentFromOriginalUrl;
