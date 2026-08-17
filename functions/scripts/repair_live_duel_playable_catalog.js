#!/usr/bin/env node
'use strict';

const { createHash } = require('node:crypto');
const fs = require('node:fs');
const path = require('node:path');
const { applicationDefault, initializeApp } = require('firebase-admin/app');
const { FieldValue, getFirestore } = require('firebase-admin/firestore');
const { buildQuestionCatalog } = require('../live_duel_catalog');
const { buildPlayableQuestionSet } = require('../live_duel_playable');
const {
  invalidMatchCancellationPatch,
  invalidQuestionIds,
} = require('../live_duel_recovery');

const EXPECTED_PROJECT = 'bilgi-rotasi-f255d';
const EXPECTED_RAW_QUESTION_COUNT = 8710;
const APPLY_CONFIRMATION = 'APPLY_LIVE_DUEL_PLAYABLE_CATALOG_REPAIR';
const CATALOG_PATH = 'live_duel_config/question_catalog';
const BANK_PATH = path.resolve(__dirname, '../../assets/questions.json');

function parseArgs(argv) {
  const args = { apply: false, project: '', confirm: '' };
  for (let index = 0; index < argv.length; index += 1) {
    const value = argv[index];
    if (value === '--apply') {
      args.apply = true;
    } else if (value === '--project') {
      args.project = String(argv[++index] ?? '');
    } else if (value === '--confirm') {
      args.confirm = String(argv[++index] ?? '');
    } else {
      throw new Error(`Bilinmeyen parametre: ${value}`);
    }
  }
  if (args.project !== EXPECTED_PROJECT) {
    throw new Error(`Yalnız production proje kabul edilir: ${EXPECTED_PROJECT}`);
  }
  if (args.apply && args.confirm !== APPLY_CONFIRMATION) {
    throw new Error(`Apply için --confirm ${APPLY_CONFIRMATION} zorunludur.`);
  }
  return args;
}

function readPlan() {
  const bytes = fs.readFileSync(BANK_PATH);
  const sourceSha256 = createHash('sha256').update(bytes).digest('hex');
  const raw = JSON.parse(bytes.toString('utf8'));
  if (!Array.isArray(raw) || raw.length !== EXPECTED_RAW_QUESTION_COUNT) {
    throw new Error(
      `Release soru bankası sayısı değişti; beklenen=${EXPECTED_RAW_QUESTION_COUNT}, bulunan=${Array.isArray(raw) ? raw.length : 'liste-degil'}.`,
    );
  }

  const rawPlan = buildQuestionCatalog(raw);
  if (rawPlan.answerKeys.length !== EXPECTED_RAW_QUESTION_COUNT) {
    throw new Error('8.710 cevap anahtarı yapısal doğrulamadan geçmedi.');
  }

  const { playable, excluded } = buildPlayableQuestionSet(raw);
  if (excluded.length === 0 || !excluded.some((item) => item.id === 'q1214')) {
    throw new Error('q1214 kalite regresyonu yeniden üretilemedi; repair fail-closed durduruldu.');
  }
  const playablePlan = buildQuestionCatalog(playable);
  if (
    playablePlan.catalog.questionCount !== playable.length ||
    playable.length + excluded.length !== raw.length
  ) {
    throw new Error('Playable katalog sayımı tutarsız.');
  }

  return {
    raw,
    sourceSha256,
    playable,
    excluded,
    playableIds: new Set(playable.map((item) => String(item.id))),
    catalog: playablePlan.catalog,
    encodedBytes: playablePlan.encodedBytes,
  };
}

async function readOpenMatches(db, playableIds) {
  const snapshot = await db
    .collection('live_duel_matches')
    .where('resultProcessed', '==', false)
    .get();
  return snapshot.docs.map((doc) => {
    const data = doc.data() ?? {};
    const invalidIds = invalidQuestionIds(data.questionIds, playableIds);
    return {
      ref: doc.ref,
      id: doc.id,
      status: String(data.status ?? ''),
      playerCount: Array.isArray(data.playerUids) ? data.playerUids.length : 0,
      questionCount: Array.isArray(data.questionIds) ? data.questionIds.length : 0,
      invalidIds,
    };
  });
}

function catalogWriteData(plan) {
  return {
    ...plan.catalog,
    sourceSha256: plan.sourceSha256,
    sourcePath: 'assets/questions.json',
    qualityPolicy: 'flutter-question-quality-guard-v1',
    rawQuestionCount: EXPECTED_RAW_QUESTION_COUNT,
    excludedQuestionCount: plan.excluded.length,
    updatedAt: FieldValue.serverTimestamp(),
  };
}

async function cancelInvalidMatch(db, matchRow, playableIds) {
  return db.runTransaction(async (transaction) => {
    const fresh = await transaction.get(matchRow.ref);
    if (!fresh.exists) return { status: 'missing', matchId: matchRow.id };
    const data = fresh.data() ?? {};
    if (data.resultProcessed === true || data.status === 'completed') {
      return { status: 'already-finished', matchId: matchRow.id };
    }
    const invalidIds = invalidQuestionIds(data.questionIds, playableIds);
    if (invalidIds.length === 0) {
      return { status: 'now-compatible', matchId: matchRow.id };
    }
    transaction.update(
      matchRow.ref,
      invalidMatchCancellationPatch(invalidIds, FieldValue.serverTimestamp()),
    );
    return { status: 'cancelled', matchId: matchRow.id, invalidIds };
  });
}

async function main() {
  const args = parseArgs(process.argv.slice(2));
  const plan = readPlan();

  initializeApp({ credential: applicationDefault(), projectId: args.project });
  const db = getFirestore();
  const [existingCatalog, openMatches] = await Promise.all([
    db.doc(CATALOG_PATH).get(),
    readOpenMatches(db, plan.playableIds),
  ]);
  const invalidMatches = openMatches.filter((row) => row.invalidIds.length > 0);
  const existing = existingCatalog.data() ?? {};
  const existingCount = existingCatalog.exists ? Number(existing.questionCount ?? 0) : 0;

  if (existingCatalog.exists) {
    if (Number(existing.schemaVersion) !== 2) {
      throw new Error('Mevcut production katalog schemaVersion=2 değil.');
    }
    if (
      typeof existing.sourceSha256 === 'string' && existing.sourceSha256 &&
      existing.sourceSha256 !== plan.sourceSha256
    ) {
      throw new Error('Mevcut production katalog farklı soru bankası SHA değerine ait.');
    }
    if (
      existingCount !== EXPECTED_RAW_QUESTION_COUNT &&
      existingCount !== plan.playable.length
    ) {
      throw new Error(`Mevcut production katalog sayısı beklenmeyen değerde: ${existingCount}.`);
    }
  }

  const report = {
    mode: args.apply ? 'APPLY' : 'DRY_RUN',
    project: args.project,
    sourceSha256: plan.sourceSha256,
    rawQuestionCount: plan.raw.length,
    playableQuestionCount: plan.playable.length,
    excludedQuestionCount: plan.excluded.length,
    catalogEncodedBytes: plan.encodedBytes,
    q1214Excluded: plan.excluded.some((item) => item.id === 'q1214'),
    existingCatalogCount: existingCount,
    openMatchCount: openMatches.length,
    invalidOpenMatchCount: invalidMatches.length,
    invalidMatchSample: invalidMatches.slice(0, 10).map((row) => ({
      matchId: row.id,
      status: row.status,
      playerCount: row.playerCount,
      questionCount: row.questionCount,
      invalidIds: row.invalidIds,
    })),
  };
  process.stdout.write(`${JSON.stringify(report, null, 2)}\n`);

  if (!args.apply) {
    process.stdout.write('DRY_RUN_PASS: production verisine yazılmadı.\n');
    return;
  }

  await db.doc(CATALOG_PATH).set(catalogWriteData(plan));

  const cancellationResults = [];
  for (const row of invalidMatches) {
    cancellationResults.push(await cancelInvalidMatch(db, row, plan.playableIds));
  }

  const writtenCatalog = await db.doc(CATALOG_PATH).get();
  const written = writtenCatalog.data() ?? {};
  if (
    Number(written.questionCount) !== plan.playable.length ||
    written.sourceSha256 !== plan.sourceSha256 ||
    Number(written.rawQuestionCount) !== EXPECTED_RAW_QUESTION_COUNT ||
    Number(written.excludedQuestionCount) !== plan.excluded.length
  ) {
    throw new Error('Post-write katalog doğrulaması başarısız.');
  }

  const cancelled = cancellationResults.filter((item) => item.status === 'cancelled').length;
  process.stdout.write(
    `APPLY_PASS: catalog=${plan.playable.length}/${plan.raw.length}, cancelled_invalid_matches=${cancelled}; BR/profile/leaderboard yazılmadı.\n`,
  );
}

if (require.main === module) {
  main().catch((error) => {
    console.error(`HATA: ${error.message}`);
    process.exitCode = 1;
  });
}

module.exports = {
  APPLY_CONFIRMATION,
  EXPECTED_PROJECT,
  EXPECTED_RAW_QUESTION_COUNT,
  catalogWriteData,
  parseArgs,
  readPlan,
};
