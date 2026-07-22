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
