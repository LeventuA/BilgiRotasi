import 'package:bilgi_rotasi/word_hunt/word_hunt_progress.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_route_map_v2_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const proofProgress = WordHuntProgressSnapshot(
    bestStarsByLevelId: <String, int>{
      'baslangic-1': 3,
      'baslangic-2': 3,
      'baslangic-3': 3,
      'baslangic-4': 3,
      'baslangic-5': 3,
      'baslangic-6': 3,
      'baslangic-7': 3,
    },
  );

  testWidgets('v2 route map renders the approved ten-stop composition', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: WordHuntRouteMapV2Screen(progress: proofProgress),
      ),
    );

    expect(find.text('KELİME AVI'), findsOneWidget);
    expect(find.text('BAŞLANGIÇ LİMANI'), findsOneWidget);
    expect(find.text('MEYDAN OKUMA'), findsOneWidget);
    expect(find.text('BONUS DURAK'), findsOneWidget);
    expect(find.text('ROTA FİNALİ'), findsOneWidget);
    expect(find.byKey(const Key('word_hunt_v2_scene')), findsOneWidget);
    expect(find.byKey(const Key('word_hunt_v2_compass')), findsOneWidget);
    expect(find.byKey(const Key('word_hunt_v2_book')), findsOneWidget);

    for (var index = 1; index <= 10; index++) {
      expect(
        find.byKey(Key('word_hunt_v2_level_$index')),
        findsOneWidget,
      );
    }
  });

  testWidgets('v2 keeps progression semantics instead of faking unlock state', (
    tester,
  ) async {
    var tapped = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: WordHuntRouteMapV2Screen(
          progress: proofProgress,
          onLevelTap: (index) => tapped = index,
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('word_hunt_v2_level_8')));
    await tester.pump();
    expect(tapped, 8);

    tapped = 0;
    await tester.tap(find.byKey(const Key('word_hunt_v2_level_9')));
    await tester.pump();
    expect(tapped, 0);
  });

  testWidgets('v2 remains overflow-free on a narrow Android-sized surface', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      const MaterialApp(
        home: WordHuntRouteMapV2Screen(progress: proofProgress),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byKey(const Key('word_hunt_v2_scene')), findsOneWidget);
  });
}
