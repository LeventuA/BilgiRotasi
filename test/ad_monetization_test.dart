import 'dart:io';

import 'package:bilgi_rotasi/main.dart';
import 'package:flutter_test/flutter_test.dart';

class MemoryAdLimitStore implements AdLimitStore {
  final Map<String, String> values = <String, String>{};

  @override
  Future<String?> read(String key) async => values[key];

  @override
  Future<void> write(String key, String value) async {
    values[key] = value;
  }
}

void main() {
  group('AdMob yapılandırması', () {
    test('resmî Android test kimlikleri merkezî yapıdadır', () {
      expect(
        AdMobConfig.androidAppId,
        'ca-app-pub-3940256099942544~3347511713',
      );
      expect(
        AdMobConfig.androidBannerUnitId,
        'ca-app-pub-3940256099942544/6300978111',
      );
      expect(
        AdMobConfig.androidRewardedUnitId,
        'ca-app-pub-3940256099942544/5224354917',
      );
    });

    test('banner izin listesi açık ve varsayılan olarak kapalıdır', () {
      const allowed = <AdPlacement>{
        AdPlacement.homeMenu,
        AdPlacement.settings,
        AdPlacement.socialRecords,
        AdPlacement.familyRecords,
        AdPlacement.career,
        AdPlacement.play,
        AdPlacement.otherModes,
        AdPlacement.boardResult,
        AdPlacement.marathonResult,
        AdPlacement.challengeResult,
        AdPlacement.dailyResult,
        AdPlacement.survival,
        AdPlacement.speed,
        AdPlacement.otherModeResult,
      };

      for (final placement in AdPlacement.values) {
        expect(
          AdVisibilityPolicy.showsBanner(placement),
          allowed.contains(placement),
          reason: placement.name,
        );
      }

      final main = File('lib/main.dart').readAsStringSync();
      final gameStart = main.indexOf('class GameScreen');
      final gameEnd = main.indexOf('class BoardNode');
      final gameSource = main.substring(gameStart, gameEnd);
      expect(gameSource, isNot(contains('AdBannerSlot')));
      final questionStart = main.indexOf('class QuestionScreen');
      final questionSource = main.substring(questionStart);
      expect(questionSource, isNot(contains('AdBannerSlot')));
      expect(
        File('lib/live_duel_play_screen.dart').readAsStringSync(),
        isNot(contains('AdBannerSlot')),
      );
    });
  });

  group('ödül güvenliği', () {
    test('reward callback başarısızsa ödül verilmez', () async {
      var grants = 0;
      final controller = AdRewardController(
        showRewarded: () async => false,
        grantReward: () async => grants++,
      );

      expect(await controller.run(), isFalse);
      expect(grants, 0);
    });

    test('reward callback yalnız başarıda ödül verir', () async {
      var grants = 0;
      final controller = AdRewardController(
        showRewarded: () async => true,
        grantReward: () async => grants++,
      );

      expect(await controller.run(), isTrue);
      expect(grants, 1);
    });
  });

  group('sonuç reklamı limitleri', () {
    test('oyun başına en fazla bir kez hak verir', () async {
      final limiter = SupportRewardLimiter(
        store: MemoryAdLimitStore(),
        now: () => DateTime(2026, 7, 29),
      );

      expect(await limiter.claim('game-1'), isTrue);
      expect(await limiter.claim('game-1'), isFalse);
      expect(await limiter.claimsToday(), 1);
    });

    test('günlük en fazla üç kez hak verir ve ertesi gün sıfırlanır', () async {
      final store = MemoryAdLimitStore();
      var now = DateTime(2026, 7, 29);
      final limiter = SupportRewardLimiter(store: store, now: () => now);

      expect(await limiter.claim('game-1'), isTrue);
      expect(await limiter.claim('game-2'), isTrue);
      expect(await limiter.claim('game-3'), isTrue);
      expect(await limiter.claim('game-4'), isFalse);
      expect(await limiter.claimsToday(), 3);

      now = DateTime(2026, 7, 30);
      expect(await limiter.claim('game-4'), isTrue);
      expect(await limiter.claimsToday(), 1);
    });
  });
}
