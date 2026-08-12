import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('release readiness raporu canlı build değerlerinden üretilir', () async {
    final temp = await Directory.systemTemp.createTemp(
      'bilgi_rotasi_release_readiness_',
    );
    addTearDown(() async {
      if (await temp.exists()) {
        await temp.delete(recursive: true);
      }
    });

    final assets = Directory('${temp.path}/assets');
    await assets.create(recursive: true);
    await File('${temp.path}/pubspec.yaml').writeAsString(
      'name: fixture\nversion: 9.8.7+654\n',
    );
    await File('${assets.path}/questions.json').writeAsString(
      '[{"id":"1"},{"id":"2"},{"id":"3"}]',
    );

    final output = File('${temp.path}/reports/RELEASE_READINESS.md');
    final result = await Process.run('python3', <String>[
      File('tools/release_readiness_report.py').absolute.path,
      '--root',
      temp.path,
      '--output',
      output.path,
      '--source-sha',
      'abc123fixture',
      '--source-ref',
      'release/test-fixture',
      '--aab-file',
      'BilgiRotasi-9.8.7-654-closed-test.aab',
      '--workflow-run-url',
      'https://example.invalid/actions/runs/42',
    ]);

    expect(
      result.exitCode,
      0,
      reason: 'stdout=${result.stdout}\nstderr=${result.stderr}',
    );
    final report = await output.readAsString();

    expect(report, contains('# Bilgi Rotası 9.8.7+654'));
    expect(report, contains('Toplam soru: **3**'));
    expect(report, contains('`abc123fixture`'));
    expect(report, contains('`release/test-fixture`'));
    expect(report, contains('`BilgiRotasi-9.8.7-654-closed-test.aab`'));
    expect(report, contains('https://example.invalid/actions/runs/42'));

    for (final stale in <String>[
      '1.68.8+98',
      '73ee39c6d32eb49944db2eef0e89477a23c78e70',
      'BilgiRotasi-1.68.8-98-closed-test.aab',
      '6710 soru',
    ]) {
      expect(report, isNot(contains(stale)));
    }
  });

  test('izlenen release readiness dosyası tarihsel build sabiti taşımaz', () {
    final source = File('RELEASE_READINESS.md').readAsStringSync();
    expect(source, isNot(contains('1.68.8+98')));
    expect(
      source,
      isNot(contains('73ee39c6d32eb49944db2eef0e89477a23c78e70')),
    );
    expect(source, isNot(contains('BilgiRotasi-1.68.8-98-closed-test.aab')));
    expect(source, isNot(contains('6710 soru')));
  });

  test('RC1 wrapper yalnız GitHub Actions ortamında dinamik raporu yeniler', () {
    final wrapper = File('tools/rc1_quality_gate.py').readAsStringSync();
    expect(wrapper, contains('GITHUB_ACTIONS'));
    expect(wrapper, contains('GITHUB_SHA'));
    expect(wrapper, contains('GITHUB_REF_NAME'));
    expect(wrapper, contains('AAB_FILE'));
    expect(wrapper, contains('generate_report'));
    expect(wrapper, contains('rc1_quality_gate_impl'));
  });
}
