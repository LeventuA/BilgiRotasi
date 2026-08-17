'use strict';

const { createHash } = require('node:crypto');
const fs = require('node:fs');
const path = require('node:path');
const { applicationDefault, initializeApp } = require('firebase-admin/app');
const { FieldPath, FieldValue, getFirestore } = require('firebase-admin/firestore');
const {
  buildQuestionCatalog,
  compareLegacyKeys,
} = require('../live_duel_catalog');
const { isCompatibleSubset } = require('../live_duel_migration');

const EXPECTED_PROJECT = 'bilgi-rotasi-f255d';
const EXPECTED_BANK_QUESTION_COUNT = 8710;
const EXPECTED_LEGACY_QUESTION_COUNT = 6710;
const APPLY_CONFIRMATION = 'APPLY_LIVE_DUEL_CUTOVER';
const LEGACY_COLLECTION = 'live_duel_question_keys';
const TARGET_COLLECTION = 'live_duel_answer_keys';
const CATALOG_PATH = 'live_duel_config/question_catalog';
const BATCH_SIZE = 400;
const READ_PAGE_SIZE = 500;
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

async function countCollection(db, collectionName) {
  const snapshot = await db.collection(collectionName).count().get();
  return Number(snapshot.data().count);
}

async function readKeyRows(db, collectionName, expectedCount) {
  if (expectedCount === 0) return [];
  const rows = [];
  let cursor = null;
  while (rows.length < expectedCount) {
    let query = db.collection(collectionName)
      .select('answerIndex', 'optionCount')
      .orderBy(FieldPath.documentId())
      .limit(READ_PAGE_SIZE);
    if (cursor) query = query.startAfter(cursor);
    const snapshot = await query.get();
    if (snapshot.empty) break;
    for (const doc of snapshot.docs) {
      rows.push({ id: doc.id, ...doc.data() });
    }
    cursor = snapshot.docs.at(-1);
    process.stdout.write(`read ${collectionName}: ${rows.length}/${expectedCount}\n`);
    if (snapshot.size < READ_PAGE_SIZE) break;
  }
  if (rows.length !== expectedCount) {
    throw new Error(`${collectionName} okuma sayısı değişti; beklenen=${expectedCount}, okunan=${rows.length}.`);
  }
  return rows;
}

async function writeAnswerKeys(db, answerKeys, legacyIds) {
  let written = 0;
  for (let offset = 0; offset < answerKeys.length; offset += BATCH_SIZE) {
    const batch = db.batch();
    for (const key of answerKeys.slice(offset, offset + BATCH_SIZE)) {
      const data = {
        answerIndex: key.answerIndex,
        optionCount: key.optionCount,
        schemaVersion: 2,
        sourcePath: 'assets/questions.json',
        updatedAt: FieldValue.serverTimestamp(),
      };
      if (legacyIds.has(key.id)) {
        data.migratedFrom = LEGACY_COLLECTION;
      } else {
        data.seededFrom = 'assets/questions.json';
      }
      batch.set(db.collection(TARGET_COLLECTION).doc(key.id), data);
    }
    await batch.commit();
    written += Math.min(BATCH_SIZE, answerKeys.length - offset);
    process.stdout.write(`answer keys: ${written}/${answerKeys.length}\n`);
  }
}

async function main() {
  const args = parseArgs(process.argv.slice(2));
  const { catalog, answerKeys, encodedBytes, sha256 } = readBank();
  if (answerKeys.length !== EXPECTED_BANK_QUESTION_COUNT) {
    throw new Error(
      `Release soru bankası sayısı değişti; beklenen=${EXPECTED_BANK_QUESTION_COUNT}, bulunan=${answerKeys.length}.`,
    );
  }

  initializeApp({ credential: applicationDefault(), projectId: args.project });
  const db = getFirestore();

  const [legacyCount, targetCount, existingCatalog] = await Promise.all([
    countCollection(db, LEGACY_COLLECTION),
    countCollection(db, TARGET_COLLECTION),
    db.doc(CATALOG_PATH).get(),
  ]);

  process.stdout.write(
    `COUNTS: bank=${answerKeys.length}, legacy=${legacyCount}, target=${targetCount}, catalog=${existingCatalog.exists}\n`,
  );

  if (legacyCount !== EXPECTED_LEGACY_QUESTION_COUNT) {
    throw new Error(
      `Legacy cevap anahtarı sayısı beklenenden farklı; beklenen=${EXPECTED_LEGACY_QUESTION_COUNT}, bulunan=${legacyCount}.`,
    );
  }
  if (targetCount > EXPECTED_BANK_QUESTION_COUNT) {
    throw new Error(`Yeni cevap anahtarı sayısı release bankasını aşıyor: ${targetCount}.`);
  }

  const [legacyRows, targetRows] = await Promise.all([
    readKeyRows(db, LEGACY_COLLECTION, legacyCount),
    readKeyRows(db, TARGET_COLLECTION, targetCount),
  ]);

  const legacyReport = compareLegacyKeys(answerKeys, legacyRows);
  const legacyCompatible = isCompatibleSubset(legacyReport, {
    expectedCurrentCount: EXPECTED_BANK_QUESTION_COUNT,
    expectedSubsetCount: EXPECTED_LEGACY_QUESTION_COUNT,
  });
  const targetReport = targetRows.length === 0
    ? null
    : compareLegacyKeys(answerKeys, targetRows);
  const targetCompatible = targetReport === null || isCompatibleSubset(targetReport, {
    expectedCurrentCount: EXPECTED_BANK_QUESTION_COUNT,
    expectedSubsetCount: targetRows.length,
  });

  const report = {
    mode: args.apply ? 'APPLY' : 'DRY_RUN',
    project: args.project,
    bankSha256: sha256,
    bankQuestionCount: answerKeys.length,
    expectedLegacyCount: EXPECTED_LEGACY_QUESTION_COUNT,
    catalogEncodedBytes: encodedBytes,
    legacyCompatible,
    legacy: summarizeDiff(legacyReport),
    targetExistingCount: targetRows.length,
    targetCompatible,
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

  if (!legacyCompatible) {
    throw new Error(
      'Legacy 6.710 cevap anahtarı güncel 8.710 release bankasının doğrulanmış alt kümesi değil; apply engellendi.',
    );
  }
  if (!targetCompatible) {
    throw new Error('Mevcut live_duel_answer_keys güncel bankanın güvenli alt kümesi değil; apply engellendi.');
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

  const legacyIds = new Set(legacyRows.map((row) => row.id));
  await writeAnswerKeys(db, answerKeys, legacyIds);
  await db.doc(CATALOG_PATH).set({
    ...catalog,
    sourceSha256: sha256,
    sourcePath: 'assets/questions.json',
    legacyVerifiedCollection: LEGACY_COLLECTION,
    legacyVerifiedCount: legacyRows.length,
    currentOnlyCount: answerKeys.length - legacyRows.length,
    updatedAt: FieldValue.serverTimestamp(),
  });
  process.stdout.write(
    'APPLY_PASS: 8.710 cevap anahtarı ve soru kataloğu yazıldı; legacy 6.710 koleksiyon değiştirilmedi.\n',
  );
}

main().catch((error) => {
  console.error(`HATA: ${error.message}`);
  process.exitCode = 1;
});
