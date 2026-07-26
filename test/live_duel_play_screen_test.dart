import 'package:bilgi_rotasi/main.dart';
import 'package:flutter_test/flutter_test.dart';

LiveDuelPlayerProgress finishedProgress({
  required String uid,
  required int correct,
}) {
  return LiveDuelPlayerProgress(
    uid: uid,
    currentQuestionIndex: 10,
    answeredCount: 10,
    correctCount: correct,
    wrongCount: 10 - correct,
    finished: true,
  );
}

void main() {
  group('Canlı düello maç görünüm verisi', () {
    test('oyuncu ve soru bilgilerini doğru çözer', () {
      final questionIds = List<String>.generate(
        10,
        (index) => 'question-$index',
      );

      final match = LiveDuelMatchViewData.fromMap(<String, dynamic>{
        'questionCount': 10,
        'questionIds': questionIds,
        'playerUids': const <String>['levent', 'emel'],
        'players': const <Map<String, dynamic>>[
          <String, dynamic>{'uid': 'levent', 'displayName': 'Levent'},
          <String, dynamic>{'uid': 'emel', 'displayName': 'Emel'},
        ],
      });

      expect(match.questionCount, 10);
      expect(match.questionIds, questionIds);
      expect(match.opponentUidFor('levent'), 'emel');
      expect(match.playerName('emel'), 'Emel');
    });

    test('tekrarlanan oyuncu kimliklerini reddeder', () {
      expect(
        () => LiveDuelMatchViewData.fromMap(<String, dynamic>{
          'questionCount': 10,
          'questionIds': List<String>.generate(
            10,
            (index) => 'question-$index',
          ),
          'playerUids': const <String>['levent', 'levent'],
        }),
        throwsA(isA<LiveDuelPlayException>()),
      );
    });
  });

  group('Canlı düello sonuç hesabı', () {
    test('yüksek doğru sayısı galibiyet üretir', () {
      expect(
        LiveDuelResultCalculator.outcome(
          own: finishedProgress(uid: 'levent', correct: 8),
          opponent: finishedProgress(uid: 'emel', correct: 6),
        ),
        LiveDuelOutcome.victory,
      );
    });

    test('eşit doğru sayısı beraberlik üretir', () {
      expect(
        LiveDuelResultCalculator.outcome(
          own: finishedProgress(uid: 'levent', correct: 7),
          opponent: finishedProgress(uid: 'emel', correct: 7),
        ),
        LiveDuelOutcome.draw,
      );
    });

    test('düşük doğru sayısı yenilgi üretir', () {
      expect(
        LiveDuelResultCalculator.outcome(
          own: finishedProgress(uid: 'levent', correct: 4),
          opponent: finishedProgress(uid: 'emel', correct: 9),
        ),
        LiveDuelOutcome.defeat,
      );
    });
  });
}
