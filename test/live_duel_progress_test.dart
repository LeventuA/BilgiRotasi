import 'package:bilgi_rotasi/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Canlı düello ilerleme sistemi', () {
    test('doğru cevap skoru artırır', () {
      const current = LiveDuelPlayerProgress(
        uid: 'levent',
        currentQuestionIndex: 0,
        answeredCount: 0,
        correctCount: 0,
        wrongCount: 0,
        finished: false,
      );

      final next = LiveDuelProgressCalculator.applyAnswer(
        current: current,
        questionId: 'q1',
        correct: true,
        questionCount: 10,
      );

      expect(next.answeredCount, 1);
      expect(next.correctCount, 1);
      expect(next.wrongCount, 0);
      expect(next.currentQuestionIndex, 1);
      expect(next.finished, isFalse);
    });

    test('yanlış cevap yanlış sayısını artırır', () {
      const current = LiveDuelPlayerProgress(
        uid: 'levent',
        currentQuestionIndex: 3,
        answeredCount: 3,
        correctCount: 2,
        wrongCount: 1,
        finished: false,
      );

      final next = LiveDuelProgressCalculator.applyAnswer(
        current: current,
        questionId: 'q4',
        correct: false,
        questionCount: 10,
      );

      expect(next.answeredCount, 4);
      expect(next.correctCount, 2);
      expect(next.wrongCount, 2);
    });

    test('son cevap maçı bitirir', () {
      const current = LiveDuelPlayerProgress(
        uid: 'levent',
        currentQuestionIndex: 9,
        answeredCount: 9,
        correctCount: 7,
        wrongCount: 2,
        finished: false,
      );

      final next = LiveDuelProgressCalculator.applyAnswer(
        current: current,
        questionId: 'q10',
        correct: true,
        questionCount: 10,
      );

      expect(next.answeredCount, 10);
      expect(next.correctCount, 8);
      expect(next.finished, isTrue);
      expect(next.currentQuestionIndex, 10);
    });

    test('ilerleme oranı doğru hesaplanır', () {
      const progress = LiveDuelPlayerProgress(
        uid: 'levent',
        currentQuestionIndex: 4,
        answeredCount: 4,
        correctCount: 3,
        wrongCount: 1,
        finished: false,
      );

      expect(progress.progressRatio(10), 0.4);
    });

    test('önce doğru sayısı sonra ilerleme karşılaştırılır', () {
      const first = LiveDuelPlayerProgress(
        uid: 'levent',
        currentQuestionIndex: 5,
        answeredCount: 5,
        correctCount: 4,
        wrongCount: 1,
        finished: false,
      );

      const second = LiveDuelPlayerProgress(
        uid: 'rakip',
        currentQuestionIndex: 7,
        answeredCount: 7,
        correctCount: 3,
        wrongCount: 4,
        finished: false,
      );

      expect(LiveDuelProgressCalculator.compare(first, second), greaterThan(0));
    });

    test('bitmiş maça cevap eklenemez', () {
      const current = LiveDuelPlayerProgress(
        uid: 'levent',
        currentQuestionIndex: 10,
        answeredCount: 10,
        correctCount: 8,
        wrongCount: 2,
        finished: true,
      );

      expect(
        () => LiveDuelProgressCalculator.applyAnswer(
          current: current,
          questionId: 'q11',
          correct: true,
          questionCount: 10,
        ),
        throwsA(isA<LiveDuelProgressException>()),
      );
    });
  });
}
