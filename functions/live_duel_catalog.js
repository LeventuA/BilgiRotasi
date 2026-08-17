'use strict';

const { createHash } = require('node:crypto');

const DIFFICULTIES = Object.freeze(['Kolay', 'Orta', 'Zor']);
const DIFFICULTY_TARGETS = Object.freeze({
  10: Object.freeze({ Kolay: 5, Orta: 3, Zor: 2 }),
  20: Object.freeze({ Kolay: 10, Orta: 6, Zor: 4 }),
  30: Object.freeze({ Kolay: 15, Orta: 9, Zor: 6 }),
});
const EXPECTED_CATEGORY_INDEXES = Object.freeze([0, 1, 2, 3, 4, 5]);

class LiveDuelCatalogError extends Error {}

function difficultyTargets(questionCount) {
  const targets = DIFFICULTY_TARGETS[Number(questionCount)];
  if (!targets) {
    throw new LiveDuelCatalogError('Canlı düello soru sayısı geçersiz.');
  }
  return targets;
}

function normalizeFamilyText(text) {
  return String(text ?? '')
    .toLocaleLowerCase('tr-TR')
    .replaceAll('ç', 'c')
    .replaceAll('ğ', 'g')
    .replaceAll('ı', 'i')
    .replaceAll('ö', 'o')
    .replaceAll('ş', 's')
    .replaceAll('ü', 'u')
    .replaceAll('â', 'a')
    .replaceAll('î', 'i')
    .replaceAll('û', 'u')
    .replace(/[^a-z0-9°]+/g, ' ')
    .trim()
    .replace(/\s+/g, ' ');
}

function familyHash(text) {
  return createHash('sha256')
    .update(normalizeFamilyText(text), 'utf8')
    .digest('hex')
    .slice(0, 16);
}

function bucketKey(categoryIndex, difficulty) {
  return `${categoryIndex}|${difficulty}`;
}

function validateQuestion(raw, rowNumber) {
  if (!raw || typeof raw !== 'object' || Array.isArray(raw)) {
    throw new LiveDuelCatalogError(`${rowNumber}. soru nesne değil.`);
  }
  const id = String(raw.id ?? '').trim();
  const categoryIndex = Number(raw.categoryIndex);
  const difficulty = String(raw.difficulty ?? '').trim();
  const text = String(raw.question ?? '').trim();
  const options = raw.options;
  const answerIndex = Number(raw.answerIndex);

  if (!id || id.includes('/')) {
    throw new LiveDuelCatalogError(`${rowNumber}. soru kimliği geçersiz.`);
  }
  if (!Number.isInteger(categoryIndex) || !EXPECTED_CATEGORY_INDEXES.includes(categoryIndex)) {
    throw new LiveDuelCatalogError(`${id}: categoryIndex geçersiz.`);
  }
  if (!DIFFICULTIES.includes(difficulty)) {
    throw new LiveDuelCatalogError(`${id}: zorluk geçersiz.`);
  }
  if (!text) {
    throw new LiveDuelCatalogError(`${id}: soru metni boş.`);
  }
  if (!Array.isArray(options) || options.length !== 4) {
    throw new LiveDuelCatalogError(`${id}: dört seçenek zorunludur.`);
  }
  if (!Number.isInteger(answerIndex) || answerIndex < 0 || answerIndex >= options.length) {
    throw new LiveDuelCatalogError(`${id}: answerIndex geçersiz.`);
  }

  return {
    id,
    categoryIndex,
    difficulty,
    family: familyHash(text),
    answerIndex,
    optionCount: options.length,
  };
}

function buildQuestionCatalog(rawQuestions) {
  if (!Array.isArray(rawQuestions)) {
    throw new LiveDuelCatalogError('Soru bankasının kökü liste olmalıdır.');
  }

  const seen = new Set();
  const answerKeys = [];
  const buckets = {};
  const questionIds = [];

  rawQuestions.forEach((raw, index) => {
    const question = validateQuestion(raw, index + 1);
    if (seen.has(question.id)) {
      throw new LiveDuelCatalogError(`Tekrarlanan soru kimliği: ${question.id}`);
    }
    seen.add(question.id);
    questionIds.push(question.id);
    answerKeys.push({
      id: question.id,
      answerIndex: question.answerIndex,
      optionCount: question.optionCount,
    });
    const key = bucketKey(question.categoryIndex, question.difficulty);
    (buckets[key] ??= []).push({ id: question.id, family: question.family });
  });

  questionIds.sort();
  answerKeys.sort((a, b) => a.id.localeCompare(b.id));
  for (const values of Object.values(buckets)) {
    values.sort((a, b) => a.id.localeCompare(b.id));
  }

  for (const categoryIndex of EXPECTED_CATEGORY_INDEXES) {
    for (const difficulty of DIFFICULTIES) {
      const values = buckets[bucketKey(categoryIndex, difficulty)] ?? [];
      if (values.length < 5) {
        throw new LiveDuelCatalogError(
          `${categoryIndex}/${difficulty} kovasında en az 5 soru gerekli; bulunan=${values.length}.`,
        );
      }
    }
  }

  const catalog = {
    schemaVersion: 2,
    questionSetVersion: 2,
    categoryIndexes: [...EXPECTED_CATEGORY_INDEXES],
    difficulties: [...DIFFICULTIES],
    questionCount: questionIds.length,
    questionIds,
    buckets,
  };

  const encodedBytes = Buffer.byteLength(JSON.stringify(catalog), 'utf8');
  if (encodedBytes > 850_000) {
    throw new LiveDuelCatalogError(
      `Soru kataloğu Firestore güvenli boyut sınırını aşıyor: ${encodedBytes} bayt.`,
    );
  }

  return { catalog, answerKeys, encodedBytes };
}

function makeRandom(seed) {
  const digest = createHash('sha256').update(String(seed), 'utf8').digest();
  let state = digest.readUInt32LE(0) || 0x6d2b79f5;
  return () => {
    state = (state + 0x6d2b79f5) >>> 0;
    let value = state;
    value = Math.imul(value ^ (value >>> 15), value | 1);
    value ^= value + Math.imul(value ^ (value >>> 7), value | 61);
    return ((value ^ (value >>> 14)) >>> 0) / 4294967296;
  };
}

function shuffle(values, random) {
  const result = [...values];
  for (let index = result.length - 1; index > 0; index -= 1) {
    const swapIndex = Math.floor(random() * (index + 1));
    [result[index], result[swapIndex]] = [result[swapIndex], result[index]];
  }
  return result;
}

function normalizedBucketEntries(catalog, categoryIndex, difficulty) {
  const raw = catalog?.buckets?.[bucketKey(categoryIndex, difficulty)];
  if (!Array.isArray(raw)) return [];
  return raw
    .map((entry) => {
      if (typeof entry === 'string') return { id: entry, family: '' };
      return {
        id: String(entry?.id ?? '').trim(),
        family: String(entry?.family ?? '').trim(),
      };
    })
    .filter((entry) => entry.id)
    .sort((a, b) => a.id.localeCompare(b.id));
}

function selectBalancedQuestionIds({ catalog, questionCount, seed }) {
  if (Number(catalog?.schemaVersion) !== 2) {
    throw new LiveDuelCatalogError('Soru kataloğu şeması geçersiz.');
  }
  const targets = difficultyTargets(questionCount);
  const categories = Array.isArray(catalog.categoryIndexes)
    ? catalog.categoryIndexes.map(Number).filter(Number.isInteger).sort((a, b) => a - b)
    : [];
  if (
    categories.length !== EXPECTED_CATEGORY_INDEXES.length ||
    categories.some((value, index) => value !== EXPECTED_CATEGORY_INDEXES[index])
  ) {
    throw new LiveDuelCatalogError('Soru kataloğu kategori listesi geçersiz.');
  }

  const random = makeRandom(seed);
  const difficultyPlan = shuffle(
    Object.entries(targets).flatMap(([difficulty, count]) =>
      Array.from({ length: count }, () => difficulty),
    ),
    random,
  );

  const categoryPlan = [];
  while (categoryPlan.length < questionCount) {
    const round = shuffle(categories, random);
    if (categoryPlan.length > 0 && round.length > 1 && round[0] === categoryPlan.at(-1)) {
      const swapIndex = round.findIndex((value) => value !== categoryPlan.at(-1));
      [round[0], round[swapIndex]] = [round[swapIndex], round[0]];
    }
    const remaining = questionCount - categoryPlan.length;
    categoryPlan.push(...round.slice(0, remaining));
  }

  const usedIds = new Set();
  const usedFamilies = new Set();
  const selected = [];

  for (let index = 0; index < questionCount; index += 1) {
    const categoryIndex = categoryPlan[index];
    const difficulty = difficultyPlan[index];
    const allCandidates = normalizedBucketEntries(catalog, categoryIndex, difficulty)
      .filter((entry) => !usedIds.has(entry.id));
    let candidates = allCandidates.filter(
      (entry) => !entry.family || !usedFamilies.has(entry.family),
    );
    if (candidates.length === 0) candidates = allCandidates;
    if (candidates.length === 0) {
      throw new LiveDuelCatalogError(
        `${categoryIndex}/${difficulty} için yeterli benzersiz soru yok.`,
      );
    }
    const chosen = candidates[Math.floor(random() * candidates.length)];
    selected.push({ id: chosen.id, categoryIndex, difficulty, family: chosen.family });
    usedIds.add(chosen.id);
    if (chosen.family) usedFamilies.add(chosen.family);
  }

  const ids = selected.map((entry) => entry.id);
  if (new Set(ids).size !== questionCount) {
    throw new LiveDuelCatalogError('Ortak soru listesinde tekrar oluştu.');
  }
  const actualDifficulty = Object.fromEntries(DIFFICULTIES.map((difficulty) => [difficulty, 0]));
  const actualCategories = new Map();
  selected.forEach((entry, index) => {
    actualDifficulty[entry.difficulty] += 1;
    actualCategories.set(entry.categoryIndex, (actualCategories.get(entry.categoryIndex) ?? 0) + 1);
    if (index > 0 && selected[index - 1].categoryIndex === entry.categoryIndex) {
      throw new LiveDuelCatalogError('Ardışık sorular aynı kategoride olamaz.');
    }
  });
  for (const [difficulty, expected] of Object.entries(targets)) {
    if (actualDifficulty[difficulty] !== expected) {
      throw new LiveDuelCatalogError('Canlı düello zorluk dağılımı bozuldu.');
    }
  }
  const categoryCounts = [...actualCategories.values()];
  if (actualCategories.size !== EXPECTED_CATEGORY_INDEXES.length) {
    throw new LiveDuelCatalogError('Canlı düello kategori dağılımı eksik.');
  }
  if (Math.max(...categoryCounts) - Math.min(...categoryCounts) > 1) {
    throw new LiveDuelCatalogError('Canlı düello kategori dağılımı dengesiz.');
  }
  return ids;
}

function compareLegacyKeys(answerKeys, legacyRows) {
  const current = new Map(answerKeys.map((key) => [key.id, key]));
  const legacy = new Map(
    legacyRows.map((row) => [String(row.id ?? '').trim(), {
      id: String(row.id ?? '').trim(),
      answerIndex: Number(row.answerIndex),
      optionCount: Number(row.optionCount),
    }]),
  );
  const missing = [];
  const extra = [];
  const mismatched = [];

  for (const [id, key] of current) {
    const old = legacy.get(id);
    if (!old) {
      missing.push(id);
      continue;
    }
    if (old.answerIndex !== key.answerIndex || old.optionCount !== key.optionCount) {
      mismatched.push({ id, current: key, legacy: old });
    }
  }
  for (const id of legacy.keys()) {
    if (!current.has(id)) extra.push(id);
  }
  missing.sort();
  extra.sort();
  mismatched.sort((a, b) => a.id.localeCompare(b.id));
  return {
    currentCount: current.size,
    legacyCount: legacy.size,
    missing,
    extra,
    mismatched,
    clean: missing.length === 0 && extra.length === 0 && mismatched.length === 0,
  };
}

module.exports = {
  DIFFICULTIES,
  EXPECTED_CATEGORY_INDEXES,
  LiveDuelCatalogError,
  buildQuestionCatalog,
  compareLegacyKeys,
  difficultyTargets,
  familyHash,
  selectBalancedQuestionIds,
};
