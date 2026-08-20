import 'package:bilgi_rotasi/word_hunt/word_hunt_models.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_path.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  WordHuntLevelDefinition level({
    List<String>? grid,
    List<String>? targets,
    List<String>? bonus,
  }) {
    return WordHuntLevelDefinition(
      id: 'baslangic-1',
      routeId: 'baslangic-limani',
      index: 1,
      type: WordHuntLevelType.normal,
      grid: grid ?? const <String>['ANKARA', 'ELMALI', 'DENİZX'],
      targetWords: targets ?? const <String>['ANKARA'],
      bonusWords: bonus ?? const <String>['ELMA'],
      starRules: const WordHuntStarRules(),
    );
  }

  test('yatay düz seçim hedef kelimeyi bulur', () {
    final result = WordHuntPathEngine.evaluate(
      level: level(),
      path: const <WordHuntCell>[
        WordHuntCell(0, 0),
        WordHuntCell(0, 1),
        WordHuntCell(0, 2),
        WordHuntCell(0, 3),
        WordHuntCell(0, 4),
        WordHuntCell(0, 5),
      ],
    );

    expect(result.kind, WordHuntSelectionKind.target);
    expect(result.canonicalWord, 'ANKARA');
    expect(result.accepted, isTrue);
  });

  test('kelime ters yönden sürüklenince de kabul edilir', () {
    final result = WordHuntPathEngine.evaluate(
      level: level(),
      path: const <WordHuntCell>[
        WordHuntCell(0, 5),
        WordHuntCell(0, 4),
        WordHuntCell(0, 3),
        WordHuntCell(0, 2),
        WordHuntCell(0, 1),
        WordHuntCell(0, 0),
      ],
    );

    expect(result.kind, WordHuntSelectionKind.target);
    expect(result.selectedWord, 'ARAKNA');
    expect(result.canonicalWord, 'ANKARA');
  });

  test('çapraz sekiz yön seçimi okunur', () {
    final result = WordHuntPathEngine.evaluate(
      level: level(
        grid: const <String>['İXXX', 'XSXX', 'XXİX', 'XXX M'.replaceAll(' ', '')],
        targets: const <String>['İSİM'],
      ),
      path: const <WordHuntCell>[
        WordHuntCell(0, 0),
        WordHuntCell(1, 1),
        WordHuntCell(2, 2),
        WordHuntCell(3, 3),
      ],
    );

    expect(result.kind, WordHuntSelectionKind.target);
    expect(result.canonicalWord, 'İSİM');
  });

  test('klasik modda kıvrılan yol reddedilir', () {
    final read = WordHuntPathEngine.readWord(
      grid: const <String>['ABC', 'DEF', 'GHI'],
      path: const <WordHuntCell>[
        WordHuntCell(0, 0),
        WordHuntCell(0, 1),
        WordHuntCell(1, 1),
      ],
    );

    expect(read.isValid, isFalse);
    expect(read.error, contains('düz çizgide'));
  });

  test('gelecek zincir modunda kıvrılan bitişik yol kabul edilir', () {
    final read = WordHuntPathEngine.readWord(
      grid: const <String>['ABC', 'DEF', 'GHI'],
      path: const <WordHuntCell>[
        WordHuntCell(0, 0),
        WordHuntCell(0, 1),
        WordHuntCell(1, 1),
        WordHuntCell(2, 2),
      ],
      rule: WordHuntPathRule.adjacentEightDirections,
    );

    expect(read.isValid, isTrue);
    expect(read.word, 'ABEI');
  });

  test('aynı hücre ikinci kez kullanılamaz', () {
    final read = WordHuntPathEngine.readWord(
      grid: const <String>['ABC', 'DEF'],
      path: const <WordHuntCell>[
        WordHuntCell(0, 0),
        WordHuntCell(0, 1),
        WordHuntCell(0, 0),
      ],
      rule: WordHuntPathRule.adjacentEightDirections,
    );

    expect(read.isValid, isFalse);
    expect(read.error, contains('tekrar kullanılamaz'));
  });

  test('grid dışındaki hücre fail-closed reddedilir', () {
    final read = WordHuntPathEngine.readWord(
      grid: const <String>['ABC'],
      path: const <WordHuntCell>[WordHuntCell(0, 3)],
    );

    expect(read.isValid, isFalse);
    expect(read.error, contains('grid dışında'));
  });

  test('bonus kelime hedef kelimeden ayrı sınıflanır', () {
    final result = WordHuntPathEngine.evaluate(
      level: level(),
      path: const <WordHuntCell>[
        WordHuntCell(1, 0),
        WordHuntCell(1, 1),
        WordHuntCell(1, 2),
        WordHuntCell(1, 3),
      ],
    );

    expect(result.kind, WordHuntSelectionKind.bonus);
    expect(result.canonicalWord, 'ELMA');
  });

  test('daha önce bulunan kelime ikinci kez ödül üretmez', () {
    final result = WordHuntPathEngine.evaluate(
      level: level(),
      path: const <WordHuntCell>[
        WordHuntCell(0, 0),
        WordHuntCell(0, 1),
        WordHuntCell(0, 2),
        WordHuntCell(0, 3),
        WordHuntCell(0, 4),
        WordHuntCell(0, 5),
      ],
      foundTargetWords: const <String>{'ankara'},
    );

    expect(result.kind, WordHuntSelectionKind.alreadyFound);
    expect(result.accepted, isFalse);
    expect(result.canonicalWord, 'ANKARA');
  });

  test('Türkçe i ve ı normalizasyonu deterministiktir', () {
    expect(WordHuntPathEngine.normalizeWord('izmir'), 'İZMİR');
    expect(WordHuntPathEngine.normalizeWord('kırmızı'), 'KIRMIZI');
  });
}
