'use strict';

const MAX_QUESTION_CHARACTERS = 190;
const MAX_QUESTION_WORDS = 32;
const MAX_OPTION_CHARACTERS = 90;
const MAX_TOTAL_OPTION_CHARACTERS = 300;

function normalizeQualityText(value) {
  return String(value ?? '')
    .toLowerCase()
    .replaceAll('ç', 'c')
    .replaceAll('ğ', 'g')
    .replaceAll('ı', 'i')
    .replaceAll('ö', 'o')
    .replaceAll('ş', 's')
    .replaceAll('ü', 'u')
    .replaceAll('â', 'a')
    .replaceAll('î', 'i')
    .replaceAll('û', 'u')
    .replace(/[^a-z0-9]+/g, ' ')
    .replace(/\s+/g, ' ')
    .trim();
}

function looksLikeCategoryDisguisedMath(question, normalizedQuestion) {
  const numberCount = (normalizedQuestion.match(/\d+(?:[.,]\d+)?/g) ?? []).length;
  const numericOptionPattern =
    /^\s*[-+]?\d+(?:[.,]\d+)?(?:\s*:\s*\d+(?:[.,]\d+)?)?(?:\s*(?:mb|gb|tb|kb|km|m|cm|mm|kg|g|lt|l|saat|dakika|saniye|puan|adet|tane|yuzde|derece|°c|°f|%))?\s*$/i;
  const numericOptionCount = (question.options ?? [])
    .filter((option) => numericOptionPattern.test(String(option).trim().toLowerCase()))
    .length;

  const strongPhrases = [
    'toplam kac', 'toplam ne kadar', 'toplami nedir', 'toplam yolu',
    'toplam mesafe', 'toplam sure', 'toplam maliyet', 'toplam puan',
    'ne kadar yer kaplar', 'kac mb', 'kac gb', 'kac kilometre', 'kac km',
    'kac metre', 'kac cm', 'kac dakika', 'kac saat', 'kac tam', 'kac kat',
    'kac adet', 'kac tane', 'kac doldurur', 'sadelestirilmis en boy orani',
    'en boy orani', 'orani nedir', 'oran nedir', 'alani nedir', 'alan nedir',
    'cevresi nedir', 'cevre nedir', 'ortalamasi nedir', 'yuzdesi nedir',
    'yuzde kac', 'farki nedir', 'carpimi nedir', 'bolumu nedir', 'her bolumu',
    'her biri', 'birim fiyati', 'saatte', 'saat boyunca', 'dakikada',
    'dakika boyunca', 'saniyede', 'indirimli fiyat', 'yuzde artis',
    'yuzde azalis', 'kac derece artmis', 'kac derece azalmis',
    'kac derece yukselmis', 'kac derece dusmus', 'derece artmis olur',
    'derece azalmis olur',
  ];
  const hasStrongPhrase = strongPhrases.some((phrase) =>
    normalizedQuestion.includes(phrase));
  const hasArithmeticSymbol = /\d\s*(?:x|×|\*|\/|÷|\+|−|-)\s*\d/u
    .test(String(question.question ?? question.text ?? ''));
  const asksQuantity = ['kac', 'ne kadar', 'nedir', 'bulunur', 'hesaplanir']
    .some((phrase) => normalizedQuestion.includes(phrase));
  const words = new Set(normalizedQuestion.split(' '));
  const hasMeasurementPair = numberCount >= 2 &&
    ['mb', 'gb', 'km', 'metre', 'cm', 'saat', 'dakika', 'saniye', 'kg', 'gram', 'litre']
      .some((word) => words.has(word));

  return (
    numberCount >= 2 &&
    (hasStrongPhrase || hasArithmeticSymbol ||
      (numericOptionCount >= 3 && asksQuantity) ||
      (hasMeasurementPair && numericOptionCount >= 3))
  ) || (
    numberCount >= 1 && hasStrongPhrase && numericOptionCount >= 3
  );
}

function looksLikeLetterCounting(normalizedQuestion) {
  const asksLetters = [
    'kac harf vardir', 'kac harften olusur', 'harf sayisi kactir',
    'kac karakter vardir',
  ].some((phrase) => normalizedQuestion.includes(phrase));
  const titleOrWordContext = [
    'eser adinda', 'eser basliginda', 'adinda bosluk', 'basliginda bosluk',
    'noktalama isaretleri sayilmadan', 'bosluklar sayilmadan',
    'yalnizca harfler', 'kelimesinde kac harf',
  ].some((phrase) => normalizedQuestion.includes(phrase));
  return asksLetters && titleOrWordContext;
}

function looksLikeLowValueTextOrDateTask(normalizedQuestion) {
  const hasYear = /\b\d{3,4}\b/.test(normalizedQuestion);
  const trivialDateTask = hasYear && [
    'hangi on yilda', 'hangi on yillik donemde', 'hangi yuzyilin icindedir',
    'hangi yuzyilda yer alir',
  ].some((phrase) => normalizedQuestion.includes(phrase));
  const trivialTitleTask = [
    'basliginda kac kelime', 'basliginin ilk kelimesi', 'eser adinda kac kelime',
    'eser adinin ilk kelimesi', 'kelimesinde kac harf', 'basliginda kac harf',
  ].some((phrase) => normalizedQuestion.includes(phrase));
  const combinedTask = [
    'ortak sayisal cevabi', 'sirasiyla dogru cevaplar', 'dogru cevap cifti',
  ].some((phrase) => normalizedQuestion.includes(phrase)) &&
    (normalizedQuestion.includes('kural') || normalizedQuestion.includes('soru'));
  const vagueInstitutionTask = normalizedQuestion.includes('kurumu ekibi veya kisisi');
  return trivialDateTask || trivialTitleTask || combinedTask || vagueInstitutionTask;
}

function qualityReasons(rawQuestion) {
  const question = {
    text: String(rawQuestion?.question ?? rawQuestion?.text ?? ''),
    options: Array.isArray(rawQuestion?.options)
      ? rawQuestion.options.map((option) => String(option))
      : [],
    answerIndex: Number(rawQuestion?.answerIndex),
  };
  const reasons = [];
  const normalizedQuestion = normalizeQualityText(question.text);
  const wordCount = normalizedQuestion ? normalizedQuestion.split(' ').length : 0;
  const optionLengths = question.options.map((option) => option.trim().length);

  if (
    question.text.trim().length > MAX_QUESTION_CHARACTERS ||
    wordCount > MAX_QUESTION_WORDS ||
    optionLengths.some((length) => length > MAX_OPTION_CHARACTERS) ||
    optionLengths.reduce((sum, length) => sum + length, 0) > MAX_TOTAL_OPTION_CHARACTERS
  ) reasons.push('Aşırı uzun soru veya seçenek');

  const orderingPatterns = [
    'eskiden yeniye', 'yeniden eskiye', 'kronolojik', 'dogru siralama',
    'hangi siralama', 'sirasiyla diz', 'siraya koy', 'siralanmistir',
  ];
  if (orderingPatterns.some((pattern) => normalizedQuestion.includes(pattern))) {
    reasons.push('Sıralama/kronoloji sorusu');
  }

  const matchingPatterns = [
    'eslestirmesi hangisidir', 'dogru eslestirme', 'hangi eslestirme',
    'eslestirilmistir', 'eslestiriniz', 'eslestirilen',
  ];
  if (matchingPatterns.some((pattern) => normalizedQuestion.includes(pattern))) {
    reasons.push('Eşleştirme sorusu');
  }

  const vaguePatterns = [
    'ile iliskilendirilen', 'ile iliskilidir', 'en cok iliskilendirilen',
    'dogru kisi taraf veya gelisme', 'dogru tur ya da sanat bicimi',
    'dogru tarih veya donem', 'dogru yer eslestirmesi',
    'dogru yayin yili eslestirmesi', 'karakteri hangi filmde yer alir',
    'karakteri hangi filmde gorulur',
  ];
  if (vaguePatterns.some((pattern) => normalizedQuestion.includes(pattern))) {
    reasons.push('Belirsiz/yapay soru kalıbı');
  }

  const commaCount = (question.text.match(/,/g) ?? []).length;
  if (commaCount >= 3 && (
    normalizedQuestion.includes('arasindan hangisi') ||
    normalizedQuestion.includes('hangisi ile') ||
    normalizedQuestion.includes('hangisi asagidakilerden')
  )) reasons.push('Birleşik ve çok parçalı soru');

  if (Number.isInteger(question.answerIndex) &&
      question.answerIndex >= 0 && question.answerIndex < question.options.length) {
    const answer = normalizeQualityText(question.options[question.answerIndex]);
    if (answer.length >= 3) {
      const escaped = answer.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
      const answerPattern = new RegExp(`(?:^| )${escaped}(?: |$)`);
      if (answerPattern.test(normalizedQuestion)) {
        reasons.push('Doğru cevap soru kökünde geçiyor');
      }
    }
  }

  if (looksLikeCategoryDisguisedMath(question, normalizedQuestion)) {
    reasons.push('Kategori dışı matematik problemi');
  }
  if (looksLikeLetterCounting(normalizedQuestion)) {
    reasons.push('Kategori dışı harf sayma sorusu');
  }
  if (looksLikeLowValueTextOrDateTask(normalizedQuestion)) {
    reasons.push('Kategori dışı tarih/metin işlemi');
  }
  return [...new Set(reasons)];
}

function isPlayableQuestion(rawQuestion) {
  return qualityReasons(rawQuestion).length === 0;
}

function buildPlayableQuestionSet(rawQuestions) {
  if (!Array.isArray(rawQuestions)) {
    throw new TypeError('Soru bankasının kökü liste olmalıdır.');
  }
  const playable = [];
  const excluded = [];
  for (const question of rawQuestions) {
    const reasons = qualityReasons(question);
    if (reasons.length === 0) playable.push(question);
    else excluded.push({ id: String(question?.id ?? '').trim(), reasons });
  }
  return { playable, excluded };
}

module.exports = {
  MAX_OPTION_CHARACTERS,
  MAX_QUESTION_CHARACTERS,
  MAX_QUESTION_WORDS,
  MAX_TOTAL_OPTION_CHARACTERS,
  buildPlayableQuestionSet,
  isPlayableQuestion,
  normalizeQualityText,
  qualityReasons,
};
