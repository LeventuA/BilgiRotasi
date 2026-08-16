'use strict';

const { createHash } = require('node:crypto');
const fs = require('node:fs');
const path = require('node:path');
const { applicationDefault, initializeApp } = require('firebase-admin/app');
const { FieldValue, getFirestore } = require('firebase-admin/firestore');
const {
  buildQuestionCatalog,
  compareLegacyKeys,
} = require('../live_duel_catalog');

const EXPECTED_PROJECT = 'bilgi-rotasi-f255d';
const APPLY_CONFIRMATION = 'APPLY_LIVE_DUEL_CUTOVER';
const LEGACY_COLLECTION = 'live_duel_question_keys';
const TARGET_COLLECTION = 'live_duel_answer_keys';
const CATALOG_PATH = 'live_duel_config/question_catalog';
const BATCH_SIZE = 400;
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

function readBank() {
  const bytes = fs.readFileSync(BANK_PATH);
  const sha256 = createHash('sha256').update(bytes).digest('hex');
  const raw = JSON.parse(bytes.toString('utf8'));
  const plan = buildQuestionCatalog(raw);
  return { ...plan, sha256 };
}

function rowsFromSnapshot(snapshot) {
  return snapshot.docs.map((doc) => ({ id: doc.id, ...doc.data() }));
}

function summarizeDiff(report) {
  return {
    currentCount: report.currentCount,
    legacyCount: report.legacyCount,
    missingCount: report.missing.length,
    extraCount: report.extra.length,
    mismatchCount: report.mismatched.length,
    missingSample: report.missing.slice(0, 10),
    extraSample: report.extra.slice(0, 10),
    mismatchSample: report.mismatched.slice(0, 5),
  };
}

async function writeAnswerKeys(db, answerKeys) {
  let written = 0;
  for (let offset = 0; offset < answerKeys.length; offset += BATCH_SIZE) {
    const batch = db.batch();
    for (const key of answerKeys.slice(offset, offset + BATCH_SIZE)) {
      batch.set(db.collection(TARGET_COLLECTION).doc(key.id), {
        answerIndex: key.answerIndex,
        optionCount: key.optionCount,
        schemaVersion: 2,
        migratedFrom: LEGACY_COLLECTION,
        updatedAt: FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();
    written += Math.min(BATCH_SIZE, answerKeys.length - offset);
    process.stdout.write(`answer keys: ${written}/${answerKeys.length}\n`);
  }
}

async function main() {
  const args = parseArgs(process.argv.slice(2));
  const { catalog, answerKeys, encodedBytes, sha256 } = readBank();
  initializeApp({ credential: applicationDefault(), projectId: args.project });
  const db = getFirestore();

  const [legacySnapshot, targetSnapshot, existingCatalog] = await Promise.all([
    db.collection(LEGACY_COLLECTION).get(),
    db.collection(TARGET_COLLECTION).get(),
    db.doc(CATALOG_PATH).get(),
  ]);

  const legacyReport = compareLegacyKeys(answerKeys, rowsFromSnapshot(legacySnapshot));
  const targetRows = rowsFromSnapshot(targetSnapshot);
  const targetReport = targetRows.length === 0
    ? null
    : compareLegacyKeys(answerKeys, targetRows);

  const report = {
    mode: args.apply ? 'APPLY' : 'DRY_RUN',
    project: args.project,
    bankSha256: sha256,
    bankQuestionCount: answerKeys.length,
    catalogEncodedBytes: encodedBytes,
    legacy: summarizeDiff(legacyReport),
    targetExistingCount: targetRows.length,
    targetExisting: targetReport ? summarizeDiff(targetReport) : null,
    existingCatalog: existingCatalog.exists
      ? {
          schemaVersion: existingCatalog.data()?.schemaVersion ?? null,
          sourceSha256: existingCatalog.data()?.sourceSha256 ?? null,
          questionCount: existingCatalog.data()?.questionCount ?? null,
        }
      : null,
  };
  process.stdout.write(`${JSON.stringify(report, null, 2)}\n`);

  if (!legacyReport.clean) {
    throw new Error('Legacy cevap anahtarları güncel release soru bankasıyla birebir uyuşmuyor; apply engellendi.');
  }
  if (targetReport && !targetReport.clean) {
    throw new Error('Mevcut live_duel_answer_keys güncel bankayla uyuşmuyor; apply engellendi.');
  }
  if (existingCatalog.exists) {
    const data = existingCatalog.data() ?? {};
    if (
      Number(data.schemaVersion) !== 2 ||
      data.sourceSha256 !== sha256 ||
      Number(data.questionCount) !== answerKeys.length
    ) {
      throw new Error('Mevcut question_catalog farklı bir kaynağa ait; apply engellendi.');
    }
  }

  if (!args.apply) {
    process.stdout.write('DRY_RUN_PASS: production verisine yazılmadı.\n');
    return;
  }

  await writeAnswerKeys(db, answerKeys);
  await db.doc(CATALOG_PATH).set({
    ...catalog,
    sourceSha256: sha256,
    sourcePath: 'assets/questions.json',
    migratedFrom: LEGACY_COLLECTION,
    updatedAt: FieldValue.serverTimestamp(),
  });
  process.stdout.write('APPLY_PASS: yeni cevap anahtarları ve soru kataloğu yazıldı; legacy koleksiyon değiştirilmedi.\n');
}

main().catch((error) => {
  console.error(`HATA: ${error.message}`);
  process.exitCode = 1;
});