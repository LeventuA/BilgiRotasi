import 'package:bilgi_rotasi/word_hunt/word_hunt_screens.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_starter_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Başlangıç Limanı production ekranı liman tema katmanını korur', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(411, 731));
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

    expect(
      find.byKey(const Key('word_hunt_production_harbor_theme')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('word_hunt_production_harbor_warm_filter')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('word_hunt_production_harbor_overlay')),
      findsOneWidget,
    );

    // Core production sözleşmesi tema katmanının altında aynen kalmalı.
    expect(
      find.byKey(const Key('word_hunt_production_screen')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('word_hunt_production_grid')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('word_hunt_production_cell_7_7')),
      findsOneWidget,
    );
    expect(find.text('Bölüm 1'), findsOneWidget);
    expect(find.text('Başlangıç Limanı'), findsOneWidget);
    expect(find.text('0/5'), findsOneWidget);
    expect(find.text('✦ ELMA'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
