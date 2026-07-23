part of 'main.dart';

class QuestionQualityGuard {
  QuestionQualityGuard._();

  static const int maxQuestionCharacters = 190;
  static const int maxQuestionWords = 32;
  static const int maxOptionCharacters = 90;
  static const int maxTotalOptionCharacters = 300;

  static int lastScannedCount = 0;
  static int lastExcludedCount = 0;
  static Map<String, int> lastReasonCounts = <String, int>{};

  static String _normalize(String value) {
    return value
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
        .replaceAll(RegExp(r'[^a-z0-9]+'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  static bool _looksLikeCategoryDisguisedMath(
    QuizQuestion question,
    String normalizedQuestion,
  ) {
    final numberCount = RegExp(
      r'\d+(?:[.,]\d+)?',
    ).allMatches(normalizedQuestion).length;

    final numericOptionPattern = RegExp(
      r'^\s*[-+]?\d+(?:[.,]\d+)?'
      r'(?:\s*:\s*\d+(?:[.,]\d+)?)?'
      r'(?:\s*(?:mb|gb|tb|kb|km|m|cm|mm|kg|g|lt|l|'
      r'saat|dakika|saniye|puan|adet|tane|yuzde|derece|°c|°f|%))?\s*$',
      caseSensitive: false,
    );

    final numericOptionCount = question.options
        .where(
          (option) => numericOptionPattern.hasMatch(
            option.trim().toLowerCase(),
          ),
        )
        .length;

    const strongPhrases = <String>[
      'toplam kac',
      'toplam ne kadar',
      'toplami nedir',
      'toplam yolu',
      'toplam mesafe',
      'toplam sure',
      'toplam maliyet',
      'toplam puan',
      'ne kadar yer kaplar',
      'kac mb',
      'kac gb',
      'kac kilometre',
      'kac km',
      'kac metre',
      'kac cm',
      'kac dakika',
      'kac saat',
      'kac tam',
      'kac kat',
      'kac adet',
      'kac tane',
      'kac doldurur',
      'sadelestirilmis en boy orani',
      'en boy orani',
      'orani nedir',
      'oran nedir',
      'alani nedir',
      'alan nedir',
      'cevresi nedir',
      'cevre nedir',
      'ortalamasi nedir',
      'yuzdesi nedir',
      'yuzde kac',
      'farki nedir',
      'carpimi nedir',
      'bolumu nedir',
      'her bolumu',
      'her biri',
      'birim fiyati',
      'saatte',
      'saat boyunca',
      'dakikada',
      'dakika boyunca',
      'saniyede',
      'indirimli fiyat',
      'yuzde artis',
      'yuzde azalis',
      'kac derece artmis',
      'kac derece azalmis',
      'kac derece yukselmis',
      'kac derece dusmus',
      'derece artmis olur',
      'derece azalmis olur',
    ];

    final hasStrongPhrase = strongPhrases.any(
      normalizedQuestion.contains,
    );
    final hasArithmeticSymbol = RegExp(
      r'\d\s*(?:x|×|\*|/|÷|\+|−|-)\s*\d',
    ).hasMatch(question.text);
    final asksQuantity = const <String>[
      'kac',
      'ne kadar',
      'nedir',
      'bulunur',
      'hesaplanir',
    ].any(normalizedQuestion.contains);

    final words = normalizedQuestion.split(' ').toSet();
    final hasMeasurementPair = numberCount >= 2 &&
        const <String>[
          'mb',
          'gb',
          'km',
          'metre',
          'cm',
          'saat',
          'dakika',
          'saniye',
          'kg',
          'gram',
          'litre',
        ].any(words.contains);

    return (numberCount >= 2 &&
            (hasStrongPhrase ||
                hasArithmeticSymbol ||
                (numericOptionCount >= 3 && asksQuantity) ||
                (hasMeasurementPair &&
                    numericOptionCount >= 3))) ||
        (numberCount >= 1 &&
            hasStrongPhrase &&
            numericOptionCount >= 3);
  }

  static bool _looksLikeLetterCounting(
    QuizQuestion question,
    String normalizedQuestion,
  ) {
    final asksLetters = const <String>[
      'kac harf vardir',
      'kac harften olusur',
      'harf sayisi kactir',
      'kac karakter vardir',
    ].any(normalizedQuestion.contains);

    final titleOrWordContext = const <String>[
      'eser adinda',
      'eser basliginda',
      'adinda bosluk',
      'basliginda bosluk',
      'noktalama isaretleri sayilmadan',
      'bosluklar sayilmadan',
      'yalnizca harfler',
      'kelimesinde kac harf',
    ].any(normalizedQuestion.contains);

    return asksLetters && titleOrWordContext;
  }

  static bool _looksLikeLowValueTextOrDateTask(
    QuizQuestion question,
    String normalizedQuestion,
  ) {
    final hasYear = RegExp(r'\b\d{3,4}\b')
        .hasMatch(normalizedQuestion);

    final trivialDateTask = hasYear &&
        const <String>[
          'hangi on yilda',
          'hangi on yillik donemde',
          'hangi yuzyilin icindedir',
          'hangi yuzyilda yer alir',
        ].any(normalizedQuestion.contains);

    final trivialTitleTask = const <String>[
      'basliginda kac kelime',
      'basliginin ilk kelimesi',
      'eser adinda kac kelime',
      'eser adinin ilk kelimesi',
      'kelimesinde kac harf',
      'basliginda kac harf',
    ].any(normalizedQuestion.contains);

    final combinedTask = const <String>[
      'ortak sayisal cevabi',
      'sirasiyla dogru cevaplar',
      'dogru cevap cifti',
    ].any(normalizedQuestion.contains) &&
        (normalizedQuestion.contains('kural') ||
            normalizedQuestion.contains('soru'));

    final vagueInstitutionTask = normalizedQuestion.contains(
      'kurumu ekibi veya kisisi',
    );

    return trivialDateTask ||
        trivialTitleTask ||
        combinedTask ||
        vagueInstitutionTask;
  }

  static List<String> reasons(QuizQuestion question) {
    final reasons = <String>[];
    final normalizedQuestion = _normalize(question.text);
    final wordCount = normalizedQuestion.isEmpty
        ? 0
        : normalizedQuestion.split(' ').length;
    final optionLengths = question.options
        .map((option) => option.trim().length)
        .toList(growable: false);

    if (question.text.trim().length > maxQuestionCharacters ||
        wordCount > maxQuestionWords ||
        optionLengths.any(
          (length) => length > maxOptionCharacters,
        ) ||
        optionLengths.fold<int>(
              0,
              (sum, length) => sum + length,
            ) >
            maxTotalOptionCharacters) {
      reasons.add('Aşırı uzun soru veya seçenek');
    }

    const orderingPatterns = <String>[
      'eskiden yeniye',
      'yeniden eskiye',
      'kronolojik',
      'dogru siralama',
      'hangi siralama',
      'sirasiyla diz',
      'siraya koy',
      'siralanmistir',
    ];

    if (orderingPatterns.any(normalizedQuestion.contains)) {
      reasons.add('Sıralama/kronoloji sorusu');
    }

    const matchingPatterns = <String>[
      'eslestirmesi hangisidir',
      'dogru eslestirme',
      'hangi eslestirme',
      'eslestirilmistir',
      'eslestiriniz',
      'eslestirilen',
    ];

    if (matchingPatterns.any(normalizedQuestion.contains)) {
      reasons.add('Eşleştirme sorusu');
    }

    const vaguePatterns = <String>[
      'ile iliskilendirilen',
      'ile iliskilidir',
      'en cok iliskilendirilen',
      'dogru kisi taraf veya gelisme',
      'dogru tur ya da sanat bicimi',
      'dogru tarih veya donem',
      'dogru yer eslestirmesi',
      'dogru yayin yili eslestirmesi',
      'karakteri hangi filmde yer alir',
      'karakteri hangi filmde gorulur',
    ];

    if (vaguePatterns.any(normalizedQuestion.contains)) {
      reasons.add('Belirsiz/yapay soru kalıbı');
    }

    final commaCount = ','.allMatches(question.text).length;
    if (commaCount >= 3 &&
        (normalizedQuestion.contains('arasindan hangisi') ||
            normalizedQuestion.contains('hangisi ile') ||
            normalizedQuestion.contains(
              'hangisi asagidakilerden',
            ))) {
      reasons.add('Birleşik ve çok parçalı soru');
    }

    if (question.answerIndex >= 0 &&
        question.answerIndex < question.options.length) {
      final answer = _normalize(
        question.options[question.answerIndex],
      );

      if (answer.length >= 3) {
        final answerPattern = RegExp(
          '(?:^| )${RegExp.escape(answer)}(?: |\$)',
        );

        if (answerPattern.hasMatch(normalizedQuestion)) {
          reasons.add('Doğru cevap soru kökünde geçiyor');
        }
      }
    }

    if (_looksLikeCategoryDisguisedMath(
      question,
      normalizedQuestion,
    )) {
      reasons.add('Kategori dışı matematik problemi');
    }

    if (_looksLikeLetterCounting(
      question,
      normalizedQuestion,
    )) {
      reasons.add('Kategori dışı harf sayma sorusu');
    }

    if (_looksLikeLowValueTextOrDateTask(
      question,
      normalizedQuestion,
    )) {
      reasons.add('Kategori dışı tarih/metin işlemi');
    }

    return reasons.toSet().toList(growable: false);
  }

  static bool isPlayable(QuizQuestion question) {
    return reasons(question).isEmpty;
  }

  static void updateLastScan(
    List<QuizQuestion> allQuestions,
  ) {
    lastScannedCount = allQuestions.length;
    final counts = <String, int>{};
    var excluded = 0;

    for (final question in allQuestions) {
      final issues = reasons(question);
      if (issues.isEmpty) continue;

      excluded++;
      for (final issue in issues) {
        counts[issue] = (counts[issue] ?? 0) + 1;
      }
    }

    lastExcludedCount = excluded;
    lastReasonCounts = Map<String, int>.unmodifiable(counts);
  }

  static String get summary {
    final playable = max(
      0,
      lastScannedCount - lastExcludedCount,
    );

    return '$playable uygun • $lastExcludedCount elendi';
  }
}
