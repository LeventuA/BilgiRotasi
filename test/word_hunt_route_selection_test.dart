import 'package:bilgi_rotasi/word_hunt/word_hunt_gokyuzu_content.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_production_entry_screen.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_progress.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_progress_codec.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  testWidgets('production giriş iki rotalı seçiciyi gösterir', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: WordHuntProductionEntryScreen()),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('word_hunt_route_selector')), findsOneWidget);
    expect(
      find.byKey(const Key('word_hunt_route_card_starter')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('word_hunt_route_card_gokyuzu')),
      findsOneWidget,
    );
    expect(find.text('Başlangıç Limanı'), findsOneWidget);
    expect(find.text('Gökyüzü Adaları'), findsOneWidget);
    expect(find.text('0 / 18'), findsOneWidget);
  });

  testWidgets('Başlangıç Limanı seçimi mevcut production rotayı açar', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: WordHuntProductionEntryScreen()),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('word_hunt_route_card_starter')));
    await tester.pump();

    expect(
      find.byKey(const Key('word_hunt_production_entry_route')),
      findsOneWidget,
    );
  });

  testWidgets('18 Başlangıç yıldızı Gökyüzü Adaları kapısını açar', (
    tester,
  ) async {
    const progress = WordHuntProgressSnapshot(
      bestStarsByLevelId: <String, int>{
        'baslangic-1': 3,
        'baslangic-2': 3,
        'baslangic-3': 3,
        'baslangic-4': 3,
        'baslangic-5': 3,
        'baslangic-6': 3,
      },
    );
    final raw = WordHuntProgressCodec.encode(
      progress,
      ownerScope: WordHuntProgressCodec.scopeForUid(null),
    );
    SharedPreferences.setMockInitialValues(<String, Object>{
      WordHuntProgressCodec.storageKeyForUid(null): raw,
    });

    await tester.pumpWidget(
      const MaterialApp(home: WordHuntProductionEntryScreen()),
    );
    await tester.pumpAndSettle();

    expect(find.text('18 / 30'), findsOneWidget);
    await tester.tap(find.byKey(const Key('word_hunt_route_card_gokyuzu')));
    await tester.pump();

    expect(
      find.byKey(const Key('word_hunt_production_entry_gokyuzu_route')),
      findsOneWidget,
    );
  });

  testWidgets('QA doğrudan Gökyüzü rotasını seçici olmadan açabilir', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: WordHuntProductionEntryScreen(
          route: WordHuntGokyuzuContent.gokyuzuAdalari,
          infoCards: WordHuntGokyuzuContent.infoCards,
          routeSelectionEnabled: false,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('word_hunt_route_selector')), findsNothing);
    expect(
      find.byKey(const Key('word_hunt_production_entry_gokyuzu_route')),
      findsOneWidget,
    );
  });
}
