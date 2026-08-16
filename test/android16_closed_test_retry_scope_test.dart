import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final validator = File('tools/validate_android16_closed_test.sh');

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

  setUpAll(() {
    expect(validator.existsSync(), isTrue);
  });

  test('retry_capture_screen çağıranın attempt sayacını değiştirmez', () {
    final source = validator.readAsStringSync().replaceAll('\r\n', '\n');
    final match = RegExp(
      r'retry_capture_screen\(\) \{\n([\s\S]*?)\n\}\n\nfind_word\(\)',
    ).firstMatch(source);
    expect(match, isNotNull);

    final tempDir = Directory.systemTemp.createTempSync(
      'bilgi_rotasi_android16_retry_scope_',
    );
    addTearDown(() => tempDir.deleteSync(recursive: true));
    final script = File('${tempDir.path}/scope_test.sh')
      ..writeAsStringSync(
        '#!/usr/bin/env bash\n'
        'set -euo pipefail\n'
        'capture_screen() { return 0; }\n'
        'retry_capture_screen() {\n${match!.group(1)}\n}\n'
        'attempt=2\n'
        'retry_capture_screen SETTINGS_TUTORIAL_2\n'
        "printf '%s\\n' \"\$attempt\"\n",
      );

    final result = Process.runSync(
      bashExecutable(),
      [bashPath(script.path)],
    );
    expect(result.exitCode, 0, reason: '${result.stdout}\n${result.stderr}');
    expect(result.stdout.toString().trim(), '2');
  });

  test('tutorial taraması helper retry sayacından bağımsız sayaç kullanır', () {
    final source = validator.readAsStringSync().replaceAll('\r\n', '\n');
    expect(
      source,
      contains('local attempts="\${2:-3}"\n  local attempt\n'),
    );
    expect(source, contains('local tutorial_attempt\n'));
    expect(source, contains('for tutorial_attempt in \$(seq 1 4); do'));
    expect(
      source,
      contains(
        'retry_capture_screen "SETTINGS_TUTORIAL_\${tutorial_attempt}"',
      ),
    );
    expect(
      source,
      contains(
        'find_word "SETTINGS_TUTORIAL_\${tutorial_attempt}" \'Yeniden\'',
      ),
    );
    expect(source, isNot(contains('python3 tools/find_ocr_word.py')));
    expect(source, contains("BEGIN { IGNORECASE = 1 }"));
  });
}
