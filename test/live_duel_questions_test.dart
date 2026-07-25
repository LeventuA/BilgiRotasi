import 'package:bilgi_rotasi/main.dart';
import 'package:flutter_test/flutter_test.dart';

QuizQuestion createQuestion(String id, int category) {
  return QuizQuestion(
    id: id,
    categoryIndex: category,
    text: 'Soru $id',
    options: const <String>['A', 'B', 'C', 'D'],
    answerIndex: 0,
    difficulty: 'Orta',
    explanation: '',
  );
}

QuestionBank createBank() {
  return QuestionBank(<int, List<QuizQuestion>>{
    for (var category = 0; category < 6; category++)
      category: List<QuizQuestion>.generate(
        10,
        (index) => createQuestion('q_${category}_$index', category),
      ),
  });
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

    test('kimlikler aynı sırayla sorulara çevrilir', () {
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
  });
}
