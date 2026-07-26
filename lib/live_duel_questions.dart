part of 'main.dart';

class LiveDuelQuestionSetException implements Exception {
  const LiveDuelQuestionSetException(this.message);

  final String message;

  @override
  String toString() => message;
}

class LiveDuelQuestionSet {
  const LiveDuelQuestionSet({
    required this.questionIds,
    required this.questions,
  });

  final List<String> questionIds;
  final List<QuizQuestion> questions;

  int get length => questions.length;
}

class LiveDuelQuestionSetService {
  LiveDuelQuestionSetService._();

  static const int currentVersion = 2;

  static bool supportsQuestionSetVersion(Object? value) {
    return (value as num?)?.toInt() == currentVersion;
  }

  static Map<String, int> difficultyTargetsForCount(int questionCount) {
    return switch (questionCount) {
      10 => const <String, int>{'Kolay': 5, 'Orta': 3, 'Zor': 2},
      20 => const <String, int>{'Kolay': 10, 'Orta': 6, 'Zor': 4},
      30 => const <String, int>{'Kolay': 15, 'Orta': 9, 'Zor': 6},
      _ =>
        throw const LiveDuelQuestionSetException(
          'Canlı düello soru sayısı geçersiz.',
        ),
    };
  }

  static Future<List<String>> createQuestionIds({
    required int questionCount,
    required int seed,
  }) async {
    final bank = await QuestionBank.load();

    return createQuestionIdsFromBank(
      bank: bank,
      questionCount: questionCount,
      seed: seed,
    );
  }

  static List<String> createQuestionIdsFromBank({
    required QuestionBank bank,
    required int questionCount,
    required int seed,
  }) {
    if (!LiveDuelMatchmakingPolicy.supportsQuestionCount(questionCount)) {
      throw const LiveDuelQuestionSetException(
        'Canlı düello soru sayısı geçersiz.',
      );
    }

    final random = Random(seed);
    final targets = difficultyTargetsForCount(questionCount);

    final categories = bank.questionsByCategory.entries
      .where((entry) => entry.value.isNotEmpty)
      .map((entry) => entry.key)
      .where(
        (category) => category >= 0 && category < GameCategory.values.length,
      )
      .toList(growable: true)..sort();

    final requiredCategoryCount = min(
      questionCount,
      GameCategory.values.length,
    );

    if (categories.length < requiredCategoryCount) {
      throw const LiveDuelQuestionSetException(
        'Canlı düello için bütün kategorilerde yeterli soru yok.',
      );
    }

    final difficultyPlan = <String>[
      for (final entry in targets.entries)
        ...List<String>.filled(entry.value, entry.key),
    ]..shuffle(random);

    final categoryPlan = <int>[];

    while (categoryPlan.length < questionCount) {
      final round = List<int>.from(categories)..shuffle(random);

      if (categoryPlan.isNotEmpty &&
          round.length > 1 &&
          round.first == categoryPlan.last) {
        final swapIndex = round.indexWhere(
          (category) => category != categoryPlan.last,
        );
        final first = round.first;
        round[0] = round[swapIndex];
        round[swapIndex] = first;
      }

      final remaining = questionCount - categoryPlan.length;
      categoryPlan.addAll(round.take(remaining));
    }

    final selected = <QuizQuestion>[];
    final usedIds = <String>{};
    final usedFamilies = <String>{};

    for (var index = 0; index < questionCount; index++) {
      final targetCategory = categoryPlan[index];
      final targetDifficulty = difficultyPlan[index];
      final categoryQuestions =
          bank.questionsByCategory[targetCategory] ?? const <QuizQuestion>[];

      var candidates = categoryQuestions
          .where(
            (question) =>
                question.difficulty == targetDifficulty &&
                !usedIds.contains(question.id) &&
                !usedFamilies.contains(
                  QuestionBank.questionFamilyKey(question.text),
                ),
          )
          .toList(growable: true);

      if (candidates.isEmpty) {
        candidates = categoryQuestions
            .where(
              (question) =>
                  question.difficulty == targetDifficulty &&
                  !usedIds.contains(question.id),
            )
            .toList(growable: true);
      }

      if (candidates.isEmpty) {
        throw LiveDuelQuestionSetException(
          '$targetCategory kategorisinde '
          '$targetDifficulty seviyesinde yeterli soru yok.',
        );
      }

      candidates.sort((first, second) => first.id.compareTo(second.id));

      final chosen = candidates[random.nextInt(candidates.length)];

      selected.add(chosen);
      usedIds.add(chosen.id);
      usedFamilies.add(QuestionBank.questionFamilyKey(chosen.text));
    }

    final actualDifficultyCounts = <String, int>{
      'Kolay': 0,
      'Orta': 0,
      'Zor': 0,
    };
    final actualCategoryCounts = <int, int>{};

    for (final question in selected) {
      actualDifficultyCounts[question.difficulty] =
          (actualDifficultyCounts[question.difficulty] ?? 0) + 1;
      actualCategoryCounts[question.categoryIndex] =
          (actualCategoryCounts[question.categoryIndex] ?? 0) + 1;
    }

    for (final entry in targets.entries) {
      if (actualDifficultyCounts[entry.key] != entry.value) {
        throw const LiveDuelQuestionSetException(
          'Canlı düello zorluk dağılımı oluşturulamadı.',
        );
      }
    }

    if (actualCategoryCounts.length != requiredCategoryCount) {
      throw const LiveDuelQuestionSetException(
        'Canlı düello kategori dağılımı oluşturulamadı.',
      );
    }

    final categoryValues = actualCategoryCounts.values.toList(growable: false);
    final minCategoryCount = categoryValues.reduce(min);
    final maxCategoryCount = categoryValues.reduce(max);

    if (maxCategoryCount - minCategoryCount > 1) {
      throw const LiveDuelQuestionSetException(
        'Canlı düello kategorileri dengeli dağıtılamadı.',
      );
    }

    for (var index = 1; index < selected.length; index++) {
      if (selected[index - 1].categoryIndex == selected[index].categoryIndex) {
        throw const LiveDuelQuestionSetException(
          'Canlı düello soru sırası karıştırılamadı.',
        );
      }
    }

    final ids = selected.map((question) => question.id).toList(growable: false);

    if (ids.length != questionCount || ids.toSet().length != questionCount) {
      throw const LiveDuelQuestionSetException(
        'Ortak soru listesi oluşturulamadı.',
      );
    }

    return List<String>.unmodifiable(ids);
  }

  static Future<LiveDuelQuestionSet> resolveQuestionIds(
    List<String> questionIds,
  ) async {
    final bank = await QuestionBank.load();

    return resolveQuestionIdsFromBank(bank: bank, questionIds: questionIds);
  }

  static LiveDuelQuestionSet resolveQuestionIdsFromBank({
    required QuestionBank bank,
    required List<String> questionIds,
  }) {
    if (!LiveDuelMatchmakingPolicy.supportsQuestionCount(questionIds.length)) {
      throw const LiveDuelQuestionSetException('Maç soru listesi geçersiz.');
    }

    if (questionIds.toSet().length != questionIds.length) {
      throw const LiveDuelQuestionSetException(
        'Maç soru listesinde tekrar var.',
      );
    }

    final byId = <String, QuizQuestion>{
      for (final question in bank.questionsByCategory.values.expand(
        (questions) => questions,
      ))
        question.id: question,
    };

    final questions = <QuizQuestion>[];

    for (final id in questionIds) {
      final question = byId[id];

      if (question == null) {
        throw LiveDuelQuestionSetException(
          'Maç sorusu cihazda bulunamadı: $id',
        );
      }

      questions.add(question);
    }

    return LiveDuelQuestionSet(
      questionIds: List<String>.unmodifiable(questionIds),
      questions: List<QuizQuestion>.unmodifiable(questions),
    );
  }

  static int seedForMatch({
    required String matchId,
    required String firstPlayerUid,
    required String secondPlayerUid,
  }) {
    final players = <String>[firstPlayerUid, secondPlayerUid]..sort();

    final source = '$matchId|${players.join('|')}';
    var hash = 0x811C9DC5;

    for (final unit in source.codeUnits) {
      hash ^= unit;
      hash = (hash * 0x01000193) & 0x7FFFFFFF;
    }

    return hash;
  }

  static List<String> questionIdsFromMatchData(Map<String, dynamic> data) {
    final raw = data['questionIds'];

    if (raw is! List) {
      throw const LiveDuelQuestionSetException(
        'Maçın soru listesi bulunamadı.',
      );
    }

    return raw.map((item) => item.toString()).toList(growable: false);
  }
}
