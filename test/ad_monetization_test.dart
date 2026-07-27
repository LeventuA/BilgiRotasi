import 'dart:io';

import 'package:bilgi_rotasi/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AdMob gelir modeli', () {
    test('Google test reklam kimlikleri kullanılır', () {
      expect(
        AdMonetizationService.androidBannerTestUnitId,
        'ca-app-pub-3940256099942544/9214589741',
      );
      expect(
        AdMonetizationService.androidRewardedTestUnitId,
        'ca-app-pub-3940256099942544/5224354917',
      );
    });

    test('joker ödüllü reklamdan sonra verilir', () {
      final source = File('lib/main.dart').readAsStringSync();
      final rewardCall = source.indexOf(
        'final earned = await AdMonetizationService.showRewarded();',
      );
      final grantCall = source.indexOf(
        '_currentPlayer.jokers.grant(kind);',
        rewardCall,
      );

      expect(rewardCall, greaterThanOrEqualTo(0));
      expect(grantCall, greaterThan(rewardCall));
      expect(
        File('lib/ad_monetization.dart').readAsStringSync(),
        contains('Jokersiz Devam Et'),
      );
    });

    test('sonuç ekranında bir kez +10 XP desteği vardır', () {
      final source = File('lib/ad_monetization.dart').readAsStringSync();
      final xpSource = File('lib/xp_progression.dart').readAsStringSync();

      expect(source, contains('SupportRewardClaimService.awardOnce'));
      expect(source, contains('Reklamı İzle · +10 XP'));
      expect(
        xpSource,
        contains("return _award(10, 'Bilgi Rotası destek reklamı')"),
      );
    });

    test('banner yalnız menü ve sonuç ekranlarına eklenir', () {
      final mainSource = File('lib/main.dart').readAsStringSync();
      final duelSource = File('lib/live_duel_screen.dart').readAsStringSync();
      final leagueSource =
          File('lib/live_duel_leaderboard.dart').readAsStringSync();
      final playSource =
          File('lib/live_duel_play_screen.dart').readAsStringSync();

      expect(
        'bottomNavigationBar: const AdBannerSlot()'
            .allMatches(mainSource)
            .length,
        greaterThanOrEqualTo(4),
      );
      expect(duelSource, contains('bottomNavigationBar: const AdBannerSlot()'));
      expect(
        leagueSource,
        contains('bottomNavigationBar: const AdBannerSlot()'),
      );
      expect(
        playSource,
        isNot(contains('bottomNavigationBar: const AdBannerSlot()')),
      );
    });

    test('yerel Android eklentisi test uygulama kimliğini taşır', () {
      final manifest =
          File(
            'lib/admob_config_plugin/android/src/main/AndroidManifest.xml',
          ).readAsStringSync();
      final pubspec = File('pubspec.yaml').readAsStringSync();

      expect(manifest, contains('ca-app-pub-3940256099942544~3347511713'));
      expect(manifest, contains('com.google.android.gms.ads.APPLICATION_ID'));
      expect(pubspec, contains('bilgi_rotasi_admob_config:'));
      expect(pubspec, contains('path: lib/admob_config_plugin'));
    });
  });
}
