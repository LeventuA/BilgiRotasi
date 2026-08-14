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

    test('kapalı test açılır, gerçek production reklam profili daima kapalıdır', () {
      expect(
        supportRewardEnabledForProfile(
          firebaseProductionEnabled: true,
          isClosedTest: true,
          isProductionAds: false,
        ),
        isTrue,
      );
      expect(
        supportRewardEnabledForProfile(
          firebaseProductionEnabled: true,
          isClosedTest: false,
          isProductionAds: true,
        ),
        isFalse,
      );
      expect(
        supportRewardEnabledForProfile(
          firebaseProductionEnabled: false,
          isClosedTest: false,
          isProductionAds: true,
        ),
        isFalse,
      );
      expect(
        supportRewardEnabledForProfile(
          firebaseProductionEnabled: false,
          isClosedTest: false,
          isProductionAds: false,
        ),
        isTrue,
      );

      final source = File('lib/ad_monetization.dart').readAsStringSync();
      expect(
        source,
        contains('isProductionAds: AdMobConfig.isProduction'),
      );
      expect(
        source,
        contains('_rewardProfileEnabled && await _limiter.canClaim'),
      );
      expect(
        source,
        contains('if (_busy || !_available || !_rewardProfileEnabled)'),
      );
    });

    test('ödül verilmezse kalan hak aynı ekranda yeniden denenebilir', () {
      expect(
        supportRewardAvailabilityAfterAttempt(
          rewardGranted: false,
          canClaimAgain: true,
        ),
        isTrue,
      );
      expect(
        supportRewardAvailabilityAfterAttempt(
          rewardGranted: false,
          canClaimAgain: false,
        ),
        isFalse,
      );
    });

    test('ödül verildiyse sonuç kartı yeniden açılmaz', () {
      expect(
        supportRewardAvailabilityAfterAttempt(
          rewardGranted: true,
          canClaimAgain: true,
        ),
        isFalse,
      );
    });
  });

  group('sonuç reklamı hakları', () {
    test('aynı tamamlanan oyun yalnız bir kez hak verir', () async {
      final limiter = SupportRewardLimiter(store: MemoryAdLimitStore());

      expect(await limiter.claim('game-1'), isTrue);
      expect(await limiter.claim('game-1'), isFalse);
      expect(await limiter.wasClaimedForGame('game-1'), isTrue);
    });

    test('farklı tamamlanan oyunlara günlük veya oturumluk kota uygulamaz', () async {
      final limiter = SupportRewardLimiter(store: MemoryAdLimitStore());

      for (var index = 1; index <= 10; index++) {
        expect(
          await limiter.claim('game-$index'),
          isTrue,
          reason: 'game-$index ayrı bir tamamlanan oyundur',
        );
      }
    });

    test('eski oyun hakkı 200 yeni oyundan sonra yeniden açılmaz', () async {
      final limiter = SupportRewardLimiter(store: MemoryAdLimitStore());

      expect(await limiter.claim('game-1'), isTrue);
      for (var index = 2; index <= 250; index++) {
        expect(await limiter.claim('game-$index'), isTrue);
      }

      expect(await limiter.claim('game-1'), isFalse);
      expect(await limiter.wasClaimedForGame('game-1'), isTrue);
    });

    test('eşzamanlı aynı oyun taleplerinden yalnız biri hak kazanır', () async {
      final limiter = SupportRewardLimiter(store: MemoryAdLimitStore());

      final results = await Future.wait<bool>(<Future<bool>>[
        limiter.claim('same-game'),
        limiter.claim('same-game'),
      ]);

      expect(results.where((result) => result).length, 1);
      expect(await limiter.claim('same-game'), isFalse);
    });

    test('eşzamanlı farklı oyun taleplerinin ikisini de kalıcı tutar', () async {
      final limiter = SupportRewardLimiter(store: MemoryAdLimitStore());

      final results = await Future.wait<bool>(<Future<bool>>[
        limiter.claim('game-a'),
        limiter.claim('game-b'),
      ]);

      expect(results, everyElement(isTrue));
      expect(await limiter.wasClaimedForGame('game-a'), isTrue);
      expect(await limiter.wasClaimedForGame('game-b'), isTrue);
    });

    test('boş oyun kimliğine hak vermez', () async {
      final limiter = SupportRewardLimiter(store: MemoryAdLimitStore());

      expect(await limiter.claim(''), isFalse);
      expect(await limiter.claim('   '), isFalse);
    });

    test('alınan hak yeni limiter örneğinde de tekrar verilmez', () async {
      final store = MemoryAdLimitStore();
      final firstLimiter = SupportRewardLimiter(store: store);
      final secondLimiter = SupportRewardLimiter(store: store);

      expect(await firstLimiter.claim('game-1'), isTrue);
      expect(await secondLimiter.canClaim('game-1'), isFalse);
      expect(await secondLimiter.claim('game-2'), isTrue);
    });
  });
}
