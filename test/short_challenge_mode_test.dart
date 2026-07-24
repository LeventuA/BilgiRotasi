import 'package:bilgi_rotasi/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Seçilebilir kısa meydan okuma', () {
    late QuestionBank questionBank;

    setUpAll(() {
      final grouped = <int, List<QuizQuestion>>{};

      for (var index = 0; index < 72; index++) {
        final category = index % 6;
        grouped.putIfAbsent(category, () => <QuizQuestion>[]).add(
              QuizQuestion(
                id: 'challenge_test_${index.toString().padLeft(3, '0')}',
                categoryIndex: category,
                text: 'Test sorusu $index',
                options: const <String>['A', 'B', 'C', 'D'],
                answerIndex: index % 4,
                difficulty: 'Orta',
                explanation: 'Test açıklaması.',
              ),
            );
      }

      questionBank = QuestionBank(grouped);
    });

    test('kod seçilen soru sayısını ve hedefi taşır', () {
      final cases = <String, (int, int)>{
        'BR1905': (10, 7),
        'BR2905': (20, 14),
        'BR3905': (30, 21),
      };

      for (final entry in cases.entries) {
        expect(
          ShortChallengeCodeService.questionCountForCode(entry.key),
          entry.value.$1,
        );
        expect(
          ShortChallengeCodeService.targetScoreForCode(entry.key),
          entry.value.$2,
        );
      }
    });

    test('üretilen kısa kod soru sayısını korur', () {
      for (final count
          in ShortChallengeCodeService.questionCountOptions) {
        final code =
            ShortChallengeCodeService.generateForCount(count);

        expect(
          ShortChallengeCodeService.questionCountForCode(code),
          count,
        );
      }
    });

    test('aynı kod aynı soruları aynı sırayla seçer', () {
      for (final code in <String>['BR1905', 'BR2905', 'BR3905']) {
        final first = ShortChallengeCodeService.selectQuestions(
          questionBank,
          code,
        );
        final second = ShortChallengeCodeService.selectQuestions(
          questionBank,
          code,
        );
        final count =
            ShortChallengeCodeService.questionCountForCode(code);

        expect(first.length, count);
        expect(
          first.map((item) => item.id).toList(),
          second.map((item) => item.id).toList(),
        );
        expect(
          first.map((item) => item.id).toSet().length,
          count,
        );
      }
    });

    test('meydan okuma yapılandırması dinamik hedef üretir', () {
      for (final code in <String>['BR1905', 'BR2905', 'BR3905']) {
        final config = ShortChallengeCodeService.buildConfig(
          questionBank: questionBank,
          rawCode: code,
          challengerName: 'Test Oyuncusu',
        );
        final count =
            ShortChallengeCodeService.questionCountForCode(code);

        expect(config.code, code);
        expect(config.questionIds.length, count);
        expect(
          config.targetScore,
          ShortChallengeCodeService.targetScoreForCount(count),
        );
      }
    });
  });
}
