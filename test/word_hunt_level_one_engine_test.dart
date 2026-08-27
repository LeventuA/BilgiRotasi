import 'package:bilgi_rotasi/word_hunt/word_hunt_path.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_starter_content.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final level = WordHuntStarterContent.baslangicLimani.levels.first;

  WordHuntSelectionResult evaluate(
    List<WordHuntCell> path, {
    Set<String> foundTargets = const <String>{},
    Set<String> foundBonus = const <String>{},
  }) {
    return WordHuntPathEngine.evaluate(
      level: level,
      path: path,
      foundTargetWords: foundTargets,
      foundBonusWords: foundBonus,
    );
  }

  test('Bölüm 1 canonical KALEM ileri ve ters yönde hedef olur', () {
    const forward = <WordHuntCell>[
      WordHuntCell(0, 0),
      WordHuntCell(0, 1),
      WordHuntCell(0, 2),
      WordHuntCell(0, 3),
      WordHuntCell(0, 4),
    ];
    const reverse = <WordHuntCell>[
      WordHuntCell(0, 4),
      WordHuntCell(0, 3),
      WordHuntCell(0, 2),
      WordHuntCell(0, 1),
      WordHuntCell(0, 0),
    ];

    expect(evaluate(forward).kind, WordHuntSelectionKind.target);
    expect(evaluate(forward).canonicalWord, 'KALEM');
    expect(evaluate(reverse).kind, WordHuntSelectionKind.target);
    expect(evaluate(reverse).canonicalWord, 'KALEM');
  });

  test('Bölüm 1 canonical MASA hedef ve ELMA bonus olur', () {
    const masa = <WordHuntCell>[
      WordHuntCell(1, 0),
      WordHuntCell(1, 1),
      WordHuntCell(1, 2),
      WordHuntCell(1, 3),
    ];
    const elma = <WordHuntCell>[
      WordHuntCell(2, 0),
      WordHuntCell(2, 1),
      WordHuntCell(2, 2),
      WordHuntCell(2, 3),
    ];

    expect(evaluate(masa).kind, WordHuntSelectionKind.target);
    expect(evaluate(masa).canonicalWord, 'MASA');
    expect(evaluate(elma).kind, WordHuntSelectionKind.bonus);
    expect(evaluate(elma).canonicalWord, 'ELMA');
  });

  test('bonus completion için gerekmez ve tekrar KALEM ödül üretmez', () {
    const kalem = <WordHuntCell>[
      WordHuntCell(0, 0),
      WordHuntCell(0, 1),
      WordHuntCell(0, 2),
      WordHuntCell(0, 3),
      WordHuntCell(0, 4),
    ];

    final repeated = evaluate(kalem, foundTargets: const <String>{'KALEM'});
    expect(repeated.kind, WordHuntSelectionKind.alreadyFound);
    expect(level.targetWords, <String>['KALEM', 'MASA']);
    expect(level.bonusWords, <String>['ELMA']);
  });

  test('straight bilinmeyen seçim notAWord, kıvrılan yol invalidPath olur', () {
    final unknown = evaluate(const <WordHuntCell>[
      WordHuntCell(0, 0),
      WordHuntCell(0, 1),
    ]);
    final invalid = evaluate(const <WordHuntCell>[
      WordHuntCell(0, 0),
      WordHuntCell(0, 1),
      WordHuntCell(1, 1),
    ]);

    expect(unknown.kind, WordHuntSelectionKind.notAWord);
    expect(invalid.kind, WordHuntSelectionKind.invalidPath);
  });
}
