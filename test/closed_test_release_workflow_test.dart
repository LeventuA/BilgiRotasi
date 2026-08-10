import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Nihai kapalı test release workflow', () {
    late String workflow;
    late String manualWorkflow;
    late String androidApkLauncher;
    late String coreWorkflow;
    late String android16Script;

    setUpAll(() {
      manualWorkflow =
          File('.github/workflows/closed-test-release.yml').readAsStringSync();
      androidApkLauncher =
          File('.github/workflows/android-apk.yml').readAsStringSync();
      coreWorkflow =
          File(
            '.github/workflows/closed-test-release-core.yml',
          ).readAsStringSync();
      android16Script = File(
        'tools/validate_android16_closed_test.sh',
      ).readAsStringSync().replaceAll('\r\n', '\n');
      workflow = '$manualWorkflow\n$coreWorkflow\n$android16Script';
    });

    test(
      'android-apk yalnız güvenli manuel kapalı-test çekirdeğini çağırır',
      () {
        expect(androidApkLauncher, contains('workflow_dispatch:'));
        expect(androidApkLauncher, contains('confirmation:'));
        expect(
          androidApkLauncher,
          contains("Kapalı test build'i için CLOSED_TEST yazın"),
        );
        expect(
          androidApkLauncher,
          contains('uses: ./.github/workflows/closed-test-release-core.yml'),
        );
        expect(androidApkLauncher, contains('secrets: inherit'));
        expect(androidApkLauncher, isNot(contains('\n  push:')));
        expect(androidApkLauncher, isNot(contains('\n  pull_request:')));
        expect(androidApkLauncher, isNot(contains('\n  schedule:')));
        expect(
          androidApkLauncher,
          isNot(RegExp(r'flutter\s+build\s+(apk|appbundle)')),
        );
        expect(androidApkLauncher, isNot(contains('1.61.0+82')));
      },
    );

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
      final accountCloud = File('lib/account_cloud.dart').readAsStringSync();
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
      expect(workflow, contains('263c46c6ae9f27c3b33810fa898cd7eb9373ccf4'));
      expect(workflow, contains('ca-app-pub-3940256099942544~3347511713'));
      expect(workflow, contains('ca-app-pub-3940256099942544/6300978111'));
      expect(workflow, contains('ca-app-pub-3940256099942544/5224354917'));
      expect(
        workflow,
        contains("! grep -Fq 'ca-app-pub-7452194004008791~7046504043'"),
      );
      expect(
        accountCloud,
        contains('184174765052-cq19m113aum2jofrfj3np8adbulgmeon'),
      );
      expect(accountCloud, contains('.apps.googleusercontent.com'));
      expect(accountCloud, contains('serverClientId: _googleServerClientId'));
      expect(
        workflow,
        contains('dart_server_client_id == expected_web_client_id'),
      );
      expect(
        workflow,
        contains('dart_server_client_id not in android_client_ids'),
      );
      expect(
        workflow,
        contains(
          '184174765052-tug3r8maeh0bvvvjibjtiogifrmummiq'
          '.apps.googleusercontent.com',
        ),
      );
      expect(
        workflow,
        contains(
          '184174765052-8vma0frp2jqlf3iqui7hm7qlilluklgo'
          '.apps.googleusercontent.com',
        ),
      );
      expect(workflow, isNot(contains("! grep -R -Fq 'serverClientId:' lib")));
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
        '--ks-pass="file:\$KS_PASS_FILE"',
        '--key-pass="file:\$KEY_PASS_FILE"',
        "AAB_SHA1=\"\$(awk -F': '",
        "tr -d '[:space:]:'",
        "! grep -Fq 'android:debuggable=\"true\"'",
        "BEGIN (RSA |EC |OPENSSH )?PRIVATE KEY",
      ]) {
        expect(workflow, contains(expected), reason: expected);
      }
      expect(workflow, isNot(contains('--ks-pass=env:')));
      expect(workflow, isNot(contains('--key-pass=env:')));
    });

    test('AAB türevi Android 16 kritik akış doğrulaması yapar', () {
      expect(workflow, isNot(contains('flutter build apk --release')));
      expect(workflow, contains('flutter build appbundle --release'));
      expect(workflow, contains('universal.apk'));
      expect(workflow, contains('api-level: 36'));
      expect(coreWorkflow, contains('target: google_apis'));
      expect(coreWorkflow, contains('cores: 4'));
      expect(coreWorkflow, contains('cores: 2'));
      expect(coreWorkflow, contains('ram-size: 4096M'));
      expect(coreWorkflow, contains('id: android16_attempt_1'));
      expect(coreWorkflow, contains('continue-on-error: true'));
      expect(coreWorkflow, contains('id: android16_retry'));
      expect(
        coreWorkflow,
        contains("if: steps.android16_retry.outputs.retry == 'true'"),
      );
      expect(
        RegExp(
          r'uses: reactivecircus/android-emulator-runner@v2',
        ).allMatches(coreWorkflow).length,
        2,
      );
      expect(
        coreWorkflow,
        contains('timeout 1200 bash tools/validate_android16_closed_test.sh'),
      );
      expect(
        android16Script,
        startsWith('#!/usr/bin/env bash\nset -euo pipefail'),
      );
      expect(workflow, contains(r'adb shell getprop ro.build.version.sdk'));
      expect(workflow, contains(r'adb shell service check package'));
      expect(workflow, contains(r'adb shell service check activity'));
      expect(workflow, contains(r'adb shell pm path android'));
      expect(workflow, contains('stable_service_checks'));
      expect(workflow, contains(r'$(seq 1 120)'));
      expect(workflow, contains(r'timeout 300 adb push "$APK" "$REMOTE_APK"'));
      expect(
        workflow,
        contains(r'timeout 300 adb shell pm install -r "$REMOTE_APK"'),
      );
      expect(
        workflow,
        contains(
          r'APK="dist/BilgiRotasi-${VERSION_LABEL}-closed-test-universal.apk"',
        ),
      );
      expect(workflow, contains('adb exec-out screencap -p'));
      expect(workflow, contains(r'tesseract "reports/UI_${label}.png"'));
      expect(workflow, contains("wait_for_word AUTH 'Google|Misafir'"));
      expect(workflow, contains('dismiss_system_anr'));
      expect(
        android16Script,
        contains(r'dismiss_system_anr "ENTRY_${attempt}"'),
      );
      expect(
        android16Script,
        contains(r'dismiss_system_anr "HOME_${attempt}"'),
      );
      expect(workflow, contains("'Process|System[[:space:]]+UI'"));
      expect(workflow, contains('SYSTEM_ANR_DISMISSED.txt'));
      expect(workflow, contains("tap_word AUTH 'Misafir'"));
      expect(workflow, contains('Guest button did not reach the home screen.'));
      expect(workflow, contains('adb_retry 15 shell input tap 540 1530'));
      expect(workflow, contains("wait_for_word TUTORIAL_DIALOG 'Anlad'"));
      expect(workflow, contains('reports/UI_*'));
      expect(workflow, contains('reports/COLD_START_LOGCAT.txt'));
      expect(android16Script, contains('trap finalize_validation EXIT'));
      expect(android16Script, contains('capture_diagnostics'));
      expect(android16Script, isNot(contains('uiautomator dump')));
      expect(android16Script, contains('reports/APP_PID.txt'));
      expect(android16Script, contains('ResumedActivity'));
      expect(android16Script, contains('UserMessagingPlatform'));
      expect(
        android16Script,
        contains('APPLICATION_CRASH_ANR_FATAL_OR_PROCESS_DEATH'),
      );
      expect(android16Script, contains('APK_INSTALL=PASS'));
      expect(android16Script, contains('APP_LAUNCH=PASS'));
      expect(android16Script, contains('GUEST_LOGIN=PASS'));
      expect(android16Script, contains('HOME_OYNA=PASS'));
      expect(android16Script, contains('APP_PID=PASS'));
      expect(android16Script, contains('APP_LOGCAT=PASS'));
      expect(android16Script, contains('APP_GATE=PASS'));
      expect(android16Script, contains('RESULT=INFRASTRUCTURE_INCONCLUSIVE'));
      expect(android16Script, contains('RELEASE_GATE=PASS'));
      expect(android16Script, contains('has_infrastructure_failure'));
      expect(
        android16Script,
        contains(
          'if has_infrastructure_failure; then\n'
          '  {\n'
          "    echo 'RESULT=INFRASTRUCTURE_INCONCLUSIVE'",
        ),
      );
      expect(
        android16Script,
        contains('elif [ "\$settings_tutorial_result" -eq 0 ]; then'),
      );
      expect(android16Script, contains('POST_GATE_LOGCAT_BOUNDARY'));
      expect(android16Script, contains('reports/APP_GATE_LOGCAT.txt'));
      expect(
        android16Script,
        contains("grep -Eiv 'ANR in com\\.leventua\\.bilgirotasi'"),
      );
      expect(android16Script, contains('run_settings_tutorial_diagnostic'));
      expect(android16Script, contains('SCREEN_CAPTURE_FAILURES.txt'));
      expect(android16Script, contains('OCR_FAILED_OR_TIMED_OUT'));
      expect(android16Script, contains('retry_capture_screen'));
      expect(android16Script, contains('MANDATORY_APP_GATE_INCOMPLETE'));
      expect(android16Script, contains('EMULATOR_HEALTH=UNHEALTHY'));
      expect(android16Script, contains('PERSISTENT_SYSTEM_UI_ANR'));
      expect(
        android16Script,
        contains("result='INFRASTRUCTURE_RETRY_REQUIRED'"),
      );
      expect(coreWorkflow, contains("grep -Fxq 'EMULATOR_HEALTH=UNHEALTHY'"));
      expect(
        coreWorkflow,
        contains(
          "grep -Fqx 'REASON=APPLICATION_CRASH_ANR_FATAL_OR_PROCESS_DEATH'",
        ),
      );
      expect(coreWorkflow, contains('reports/android16-attempt-1/**'));
      expect(android16Script, contains('for attempt in 1 2 3; do'));
      expect(
        android16Script,
        contains('ADB command failed after 3 attempts: adb \$*'),
      );
      expect(android16Script, contains('adb_retry 30 logcat -c\n'));
      expect(
        android16Script,
        isNot(contains('adb_retry 30 logcat -c || true')),
      );
      expect(
        android16Script,
        contains(r'if ! capture_screen "${label}_${attempt}"; then'),
      );
      expect(
        android16Script,
        contains('PHYSICAL_PLAY_INTERNAL_TESTING_SETTINGS_TUTORIAL=REQUIRED'),
      );
      expect(workflow, contains('FATAL EXCEPTION'));
    });

    test('istenen AAB ve kanıt dosyalarını artifact olarak yükler', () {
      for (final expected in <String>[
        r'dist/${{ env.AAB_FILE }}',
        'AAB_CERTIFICATE.txt',
        'AAB_BADGING.txt',
        'TEST_RESULTS.txt',
        'COLD_START_LOGCAT.txt',
        'APP_GATE_LOGCAT.txt',
        'RELEASE_READINESS.md',
        'DEPENDENCY_GRAPH.txt',
        'ANDROID16_APP_GATE.txt',
        'ANDROID16_VALIDATION_RESULT.txt',
        'INFRASTRUCTURE_DIAGNOSTICS.txt',
        'SCREEN_CAPTURE_FAILURES.txt',
      ]) {
        expect(workflow, contains(expected), reason: expected);
      }
      expect(workflow, contains('python3 tools/rc1_quality_gate.py'));
      expect(workflow, contains('RC1_QUALITY_GATE.md'));
      final qualityGate = File('tools/rc1_quality_gate.py').readAsStringSync();
      expect(qualityGate, isNot(contains('EXPECTED_VERSION')));
      expect(qualityGate, contains('AppBuildInfo sürümü uyuşmuyor'));
    });

    test(
      'Ayarlar ve öğretici fiziksel Internal Testing listesinde zorunludur',
      () {
        final readiness = File('RELEASE_READINESS.md').readAsStringSync();
        final phoneChecklist =
            File('reports/RC1_MANUAL_TEST_CHECKLIST.md').readAsStringSync();
        expect(
          readiness,
          contains('Fiziksel Google Play Internal Testing kontrol listesi'),
        );
        expect(readiness, contains('Ayarlar ve öğretici: ZORUNLU'));
        expect(phoneChecklist, contains('Google Play Internal Testing'));
        expect(phoneChecklist, contains('Ayarlar ekranı fiziksel Android'));
        expect(phoneChecklist, contains('Öğretici görüntülendi'));
      },
    );

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
