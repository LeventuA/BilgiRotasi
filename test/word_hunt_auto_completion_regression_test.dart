import 'package:bilgi_rotasi/word_hunt/word_hunt_models.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_path.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_screens.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_starter_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> pumpLevel(
    WidgetTester tester,
    WordHuntLevelDefinition level, {
    required int session,
  }) async {
    await tester.binding.setSurfaceSize(const Size(720, 1280));
    await tester.pumpWidget(
      MaterialApp(
        key: ValueKey<String>('word_hunt_auto_completion_session_$session'),
        home: WordHuntLevelProductionScreen(
          level: level,
          infoCards: WordHuntStarterContent.infoCards,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> dragCells(
    WidgetTester tester,
    List<int> endpoints,
  ) async {
    final start = tester.getCenter(
      find.byKey(
        Key('word_hunt_production_cell_${endpoints[0]}_${endpoints[1]}'),
      ),
    );
    final end = tester.getCenter(
      find.byKey(
        Key('word_hunt_production_cell_${endpoints[2]}_${endpoints[3]}'),
      ),
    );
    final gesture = await tester.startGesture(start);
    await gesture.moveTo(end);
    await gesture.up();
    await tester.pump();
  }

  List<int> findStraightPath(
    WordHuntLevelDefinition level,
    String word,
  ) {
    final target = WordHuntPathEngine.normalizeWord(word);
    final length = word.runes.length;
    const directions = <List<int>>[
      [-1, -1],
      [-1, 0],
      [-1, 1],
      [0, -1],
      [0, 1],
      [1, -1],
      [1, 0],
      [1, 1],
    ];

    for (var row = 0; row < level.rowCount; row++) {
      for (var column = 0; column < level.columnCount; column++) {
        for (final direction in directions) {
          final endRow = row + direction[0] * (length - 1);
          final endColumn = column + direction[1] * (length - 1);
          if (endRow < 0 ||
              endRow >= level.rowCount ||
              endColumn < 0 ||
              endColumn >= level.columnCount) {
            continue;
          }

          final buffer = StringBuffer();
          for (var step = 0; step < length; step++) {
            final currentRow = row + direction[0] * step;
            final currentColumn = column + direction[1] * step;
            buffer.write(
              String.fromCharCode(
                level.grid[currentRow].runes.elementAt(currentColumn),
              ),
            );
          }
          if (WordHuntPathEngine.normalizeWord(buffer.toString()) == target) {
            return <int>[row, column, endRow, endColumn];
          }
        }
      }
    }
    throw StateError('Straight path bulunamadı: ${level.id} / $word');
  }

  Future<void> completeTargets(
    WidgetTester tester,
    WordHuntLevelDefinition level,
  ) async {
    for (final word in level.targetWords) {
      await dragCells(tester, findStraightPath(level, word));
    }
    await tester.pumpAndSettle();
  }

  testWidgets(
    'B5 -> B10 -> yeniden B5 her yeni oyun oturumunda sonucu otomatik bir kez açar',
    (tester) async {
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final levels = WordHuntStarterContent.baslangicLimani.levels;
      final sequence = <WordHuntLevelDefinition>[levels[4], levels[9], levels[4]];

      for (var session = 0; session < sequence.length; session++) {
        final level = sequence[session];
        await pumpLevel(tester, level, session: session);
        expect(
          find.byKey(const Key('word_hunt_production_result_dialog')),
          findsNothing,
        );

        await completeTargets(tester, level);

        expect(
          find.byKey(const Key('word_hunt_production_result_dialog')),
          findsOneWidget,
          reason: '${level.id} tamamlanınca sonuç otomatik açılmalı',
        );
        expect(find.text('Bölüm Tamamlandı'), findsOneWidget);

        await tester.pump(const Duration(milliseconds: 500));
        expect(
          find.byKey(const Key('word_hunt_production_result_dialog')),
          findsOneWidget,
          reason: '${level.id} aynı oturumda ikinci dialog açmamalı',
        );
      }
    },
  );
}
