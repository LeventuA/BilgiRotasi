import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final validator = File('tools/validate_admob_android16_cold_start.sh');
  final fakeAdb = File('test/fixtures/fake_adb_android16.sh');

  String bashExecutable() {
    if (!Platform.isWindows) return 'bash';
    final candidates = <String>[
      r'C:\Program Files\Git\bin\bash.exe',
      r'C:\Program Files (x86)\Git\bin\bash.exe',
    ];
    return candidates.firstWhere(
      (candidate) => File(candidate).existsSync(),
      orElse: () => 'bash',
    );
  }

  String bashPath(String path) {
    final normalized = path.replaceAll('\\', '/');
    final driveMatch = RegExp(r'^([A-Za-z]):/(.*)$').firstMatch(normalized);
    if (driveMatch == null) return normalized;
    return '/${driveMatch.group(1)!.toLowerCase()}/${driveMatch.group(2)}';
  }

  ({ProcessResult result, Directory reports}) runScenario(String scenario) {
    final tempDir = Directory.systemTemp.createTempSync(
      'bilgi_rotasi_admob_android16_',
    );
    addTearDown(() => tempDir.deleteSync(recursive: true));
    final apk = File('${tempDir.path}/app-release.apk')..writeAsBytesSync([1]);
    final reports = Directory('${tempDir.path}/reports');
    final result = Process.runSync(
      bashExecutable(),
      [validator.path, bashPath(apk.path)],
      environment: {
        'ADB_FAKE_SCRIPT': bashPath(fakeAdb.absolute.path),
        'FAKE_ADB_STATE_DIR': bashPath(tempDir.path),
        'FAKE_ADB_SCENARIO': scenario,
        'REPORTS_DIR': bashPath(reports.path),
        'STARTUP_WAIT_SECONDS': '0',
        'RETRY_WAIT_SECONDS': '0',
      },
    );
    return (result: result, reports: reports);
  }

  setUpAll(() {
    expect(validator.existsSync(), isTrue);
    expect(fakeAdb.existsSync(), isTrue);
  });

  test('paket servisi Broken pipe yalnız altyapı retry sonucu üretir', () {
    final execution = runScenario('infrastructure_install');
    expect(
      execution.result.exitCode,
      75,
      reason: '${execution.result.stdout}\n${execution.result.stderr}',
    );
    final health =
        File(
          '${execution.reports.path}/ADMOB_ANDROID16_EMULATOR_HEALTH.txt',
        ).readAsStringSync();
    final result =
        File(
          '${execution.reports.path}/ADMOB_ANDROID16_VALIDATION_RESULT.txt',
        ).readAsStringSync();
    expect(health, contains('EMULATOR_HEALTH=UNHEALTHY'));
    expect(health, contains('ANDROID_PACKAGE_SERVICE_UNAVAILABLE'));
    expect(result, contains('RESULT=INFRASTRUCTURE_RETRY_REQUIRED'));
    expect(result, contains('RELEASE_GATE=FAIL'));
    expect(result, isNot(contains('APP_GATE=PASS')));
  });

  test('kayıp paket servisi yalnız altyapı retry sonucu üretir', () {
    final execution = runScenario('missing_package_service');
    expect(
      execution.result.exitCode,
      75,
      reason: '${execution.result.stdout}\n${execution.result.stderr}',
    );
    final health =
        File(
          '${execution.reports.path}/ADMOB_ANDROID16_EMULATOR_HEALTH.txt',
        ).readAsStringSync();
    final result =
        File(
          '${execution.reports.path}/ADMOB_ANDROID16_VALIDATION_RESULT.txt',
        ).readAsStringSync();
    expect(health, contains('EMULATOR_HEALTH=UNHEALTHY'));
    expect(health, contains('ANDROID_PACKAGE_SERVICE_UNAVAILABLE'));
    expect(result, contains('RESULT=INFRASTRUCTURE_RETRY_REQUIRED'));
    expect(result, contains('RELEASE_GATE=FAIL'));
    expect(result, isNot(contains('APP_GATE=PASS')));
  });

  test('Bilgi Rotası FATAL EXCEPTION altyapı retry olarak sınıflanmaz', () {
    final execution = runScenario('app_crash');
    expect(execution.result.exitCode, 1);
    final result =
        File(
          '${execution.reports.path}/ADMOB_ANDROID16_VALIDATION_RESULT.txt',
        ).readAsStringSync();
    expect(
      result,
      contains('REASON=APPLICATION_CRASH_ANR_FATAL_OR_PROCESS_DEATH'),
    );
    expect(
      File(
        '${execution.reports.path}/ADMOB_ANDROID16_EMULATOR_HEALTH.txt',
      ).existsSync(),
      isFalse,
    );
  });

  test('geçici paket servisi Broken pipe hatası aynı denemede toparlanır', () {
    final execution = runScenario('transient_infrastructure_install');
    expect(
      execution.result.exitCode,
      0,
      reason: '${execution.result.stdout}\n${execution.result.stderr}',
    );
    final attempts =
        File(
          '${execution.reports.path}/ADMOB_ANDROID16_INSTALL_ATTEMPTS.txt',
        ).readAsStringSync();
    expect(attempts, contains('ATTEMPT=1 STATUS=1'));
    expect(attempts, contains('ATTEMPT=2 STATUS=0'));
    expect(
      File(
        '${execution.reports.path}/ADMOB_ANDROID16_EMULATOR_HEALTH.txt',
      ).existsSync(),
      isFalse,
    );
    expect(
      File(
        '${execution.reports.path}/ADMOB_ANDROID16_APP_GATE.txt',
      ).readAsStringSync(),
      contains('APP_GATE=PASS'),
    );
  });

  test('kanıtsız APK kurulum hatası retry üretmez', () {
    final execution = runScenario('invalid_apk');
    expect(execution.result.exitCode, 1);
    final result =
        File(
          '${execution.reports.path}/ADMOB_ANDROID16_VALIDATION_RESULT.txt',
        ).readAsStringSync();
    expect(
      result,
      contains('REASON=APK_INSTALL_FAILED_WITHOUT_INFRASTRUCTURE_EVIDENCE'),
    );
    expect(
      File(
        '${execution.reports.path}/ADMOB_ANDROID16_EMULATOR_HEALTH.txt',
      ).existsSync(),
      isFalse,
    );
  });

  test('sağlıklı cold-start bütün zorunlu kapıları geçirir', () {
    final execution = runScenario('success');
    expect(
      execution.result.exitCode,
      0,
      reason: '${execution.result.stdout}\n${execution.result.stderr}',
    );
    final gate =
        File(
          '${execution.reports.path}/ADMOB_ANDROID16_APP_GATE.txt',
        ).readAsStringSync();
    final result =
        File(
          '${execution.reports.path}/ADMOB_ANDROID16_VALIDATION_RESULT.txt',
        ).readAsStringSync();
    for (final expected in [
      'APK_INSTALL=PASS',
      'APP_LAUNCH=PASS',
      'APP_PID=PASS',
      'APP_ACTIVITY=PASS',
      'APP_LOGCAT=PASS',
      'APP_GATE=PASS',
    ]) {
      expect(gate, contains(expected), reason: expected);
    }
    expect(result, contains('RESULT=PASS'));
    expect(result, contains('RELEASE_GATE=PASS'));
  });

  test('AdMob PR workflow retry ve final gate sözleşmesini korur', () {
    final workflow =
        File('.github/workflows/admob-pr-validation.yml').readAsStringSync();
    expect(
      RegExp(
        r'uses: reactivecircus/android-emulator-runner@v2',
      ).allMatches(workflow).length,
      2,
    );
    expect(
      RegExp(r'disable-animations:\s*false').allMatches(workflow).length,
      2,
    );
    expect(workflow, isNot(contains('disable-animations: true')));
    expect(workflow, contains('id: android16_attempt_1'));
    expect(workflow, contains('id: android16_attempt_2'));
    expect(
      workflow,
      contains('bash tools/validate_admob_android16_cold_start.sh'),
    );
    expect(workflow, isNot(contains('adb install -r ')));
    expect(
      workflow,
      contains("REASON=APPLICATION_CRASH_ANR_FATAL_OR_PROCESS_DEATH"),
    );
    expect(workflow, contains('RESULT=INFRASTRUCTURE_RETRY_REQUIRED'));
    expect(workflow, contains('ADMOB_ANDROID16_APP_GATE.txt'));
    expect(workflow, contains('reports/admob-android16-attempt-1/**'));
  });
}
