import 'package:bilgi_rotasi/word_hunt/word_hunt_path.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_starter_content.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final level = WordHuntStarterContent.baslangicLimani.levels.first;

  WordHuntSelectionResult evaluate(
    List<WordHuntCell> path, {
    Set<String> foundTargets = const <String>{},
    Set<String> foundBonus = const <String>{},
  }) => WordHuntPathEngine.evaluate(
    level: level,
    path: path,
    foundTargetWords: foundTargets,
    foundBonusWords: foundBonus,
  );

  test('Bölüm 1 canonical KALEM ileri ve ters yönde hedef olur', () {
    const forward = <WordHuntCell>[
      WordHuntCell(0, 0), WordHuntCell(0, 1), WordHuntCell(0, 2),
      WordHuntCell(0, 3), WordHuntCell(0, 4),
    ];
    final reverse = forward.reversed.toList(growable: false);
    expect(evaluate(forward).kind, WordHuntSelectionKind.target);
    expect(evaluate(forward).canonicalWord, 'KALEM');
    expect(evaluate(reverse).kind, WordHuntSelectionKind.target);
    expect(evaluate(reverse).canonicalWord, 'KALEM');
  });

  test('Bölüm 1 yatay dikey/diagonal ve reverse targetları çözer', () {
    const masa = <WordHuntCell>[
      WordHuntCell(1, 0), WordHuntCell(1, 1), WordHuntCell(1, 2), WordHuntCell(1, 3),
    ];
    const oyun = <WordHuntCell>[
      WordHuntCell(9, 2), WordHuntCell(9, 3), WordHuntCell(9, 4), WordHuntCell(9, 5),
    ];
    const rota = <WordHuntCell>[
      WordHuntCell(4, 4), WordHuntCell(5, 3), WordHuntCell(6, 2), WordHuntCell(7, 1),
    ];
    const bilgi = <WordHuntCell>[
      WordHuntCell(3, 0), WordHuntCell(4, 1), WordHuntCell(5, 2),
      WordHuntCell(6, 3), WordHuntCell(7, 4),
    ];
    for (final entry in <(String, List<WordHuntCell>)>[
      ('MASA', masa), ('OYUN', oyun), ('ROTA', rota), ('BİLGİ', bilgi),
    ]) {
      expect(evaluate(entry.$2).kind, WordHuntSelectionKind.target);
      expect(evaluate(entry.$2).canonicalWord, entry.$1);
      expect(evaluate(entry.$2.reversed.toList()).canonicalWord, entry.$1);
    }
  });

  test('ELMA bonus olur ve bonus completion için zorunlu değildir', () {
    const elma = <WordHuntCell>[
      WordHuntCell(2, 0), WordHuntCell(2, 1), WordHuntCell(2, 2), WordHuntCell(2, 3),
    ];
    expect(evaluate(elma).kind, WordHuntSelectionKind.bonus);
    expect(evaluate(elma).canonicalWord, 'ELMA');
    expect(level.targetWords, <String>['KALEM', 'MASA', 'OYUN', 'ROTA', 'BİLGİ']);
    expect(level.bonusWords, <String>['ELMA']);
  });

  test('tekrar target ödül üretmez; bilinmeyen ve kıvrılan yol ayrışır', () {
    const kalem = <WordHuntCell>[
      WordHuntCell(0, 0), WordHuntCell(0, 1), WordHuntCell(0, 2),
      WordHuntCell(0, 3), WordHuntCell(0, 4),
    ];
    expect(
      evaluate(kalem, foundTargets: const <String>{'KALEM'}).kind,
      WordHuntSelectionKind.alreadyFound,
    );
    expect(
      evaluate(const <WordHuntCell>[WordHuntCell(0, 0), WordHuntCell(0, 1)]).kind,
      WordHuntSelectionKind.notAWord,
    );
    expect(
      evaluate(const <WordHuntCell>[
        WordHuntCell(0, 0), WordHuntCell(0, 1), WordHuntCell(1, 1),
      ]).kind,
      WordHuntSelectionKind.invalidPath,
    );
  });
}
