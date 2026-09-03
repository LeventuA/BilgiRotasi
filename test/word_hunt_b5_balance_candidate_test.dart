import 'package:bilgi_rotasi/word_hunt/word_hunt_models.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_path.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_starter_content.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final level = WordHuntStarterContent.baslangicLimani.levels[4];

  test('B5 60s tuning adayı içerik sözleşmesini korur', () {
    expect(level.index, 5);
    expect(level.type, WordHuntLevelType.challenge);
    expect(level.rowCount, 8);
    expect(level.columnCount, 8);
    expect(level.targetWords, const <String>[
      'ANKARA',
      'ŞEHİR',
      'TÜRKİYE',
      'BAŞKENT',
      'MECLİS',
      'KULE',
      'KALE',
    ]);
    expect(level.bonusWords, const <String>['ANIT']);
    expect(level.timeLimitSeconds, 60);
    expect(level.starRules.twoStarMaxSeconds, 50);
    expect(level.starRules.threeStarMaxSeconds, 35);
    expect(level.starRules.twoStarMaxMistakes, 1);
    expect(level.starRules.threeStarMaxMistakes, 0);
  });

  test('B5 tuning adayı her kelimeyi tek fiziksel hatta taşır', () {
    const expected = <String, String>{
      'ANKARA': '0,0|0,5',
      'TÜRKİYE': '1,0|1,6',
      'BAŞKENT': '0,7|6,7',
      'MECLİS': '2,1|7,6',
      'ŞEHİR': '7,0|7,4',
      'KULE': '2,6|5,6',
      'KALE': '5,0|5,3',
      'ANIT': '2,5|5,5',
    };

    for (final entry in expected.entries) {
      expect(
        _findPhysicalOccurrences(level.grid, entry.key),
        <String>{entry.value},
        reason: entry.key,
      );
    }
  });

  test('B5 tuning adayı yatay dikey diagonal yön ailelerini korur', () {
    const paths = <List<int>>[
      <int>[0, 0, 0, 5],
      <int>[1, 0, 1, 6],
      <int>[0, 7, 6, 7],
      <int>[2, 1, 7, 6],
      <int>[7, 0, 7, 4],
      <int>[2, 6, 5, 6],
      <int>[5, 0, 5, 3],
      <int>[2, 5, 5, 5],
    ];
    final families = <String>{};
    for (final path in paths) {
      final rowDelta = path[2] - path[0];
      final columnDelta = path[3] - path[1];
      if (rowDelta == 0) {
        families.add('horizontal');
      } else if (columnDelta == 0) {
        families.add('vertical');
      } else {
        families.add('diagonal');
      }
    }
    expect(families, const <String>{'horizontal', 'vertical', 'diagonal'});
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
          if (endRow < 0 ||
              endRow >= rows ||
              endColumn < 0 ||
              endColumn >= columns) {
            continue;
          }
          final cells = List<WordHuntCell>.generate(
            wordLength,
            (index) => WordHuntCell(
              row + rowDelta * index,
              column + columnDelta * index,
            ),
            growable: false,
          );
          final read = String.fromCharCodes(
            cells.map((cell) => grid[cell.row].runes.elementAt(cell.column)),
          );
          final normalizedRead = WordHuntPathEngine.normalizeWord(read);
          if (normalizedRead == word || _reverseRunes(normalizedRead) == word) {
            final a = '${cells.first.row},${cells.first.column}';
            final b = '${cells.last.row},${cells.last.column}';
            result.add(a.compareTo(b) <= 0 ? '$a|$b' : '$b|$a');
          }
        }
      }
    }
  }
  return result;
}

String _reverseRunes(String value) =>
    String.fromCharCodes(value.runes.toList(growable: false).reversed);
