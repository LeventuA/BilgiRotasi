import 'package:bilgi_rotasi/word_hunt/word_hunt_content_validator.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_models.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_starter_content.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const route = WordHuntStarterContent.baslangicLimani;

  test('Başlangıç Limanı tam 10 bölüm ve 30 yıldız kapasitesi taşır', () {
    expect(route.levels, hasLength(10));
    expect(route.maximumStars, 30);
    expect(route.unlockStarsRequired, 18);
    expect(route.levels.first.index, 1);
    expect(route.levels.last.index, 10);
  });

  test('bölüm tipi dağılımı v1 sözleşmesiyle eşleşir', () {
    final counts = <WordHuntLevelType, int>{};
    for (final level in route.levels) {
      counts[level.type] = (counts[level.type] ?? 0) + 1;
    }

    expect(counts[WordHuntLevelType.normal], 7);
    expect(counts[WordHuntLevelType.challenge], 1);
    expect(counts[WordHuntLevelType.bonus], 1);
    expect(counts[WordHuntLevelType.routeFinal], 1);
    expect(route.levels[4].type, WordHuntLevelType.challenge);
    expect(route.levels[7].type, WordHuntLevelType.bonus);
    expect(route.levels.last.type, WordHuntLevelType.routeFinal);
  });

  test('bütün başlangıç gridleri 6x6 boyutundadır', () {
    for (final level in route.levels) {
      expect(level.rowCount, 6, reason: level.id);
      expect(level.columnCount, 6, reason: level.id);
    }
  });

  test('rota, kelimeler ve bilgi kartları kalite validatorından geçer', () {
    final errors = WordHuntContentValidator.validate(
      route: route,
      infoCards: WordHuntStarterContent.infoCards,
    );

    expect(errors, isEmpty, reason: errors.join('\n'));
  });

  test('bilgi kartı kimlikleri benzersizdir', () {
    final ids = WordHuntStarterContent.infoCards.map((card) => card.id).toList();
    expect(ids.toSet().length, ids.length);
  });

  test('ilk rota öğretimden finale doğru kontrollü biçimde ilerler', () {
    expect(route.levels[0].targetWords, containsAll(<String>['KALEM', 'MASA']));
    expect(route.levels[3].type, WordHuntLevelType.normal);
    expect(route.levels[4].type, WordHuntLevelType.challenge);
    expect(route.levels[4].timeLimitSeconds, 60);
    expect(route.levels[6].type, WordHuntLevelType.normal);
    expect(route.levels[7].type, WordHuntLevelType.bonus);
    expect(route.levels[8].type, WordHuntLevelType.normal);
    expect(route.levels[8].timeLimitSeconds, isNull);
    expect(
      route.levels[9].targetWords,
      containsAll(<String>['PUSULA', 'ROTA', 'BİLGİ']),
    );
  });

  test('bilgi kartları rota boyunca kategori çeşitliliği sağlar', () {
    final categories = WordHuntStarterContent.infoCards
        .map((card) => card.category)
        .toSet();

    expect(categories, containsAll(<String>['Doğa', 'Kültür', 'Türkiye', 'Uzay', 'Keşif']));
    expect(WordHuntStarterContent.infoCards, hasLength(6));
  });
}
