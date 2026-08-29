import 'package:bilgi_rotasi/word_hunt/word_hunt_gameplay_flow.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('production rota Bölüm 1 açılışında Başlangıç Limanı temasını kullanır', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(540, 960));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const MaterialApp(home: WordHuntGameplayFlow()));
    await tester.pump();

    await tester.tap(find.byKey(const Key('word_hunt_pixel_proof_level_1')));
    await tester.tap(
      find.byKey(const Key('word_hunt_pixel_proof_level_1')),
      warnIfMissed: false,
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('word_hunt_baslangic_limani_theme')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('word_hunt_production_screen')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('word_hunt_production_grid')),
      findsOneWidget,
    );
    expect(find.text('Bölüm 1'), findsOneWidget);
    expect(find.text('Başlangıç Limanı'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
