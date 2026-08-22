import 'package:bilgi_rotasi/word_hunt/word_hunt_models.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_route_stop.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

WordHuntLevelDefinition _level(int index, WordHuntLevelType type) {
  return WordHuntLevelDefinition(
    id: 'test-$index',
    routeId: 'test-route',
    index: index,
    type: type,
    grid: const <String>['ABC', 'DEF', 'GHI'],
    targetWords: const <String>['ABC'],
    starRules: const WordHuntStarRules(),
  );
}

void main() {
  const metrics = WordHuntRouteStopMetrics.referenceBaseline;

  testWidgets('approved reference keeps normal medallions compact and ornate', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: WordHuntRouteStop(
            level: _level(1, WordHuntLevelType.normal),
            stars: 3,
            unlocked: true,
          ),
        ),
      ),
    );

    expect(
      metrics.normalDiameter,
      lessThanOrEqualTo(52),
      reason: 'Onaylı referansta normal rota medalyonları küçük kalmalı.',
    );
    expect(
      metrics.starSize,
      lessThanOrEqualTo(16),
      reason: 'Yıldızlar küçük medalyonla orantılı kalmalı.',
    );
    expect(
      find.byKey(const Key('word_hunt_route_stop_frame_1')),
      findsOneWidget,
      reason: 'Düz daire yerine dekoratif medalyon çerçevesi bulunmalı.',
    );

    final number = tester.widget<Text>(
      find.byKey(const Key('word_hunt_route_stop_number_1')),
    );
    expect(
      number.style?.fontSize,
      lessThanOrEqualTo(20),
      reason: 'Rota numarası referanstaki gibi küçük ve dengeli olmalı.',
    );
  });

  testWidgets('normal route stop keeps one geometry for open and locked states', (
    tester,
  ) async {
    var tapped = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Row(
            children: [
              WordHuntRouteStop(
                level: _level(1, WordHuntLevelType.normal),
                stars: 2,
                unlocked: true,
                onTap: () => tapped = 1,
              ),
              WordHuntRouteStop(
                level: _level(2, WordHuntLevelType.normal),
                stars: 0,
                unlocked: false,
                onTap: () => tapped = 2,
              ),
            ],
          ),
        ),
      ),
    );

    expect(
      tester.getSize(find.byKey(const Key('word_hunt_route_stop_orb_1'))),
      Size.square(metrics.normalDiameter),
    );
    expect(
      tester.getSize(find.byKey(const Key('word_hunt_route_stop_orb_2'))),
      Size.square(metrics.normalDiameter),
    );

    for (var star = 0; star < 3; star++) {
      expect(
        find.byKey(Key('word_hunt_route_stop_star_1_$star')),
        findsOneWidget,
      );
      expect(
        find.byKey(Key('word_hunt_route_stop_star_2_$star')),
        findsOneWidget,
      );
    }

    expect(
      find.byKey(const Key('word_hunt_route_stop_lock_2')),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const Key('word_hunt_route_stop_1')));
    await tester.pump();
    expect(tapped, 1);

    await tester.tap(
      find.byKey(const Key('word_hunt_route_stop_2')),
      warnIfMissed: false,
    );
    await tester.pump();
    expect(tapped, 1, reason: 'Kilitli durak etkileşim üretmemeli.');
  });

  testWidgets('theme changes visual tokens without changing stop geometry', (
    tester,
  ) async {
    final alternateTheme = WordHuntRouteStopTheme.harbor.copyWith(
      normalAccent: const Color(0xFF67B85C),
      challengeAccent: const Color(0xFFB78245),
      bonusAccent: const Color(0xFF4F9F62),
      finalAccent: const Color(0xFFD2B06A),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Row(
            children: [
              WordHuntRouteStop(
                level: _level(3, WordHuntLevelType.normal),
                stars: 3,
                unlocked: true,
              ),
              WordHuntRouteStop(
                level: _level(4, WordHuntLevelType.normal),
                stars: 3,
                unlocked: true,
                theme: alternateTheme,
              ),
            ],
          ),
        ),
      ),
    );

    final harborSize = tester.getSize(
      find.byKey(const Key('word_hunt_route_stop_3')),
    );
    final alternateSize = tester.getSize(
      find.byKey(const Key('word_hunt_route_stop_4')),
    );

    expect(harborSize, alternateSize);
    expect(harborSize.width, metrics.normalContainerWidth);
    expect(harborSize.height, metrics.normalContainerHeight);
  });

  testWidgets('special stops share the same component family and fixed labels', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              WordHuntRouteStop(
                level: _level(5, WordHuntLevelType.challenge),
                stars: 1,
                unlocked: true,
              ),
              WordHuntRouteStop(
                level: _level(8, WordHuntLevelType.bonus),
                stars: 2,
                unlocked: true,
              ),
              WordHuntRouteStop(
                level: _level(10, WordHuntLevelType.routeFinal),
                stars: 0,
                unlocked: false,
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('MEYDAN OKUMA'), findsOneWidget);
    expect(find.text('BONUS DURAK'), findsOneWidget);
    expect(find.text('ROTA FİNALİ'), findsOneWidget);

    expect(
      tester.getSize(find.byKey(const Key('word_hunt_route_stop_5'))).width,
      metrics.specialContainerWidth,
    );
    expect(
      tester.getSize(find.byKey(const Key('word_hunt_route_stop_8'))).width,
      metrics.specialContainerWidth,
    );
    expect(
      tester.getSize(find.byKey(const Key('word_hunt_route_stop_10'))).width,
      metrics.specialContainerWidth,
    );
    expect(
      find.byKey(const Key('word_hunt_route_stop_lock_10')),
      findsOneWidget,
    );
  });
}
