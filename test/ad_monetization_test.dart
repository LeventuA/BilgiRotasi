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

    test('sonuç yerleşimleri destek kartını otomatik açar', () {
      const automatic = <AdPlacement>{
        AdPlacement.marathonResult,
        AdPlacement.challengeResult,
        AdPlacement.dailyResult,
        AdPlacement.otherModeResult,
      };
      for (final placement in AdPlacement.values) {
        expect(
          AdVisibilityPolicy.showsAutoSupportReward(placement),
          automatic.contains(placement),
          reason: placement.name,
        );
      }

      final source = File('lib/ad_monetization.dart').readAsStringSync();
      expect(source, contains('SupportRewardCard(gameId: supportGameId)'));
      expect(source, contains('if (!showBanner && supportGameId == null)'));
    });

    test('otomatik sonuç gameId günlük görevde kararlı, diğerlerinde tekildir', () {
      final first = DateTime.utc(2026, 8, 18, 12);
      final second = DateTime.utc(2026, 8, 18, 12, 0, 0, 1);

      expect(
        autoSupportRewardGameId(AdPlacement.dailyResult, now: first),
        autoSupportRewardGameId(AdPlacement.dailyResult, now: second),
      );
      expect(
        autoSupportRewardGameId(AdPlacement.otherModeResult, now: first),
        isNot(autoSupportRewardGameId(AdPlacement.otherModeResult, now: second)),
      );
      expect(
        autoSupportRewardGameId(AdPlacement.boardResult, now: first),
        isEmpty,
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

    test('production ödül profili yalnız Firebase production ile açılır', () {
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
        isTrue,
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

    test('production SSV yalnız hesaplı sonuç XP ödülünde zorunludur', () {
      expect(
        rewardedSsvRequired(
          isProductionAds: true,
          firebaseProductionEnabled: true,
          hasAuthenticatedUser: true,
          hasGameId: true,
        ),
        isTrue,
      );
      expect(
        rewardedSsvRequired(
          isProductionAds: true,
          firebaseProductionEnabled: true,
          hasAuthenticatedUser: true,
          hasGameId: false,
        ),
        isFalse,
        reason: 'Rastgele joker gibi yerel ödül SSV gerektirmez.',
      );
      expect(
        rewardedSsvRequired(
          isProductionAds: true,
          firebaseProductionEnabled: true,
          hasAuthenticatedUser: false,
          hasGameId: true,
        ),
        isFalse,
        reason: 'Misafir XP yereldir ve Firebase UID yoktur.',
      );
      expect(
        rewardedSsvRequired(
          isProductionAds: false,
          firebaseProductionEnabled: true,
          hasAuthenticatedUser: true,
          hasGameId: true,
        ),
        isFalse,
      );
    });

    test('SSV callable yanıtı uid ve customData olmadan kabul edilmez', () {
      final valid = RewardedSsvSession.fromCallableResponse(
        uid: ' user-1 ',
        response: <String, dynamic>{'customData': ' payload '},
      );
      expect(valid, isNotNull);
      expect(valid!.uid, 'user-1');
      expect(valid.customData, 'payload');

      expect(
        RewardedSsvSession.fromCallableResponse(
          uid: '   ',
          response: <String, dynamic>{'customData': 'payload'},
        ),
        isNull,
      );
      expect(
        RewardedSsvSession.fromCallableResponse(
          uid: 'user-1',
          response: <String, dynamic>{'customData': '   '},
        ),
        isNull,
      );
      expect(
        RewardedSsvSession.fromCallableResponse(
          uid: 'user-1',
          response: const <String, dynamic>{},
        ),
        isNull,
      );
    });

    test('production rewarded akışı nonce ve server claim doğrulamasını bağlar', () {
      final source = File('lib/ad_monetization.dart').readAsStringSync();

      expect(source, contains("'issueRewardNonce'"));
      expect(source, contains("'getRewardedGameState'"));
      expect(source, contains("'gameId': normalizedGameId"));
      expect(source, contains('ServerSideVerificationOptions('));
      expect(source, contains('userId: ssvSession.uid'));
      expect(source, contains('customData: ssvSession.customData'));
      expect(source, contains('ad.setServerSideOptions(options)'));
      expect(source, contains('RewardedSsvClient.confirmForGame(normalizedGameId)'));
      expect(source, contains('showRewarded({String? gameId})'));
      expect(source, contains('gameId: widget.gameId'));
    });

    test('tahta joker reklamı gameId olmadan yerel ödül olarak kalır', () {
      final source = File('lib/main.dart').readAsStringSync();
      expect(source, contains('AdMonetizationService.instance.showRewarded()'));
      expect(
        rewardedSsvRequired(
          isProductionAds: true,
          firebaseProductionEnabled: true,
          hasAuthenticatedUser: true,
          hasGameId: false,
        ),
        isFalse,
      );
    });

    test('aktif soru ve Canlı Düello maç ekranları reklam içermez', () {
      final source = File('lib/main.dart').readAsStringSync();
      final liveDuelSource =
          File('lib/live_duel_play_screen.dart').readAsStringSync();
      final normalQuestionStart = source.indexOf('class QuestionScreen');
      final normalQuestionEnd = source.indexOf('class PlayerData');
      final liveDuelStart =
          liveDuelSource.indexOf('Widget _buildQuestionView(');
      final liveDuelEnd =
          liveDuelSource.indexOf('Widget _buildResultView(');

      expect(normalQuestionStart, greaterThanOrEqualTo(0));
      expect(normalQuestionEnd, greaterThan(normalQuestionStart));
      expect(liveDuelStart, greaterThanOrEqualTo(0));
      expect(liveDuelEnd, greaterThan(liveDuelStart));

      for (final screenSource in <String>[
        source.substring(normalQuestionStart, normalQuestionEnd),
        liveDuelSource.substring(liveDuelStart, liveDuelEnd),
      ]) {
        expect(screenSource, isNot(contains('AdBannerSlot')));
        expect(screenSource, isNot(contains('SupportRewardCard')));
        expect(screenSource, isNot(contains('showRewarded(')));
      }
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
