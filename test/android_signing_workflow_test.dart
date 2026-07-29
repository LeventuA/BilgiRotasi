import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AdMob kalıcı Android imza kapısı', () {
    late String workflow;
    late String gradle;

    setUpAll(() {
      workflow =
          File(
            '.github/workflows/admob-pr-validation.yml',
          ).readAsStringSync();
      gradle = File('android/app/build.gradle.kts').readAsStringSync();
    });

    test('dört signing secret zorunludur', () {
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

    test('release build debug imzaya düşmez', () {
      final releaseStart = gradle.indexOf('buildTypes {');
      final releaseSource = gradle.substring(releaseStart);
      expect(
        releaseSource,
        isNot(contains('signingConfigs.getByName("debug")')),
      );
      expect(releaseSource, contains('else {\n                    null'));
    });

    test('APK sertifikası beklenen SHA-1 ile doğrulanır', () {
      expect(workflow, contains('apksigner'));
      expect(
        workflow,
        contains('000EE43F410ABC6B4F634C4F716D76EB19084115'),
      );
      expect(workflow, contains('ADMOB_APK_CERTIFICATE.txt'));
    });
  });
}
