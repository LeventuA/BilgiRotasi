import 'package:bilgi_rotasi/word_hunt/word_hunt_gokyuzu_master_art_screen.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_models.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_screens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final route = WordHuntRouteDefinition(
    id: 'gokyuzu-adalari',
    title: 'Gökyüzü Adaları',
    theme: 'gokyuzu',
    unlockStarsRequired: 18,
    routeRewardId: 'badge-gokyuzu-kasifi',
    levels: <WordHuntLevelDefinition>[_level(1)],
  );

  testWidgets('Gökyüzü route keeps edge controls inside safe viewport', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    await tester.pumpWidget(
      MaterialApp(
        builder:
            (context, child) => MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(padding: const EdgeInsets.only(top: 28, bottom: 24)),
              child: child!,
            ),
        home: WordHuntGokyuzuMasterArtScreen(route: route),
      ),
    );
    await tester.pump();
    final fitted = tester.widget<FittedBox>(
      find.byKey(const Key('word_hunt_gokyuzu_master_art_fitted_box')),
    );
    expect(fitted.fit, BoxFit.fill);
    for (final key in <Key>[
      const Key('word_hunt_gokyuzu_master_art_back'),
      const Key('word_hunt_gokyuzu_master_art_info'),
      const Key('word_hunt_gokyuzu_master_art_compass'),
      const Key('word_hunt_gokyuzu_master_art_book'),
    ]) {
      final rect = tester.getRect(find.byKey(key));
      expect(rect.left, greaterThanOrEqualTo(0));
      expect(rect.right, lessThanOrEqualTo(360));
      expect(rect.top, greaterThanOrEqualTo(28));
      expect(rect.bottom, lessThanOrEqualTo(776));
    }
  });

  testWidgets('Gökyüzü gameplay uses route title and level scene', (
    tester,
  ) async {
    const background = 'assets/word_hunt/gokyuzu_adalari/scene_level_04.webp';
    await tester.pumpWidget(
      const MaterialApp(
        home: WordHuntLevelProductionScreen(
          level: WordHuntLevelDefinition(
            id: 'gokyuzu-4',
            routeId: 'gokyuzu-adalari',
            index: 4,
            type: WordHuntLevelType.normal,
            grid: <String>['ABC', 'DEF', 'GHI'],
            targetWords: <String>['ABC'],
            starRules: WordHuntStarRules(),
          ),
          infoCards: <WordHuntInfoCard>[],
          backgroundAsset: background,
          routeTitle: 'Gökyüzü Adaları',
        ),
      ),
    );
    await tester.pump();
    expect(find.text('Gökyüzü Adaları'), findsOneWidget);
    final images = tester.widgetList<Image>(find.byType(Image));
    expect(
      images.any(
        (image) =>
            image.image is AssetImage &&
            (image.image as AssetImage).assetName == background,
      ),
      isTrue,
    );
    expect(find.text('Başlangıç Limanı'), findsNothing);
  });
}

WordHuntLevelDefinition _level(int index) => WordHuntLevelDefinition(
  id: 'gokyuzu-$index',
  routeId: 'gokyuzu-adalari',
  index: index,
  type: WordHuntLevelType.normal,
  grid: const <String>['ABC', 'DEF', 'GHI'],
  targetWords: const <String>['ABC'],
  starRules: const WordHuntStarRules(),
);
