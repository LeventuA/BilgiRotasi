'use strict';

const fs = require('node:fs');
const path = require('node:path');
const test = require('node:test');
const assert = require('node:assert/strict');
const {
  buildPlayableQuestionSet,
  isPlayableQuestion,
  qualityReasons,
} = require('../live_duel_playable');

function question(overrides = {}) {
  return {
    id: 'q-test',
    categoryIndex: 0,
    question: 'Türkiye Cumhuriyeti hangi yıl ilan edildi?',
    options: ['1923', '1919', '1938', '1950'],
    answerIndex: 0,
    difficulty: 'Kolay',
    ...overrides,
  };
}

test('q1214 regression is excluded exactly like the Flutter quality guard', () => {
  const q1214 = question({
    id: 'q1214',
    categoryIndex: 2,
    question: 'Horasan ile ilişkilendirilen tarihî olay hangisidir?',
    options: ['Dandanakan Savaşı', 'Talas Savaşı', 'Malazgirt Savaşı', 'Pasinler Savaşı'],
    answerIndex: 0,
  });
  assert.equal(isPlayableQuestion(q1214), false);
  assert.deepEqual(qualityReasons(q1214), ['Belirsiz/yapay soru kalıbı']);
});

test('ordinary playable question stays eligible', () => {
  assert.equal(isPlayableQuestion(question()), true);
});

test('quality parity covers matching, answer leak and long content guards', () => {
  assert.ok(qualityReasons(question({
    question: 'Türkiye için doğru eşleştirme hangisidir?',
    options: ['Ankara', 'İstanbul', 'İzmir', 'Bursa'], answerIndex: 0,
  })).includes('Eşleştirme sorusu'));
  assert.ok(qualityReasons(question({
    question: 'Ankara Türkiye için aşağıdakilerden hangisidir?',
    options: ['Ankara', 'İstanbul', 'İzmir', 'Bursa'], answerIndex: 0,
  })).includes('Doğru cevap soru kökünde geçiyor'));
  assert.ok(qualityReasons(question({ question: 'x'.repeat(191) }))
    .includes('Aşırı uzun soru veya seçenek'));
});

test('playable set reports excluded ids and never mutates source rows', () => {
  const source = [
    question({ id: 'good-1' }),
    question({
      id: 'q1214', categoryIndex: 2,
      question: 'Horasan ile ilişkilendirilen tarihî olay hangisidir?',
      options: ['Dandanakan Savaşı', 'Talas Savaşı', 'Malazgirt Savaşı', 'Pasinler Savaşı'],
      answerIndex: 0,
    }),
  ];
  const before = JSON.stringify(source);
  const result = buildPlayableQuestionSet(source);
  assert.deepEqual(result.playable.map((item) => item.id), ['good-1']);
  assert.deepEqual(result.excluded.map((item) => item.id), ['q1214']);
  assert.equal(JSON.stringify(source), before);
});

test('release bank exposes the real playable Live Duel universe', () => {
  const bankPath = path.resolve(__dirname, '../../assets/questions.json');
  const raw = JSON.parse(fs.readFileSync(bankPath, 'utf8'));
  const { playable, excluded } = buildPlayableQuestionSet(raw);
  const excludedIds = new Set(excluded.map((item) => item.id));

  assert.equal(raw.length, 8710);
  assert.equal(excludedIds.has('q1214'), true);
  assert.ok(playable.length > 30);
  assert.ok(playable.length < raw.length);
  assert.equal(playable.length + excluded.length, raw.length);
  process.stdout.write(
    `LIVE_DUEL_PLAYABLE: raw=${raw.length} playable=${playable.length} excluded=${excluded.length}\n`,
  );
});
