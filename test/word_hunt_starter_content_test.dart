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

  test('bütün hedef ve bonus kelimeler en az 3 harftir', () {
    for (final level in route.levels) {
      for (final word in <String>[...level.targetWords, ...level.bonusWords]) {
        expect(word.trim().runes.length, greaterThanOrEqualTo(3), reason: '${level.id}: $word');
      }
    }
  });

  test('validator iki harfli hedef ve bonus kelimeleri reddeder', () {
    const level = WordHuntLevelDefinition(
      id: 'min-length-test',
      routeId: 'test-route',
      index: 1,
      type: WordHuntLevelType.normal,
      grid: <String>['AYX', 'OKX', 'XXX'],
      targetWords: <String>['AY'],
      bonusWords: <String>['OK'],
      starRules: WordHuntStarRules(),
    );

    final errors = WordHuntDefinitionValidator.validateLevel(level);

    expect(errors, contains('targetWords en az 3 harf olmalı: AY'));
    expect(errors, contains('bonusWords en az 3 harf olmalı: OK'));
  });

  test('Bölüm 8 TOP yalnız tek fiziksel çözüm hattında bulunur', () {
    final level = route.levels[7];

    expect(level.id, 'baslangic-8');
    expect(level.grid[3], 'RAKİBİ');
    expect(_countStraightOccurrences(level.grid, 'TOP'), 1);
  });

  test('Bölüm 9 bonusu AY değil, tek hatlı ROKET olur', () {
    final level = route.levels[8];

    expect(level.id, 'baslangic-9');
    expect(level.bonusWords, <String>['ROKET']);
    expect(level.bonusWords, isNot(contains('AY')));
    expect(_countStraightOccurrences(level.grid, 'ROKET'), 1);
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

int _countStraightOccurrences(List<String> grid, String candidate) {
  final rows = grid.map((row) => row.runes.toList(growable: false)).toList();
  final word = candidate.runes.toList(growable: false);
  if (rows.isEmpty || word.isEmpty) return 0;

  const directions = <(int, int)>[
    (-1, -1),
    (-1, 0),
    (-1, 1),
    (0, -1),
    (0, 1),
    (1, -1),
    (1, 0),
    (1, 1),
  ];

  var count = 0;
  for (var startRow = 0; startRow < rows.length; startRow++) {
    for (var startColumn = 0; startColumn < rows[startRow].length; startColumn++) {
      for (final direction in directions) {
        var matches = true;
        for (var index = 0; index < word.length; index++) {
          final row = startRow + direction.$1 * index;
          final column = startColumn + direction.$2 * index;
          if (row < 0 ||
              row >= rows.length ||
              column < 0 ||
              column >= rows[row].length ||
              rows[row][column] != word[index]) {
            matches = false;
            break;
          }
        }
        if (matches) count++;
      }
    }
  }

  return count;
}
