import 'package:bilgi_rotasi/word_hunt/word_hunt_screens.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_starter_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> pumpLevel(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(540, 960));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        home: WordHuntLevelProductionScreen(
          level: WordHuntStarterContent.baslangicLimani.levels.first,
          infoCards: WordHuntStarterContent.infoCards,
        ),
      ),
    );
    await tester.pump();
  }

  Future<void> dragCells(
    WidgetTester tester, {
    required int startRow,
    required int startColumn,
    required int endRow,
    required int endColumn,
  }) async {
    final start = tester.getCenter(
      find.byKey(Key('word_hunt_production_cell_${startRow}_$startColumn')),
    );
    final end = tester.getCenter(
      find.byKey(Key('word_hunt_production_cell_${endRow}_$endColumn')),
    );
    final gesture = await tester.startGesture(start);
    await gesture.moveTo(end);
    await gesture.up();
    await tester.pump();
  }

  testWidgets('ilk production render canonical Bölüm 1 durumunu gösterir', (
    tester,
  ) async {
    await pumpLevel(tester);

    expect(
      find.byKey(const Key('word_hunt_production_screen')),
      findsOneWidget,
    );
    expect(find.text('Bölüm 1'), findsOneWidget);
    expect(find.text('Başlangıç Limanı'), findsOneWidget);
    expect(find.text('0/2'), findsOneWidget);
    expect(find.text('0 hata'), findsOneWidget);
    expect(find.text('KALEM'), findsOneWidget);
    expect(find.text('MASA'), findsOneWidget);
    expect(find.text('✦ ELMA'), findsOneWidget);
    expect(find.byKey(const Key('word_hunt_production_finish')), findsNothing);
  });

  testWidgets('target, reverse, repeated, wrong, invalid ve bonus ayrışır', (
    tester,
  ) async {
    await pumpLevel(tester);

    await dragCells(
      tester,
      startRow: 0,
      startColumn: 4,
      endRow: 0,
      endColumn: 0,
    );
    expect(find.text('1/2'), findsOneWidget);
    expect(find.text('0 hata'), findsOneWidget);
    expect(
      find.byKey(const Key('word_hunt_production_target_KALEM_found')),
      findsOneWidget,
    );

    await dragCells(
      tester,
      startRow: 0,
      startColumn: 0,
      endRow: 0,
      endColumn: 4,
    );
    expect(find.text('1/2'), findsOneWidget);
    expect(find.text('0 hata'), findsOneWidget);

    await dragCells(
      tester,
      startRow: 0,
      startColumn: 0,
      endRow: 0,
      endColumn: 1,
    );
    expect(find.text('1 hata'), findsOneWidget);

    await dragCells(
      tester,
      startRow: 0,
      startColumn: 0,
      endRow: 1,
      endColumn: 2,
    );
    expect(find.text('1 hata'), findsOneWidget);

    await dragCells(
      tester,
      startRow: 2,
      startColumn: 0,
      endRow: 2,
      endColumn: 3,
    );
    expect(find.text('1/2'), findsOneWidget);
    expect(
      find.byKey(const Key('word_hunt_production_bonus_ELMA_found')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('word_hunt_production_finish')), findsNothing);
  });

  testWidgets('completion freeze ve idempotent sonuç üç yıldız döndürür', (
    tester,
  ) async {
    WordHuntLevelPlayResult? result;
    await tester.binding.setSurfaceSize(const Size(540, 960));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder:
              (context) => Scaffold(
                body: Center(
                  child: FilledButton(
                    key: const Key('open_level'),
                    onPressed: () async {
                      result = await Navigator.of(context).push(
                        MaterialPageRoute<WordHuntLevelPlayResult>(
                          builder:
                              (_) => WordHuntLevelProductionScreen(
                                level:
                                    WordHuntStarterContent
                                        .baslangicLimani
                                        .levels
                                        .first,
                                infoCards: WordHuntStarterContent.infoCards,
                              ),
                        ),
                      );
                    },
                    child: const Text('Aç'),
                  ),
                ),
              ),
        ),
      ),
    );
    await tester.tap(find.byKey(const Key('open_level')));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 2));

    await dragCells(
      tester,
      startRow: 0,
      startColumn: 0,
      endRow: 0,
      endColumn: 4,
    );
    await dragCells(
      tester,
      startRow: 1,
      startColumn: 0,
      endRow: 1,
      endColumn: 3,
    );
    expect(find.text('2/2'), findsOneWidget);
    expect(
      find.byKey(const Key('word_hunt_production_finish')),
      findsOneWidget,
    );
    final frozen =
        tester
            .widget<Text>(
              find.byKey(const Key('word_hunt_production_elapsed_text')),
            )
            .data;
    await tester.pump(const Duration(seconds: 3));
    expect(
      tester
          .widget<Text>(
            find.byKey(const Key('word_hunt_production_elapsed_text')),
          )
          .data,
      frozen,
    );

    await tester.tap(find.byKey(const Key('word_hunt_production_finish')));
    await tester.tap(
      find.byKey(const Key('word_hunt_production_finish')),
      warnIfMissed: false,
    );
    await tester.pumpAndSettle();
    expect(
      find.byKey(const Key('word_hunt_production_result_dialog')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('word_hunt_production_result_star_3')),
      findsOneWidget,
    );
    await tester.tap(
      find.byKey(const Key('word_hunt_production_return_route')),
    );
    await tester.pumpAndSettle();

    expect(result?.levelId, 'baslangic-1');
    expect(result?.stars, 3);
    expect(result?.unlockedInfoCardIds, isEmpty);
  });

  testWidgets('production result mistake tierlarına göre 2 ve 1 yıldız verir', (
    tester,
  ) async {
    Future<void> openLevel() async {
      await tester.binding.setSurfaceSize(const Size(540, 960));
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder:
                (context) => Scaffold(
                  body: FilledButton(
                    key: const Key('open_level_for_tier'),
                    onPressed:
                        () => Navigator.of(context).push(
                          MaterialPageRoute<WordHuntLevelPlayResult>(
                            builder:
                                (_) => WordHuntLevelProductionScreen(
                                  level:
                                      WordHuntStarterContent
                                          .baslangicLimani
                                          .levels
                                          .first,
                                  infoCards: WordHuntStarterContent.infoCards,
                                ),
                          ),
                        ),
                    child: const Text('Aç'),
                  ),
                ),
          ),
        ),
      );
      await tester.tap(find.byKey(const Key('open_level_for_tier')));
      await tester.pumpAndSettle();
    }

    Future<void> completeWithMistakes(int mistakeCount) async {
      for (var index = 0; index < mistakeCount; index++) {
        await dragCells(
          tester,
          startRow: 0,
          startColumn: 0,
          endRow: 0,
          endColumn: 1,
        );
      }
      await dragCells(
        tester,
        startRow: 0,
        startColumn: 0,
        endRow: 0,
        endColumn: 4,
      );
      await dragCells(
        tester,
        startRow: 1,
        startColumn: 0,
        endRow: 1,
        endColumn: 3,
      );
      await tester.ensureVisible(
        find.byKey(const Key('word_hunt_production_finish')),
      );
      await tester.tap(find.byKey(const Key('word_hunt_production_finish')));
      await tester.pumpAndSettle();
    }

    addTearDown(() => tester.binding.setSurfaceSize(null));
    await openLevel();
    await completeWithMistakes(2);
    expect(
      tester
          .widget<Icon>(
            find.byKey(const Key('word_hunt_production_result_star_2')),
          )
          .icon,
      Icons.star_rounded,
    );
    expect(
      tester
          .widget<Icon>(
            find.byKey(const Key('word_hunt_production_result_star_3')),
          )
          .icon,
      Icons.star_outline_rounded,
    );

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
    await openLevel();
    await completeWithMistakes(3);
    expect(
      tester
          .widget<Icon>(
            find.byKey(const Key('word_hunt_production_result_star_1')),
          )
          .icon,
      Icons.star_rounded,
    );
    expect(
      tester
          .widget<Icon>(
            find.byKey(const Key('word_hunt_production_result_star_2')),
          )
          .icon,
      Icons.star_outline_rounded,
    );
  });

  testWidgets('anlamlı attempt geri çıkış onayı verir ve null döner', (
    tester,
  ) async {
    await pumpLevel(tester);
    await dragCells(
      tester,
      startRow: 0,
      startColumn: 0,
      endRow: 0,
      endColumn: 1,
    );

    await tester.tap(find.byKey(const Key('word_hunt_production_back')));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const Key('word_hunt_production_exit_dialog')),
      findsOneWidget,
    );
    await tester.tap(
      find.byKey(const Key('word_hunt_production_exit_continue')),
    );
    await tester.pumpAndSettle();
    expect(
      find.byKey(const Key('word_hunt_production_screen')),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const Key('word_hunt_production_back')));
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const Key('word_hunt_production_exit_confirm')),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('word_hunt_production_screen')), findsNothing);
    await tester.pump(const Duration(seconds: 2));
    expect(tester.takeException(), isNull);
  });
}
