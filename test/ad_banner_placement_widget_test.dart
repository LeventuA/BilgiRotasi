import 'dart:io';

import 'package:bilgi_rotasi/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

void main() {
  const allowedScreens = <String, AdPlacement>{
    'Ana menü': AdPlacement.homeMenu,
    'Ayarlar ekranı': AdPlacement.settings,
    'Sosyal ve Rekorlar ekranı': AdPlacement.socialRecords,
    'Aile Rekorları ekranı': AdPlacement.familyRecords,
    'Kariyer bölümü': AdPlacement.career,
    'Oyna bölümü': AdPlacement.play,
    'Diğer Oyun Modları bölümü': AdPlacement.otherModes,
    'Tahta oyunu sonuç ekranı': AdPlacement.boardResult,
    'Maraton sonuç ekranı': AdPlacement.marathonResult,
    'Meydan Okuma sonuç ekranı': AdPlacement.challengeResult,
    'Günlük Görev sonuç ekranı': AdPlacement.dailyResult,
    'Hayatta Kalma modu': AdPlacement.survival,
    '60 Saniye modu': AdPlacement.speed,
    'Diğer oyun modlarının sonuç ekranları': AdPlacement.otherModeResult,
  };

  const forbiddenScreens = <String, AdPlacement>{
    'Google/misafir giriş ekranı': AdPlacement.auth,
    'Aktif tahta oyunu': AdPlacement.boardGame,
    'Normal soru ekranları': AdPlacement.question,
    'Canlı Düello giriş ekranı': AdPlacement.liveDuelEntry,
    'Canlı Düello eşleştirme ekranı': AdPlacement.liveDuelMatchmaking,
    'Canlı Düello maç ekranı': AdPlacement.liveDuelMatch,
  };

  group('ortak güvenli banner scaffold widget matrisi', () {
    for (final entry in allowedScreens.entries) {
      testWidgets('${entry.key} banner alt çubuğunu kullanır', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: AdBannerScaffold(
              placement: entry.value,
              bannerLoader: () async => null,
              body: const Text('İçerik'),
            ),
          ),
        );
        await tester.pump();

        final slot = find.byKey(
          ValueKey<String>('ad-banner-${entry.value.name}'),
        );
        expect(slot, findsOneWidget);
        expect(
          tester.widget<Scaffold>(find.byType(Scaffold)).bottomNavigationBar,
          isA<AdBannerSlot>(),
        );
        expect(find.byType(AdWidget), findsNothing);
        expect(tester.getSize(slot).height, 0);
      });
    }

    for (final entry in forbiddenScreens.entries) {
      testWidgets('${entry.key} banner üretmez', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: AdBannerScaffold(
              placement: entry.value,
              bannerLoader: () async => null,
              body: const Text('İçerik'),
            ),
          ),
        );

        expect(find.byType(AdBannerSlot), findsNothing);
        expect(
          tester.widget<Scaffold>(find.byType(Scaffold)).bottomNavigationBar,
          isNull,
        );
      });
    }
  });

  test('gerçek ekranlar ortak yerleşim anahtarlarına bağlıdır', () {
    final sources = <String, String>{
      'main': File('lib/main.dart').readAsStringSync(),
      'navigation': File('lib/main_navigation.dart').readAsStringSync(),
      'social': File('lib/social_features.dart').readAsStringSync(),
      'daily': File('lib/daily_challenge.dart').readAsStringSync(),
      'quick': File('lib/quick_modes.dart').readAsStringSync(),
      'advanced': File('lib/advanced_modes.dart').readAsStringSync(),
      'settings': File('lib/accessibility_settings.dart').readAsStringSync(),
    };

    for (final placement in allowedScreens.values) {
      expect(
        sources.values.any(
          (source) => source.contains('AdPlacement.${placement.name}'),
        ),
        isTrue,
        reason: placement.name,
      );
    }

    expect(
      File('lib/account_cloud.dart').readAsStringSync(),
      isNot(contains('AdBannerSlot')),
    );
    expect(
      File('lib/live_duel_screen.dart').readAsStringSync(),
      isNot(contains('AdBannerSlot')),
    );
    expect(
      File('lib/live_duel_play_screen.dart').readAsStringSync(),
      isNot(contains('AdBannerSlot')),
    );
  });
}
