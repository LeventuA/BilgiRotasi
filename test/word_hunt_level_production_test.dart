import 'package:bilgi_rotasi/word_hunt/word_hunt_models.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_screens.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_starter_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> pumpLevel(
    WidgetTester tester, {
    WordHuntLevelDefinition? level,
    DateTime Function()? now,
  }) async {
    await tester.binding.setSurfaceSize(const Size(720, 1280));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        home: WordHuntLevelProductionScreen(
          level: level ?? WordHuntStarterContent.baslangicLimani.levels.first,
          infoCards: WordHuntStarterContent.infoCards,
          now: now,
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

  Future<void> completeLevelOneTargets(WidgetTester tester) async {
    await dragCells(tester, startRow: 0, startColumn: 0, endRow: 0, endColumn: 4);
    await dragCells(tester, startRow: 1, startColumn: 0, endRow: 1, endColumn: 3);
    await dragCells(tester, startRow: 9, startColumn: 2, endRow: 9, endColumn: 5);
    await dragCells(tester, startRow: 4, startColumn: 4, endRow: 7, endColumn: 1);
    await dragCells(tester, startRow: 3, startColumn: 0, endRow: 7, endColumn: 4);
  }

  testWidgets('production Bölüm 1 10x6 grid ve 0/5 başlangıç durumunu gösterir', (tester) async {
    await pumpLevel(tester);
    expect(find.byKey(const Key('word_hunt_production_screen')), findsOneWidget);
    expect(find.text('Bölüm 1'), findsOneWidget);
    expect(find.text('0/5'), findsOneWidget);
    expect(find.text('0 hata'), findsOneWidget);
    expect(find.text('KALEM'), findsOneWidget);
    expect(find.text('BİLGİ'), findsOneWidget);
    expect(find.text('✦ ELMA'), findsOneWidget);
    expect(find.byKey(const Key('word_hunt_production_cell_9_5')), findsOneWidget);
    final rect = tester.getRect(find.byKey(const Key('word_hunt_production_grid')));
    expect(rect.width / rect.height, closeTo(0.6, 0.01));
    expect(tester.takeException(), isNull);
  });

  testWidgets('target reverse wrong ve bonus ayrışır', (tester) async {
    await pumpLevel(tester);
    await dragCells(tester, startRow: 0, startColumn: 4, endRow: 0, endColumn: 0);
    expect(find.text('1/5'), findsOneWidget);
    expect(find.byKey(const Key('word_hunt_production_target_KALEM_found')), findsOneWidget);

    await dragCells(tester, startRow: 3, startColumn: 0, endRow: 3, endColumn: 1);
    expect(find.text('1 hata'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 300));

    await dragCells(tester, startRow: 2, startColumn: 0, endRow: 2, endColumn: 3);
    expect(find.byKey(const Key('word_hunt_production_bonus_ELMA_found')), findsOneWidget);
    expect(find.byKey(const Key('word_hunt_production_finish')), findsNothing);
  });

  testWidgets('targetlar bitince süre ve hata donar, grid bonus için açık kalır', (tester) async {
    var now = DateTime(2026, 8, 28, 12);
    await pumpLevel(tester, now: () => now);

    await dragCells(tester, startRow: 3, startColumn: 0, endRow: 3, endColumn: 1);
    expect(find.text('1 hata'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 300));

    now = now.add(const Duration(seconds: 10));
    await completeLevelOneTargets(tester);
    expect(find.text('5/5'), findsOneWidget);
    expect(find.byKey(const Key('word_hunt_production_finish')), findsOneWidget);
    expect(find.byKey(const Key('word_hunt_production_result_dialog')), findsNothing);

    final frozen = tester
        .widget<Text>(find.byKey(const Key('word_hunt_production_elapsed_text')))
        .data;
    expect(frozen, '10s');

    now = now.add(const Duration(seconds: 20));
    await tester.pump(const Duration(seconds: 2));
    expect(
      tester.widget<Text>(find.byKey(const Key('word_hunt_production_elapsed_text'))).data,
      frozen,
    );

    await dragCells(tester, startRow: 3, startColumn: 0, endRow: 3, endColumn: 1);
    expect(find.text('1 hata'), findsOneWidget);

    await dragCells(tester, startRow: 2, startColumn: 0, endRow: 2, endColumn: 3);
    expect(find.byKey(const Key('word_hunt_production_bonus_ELMA_found')), findsOneWidget);
    expect(find.byKey(const Key('word_hunt_production_result_dialog')), findsNothing);

    await tester.ensureVisible(find.byKey(const Key('word_hunt_production_finish')));
    await tester.tap(find.byKey(const Key('word_hunt_production_finish')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('word_hunt_production_result_dialog')), findsOneWidget);
    expect(find.text('10 saniye'), findsOneWidget);
    expect(find.text('1 hata'), findsWidgets);
    expect(
      tester.widget<Icon>(find.byKey(const Key('word_hunt_production_result_star_2'))).icon,
      Icons.star_rounded,
    );
    expect(
      tester.widget<Icon>(find.byKey(const Key('word_hunt_production_result_star_3'))).icon,
      Icons.star_outline_rounded,
    );
  });

  testWidgets('timeLimit production oynanışı hard fail ile kapatmaz', (tester) async {
    var now = DateTime(2026, 8, 28, 12);
    final level = WordHuntStarterContent.baslangicLimani.levels[4];
    await pumpLevel(tester, level: level, now: () => now);
    now = now.add(const Duration(seconds: 65));
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('65s'), findsOneWidget);

    await dragCells(tester, startRow: 0, startColumn: 5, endRow: 5, endColumn: 5);
    expect(find.byKey(const Key('word_hunt_production_target_ANKARA_found')), findsOneWidget);
    expect(find.text('1/7'), findsOneWidget);
  });

  testWidgets('anlamlı attempt geri çıkış onayı verir', (tester) async {
    await pumpLevel(tester);
    await dragCells(tester, startRow: 0, startColumn: 0, endRow: 0, endColumn: 1);
    await tester.tap(find.byKey(const Key('word_hunt_production_back')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('word_hunt_production_exit_dialog')), findsOneWidget);
    await tester.tap(find.byKey(const Key('word_hunt_production_exit_continue')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('word_hunt_production_screen')), findsOneWidget);
  });
}
