import 'package:bilgi_rotasi/word_hunt/home_hub_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('yeni ana ekran yalnız kararlaştırılan ana alanları gösterir', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: BilgiRotasiHomeHubPrototype()),
    );
    await tester.pump();

    expect(find.text('BİLGİ ROTASI'), findsOneWidget);
    expect(find.text('Bilgi Oyunu'), findsOneWidget);
    expect(find.text('Kelime Avı'), findsOneWidget);
    expect(find.text('Günlük Görevler'), findsOneWidget);
    expect(find.text('Yeni modlar yolda!'), findsOneWidget);

    expect(find.text('Kariyer'), findsNothing);
    expect(find.text('Sosyal'), findsNothing);
    expect(find.text('Ayarlar'), findsNothing);
  });

  testWidgets('profil, ayarlar ve bildirim aksiyonları üst alandadır', (
    tester,
  ) async {
    var profile = 0;
    var settings = 0;
    var notifications = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: BilgiRotasiHomeHubPrototype(
          onProfile: () => profile++,
          onSettings: () => settings++,
          onNotifications: () => notifications++,
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.byKey(const Key('home_hub_profile')));
    await tester.tap(find.byKey(const Key('home_hub_settings')));
    await tester.tap(find.byKey(const Key('home_hub_notifications')));
    await tester.pump();

    expect(profile, 1);
    expect(settings, 1);
    expect(notifications, 1);
  });

  testWidgets('iki ana oyun kartı ayrı callback üretir', (tester) async {
    var bilgiOyunu = 0;
    var kelimeAvi = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: BilgiRotasiHomeHubPrototype(
          onBilgiOyunu: () => bilgiOyunu++,
          onKelimeAvi: () => kelimeAvi++,
        ),
      ),
    );
    await tester.pump();

    await tester.tap(
      find.descendant(
        of: find.byKey(const Key('home_hub_bilgi_oyunu')),
        matching: find.text('Oyna'),
      ),
    );
    await tester.tap(
      find.descendant(
        of: find.byKey(const Key('home_hub_kelime_avi')),
        matching: find.text('Başla'),
      ),
    );
    await tester.pump();

    expect(bilgiOyunu, 1);
    expect(kelimeAvi, 1);
  });

  testWidgets('günlük kartı ilerleme ve callback taşır', (tester) async {
    var daily = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: BilgiRotasiHomeHubPrototype(
          data: const HomeHubPrototypeData(
            username: '@test',
            level: 7,
            currentXp: 250,
            nextLevelXp: 1000,
            dailyCompleted: 3,
            dailyTotal: 5,
          ),
          onDaily: () => daily++,
        ),
      ),
    );
    await tester.pump();

    expect(find.text('@test'), findsOneWidget);
    expect(find.text('250 / 1000 XP'), findsOneWidget);
    expect(find.text('3/5'), findsOneWidget);

    await tester.tap(find.byKey(const Key('home_hub_daily')));
    await tester.pump();
    expect(daily, 1);
  });

  testWidgets('dar ekranda taşma olmadan iki ana oyun kartını korur', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(360, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const MaterialApp(home: BilgiRotasiHomeHubPrototype()),
    );
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.byKey(const Key('home_hub_bilgi_oyunu')), findsOneWidget);
    expect(find.byKey(const Key('home_hub_kelime_avi')), findsOneWidget);
    expect(find.byKey(const Key('home_hub_settings')), findsOneWidget);
  });
}
