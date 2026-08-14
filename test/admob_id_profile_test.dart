import 'package:bilgi_rotasi/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const expectedEnvironment = String.fromEnvironment(
    'ADMOB_ENVIRONMENT',
    defaultValue: 'test',
  );

  test('AdMob kimlikleri seçilen derleme profiliyle eşleşir', () {
    expect(AdMobConfig.environment, expectedEnvironment);

    if (expectedEnvironment == 'production') {
      expect(AdMobConfig.isProduction, isTrue);
      expect(
        AdMobConfig.androidAppId,
        'ca-app-pub-7452194004008791~7046504043',
      );
      expect(
        AdMobConfig.androidBannerUnitId,
        'ca-app-pub-7452194004008791/4228769011',
      );
      expect(
        AdMobConfig.androidRewardedUnitId,
        'ca-app-pub-7452194004008791/4974874471',
      );
      return;
    }

    expect(expectedEnvironment, anyOf('test', 'closed_test'));
    expect(AdMobConfig.isProduction, isFalse);
    expect(AdMobConfig.isClosedTest, expectedEnvironment == 'closed_test');
    expect(AdMobConfig.usesGoogleTestAds, isTrue);
    expect(AdMobConfig.androidAppId, 'ca-app-pub-3940256099942544~3347511713');
    expect(
      AdMobConfig.androidBannerUnitId,
      'ca-app-pub-3940256099942544/6300978111',
    );
    expect(
      AdMobConfig.androidRewardedUnitId,
      'ca-app-pub-3940256099942544/5224354917',
    );
  });
}
