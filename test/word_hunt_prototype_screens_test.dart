import 'package:bilgi_rotasi/word_hunt/word_hunt_progress.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_screens.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_starter_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('boş ilerlemede yalnız ilk rota durağı açıktır', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: WordHuntRoutePrototypeScreen()),
    );
    await tester.pumpAndSettle();

    expect(find.text('Başlangıç Limanı'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(const Key('word_hunt_level_1')),
        matching: find.byIcon(Icons.lock_rounded),
      ),
      findsNothing,
    );
    expect(
      find.descendant(
        of: find.byKey(const Key('word_hunt_level_2')),
        matching: find.byIcon(Icons.lock_rounded),
      ),
      findsOneWidget,
    );
  });

  testWidgets('önceki bölüm tamamlanınca ikinci durak açılır', (tester) async {
    const progress = WordHuntProgressSnapshot(
      bestStarsByLevelId: <String, int>{'baslangic-1': 2},
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: WordHuntRoutePrototypeScreen(initialProgress: progress),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.descendant(
        of: find.byKey(const Key('word_hunt_level_2')),
        matching: find.byIcon(Icons.lock_rounded),
      ),
      findsNothing,
    );
    expect(find.text('2 / 30'), findsOneWidget);
  });

  testWidgets('parmak sürükleme hedef kelimeyi bulup bölümü tamamlatır', (
    tester,
  ) async {
    final level = WordHuntStarterContent.baslangicLimani.levels.first;
    await tester.pumpWidget(
      MaterialApp(
        home: WordHuntLevelPrototypeScreen(
          level: level,
          infoCards: WordHuntStarterContent.infoCards,
        ),
      ),
    );
    await tester.pump();

    Future<void> dragAcross({
      required int row,
      required int startColumn,
      required int endColumn,
    }) async {
      final rect = tester.getRect(find.byKey(const Key('word_hunt_grid')));
      final cellWidth = rect.width / 6;
      final cellHeight = rect.height / 6;
      final start = Offset(
        rect.left + (startColumn + 0.5) * cellWidth,
        rect.top + (row + 0.5) * cellHeight,
      );
      final end = Offset(
        rect.left + (endColumn + 0.5) * cellWidth,
        rect.top + (row + 0.5) * cellHeight,
      );
      final gesture = await tester.startGesture(start);
      await gesture.moveTo(end);
      await gesture.up();
      await tester.pump();
    }

    await dragAcross(row: 0, startColumn: 0, endColumn: 4);
    expect(find.text('Harika! KALEM bulundu.'), findsOneWidget);

    await dragAcross(row: 1, startColumn: 0, endColumn: 3);
    expect(find.byKey(const Key('word_hunt_finish_button')), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });

  testWidgets('bilgi kartı bağlı kelime bulunduğunda geri bildirim görünür', (
    tester,
  ) async {
    final level = WordHuntStarterContent.baslangicLimani.levels[1];
    await tester.pumpWidget(
      MaterialApp(
        home: WordHuntLevelPrototypeScreen(
          level: level,
          infoCards: WordHuntStarterContent.infoCards,
        ),
      ),
    );
    await tester.pump();

    final rect = tester.getRect(find.byKey(const Key('word_hunt_grid')));
    final cellWidth = rect.width / 6;
    final cellHeight = rect.height / 6;
    final start = Offset(
      rect.left + 0.5 * cellWidth,
      rect.top + 0.5 * cellHeight,
    );
    final end = Offset(
      rect.left + 4.5 * cellWidth,
      rect.top + 0.5 * cellHeight,
    );

    final gesture = await tester.startGesture(start);
    await gesture.moveTo(end);
    await gesture.up();
    await tester.pump();

    expect(find.text('Bilgi kartı açıldı: Deniz'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });
}
