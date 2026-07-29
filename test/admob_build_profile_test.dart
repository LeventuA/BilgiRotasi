import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AdMob Android derleme profilleri', () {
    late String gradle;
    late String workflow;
    late String productionBuildScript;

    setUpAll(() {
      gradle = File('android/app/build.gradle.kts').readAsStringSync();
      workflow =
          File('.github/workflows/admob-pr-validation.yml').readAsStringSync();
      productionBuildScript =
          File('tools/build_admob_production.ps1').readAsStringSync();
    });

    test('debug ve varsayılan release profili test App ID kullanır', () {
      expect(
        gradle,
        contains(
          'val adMobTestAppId = '
          '"ca-app-pub-3940256099942544~3347511713"',
        ),
      );
      expect(
        gradle,
        contains('manifestPlaceholders["admobAppId"] = adMobTestAppId'),
      );
      expect(workflow, contains('ORG_GRADLE_PROJECT_ADMOB_ENVIRONMENT: test'));
      expect(workflow, contains('--dart-define=ADMOB_ENVIRONMENT=test'));
    });

    test('production App ID yalnız production kapısında seçilir', () {
      expect(
        gradle,
        contains(
          'val adMobProductionAppId = '
          '"ca-app-pub-7452194004008791~7046504043"',
        ),
      );
      expect(
        gradle,
        contains('val useProductionAds = adMobEnvironment == "production"'),
      );
      expect(gradle, contains('if (useProductionAds)'));
      expect(gradle, contains('if (!hasReleaseKeystore)'));
      expect(gradle, contains('000EE43F410ABC6B4F634C4F716D76EB19084115'));
    });

    test('üretim yardımcısı Gradle ve Dart profilini birlikte seçer', () {
      expect(
        productionBuildScript,
        contains(r'$env:ORG_GRADLE_PROJECT_ADMOB_ENVIRONMENT = "production"'),
      );
      expect(
        productionBuildScript,
        contains('--dart-define=ADMOB_ENVIRONMENT=production'),
      );
      expect(productionBuildScript, contains('flutter build apk --release'));
    });

    test('CI APK ve Android 16 cold-start gerçek kimlik kullanmaz', () {
      expect(
        workflow,
        contains('grep -Fq "ca-app-pub-3940256099942544~3347511713"'),
      );
      expect(
        workflow,
        contains('! grep -Fq "ca-app-pub-7452194004008791~7046504043"'),
      );
      expect(
        workflow,
        contains(
          'flutter test \\\n'
          '            --dart-define=ADMOB_ENVIRONMENT=production',
        ),
      );
    });
  });
}
