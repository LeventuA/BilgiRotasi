import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Nihai kapalı test release workflow', () {
    late String workflow;
    late String manualWorkflow;

    setUpAll(() {
      manualWorkflow =
          File('.github/workflows/closed-test-release.yml').readAsStringSync();
      final coreWorkflow =
          File(
            '.github/workflows/closed-test-release-core.yml',
          ).readAsStringSync();
      workflow = '$manualWorkflow\n$coreWorkflow';
    });

    test('yalnız elle ve açık onayla çalışır', () {
      expect(manualWorkflow, contains('workflow_dispatch:'));
      expect(
        workflow,
        contains(r'test "$CLOSED_TEST_CONFIRMATION" = "CLOSED_TEST"'),
      );
      expect(manualWorkflow, isNot(contains('workflow_call:')));
      expect(manualWorkflow, isNot(contains('\n  push:')));
      expect(manualWorkflow, isNot(contains('\n  pull_request:')));
      expect(manualWorkflow, isNot(contains('\n  schedule:')));
      expect(
        manualWorkflow,
        contains('uses: ./.github/workflows/closed-test-release-core.yml'),
      );
    });

    test('kayıtlı manuel workflow kapalı-test çekirdeğini çağırabilir', () {
      final registeredWorkflow =
          File(
            '.github/workflows/apply-permanent-admob-v7.yml',
          ).readAsStringSync();
      expect(
        registeredWorkflow,
        contains("if: inputs.confirmation == 'CLOSED_TEST'"),
      );
      expect(
        registeredWorkflow,
        contains('uses: ./.github/workflows/closed-test-release-core.yml'),
      );
      expect(
        registeredWorkflow,
        contains("if: inputs.confirmation == 'PRODUCTION'"),
      );
    });

    test('sürüm pubspec dosyasından dinamik okunur', () {
      expect(workflow, contains('VERSION="\$(sed -nE'));
      expect(workflow, contains(r'echo "VERSION_NAME=$VERSION_NAME"'));
      expect(workflow, contains(r'echo "VERSION_CODE=$VERSION_CODE"'));
      expect(
        workflow,
        contains(
          r'BilgiRotasi-${VERSION_NAME}-${VERSION_CODE}-closed-test.aab',
        ),
      );
      expect(workflow, isNot(contains('1.68.8')));
      expect(workflow, isNot(contains("versionCode='98'")));
    });

    test('production Firebase ile Google demo reklam profili seçilir', () {
      expect(
        workflow,
        contains('ORG_GRADLE_PROJECT_ADMOB_ENVIRONMENT: closed_test'),
      );
      expect(workflow, contains('--dart-define=ADMOB_ENVIRONMENT=closed_test'));
      expect(
        workflow,
        contains('--dart-define=FIREBASE_ENVIRONMENT=production'),
      );
      expect(workflow, contains('bilgi-rotasi-f255d'));
      expect(workflow, contains('ca-app-pub-3940256099942544~3347511713'));
      expect(workflow, contains('ca-app-pub-3940256099942544/6300978111'));
      expect(workflow, contains('ca-app-pub-3940256099942544/5224354917'));
      expect(
        workflow,
        contains("! grep -Fq 'ca-app-pub-7452194004008791~7046504043'"),
      );
    });

    test('imza, paket, AAB metadata ve gizli bilgi kapıları bulunur', () {
      for (final expected in <String>[
        'ANDROID_KEYSTORE_BASE64',
        'ANDROID_KEYSTORE_PASSWORD',
        'ANDROID_KEY_ALIAS',
        'ANDROID_KEY_PASSWORD',
        'com.leventua.bilgirotasi',
        '000EE43F410ABC6B4F634C4F716D76EB19084115',
        'jarsigner -verify',
        'keytool -printcert -jarfile',
        'bundletool.jar',
        "! grep -Fq 'android:debuggable=\"true\"'",
        "BEGIN (RSA |EC |OPENSSH )?PRIVATE KEY",
      ]) {
        expect(workflow, contains(expected), reason: expected);
      }
    });

    test('AAB türevi Android 16 kritik akış doğrulaması yapar', () {
      expect(workflow, contains('api-level: 36'));
      expect(workflow, contains(r'install-apks --apks="$APKS"'));
      expect(workflow, contains("wait_for_text 'Google ile giriş yap'"));
      expect(workflow, contains("tap_text 'Misafir olarak devam et'"));
      expect(workflow, contains("tap_text 'Eğitimi Yeniden Göster'"));
      expect(workflow, contains('reports/COLD_START_LOGCAT.txt'));
      expect(workflow, contains('FATAL EXCEPTION'));
    });

    test('istenen AAB ve kanıt dosyalarını artifact olarak yükler', () {
      for (final expected in <String>[
        r'dist/${{ env.AAB_FILE }}',
        'AAB_CERTIFICATE.txt',
        'AAB_BADGING.txt',
        'TEST_RESULTS.txt',
        'COLD_START_LOGCAT.txt',
        'RELEASE_READINESS.md',
        'DEPENDENCY_GRAPH.txt',
      ]) {
        expect(workflow, contains(expected), reason: expected);
      }
      expect(workflow, contains('python3 tools/rc1_quality_gate.py'));
      expect(workflow, contains('RC1_QUALITY_GATE.md'));
      final qualityGate = File('tools/rc1_quality_gate.py').readAsStringSync();
      expect(qualityGate, isNot(contains('EXPECTED_VERSION')));
      expect(qualityGate, contains('AppBuildInfo sürümü uyuşmuyor'));
    });

    test('workflow backend dağıtımı veya gerçek reklam isteği yapmaz', () {
      expect(workflow, isNot(contains('firebase deploy')));
      expect(workflow, isNot(contains('MobileAds.instance.initialize')));
      expect(
        workflow,
        isNot(contains('ORG_GRADLE_PROJECT_ADMOB_ENVIRONMENT: production')),
      );
    });
  });
}
