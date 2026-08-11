import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('gerçek RC2 OCR TSV biçiminde System UI ANR algılanır', () {
    final detector = File('tools/detect_android16_system_anr.sh');
    final fixture = File(
      'test/fixtures/android16_system_ui_anr_multiline.tsv',
    );

    expect(detector.existsSync(), isTrue);
    expect(fixture.existsSync(), isTrue);

    final result = Process.runSync('bash', [detector.path, fixture.path]);
    expect(
      result.exitCode,
      0,
      reason: '${result.stdout}\n${result.stderr}',
    );
  });

  test('Process system ANR satırlara bölünse de algılanır', () {
    final detector = File('tools/detect_android16_system_anr.sh');
    final tempDir = Directory.systemTemp.createTempSync(
      'bilgi_rotasi_process_system_anr_',
    );
    addTearDown(() => tempDir.deleteSync(recursive: true));

    final fixture = File('${tempDir.path}/process_system.tsv')
      ..writeAsStringSync(
        'level\tpage_num\tblock_num\tpar_num\tline_num\tword_num\tleft\ttop\twidth\theight\tconf\ttext\n'
        '5\t1\t1\t1\t1\t1\t0\t0\t1\t1\t95\tProcess\n'
        '5\t1\t1\t1\t1\t2\t0\t0\t1\t1\t95\tsystem\n'
        "5\t1\t1\t1\t1\t3\t0\t0\t1\t1\t95\tisn't\n"
        '5\t1\t1\t1\t1\t4\t0\t0\t1\t1\t95\tresponding\n',
      );

    final result = Process.runSync('bash', [detector.path, fixture.path]);
    expect(result.exitCode, 0);
  });

  test('normal giriş ekranı sistem ANR sayılmaz', () {
    final detector = File('tools/detect_android16_system_anr.sh');
    final tempDir = Directory.systemTemp.createTempSync(
      'bilgi_rotasi_normal_auth_',
    );
    addTearDown(() => tempDir.deleteSync(recursive: true));

    final fixture = File('${tempDir.path}/normal_auth.tsv')
      ..writeAsStringSync(
        'level\tpage_num\tblock_num\tpar_num\tline_num\tword_num\tleft\ttop\twidth\theight\tconf\ttext\n'
        '5\t1\t1\t1\t1\t1\t0\t0\t1\t1\t95\tGoogle\n'
        '5\t1\t1\t1\t1\t2\t0\t0\t1\t1\t95\tMisafir\n',
      );

    final result = Process.runSync('bash', [detector.path, fixture.path]);
    expect(result.exitCode, isNot(0));
  });
}
