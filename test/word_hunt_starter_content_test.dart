import 'package:bilgi_rotasi/word_hunt/word_hunt_content_validator.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_models.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_path.dart';
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

  test('Bölüm 1 canonical content snapshotı değişmemiştir', () {
    final level = route.levels.first;

    expect(level.id, 'baslangic-1');
    expect(level.grid, const <String>[
      'KALEMS',
      'MASALI',
      'ELMALI',
      'BİLGİN',
      'OYUNCU',
      'ROTASI',
    ]);
    expect(level.targetWords, const <String>['KALEM', 'MASA']);
    expect(level.bonusWords, const <String>['ELMA']);
    expect(level.infoCardIds, isEmpty);
    expect(level.timeLimitSeconds, isNull);
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
        expect(
          word.trim().runes.length,
          greaterThanOrEqualTo(3),
          reason: '${level.id}: $word',
        );
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
    expect(_countStraightOccurrences(level.grid, 'TOP'), 1);
  });

  test('Bölüm 9 bonusu AY değil, tek hatlı ROKET olur', () {
    final level = route.levels[8];

    expect(level.id, 'baslangic-9');
    expect(level.bonusWords, <String>['ROKET']);
    expect(level.bonusWords, isNot(contains('AY')));
    expect(_countStraightOccurrences(level.grid, 'ROKET'), 1);
  });

  test('Bölüm 9 target ve bonus listesinde AY yoktur', () {
    final level = route.levels[8];

    expect(<String>[
      ...level.targetWords,
      ...level.bonusWords,
    ], isNot(contains('AY')));
  });

  test('Bölüm 10 canonical ROTA yerine YOL kullanır', () {
    final level = route.levels[9];

    expect(level.targetWords, const <String>['PUSULA', 'YOL', 'BİLGİ']);
    expect(level.targetWords, isNot(contains('ROTA')));
    expect(level.bonusWords, const <String>['YILDIZ']);
    expect(_countStraightOccurrences(level.grid, 'YOL'), 1);
  });

  for (final productionCase in _productionCases) {
    test(
      'Bölüm ${productionCase.levelIndex} production grid/path sözleşmesi',
      () {
        final level = route.levels[productionCase.levelIndex - 1];

        expect(level.grid, productionCase.grid, reason: level.id);
        expect(level.rowCount, 6, reason: level.id);
        expect(level.columnCount, 6, reason: level.id);
        expect(
          <String>{...level.targetWords, ...level.bonusWords},
          productionCase.paths.map((path) => path.word).toSet(),
          reason: '${level.id}: canonical kelime listesi',
        );

        for (final expected in productionCase.paths) {
          final physicalOccurrences = _findStraightOccurrences(
            level.grid,
            expected.word,
          );
          expect(
            physicalOccurrences,
            hasLength(1),
            reason: '${level.id}: ${expected.word} exactly one occurrence',
          );
          expect(
            physicalOccurrences.single,
            expected.cells,
            reason: '${level.id}: ${expected.word} intended path',
          );

          final forward = WordHuntPathEngine.evaluate(
            level: level,
            path: expected.cells,
          );
          expect(
            forward.kind,
            expected.isBonus
                ? WordHuntSelectionKind.bonus
                : WordHuntSelectionKind.target,
            reason: '${level.id}: ${expected.word} forward kind',
          );
          expect(forward.canonicalWord, expected.word);

          final opposite = WordHuntPathEngine.evaluate(
            level: level,
            path: expected.cells.reversed.toList(growable: false),
          );
          expect(
            opposite.kind,
            forward.kind,
            reason: '${level.id}: ${expected.word} opposite gesture kind',
          );
          expect(
            opposite.canonicalWord,
            expected.word,
            reason: '${level.id}: ${expected.word} opposite canonical word',
          );

          expect(expected.rowDelta, inInclusiveRange(-1, 1));
          expect(expected.columnDelta, inInclusiveRange(-1, 1));
          expect(expected.rowDelta != 0 || expected.columnDelta != 0, isTrue);
        }

        final cardsById = <String, WordHuntInfoCard>{
          for (final card in WordHuntStarterContent.infoCards) card.id: card,
        };
        final allowedWords = <String>{
          ...level.targetWords.map(WordHuntPathEngine.normalizeWord),
          ...level.bonusWords.map(WordHuntPathEngine.normalizeWord),
        };
        for (final cardId in level.infoCardIds) {
          expect(cardsById, contains(cardId), reason: '${level.id}: $cardId');
          expect(
            allowedWords,
            contains(WordHuntPathEngine.normalizeWord(cardsById[cardId]!.word)),
            reason: '${level.id}: $cardId kelime bütünlüğü',
          );
        }
      },
    );
  }

  test('bilgi kartı kimlikleri benzersizdir', () {
    final ids =
        WordHuntStarterContent.infoCards.map((card) => card.id).toList();
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
      containsAll(<String>['PUSULA', 'YOL', 'BİLGİ']),
    );
  });

  test('bilgi kartları rota boyunca kategori çeşitliliği sağlar', () {
    final categories =
        WordHuntStarterContent.infoCards.map((card) => card.category).toSet();

    expect(
      categories,
      containsAll(<String>['Doğa', 'Kültür', 'Türkiye', 'Uzay', 'Keşif']),
    );
    expect(WordHuntStarterContent.infoCards, hasLength(6));
  });
}

const _productionCases = <_ProductionContentCase>[
  _ProductionContentCase(
    levelIndex: 2,
    grid: <String>['DDLELA', 'EUEEİM', 'NSGAML', 'İIAIAG', 'ZİAANİ', 'İGEMİD'],
    paths: <_ExpectedWordPath>[
      _ExpectedWordPath('DENİZ', 0, 0, 1, 0, 5),
      _ExpectedWordPath('GEMİ', 5, 1, 0, 1, 4),
      _ExpectedWordPath('LİMAN', 0, 4, 1, 0, 5, isBonus: true),
    ],
  ),
  _ProductionContentCase(
    levelIndex: 3,
    grid: <String>['GRİÖNY', 'FPATİK', 'LIDOSD', 'USNÖBB', 'KİCIRG', 'OCADSİ'],
    paths: <_ExpectedWordPath>[
      _ExpectedWordPath('KİTAP', 1, 5, 0, -1, 5),
      _ExpectedWordPath('OKUL', 5, 0, -1, 0, 4),
      _ExpectedWordPath('SINIF', 5, 4, -1, -1, 5, isBonus: true),
    ],
  ),
  _ProductionContentCase(
    levelIndex: 4,
    grid: <String>['HCHYNF', 'SIYSÇZ', 'BDZUYA', 'EOÇLHM', 'BAENIA', 'KERÜSN'],
    paths: <_ExpectedWordPath>[
      _ExpectedWordPath('HIZLI', 0, 0, 1, 1, 5),
      _ExpectedWordPath('ZAMAN', 1, 5, 1, 0, 5),
      _ExpectedWordPath('SÜRE', 5, 4, 0, -1, 4, isBonus: true),
    ],
  ),
  _ProductionContentCase(
    levelIndex: 5,
    grid: <String>['AAKİİŞ', 'ENÜERE', 'YEKEÜH', 'KLNAEİ', 'EATŞRR', 'NKRKAA'],
    paths: <_ExpectedWordPath>[
      _ExpectedWordPath('ANKARA', 0, 0, 1, 1, 6),
      _ExpectedWordPath('ŞEHİR', 0, 5, 1, 0, 5),
      _ExpectedWordPath('KALE', 5, 1, -1, 0, 4, isBonus: true),
    ],
  ),
  _ProductionContentCase(
    levelIndex: 6,
    grid: <String>['İNAMRO', 'TOPÇLŞ', 'İKNAEA', 'ŞÇĞKŞĞ', 'AOYOKA', 'DEHHNÇ'],
    paths: <_ExpectedWordPath>[
      _ExpectedWordPath('DOĞA', 5, 0, -1, 1, 4),
      _ExpectedWordPath('ORMAN', 0, 5, 0, -1, 5),
      _ExpectedWordPath('AĞAÇ', 2, 5, 1, 0, 4, isBonus: true),
    ],
  ),
  _ProductionContentCase(
    levelIndex: 7,
    grid: <String>['ELLABP', 'NEEPNK', 'PDOKEA', 'VNIÇAP', 'ERİKLV', 'AÇPADĞ'],
    paths: <_ExpectedWordPath>[
      _ExpectedWordPath('ARI', 5, 0, -1, 1, 3),
      _ExpectedWordPath('ÇİÇEK', 5, 1, -1, 1, 5),
      _ExpectedWordPath('BAL', 0, 4, 0, -1, 3, isBonus: true),
    ],
  ),
  _ProductionContentCase(
    levelIndex: 8,
    grid: <String>['SAAAIA', 'KPZKHR', 'YAOUAA', 'ILORİP', 'ZAUTKO', 'IUŞOKT'],
    paths: <_ExpectedWordPath>[
      _ExpectedWordPath('SPOR', 0, 0, 1, 1, 4),
      _ExpectedWordPath('TOP', 5, 5, -1, 0, 3),
      _ExpectedWordPath('KOŞU', 5, 4, 0, -1, 4, isBonus: true),
    ],
  ),
  _ProductionContentCase(
    levelIndex: 9,
    grid: <String>['NRIZDN', 'NSONÜR', 'YYRKGE', 'AÖEAEY', 'ZÜÜÜMT', 'UZEGÜL'],
    paths: <_ExpectedWordPath>[
      _ExpectedWordPath('MARS', 4, 4, -1, -1, 4),
      _ExpectedWordPath('UZAY', 5, 0, -1, 0, 4),
      _ExpectedWordPath('ROKET', 0, 1, 1, 1, 5, isBonus: true),
    ],
  ),
  _ProductionContentCase(
    levelIndex: 10,
    grid: <String>['PUSULA', 'KİYABT', 'EEOİİN', 'YILDIZ', 'AGHAİE', 'İKKERE'],
    paths: <_ExpectedWordPath>[
      _ExpectedWordPath('PUSULA', 0, 0, 0, 1, 6),
      _ExpectedWordPath('YOL', 1, 2, 1, 0, 3),
      _ExpectedWordPath('BİLGİ', 1, 4, 1, -1, 5),
      _ExpectedWordPath('YILDIZ', 3, 0, 0, 1, 6, isBonus: true),
    ],
  ),
];

class _ProductionContentCase {
  const _ProductionContentCase({
    required this.levelIndex,
    required this.grid,
    required this.paths,
  });

  final int levelIndex;
  final List<String> grid;
  final List<_ExpectedWordPath> paths;
}

class _ExpectedWordPath {
  const _ExpectedWordPath(
    this.word,
    this.startRow,
    this.startColumn,
    this.rowDelta,
    this.columnDelta,
    this.length, {
    this.isBonus = false,
  });

  final String word;
  final int startRow;
  final int startColumn;
  final int rowDelta;
  final int columnDelta;
  final int length;
  final bool isBonus;

  List<WordHuntCell> get cells => List<WordHuntCell>.generate(
    length,
    (index) => WordHuntCell(
      startRow + rowDelta * index,
      startColumn + columnDelta * index,
    ),
    growable: false,
  );
}

int _countStraightOccurrences(List<String> grid, String candidate) {
  return _findStraightOccurrences(grid, candidate).length;
}

List<List<WordHuntCell>> _findStraightOccurrences(
  List<String> grid,
  String candidate,
) {
  final rows = grid.map((row) => row.runes.toList(growable: false)).toList();
  final word = WordHuntPathEngine.normalizeWord(
    candidate,
  ).runes.toList(growable: false);
  if (rows.isEmpty || word.isEmpty) return const <List<WordHuntCell>>[];

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

  final occurrences = <List<WordHuntCell>>[];
  for (var startRow = 0; startRow < rows.length; startRow++) {
    for (
      var startColumn = 0;
      startColumn < rows[startRow].length;
      startColumn++
    ) {
      for (final direction in directions) {
        var matches = true;
        for (var index = 0; index < word.length; index++) {
          final row = startRow + direction.$1 * index;
          final column = startColumn + direction.$2 * index;
          if (row < 0 ||
              row >= rows.length ||
              column < 0 ||
              column >= rows[row].length ||
              WordHuntPathEngine.normalizeWord(
                    String.fromCharCode(rows[row][column]),
                  ).runes.single !=
                  word[index]) {
            matches = false;
            break;
          }
        }
        if (matches) {
          occurrences.add(
            List<WordHuntCell>.generate(
              word.length,
              (index) => WordHuntCell(
                startRow + direction.$1 * index,
                startColumn + direction.$2 * index,
              ),
              growable: false,
            ),
          );
        }
      }
    }
  }

  return occurrences;
}
