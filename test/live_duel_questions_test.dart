import 'package:bilgi_rotasi/main.dart';
import 'package:flutter_test/flutter_test.dart';

QuizQuestion createQuestion({
  required String id,
  required int category,
  required String difficulty,
}) {
  return QuizQuestion(
    id: id,
    categoryIndex: category,
    text: 'Benzersiz bilgi sorusu $id',
    options: const <String>['A', 'B', 'C', 'D'],
    answerIndex: 0,
    difficulty: difficulty,
    explanation: '',
  );
}

QuestionBank createBank() {
  const difficulties = <String>['Kolay', 'Orta', 'Zor'];

  return QuestionBank(<int, List<QuizQuestion>>{
    for (var category = 0; category < 6; category++)
      category: <QuizQuestion>[
        for (final difficulty in difficulties)
          for (var index = 0; index < 20; index++)
            createQuestion(
              id: 'q_${category}_${difficulty}_$index',
              category: category,
              difficulty: difficulty,
            ),
      ],
  });
}

Map<String, int> difficultyCounts(List<QuizQuestion> questions) {
  final counts = <String, int>{'Kolay': 0, 'Orta': 0, 'Zor': 0};

  for (final question in questions) {
    counts[question.difficulty] = (counts[question.difficulty] ?? 0) + 1;
  }

  return counts;
}

void expectBalancedCategories(List<QuizQuestion> questions) {
  final counts = <int, int>{};

  for (final question in questions) {
    counts[question.categoryIndex] = (counts[question.categoryIndex] ?? 0) + 1;
  }

  expect(counts.length, 6);

  final values = counts.values.toList(growable: false);
  final highest = values.reduce(
    (first, second) => first > second ? first : second,
  );
  final lowest = values.reduce(
    (first, second) => first < second ? first : second,
  );
  expect(highest - lowest, lessThanOrEqualTo(1));

  for (var index = 1; index < questions.length; index++) {
    expect(
      questions[index - 1].categoryIndex,
      isNot(questions[index].categoryIndex),
    );
  }
}

void main() {
  group('Canlı düello ortak soru sistemi', () {
    test('aynı tohum aynı soru sırasını üretir', () {
      final bank = createBank();

      final first = LiveDuelQuestionSetService.createQuestionIdsFromBank(
        bank: bank,
        questionCount: 10,
        seed: 1905,
      );

      final second = LiveDuelQuestionSetService.createQuestionIdsFromBank(
        bank: bank,
        questionCount: 10,
        seed: 1905,
      );

      expect(second, first);
      expect(first.length, 10);
      expect(first.toSet().length, 10);
    });

    test('10 soru 5 kolay 3 orta 2 zor olur', () {
      final bank = createBank();
      final ids = LiveDuelQuestionSetService.createQuestionIdsFromBank(
        bank: bank,
        questionCount: 10,
        seed: 2026,
      );
      final set = LiveDuelQuestionSetService.resolveQuestionIdsFromBank(
        bank: bank,
        questionIds: ids,
      );

      expect(difficultyCounts(set.questions), const <String, int>{
        'Kolay': 5,
        'Orta': 3,
        'Zor': 2,
      });
      expectBalancedCategories(set.questions);
    });

    test('20 ve 30 soruda aynı oran korunur', () {
      final bank = createBank();

      final expectations = <int, Map<String, int>>{
        20: const <String, int>{'Kolay': 10, 'Orta': 6, 'Zor': 4},
        30: const <String, int>{'Kolay': 15, 'Orta': 9, 'Zor': 6},
      };

      for (final entry in expectations.entries) {
        final ids = LiveDuelQuestionSetService.createQuestionIdsFromBank(
          bank: bank,
          questionCount: entry.key,
          seed: 3000 + entry.key,
        );
        final set = LiveDuelQuestionSetService.resolveQuestionIdsFromBank(
          bank: bank,
          questionIds: ids,
        );

        expect(difficultyCounts(set.questions), entry.value);
        expectBalancedCategories(set.questions);
      }
    });

    test('kimlikler aynı sırayla sorulara çevrilir', () {
      final bank = createBank();

      final ids = LiveDuelQuestionSetService.createQuestionIdsFromBank(
        bank: bank,
        questionCount: 10,
        seed: 2027,
      );

      final set = LiveDuelQuestionSetService.resolveQuestionIdsFromBank(
        bank: bank,
        questionIds: ids,
      );

      expect(set.questions.map((question) => question.id).toList(), ids);
    });

    test('maç tohumu oyuncu sırasından etkilenmez', () {
      final first = LiveDuelQuestionSetService.seedForMatch(
        matchId: 'match-1',
        firstPlayerUid: 'levent',
        secondPlayerUid: 'emel',
      );

      final second = LiveDuelQuestionSetService.seedForMatch(
        matchId: 'match-1',
        firstPlayerUid: 'emel',
        secondPlayerUid: 'levent',
      );

      expect(second, first);
    });

    test('yalnızca güncel soru planı sürümü devam ettirilir', () {
      expect(LiveDuelQuestionSetService.currentVersion, 2);
      expect(LiveDuelQuestionSetService.supportsQuestionSetVersion(2), isTrue);
      expect(LiveDuelQuestionSetService.supportsQuestionSetVersion(1), isFalse);
    });
  });
}
