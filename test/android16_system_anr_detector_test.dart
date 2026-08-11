import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
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

  test('gerçek RC2 OCR TSV biçiminde System UI ANR algılanır', () {
    final detector = File('tools/detect_android16_system_anr.sh');
    final fixture = File('test/fixtures/android16_system_ui_anr_multiline.tsv');
    final tempDir = Directory.systemTemp.createTempSync(
      'bilgi_rotasi_system_ui_anr_',
    );
    addTearDown(() => tempDir.deleteSync(recursive: true));

    expect(detector.existsSync(), isTrue);
    expect(fixture.existsSync(), isTrue);

    final result = Process.runSync(bashExecutable(), [
      detector.path,
      fixture.path,
      tempDir.path,
    ]);
    expect(result.exitCode, 0, reason: '${result.stdout}\n${result.stderr}');
    expect(
      File('${tempDir.path}/ANDROID16_EMULATOR_HEALTH.txt').existsSync(),
      isFalse,
      reason: 'Tek sistem ANR gözlemi retry tetiklememeli.',
    );
  });

  test('Process system ANR satırlara bölünse de algılanır', () {
    final detector = File('tools/detect_android16_system_anr.sh');
    final tempDir = Directory.systemTemp.createTempSync(
      'bilgi_rotasi_process_system_anr_',
    );
    addTearDown(() => tempDir.deleteSync(recursive: true));

    final fixture = File(
      '${tempDir.path}/process_system.tsv',
    )..writeAsStringSync(
      'level\tpage_num\tblock_num\tpar_num\tline_num\tword_num\tleft\ttop\twidth\theight\tconf\ttext\n'
      '5\t1\t1\t1\t1\t1\t0\t0\t1\t1\t95\tProcess\n'
      '5\t1\t1\t1\t1\t2\t0\t0\t1\t1\t95\tsystem\n'
      "5\t1\t1\t1\t1\t3\t0\t0\t1\t1\t95\tisn't\n"
      '5\t1\t1\t1\t1\t4\t0\t0\t1\t1\t95\tresponding\n',
    );

    final result = Process.runSync(bashExecutable(), [
      detector.path,
      fixture.path,
      tempDir.path,
    ]);
    expect(result.exitCode, 0);
  });

  test('iki sistem ANR gözlemi temiz emülatör retry işareti üretir', () {
    final detector = File('tools/detect_android16_system_anr.sh');
    final fixture = File('test/fixtures/android16_system_ui_anr_multiline.tsv');
    final tempDir = Directory.systemTemp.createTempSync(
      'bilgi_rotasi_recurring_system_anr_',
    );
    addTearDown(() => tempDir.deleteSync(recursive: true));

    File('${tempDir.path}/SYSTEM_ANR_DISMISSED.txt').writeAsStringSync(
      'ENTRY_1: Android system ANR dialog observed.\n'
      'ENTRY_1: Android system ANR dialog dismissed with Wait.\n',
    );

    final result = Process.runSync(bashExecutable(), [
      detector.path,
      fixture.path,
      tempDir.path,
    ]);
    expect(result.exitCode, 0);

    final health = File('${tempDir.path}/ANDROID16_EMULATOR_HEALTH.txt');
    expect(health.existsSync(), isTrue);
    expect(health.readAsStringSync(), contains('EMULATOR_HEALTH=UNHEALTHY'));
    expect(
      health.readAsStringSync(),
      contains('REASON=RECURRING_ANDROID_SYSTEM_ANR'),
    );
  });

  test('normal giriş ekranı sistem ANR sayılmaz', () {
    final detector = File('tools/detect_android16_system_anr.sh');
    final tempDir = Directory.systemTemp.createTempSync(
      'bilgi_rotasi_normal_auth_',
    );
    addTearDown(() => tempDir.deleteSync(recursive: true));

    final fixture = File('${tempDir.path}/normal_auth.tsv')..writeAsStringSync(
      'level\tpage_num\tblock_num\tpar_num\tline_num\tword_num\tleft\ttop\twidth\theight\tconf\ttext\n'
      '5\t1\t1\t1\t1\t1\t0\t0\t1\t1\t95\tGoogle\n'
      '5\t1\t1\t1\t1\t2\t0\t0\t1\t1\t95\tMisafir\n',
    );

    File(
      '${tempDir.path}/SYSTEM_ANR_DISMISSED.txt',
    ).writeAsStringSync('ENTRY_1: Android system ANR dialog observed.\n');

    final result = Process.runSync(bashExecutable(), [
      detector.path,
      fixture.path,
      tempDir.path,
    ]);
    expect(result.exitCode, isNot(0));
    expect(
      File('${tempDir.path}/ANDROID16_EMULATOR_HEALTH.txt').existsSync(),
      isFalse,
      reason: 'Normal auth ekranı mevcut geçmişe rağmen retry üretmemeli.',
    );
  });
}
