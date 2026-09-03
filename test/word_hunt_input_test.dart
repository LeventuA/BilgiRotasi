import 'package:bilgi_rotasi/word_hunt/word_hunt_input.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_path.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_starter_content.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final level = WordHuntStarterContent.baslangicLimani.levels[4];

  List<WordHuntCell> horizontal(int start, int end) => <WordHuntCell>[
    for (var column = start; column <= end; column++) WordHuntCell(0, column),
  ];

  test('kelime olamayacak kadar kısa temas seçim sayılmaz', () {
    final result = WordHuntInputResolver.resolve(
      level: level,
      path: horizontal(0, 1),
    );

    expect(result.isIgnored, isTrue);
  });

  test('hedefin ardındaki tek fazla hücre güvenle kırpılır', () {
    final result = WordHuntInputResolver.resolve(
      level: level,
      path: horizontal(0, 6),
    );

    expect(result.path, horizontal(0, 5));
    expect(result.result?.kind, WordHuntSelectionKind.target);
    expect(result.result?.canonicalWord, 'ANKARA');
  });

  test('iki fazla hücre otomatik düzeltilmez', () {
    final result = WordHuntInputResolver.resolve(
      level: level,
      path: horizontal(0, 7),
    );

    expect(result.path, horizontal(0, 7));
    expect(result.result?.kind, WordHuntSelectionKind.notAWord);
  });

  test('anlamlı gerçek yanlış seçim hata adayı olarak korunur', () {
    final result = WordHuntInputResolver.resolve(
      level: level,
      path: <WordHuntCell>[
        for (var column = 0; column <= 3; column++) WordHuntCell(2, column),
      ],
    );

    expect(result.isIgnored, isFalse);
    expect(result.result?.kind, WordHuntSelectionKind.notAWord);
  });
}
