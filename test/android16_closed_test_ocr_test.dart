import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final helper = File('tools/find_ocr_word.py');
  final validator = File('tools/validate_android16_closed_test.sh');

  String pythonExecutable() => Platform.isWindows ? 'python' : 'python3';

  setUpAll(() {
    expect(helper.existsSync(), isTrue);
    expect(validator.existsSync(), isTrue);
  });

  test('Run #9 tarzı Yeniden OCR satırını deterministik koordinata çözer', () {
    final tempDir = Directory.systemTemp.createTempSync(
      'bilgi_rotasi_android16_ocr_',
    );
    addTearDown(() => tempDir.deleteSync(recursive: true));
    final fixture = File('${tempDir.path}/tutorial.tsv')
      ..writeAsStringSync(
        'level\tpage_num\tblock_num\tpar_num\tline_num\tword_num\t'
        'left\ttop\twidth\theight\tconf\ttext\n'
        '5\t1\t26\t1\t1\t2\t365\t1703\t150\t31\t90\tYeniden\n',
      );

    final exact = Process.runSync(
      pythonExecutable(),
      [helper.path, fixture.path, 'Yeniden'],
    );
    expect(exact.exitCode, 0, reason: '${exact.stdout}\n${exact.stderr}');
    expect(exact.stdout.toString().trim(), '440 1718');

    final caseInsensitive = Process.runSync(
      pythonExecutable(),
      [helper.path, fixture.path, '^yeniden\$'],
    );
    expect(
      caseInsensitive.exitCode,
      0,
      reason: '${caseInsensitive.stdout}\n${caseInsensitive.stderr}',
    );
    expect(caseInsensitive.stdout.toString().trim(), '440 1718');

    final missing = Process.runSync(
      pythonExecutable(),
      [helper.path, fixture.path, 'Anlad'],
    );
    expect(missing.exitCode, 0, reason: '${missing.stdout}\n${missing.stderr}');
    expect(missing.stdout.toString().trim(), isEmpty);
  });

  test('Android 16 validator OCR koordinatlarını Python yardımcıdan alır', () {
    final source = validator.readAsStringSync();
    expect(source, contains('python3 tools/find_ocr_word.py'));
    expect(source, isNot(contains('BEGIN { IGNORECASE = 1 }')));
  });
}
