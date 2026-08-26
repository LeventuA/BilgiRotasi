import 'package:bilgi_rotasi/word_hunt/word_hunt_models.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_scoring.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  WordHuntLevelDefinition level({
    WordHuntStarRules rules = const WordHuntStarRules(
      twoStarMaxMistakes: 2,
      threeStarMaxMistakes: 0,
    ),
  }) {
    return WordHuntLevelDefinition(
      id: 'level-1',
      routeId: 'route-1',
      index: 1,
      type: WordHuntLevelType.normal,
      grid: const <String>['ABC', 'DEF', 'GHI'],
      targetWords: const <String>['ABC', 'DEF'],
      starRules: rules,
    );
  }

  test('bütün hedefler bulunmadan yıldız verilmez', () {
    final result = WordHuntScoringEngine.calculate(
      level: level(),
      foundTargetCount: 1,
      mistakes: 0,
      elapsedSeconds: 10,
    );

    expect(result.completed, isFalse);
    expect(result.stars, 0);
  });

  test('hatasız tamamlanan normal bölüm üç yıldız verir', () {
    final result = WordHuntScoringEngine.calculate(
      level: level(),
      foundTargetCount: 2,
      mistakes: 0,
      elapsedSeconds: 40,
    );

    expect(result.completed, isTrue);
    expect(result.stars, 3);
  });

  test('iki hata iki yıldız eşiğinde kalır', () {
    final result = WordHuntScoringEngine.calculate(
      level: level(),
      foundTargetCount: 2,
      mistakes: 2,
      elapsedSeconds: 40,
    );

    expect(result.stars, 2);
  });

  test('iki yıldız eşiğini de aşan tamamlanmış bölüm bir yıldız verir', () {
    final result = WordHuntScoringEngine.calculate(
      level: level(),
      foundTargetCount: 2,
      mistakes: 3,
      elapsedSeconds: 40,
    );

    expect(result.stars, 1);
  });

  test('meydan okumada hata ve süre koşullarının ikisi de sağlanır', () {
    final challenge = level(
      rules: const WordHuntStarRules(
        twoStarMaxMistakes: 1,
        threeStarMaxMistakes: 0,
        twoStarMaxSeconds: 50,
        threeStarMaxSeconds: 35,
      ),
    );

    expect(
      WordHuntScoringEngine.calculate(
        level: challenge,
        foundTargetCount: 2,
        mistakes: 0,
        elapsedSeconds: 35,
      ).stars,
      3,
    );
    expect(
      WordHuntScoringEngine.calculate(
        level: challenge,
        foundTargetCount: 2,
        mistakes: 1,
        elapsedSeconds: 45,
      ).stars,
      2,
    );
    expect(
      WordHuntScoringEngine.calculate(
        level: challenge,
        foundTargetCount: 2,
        mistakes: 0,
        elapsedSeconds: 55,
      ).stars,
      1,
    );
  });

  test('negatif sayaç girdileri sıfıra sabitlenir', () {
    final result = WordHuntScoringEngine.calculate(
      level: level(),
      foundTargetCount: 2,
      mistakes: -3,
      elapsedSeconds: -10,
    );

    expect(result.stars, 3);
  });
}
