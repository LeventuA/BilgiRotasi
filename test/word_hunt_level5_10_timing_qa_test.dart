import 'package:bilgi_rotasi/word_hunt/word_hunt_scoring.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_starter_content.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final route = WordHuntStarterContent.baslangicLimani;
  final level5 = route.levels[4];
  final level10 = route.levels[9];

  int starsFor(level, int elapsedSeconds, int mistakes) {
    return WordHuntScoringEngine.calculate(
      level: level,
      foundTargetCount: level.targetWords.length,
      mistakes: mistakes,
      elapsedSeconds: elapsedSeconds,
    ).stars;
  }

  test('Bölüm 5 süre sınırları gerçek scoring engine ile kilitlidir', () {
    expect(level5.timeLimitSeconds, 60);
    expect(starsFor(level5, 35, 0), 3);
    expect(starsFor(level5, 36, 0), 2);
    expect(starsFor(level5, 50, 0), 2);
    expect(starsFor(level5, 51, 0), 1);
    expect(starsFor(level5, 60, 0), 1);
    expect(starsFor(level5, 61, 0), 1);
  });

  test('Bölüm 10 süre sınırları gerçek scoring engine ile kilitlidir', () {
    expect(level10.timeLimitSeconds, 120);
    expect(starsFor(level10, 75, 0), 3);
    expect(starsFor(level10, 76, 0), 2);
    expect(starsFor(level10, 100, 0), 2);
    expect(starsFor(level10, 101, 0), 1);
    expect(starsFor(level10, 120, 0), 1);
    expect(starsFor(level10, 121, 0), 1);
  });

  test('Bölüm 5 hata sınırları gerçek scoring engine ile kilitlidir', () {
    expect(starsFor(level5, 30, 0), 3);
    expect(starsFor(level5, 30, 1), 2);
    expect(starsFor(level5, 30, 2), 1);
  });

  test('Bölüm 10 hata sınırları gerçek scoring engine ile kilitlidir', () {
    expect(starsFor(level10, 60, 0), 3);
    expect(starsFor(level10, 90, 2), 2);
    expect(starsFor(level10, 90, 3), 1);
  });

  test('scoring engine timeLimitSeconds sonrasında da tamamlanmış skor üretir', () {
    final afterLevel5Limit = WordHuntScoringEngine.calculate(
      level: level5,
      foundTargetCount: level5.targetWords.length,
      mistakes: 0,
      elapsedSeconds: 61,
    );
    final afterLevel10Limit = WordHuntScoringEngine.calculate(
      level: level10,
      foundTargetCount: level10.targetWords.length,
      mistakes: 0,
      elapsedSeconds: 121,
    );

    expect(afterLevel5Limit.completed, isTrue);
    expect(afterLevel5Limit.stars, 1);
    expect(afterLevel10Limit.completed, isTrue);
    expect(afterLevel10Limit.stars, 1);
  });
}
