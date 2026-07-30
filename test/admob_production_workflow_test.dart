import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Manuel AdMob production release workflow', () {
    late String workflow;

    setUpAll(() {
      workflow =
          File(
            '.github/workflows/apply-permanent-admob-v7.yml',
          ).readAsStringSync();
    });

    test('yalnız workflow_dispatch ile elle çalışır', () {
      expect(workflow, contains('workflow_dispatch:'));
      expect(workflow, isNot(contains('\n  push:')));
      expect(workflow, isNot(contains('\n  pull_request:')));
      expect(workflow, isNot(contains('\n  schedule:')));
    });

    test('kalıcı keystore secret değerlerinin tamamını zorunlu tutar', () {
      for (final secret in <String>[
        'ANDROID_KEYSTORE_BASE64',
        'ANDROID_KEYSTORE_PASSWORD',
        'ANDROID_KEY_ALIAS',
        'ANDROID_KEY_PASSWORD',
      ]) {
        expect(workflow, contains(r'test -n "$' + secret + '"'));
      }
      expect(workflow, contains('android/key.properties'));
      expect(workflow, contains('android/app/bilgi_rotasi_upload.jks'));
    });

    test('Gradle ve Dart production profilini birlikte seçer', () {
      expect(
        workflow,
        contains('ORG_GRADLE_PROJECT_ADMOB_ENVIRONMENT: production'),
      );
      expect(workflow, contains('--dart-define=ADMOB_ENVIRONMENT=production'));
      expect(workflow, contains('test/admob_id_profile_test.dart'));
    });

    test('production APK ve AAB üretip ayrı artifact yükler', () {
      expect(workflow, contains('flutter build apk --release'));
      expect(workflow, contains('flutter build appbundle --release'));
      expect(workflow, contains('BilgiRotasi-Production-APK-1.68.6-96'));
      expect(workflow, contains('BilgiRotasi-Production-AAB-1.68.6-96'));
    });

    test('paket, sürüm, production App ID ve SHA-1 doğrulanır', () {
      for (final expected in <String>[
        'com.leventua.bilgirotasi',
        "versionCode='96'",
        "versionName='1.68.6'",
        'ca-app-pub-7452194004008791~7046504043',
        'ca-app-pub-3940256099942544~3347511713',
        '000EE43F410ABC6B4F634C4F716D76EB19084115',
        'apksigner',
        'jarsigner -verify',
        'bundletool.jar',
      ]) {
        expect(workflow, contains(expected), reason: expected);
      }
    });

    test('emülatör veya gerçek reklam isteği çalıştırmaz', () {
      expect(workflow, isNot(contains('android-emulator-runner')));
      expect(workflow, isNot(contains('adb ')));
      expect(workflow, isNot(contains('MobileAds.instance.initialize')));
    });
  });
}
