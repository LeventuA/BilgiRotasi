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

  test('bölüm tipi dağılımı production sözleşmesiyle eşleşir', () {
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

  test('bütün Başlangıç Limanı gridleri 10 satır x 6 sütundur', () {
    for (final level in route.levels) {
      expect(level.rowCount, 10, reason: level.id);
      expect(level.columnCount, 6, reason: level.id);
    }
  });

  test('kelime yoğunluğu 6 kelimeden 10 kelimeye kontrollü artar', () {
    const expectedTargetCounts = <int>[5, 5, 6, 6, 7, 7, 8, 7, 9, 9];
    const expectedBonusCounts = <int>[1, 1, 1, 1, 1, 1, 1, 2, 1, 1];
    const expectedTotals = <int>[6, 6, 7, 7, 8, 8, 9, 9, 10, 10];
    var totalWords = 0;
    for (var index = 0; index < route.levels.length; index++) {
      final level = route.levels[index];
      expect(level.targetWords, hasLength(expectedTargetCounts[index]));
      expect(level.bonusWords, hasLength(expectedBonusCounts[index]));
      final total = level.targetWords.length + level.bonusWords.length;
      expect(total, expectedTotals[index], reason: level.id);
      totalWords += total;
    }
    expect(totalWords, 80);
  });

  test('rota, kelimeler ve bilgi kartları kalite validatorından geçer', () {
    final errors = WordHuntContentValidator.validate(
      route: route,
      infoCards: WordHuntStarterContent.infoCards,
    );
    expect(errors, isEmpty, reason: errors.join('\n'));
  });

  test('bütün target ve bonus kelimeler en az üç harftir', () {
    for (final level in route.levels) {
      for (final word in <String>[...level.targetWords, ...level.bonusWords]) {
        expect(word.trim().runes.length, greaterThanOrEqualTo(3), reason: '${level.id}: $word');
      }
    }
  });

  for (final productionCase in _productionCases) {
    test('Bölüm ${productionCase.levelIndex} 6x10 production sözleşmesi', () {
      final level = route.levels[productionCase.levelIndex - 1];
      expect(level.grid, productionCase.grid, reason: level.id);
      expect(level.rowCount, 10, reason: level.id);
      expect(level.columnCount, 6, reason: level.id);
      expect(level.targetWords, productionCase.targets, reason: level.id);
      expect(level.bonusWords, productionCase.bonus, reason: level.id);
      final canonicalWords = <String>{...level.targetWords, ...level.bonusWords};
      expect(productionCase.paths.map((path) => path.word).toSet(), canonicalWords);

      for (final expected in productionCase.paths) {
        final occurrences = _findPhysicalOccurrences(level.grid, expected.word);
        expect(
          occurrences,
          <String>{_physicalPathKey(expected.cells)},
          reason: '${level.id}: ${expected.word} exactly one physical occurrence',
        );
        final forward = WordHuntPathEngine.evaluate(level: level, path: expected.cells);
        expect(
          forward.kind,
          expected.isBonus ? WordHuntSelectionKind.bonus : WordHuntSelectionKind.target,
          reason: '${level.id}: ${expected.word} forward',
        );
        expect(forward.canonicalWord, expected.word);
        final reverse = WordHuntPathEngine.evaluate(
          level: level,
          path: expected.cells.reversed.toList(growable: false),
        );
        expect(reverse.kind, forward.kind, reason: '${level.id}: ${expected.word} reverse');
        expect(reverse.canonicalWord, expected.word);
      }
    });
  }

  test('Bölüm 8 Bonus Durak iki bonus taşır ve TOP tek hattadır', () {
    final level = route.levels[7];
    expect(level.bonusWords, const <String>['HIZ', 'SKOR']);
    expect(_findPhysicalOccurrences(level.grid, 'TOP'), hasLength(1));
  });

  test('Bölüm 9 ROKET bonusunu korur ve AY geri dönmez', () {
    final level = route.levels[8];
    expect(level.bonusWords, const <String>['ROKET']);
    expect(<String>[...level.targetWords, ...level.bonusWords], isNot(contains('AY')));
    expect(_findPhysicalOccurrences(level.grid, 'ROKET'), hasLength(1));
  });

  test('Bölüm 10 dokuz target + HAZİNE final sözleşmesini taşır', () {
    final level = route.levels[9];
    expect(
      level.targetWords,
      const <String>[
        'PUSULA', 'YOL', 'BİLGİ', 'YILDIZ', 'HEDEF',
        'KEŞİF', 'HARİTA', 'MACERA', 'KAPTAN',
      ],
    );
    expect(level.targetWords, isNot(contains('ROTA')));
    expect(level.bonusWords, const <String>['HAZİNE']);
  });

  test('Bölüm 5 ve final yatay dikey diagonal yön ailelerini birlikte taşır', () {
    for (final levelIndex in <int>[5, 10]) {
      final productionCase = _productionCases[levelIndex - 1];
      final families = productionCase.paths.map((path) {
        if (path.rowDelta == 0) return 'horizontal';
        if (path.columnDelta == 0) return 'vertical';
        return 'diagonal';
      }).toSet();
      expect(families, const <String>{'horizontal', 'vertical', 'diagonal'}, reason: 'Bölüm $levelIndex');
    }
  });

  test('bilgi kartları canonical kelimelerle bağlı ve kimlikleri benzersizdir', () {
    final cardsById = <String, WordHuntInfoCard>{
      for (final card in WordHuntStarterContent.infoCards) card.id: card,
    };
    expect(cardsById, hasLength(WordHuntStarterContent.infoCards.length));
    for (final level in route.levels) {
      final words = <String>{...level.targetWords, ...level.bonusWords}
          .map(WordHuntPathEngine.normalizeWord)
          .toSet();
      for (final cardId in level.infoCardIds) {
        expect(cardsById, contains(cardId), reason: '${level.id}: $cardId');
        expect(words, contains(WordHuntPathEngine.normalizeWord(cardsById[cardId]!.word)), reason: '${level.id}: $cardId');
      }
    }
  });

  test('Bölüm 5 ve Bölüm 10 süre/yıldız eşikleri içerikte korunur', () {
    final level5 = route.levels[4];
    final level10 = route.levels[9];
    expect(level5.timeLimitSeconds, 60);
    expect(level5.starRules.twoStarMaxSeconds, 50);
    expect(level5.starRules.threeStarMaxSeconds, 35);
    expect(level10.timeLimitSeconds, 120);
    expect(level10.starRules.twoStarMaxSeconds, 100);
    expect(level10.starRules.threeStarMaxSeconds, 75);
  });
}

Set<String> _findPhysicalOccurrences(List<String> grid, String canonicalWord) {
  final rows = grid.length;
  final columns = grid.first.runes.length;
  final word = WordHuntPathEngine.normalizeWord(canonicalWord);
  final wordLength = word.runes.length;
  final result = <String>{};
  for (var row = 0; row < rows; row++) {
    for (var column = 0; column < columns; column++) {
      for (final rowDelta in const <int>[-1, 0, 1]) {
        for (final columnDelta in const <int>[-1, 0, 1]) {
          if (rowDelta == 0 && columnDelta == 0) continue;
          final endRow = row + rowDelta * (wordLength - 1);
          final endColumn = column + columnDelta * (wordLength - 1);
          if (endRow < 0 || endRow >= rows || endColumn < 0 || endColumn >= columns) continue;
          final cells = List<WordHuntCell>.generate(
            wordLength,
            (index) => WordHuntCell(row + rowDelta * index, column + columnDelta * index),
            growable: false,
          );
          final read = String.fromCharCodes(
            cells.map((cell) => grid[cell.row].runes.elementAt(cell.column)),
          );
          final normalizedRead = WordHuntPathEngine.normalizeWord(read);
          if (normalizedRead == word || _reverseRunes(normalizedRead) == word) {
            result.add(_physicalPathKey(cells));
          }
        }
      }
    }
  }
  return result;
}

String _reverseRunes(String value) => String.fromCharCodes(value.runes.toList(growable: false).reversed);

String _physicalPathKey(List<WordHuntCell> cells) {
  final a = '${cells.first.row},${cells.first.column}';
  final b = '${cells.last.row},${cells.last.column}';
  return a.compareTo(b) <= 0 ? '$a|$b' : '$b|$a';
}

class _ProductionCase {
  const _ProductionCase({required this.levelIndex, required this.grid, required this.targets, required this.bonus, required this.paths});
  final int levelIndex;
  final List<String> grid;
  final List<String> targets;
  final List<String> bonus;
  final List<_ExpectedPath> paths;
}

class _ExpectedPath {
  const _ExpectedPath(this.word, this.startRow, this.startColumn, this.rowDelta, this.columnDelta, this.length, {this.isBonus = false});
  final String word;
  final int startRow;
  final int startColumn;
  final int rowDelta;
  final int columnDelta;
  final int length;
  final bool isBonus;
  List<WordHuntCell> get cells => List<WordHuntCell>.generate(
        length,
        (index) => WordHuntCell(startRow + rowDelta * index, startColumn + columnDelta * index),
        growable: false,
      );
}

const _productionCases = <_ProductionCase>[
  _ProductionCase(levelIndex: 1, grid: <String>['KALEMI','MASADJ','ELMABR','BCVOİÇ','İÖBRLN','FBCOGK','KCGTİC','OKBAVÖ','ÇGRRÖB','ÖÖOYUN'], targets: <String>['KALEM','MASA','OYUN','ROTA','BİLGİ'], bonus: <String>['ELMA'], paths: <_ExpectedPath>[
    _ExpectedPath('KALEM',0,0,0,1,5), _ExpectedPath('MASA',1,0,0,1,4), _ExpectedPath('OYUN',9,2,0,1,4), _ExpectedPath('ROTA',4,4,1,-1,4), _ExpectedPath('BİLGİ',3,0,1,1,5), _ExpectedPath('ELMA',2,0,0,1,4,isBonus:true),
  ]),
  _ProductionCase(levelIndex: 2, grid: <String>['DIDJRL','EBCVOİ','NÇSİÖM','İDALGA','ZBHNMN','FBİCAK','KCLGRC','OKBVTÖ','ÇGRRIÖ','BGEMİÖ'], targets: <String>['DENİZ','GEMİ','LİMAN','DALGA','SAHİL'], bonus: <String>['MARTI'], paths: <_ExpectedPath>[
    _ExpectedPath('DENİZ',0,0,1,0,5), _ExpectedPath('GEMİ',9,1,0,1,4), _ExpectedPath('LİMAN',0,4,1,0,5), _ExpectedPath('DALGA',3,1,0,1,5), _ExpectedPath('SAHİL',5,5,1,-1,5), _ExpectedPath('MARTI',4,5,1,-1,5,isBonus:true),
  ]),
  _ProductionCase(levelIndex: 3, grid: <String>['VEDÖID','JPATİK','LSAYFA','URRBIL','KECVNE','ODOÇIM','İÖBNSF','BCKKCG','COKBVÖ','ÇGRRÖB'], targets: <String>['KİTAP','OKUL','SINIF','KALEM','DERS','ÖDEV'], bonus: <String>['SAYFA'], paths: <_ExpectedPath>[
    _ExpectedPath('KİTAP',1,5,0,-1,5), _ExpectedPath('OKUL',9,0,-1,0,4), _ExpectedPath('SINIF',6,5,0,-1,5), _ExpectedPath('KALEM',4,0,1,1,5), _ExpectedPath('DERS',0,5,1,-1,4), _ExpectedPath('ÖDEV',0,3,0,-1,4), _ExpectedPath('SAYFA',2,1,0,1,5,isBonus:true),
  ]),
  _ProductionCase(levelIndex: 4, grid: <String>['HEDEFI','SIDJSR','ÜÇZABC','RVALOU','ETMBIŞ','ÇİAÖUO','BNNFBK','CKKCGC','OKBVÖÇ','GRRÖBÖ'], targets: <String>['HIZLI','ZAMAN','SÜRE','HEDEF','ÇABUK','SAAT'], bonus: <String>['KOŞU'], paths: <_ExpectedPath>[
    _ExpectedPath('HIZLI',0,0,1,1,5), _ExpectedPath('ZAMAN',1,1,1,0,5), _ExpectedPath('SÜRE',1,0,1,0,4), _ExpectedPath('HEDEF',0,0,0,1,5), _ExpectedPath('ÇABUK',2,1,0,1,5), _ExpectedPath('SAAT',1,5,1,-1,4), _ExpectedPath('KOŞU',3,5,1,0,4,isBonus:true),
  ]),
  _ProductionCase(levelIndex: 5, grid: <String>['IBDJRS','BACEİA','VŞOLRT','ŞKCAÇÜ','İEKKÖR','MNHBNK','ATFİBİ','NCKKRY','ICKULE','TGCOKB'], targets: <String>['ANKARA','ŞEHİR','TÜRKİYE','BAŞKENT','MECLİS','KULE','KALE'], bonus: <String>['ANIT'], paths: <_ExpectedPath>[
    _ExpectedPath('ANKARA',0,5,1,0,6), _ExpectedPath('ŞEHİR',2,1,1,1,5), _ExpectedPath('TÜRKİYE',2,4,1,0,7), _ExpectedPath('BAŞKENT',1,0,1,0,7), _ExpectedPath('MECLİS',5,0,-1,1,6), _ExpectedPath('KULE',8,2,0,1,4), _ExpectedPath('KALE',3,1,1,0,4), _ExpectedPath('ANIT',6,0,1,0,4,isBonus:true),
  ]),
  _ProductionCase(levelIndex: 6, grid: <String>['IDAĞAÇ','JRBCVİ','OÇİÖLÇ','NEHİRE','BNŞFBK','CEKKAN','YAPRAK','CGPMĞC','OORKOB','TOVÖDÇ'], targets: <String>['DOĞA','ORMAN','AĞAÇ','ÇİÇEK','TOPRAK','YEŞİL','NEHİR'], bonus: <String>['YAPRAK'], paths: <_ExpectedPath>[
    _ExpectedPath('DOĞA',9,5,-1,-1,4), _ExpectedPath('ORMAN',8,1,-1,1,5), _ExpectedPath('AĞAÇ',0,2,0,1,4), _ExpectedPath('ÇİÇEK',0,5,1,0,5), _ExpectedPath('TOPRAK',9,0,-1,0,6), _ExpectedPath('YEŞİL',6,0,-1,1,5), _ExpectedPath('NEHİR',3,0,0,1,5), _ExpectedPath('YAPRAK',6,0,0,1,6,isBonus:true),
  ]),
  _ProductionCase(levelIndex: 7, grid: <String>['IDJRBC','VNOÇİÖ','IBENFB','CRTLKD','KLABOR','KÇNĞAP','OİATEC','VÇKTGC','AEEOKB','NKVÖÇG'], targets: <String>['ARI','ÇİÇEK','BAL','KOVAN','KANAT','POLEN','PETEK','NEKTAR'], bonus: <String>['DOĞA'], paths: <_ExpectedPath>[
    _ExpectedPath('ARI',6,3,-1,1,3), _ExpectedPath('ÇİÇEK',5,1,1,0,5), _ExpectedPath('BAL',4,3,0,1,3), _ExpectedPath('KOVAN',4,0,1,0,5), _ExpectedPath('KANAT',9,1,-1,1,5), _ExpectedPath('POLEN',5,4,-1,0,5), _ExpectedPath('PETEK',5,5,1,-1,5), _ExpectedPath('NEKTAR',9,0,-1,1,6), _ExpectedPath('DOĞA',7,5,-1,-1,4,isBonus:true),
  ]),
  _ProductionCase(levelIndex: 8, grid: <String>['IDJRBC','VOMÇİÖ','BZIHNF','BÇKOŞU','CKAKCU','GLTMCC','OOKNBS','PGUVÖP','ÇYGRRO','OÖSKOR'], targets: <String>['SPOR','TOP','KOŞU','OYUNCU','TAKIM','GOL','MAÇ'], bonus: <String>['HIZ','SKOR'], paths: <_ExpectedPath>[
    _ExpectedPath('SPOR',6,5,1,0,4), _ExpectedPath('TOP',5,2,1,0,3), _ExpectedPath('KOŞU',3,2,0,1,4), _ExpectedPath('OYUNCU',8,5,-1,-1,6), _ExpectedPath('TAKIM',5,1,-1,0,5), _ExpectedPath('GOL',5,0,1,0,3), _ExpectedPath('MAÇ',1,2,1,0,3), _ExpectedPath('HIZ',2,3,0,-1,3,isBonus:true), _ExpectedPath('SKOR',9,2,0,1,4,isBonus:true),
  ]),
  _ProductionCase(levelIndex: 9, grid: <String>['IYUDYU','DÖZDJŞ','RRAÜEG','EÜYNRE','TNÜYMZ','AGBAIE','RERDCG','KSLVOE','ÇIİÖBN','YROKET'], targets: <String>['MARS','UZAY','YILDIZ','GEZEGEN','GÜNEŞ','DÜNYA','UYDU','KRATER','YÖRÜNGE'], bonus: <String>['ROKET'], paths: <_ExpectedPath>[
    _ExpectedPath('MARS',4,4,1,-1,4), _ExpectedPath('UZAY',0,5,0,-1,4), _ExpectedPath('YILDIZ',0,1,1,0,6), _ExpectedPath('GEZEGEN',2,5,1,0,7), _ExpectedPath('GÜNEŞ',2,5,0,-1,5), _ExpectedPath('DÜNYA',1,4,1,0,5), _ExpectedPath('UYDU',0,4,0,-1,4), _ExpectedPath('KRATER',7,0,-1,0,6), _ExpectedPath('YÖRÜNGE',9,0,-1,0,7), _ExpectedPath('ROKET',9,1,0,1,5,isBonus:true),
  ]),
  _ProductionCase(levelIndex: 10, grid: <String>['FEDEHI','ENİZAH','MACERA','BTYDYH','İPJOIA','LARBLR','GKCUDİ','İVSOIT','ÇUİÖZA','PKEŞİF'], targets: <String>['PUSULA','YOL','BİLGİ','YILDIZ','HEDEF','KEŞİF','HARİTA','MACERA','KAPTAN'], bonus: <String>['HAZİNE'], paths: <_ExpectedPath>[
    _ExpectedPath('PUSULA',9,0,-1,0,6), _ExpectedPath('YOL',7,2,-1,1,3), _ExpectedPath('BİLGİ',3,0,1,0,5), _ExpectedPath('YILDIZ',3,2,1,0,6), _ExpectedPath('HEDEF',0,4,0,-1,5), _ExpectedPath('KEŞİF',9,1,0,1,5), _ExpectedPath('HARİTA',3,5,1,0,6), _ExpectedPath('MACERA',2,0,0,1,6), _ExpectedPath('KAPTAN',9,0,-1,1,6), _ExpectedPath('HAZİNE',1,5,0,-1,6,isBonus:true),
  ]),
];
