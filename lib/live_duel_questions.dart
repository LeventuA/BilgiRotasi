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

    final pool = bank.questionsByCategory.values
        .expand((questions) => questions)
        .toList(growable: false);

    if (pool.length < questionCount) {
      throw const LiveDuelQuestionSetException(
        'Canlı düello için yeterli soru bulunamadı.',
      );
    }

    final selected = bank.diverseQuestions(
      pool: pool,
      count: questionCount,
      random: Random(seed),
    );

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
