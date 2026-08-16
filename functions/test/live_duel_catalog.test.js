'use strict';

const test = require('node:test');
const assert = require('node:assert/strict');
const {
  buildQuestionCatalog,
  compareLegacyKeys,
  difficultyTargets,
  selectBalancedQuestionIds,
} = require('../live_duel_catalog');

function bank({ perBucket = 8 } = {}) {
  const rows = [];
  for (let categoryIndex = 0; categoryIndex < 6; categoryIndex += 1) {
    for (const difficulty of ['Kolay', 'Orta', 'Zor']) {
      for (let index = 0; index < perBucket; index += 1) {
        rows.push({
          id: `q_${categoryIndex}_${difficulty}_${index}`,
          categoryIndex,
          difficulty,
          question: `Kategori ${categoryIndex} ${difficulty} aile ${index}`,
          options: ['A', 'B', 'C', 'D'],
          answerIndex: index % 4,
        });
      }
    }
  }
  return rows;
}

function metadataById(raw) {
  return new Map(raw.map((item) => [item.id, item]));
}

test('catalog plan preserves all six category/difficulty buckets', () => {
  const raw = bank();
  const { catalog, answerKeys, encodedBytes } = buildQuestionCatalog(raw);
  assert.equal(catalog.schemaVersion, 2);
  assert.equal(catalog.questionCount, raw.length);
  assert.equal(answerKeys.length, raw.length);
  assert.ok(encodedBytes < 850_000);
  for (let categoryIndex = 0; categoryIndex < 6; categoryIndex += 1) {
    for (const difficulty of ['Kolay', 'Orta', 'Zor']) {
      assert.equal(catalog.buckets[`${categoryIndex}|${difficulty}`].length, 8);
    }
  }
});

test('server selection is deterministic, varied, balanced and unique', () => {
  const raw = bank();
  const byId = metadataById(raw);
  const { catalog } = buildQuestionCatalog(raw);

  for (const questionCount of [10, 20, 30]) {
    const first = selectBalancedQuestionIds({ catalog, questionCount, seed: 'match-a' });
    const repeat = selectBalancedQuestionIds({ catalog, questionCount, seed: 'match-a' });
    const other = selectBalancedQuestionIds({ catalog, questionCount, seed: 'match-b' });
    assert.deepEqual(first, repeat);
    assert.notDeepEqual(first, other);
    assert.equal(first.length, questionCount);
    assert.equal(new Set(first).size, questionCount);

    const difficultyCounts = { Kolay: 0, Orta: 0, Zor: 0 };
    const categoryCounts = new Map();
    let previousCategory = null;
    for (const id of first) {
      const item = byId.get(id);
      difficultyCounts[item.difficulty] += 1;
      categoryCounts.set(item.categoryIndex, (categoryCounts.get(item.categoryIndex) ?? 0) + 1);
      assert.notEqual(item.categoryIndex, previousCategory);
      previousCategory = item.categoryIndex;
    }
    assert.deepEqual(difficultyCounts, difficultyTargets(questionCount));
    assert.equal(categoryCounts.size, 6);
    const counts = [...categoryCounts.values()];
    assert.ok(Math.max(...counts) - Math.min(...counts) <= 1);
  }
});

test('legacy comparison is fail-closed on missing, extra or changed answers', () => {
  const { answerKeys } = buildQuestionCatalog(bank());
  const exact = answerKeys.map((key) => ({ ...key }));
  assert.equal(compareLegacyKeys(answerKeys, exact).clean, true);

  const changed = exact.map((key) => ({ ...key }));
  changed[0].answerIndex = (changed[0].answerIndex + 1) % 4;
  const report = compareLegacyKeys(answerKeys, changed.slice(1).concat({
    id: 'legacy-only', answerIndex: 0, optionCount: 4,
  }));
  assert.equal(report.clean, false);
  assert.equal(report.missing.length, 1);
  assert.equal(report.extra.length, 1);
});

test('catalog rejects thin buckets before production', () => {
  assert.throws(() => buildQuestionCatalog(bank({ perBucket: 4 })), /en az 5 soru/);
});
