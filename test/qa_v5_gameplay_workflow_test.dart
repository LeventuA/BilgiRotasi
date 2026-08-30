import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  const workflowPath =
      '.github/workflows/word-hunt-v5-gameplay-android16-qa.yml';
  const mainPath = 'tools/word_hunt_v5_gameplay_qa_main.dart';
  const shellPath = 'tools/word_hunt_v5_gameplay_android16.sh';
  const comparisonPath = 'tools/create_word_hunt_v5_comparisons.py';

  test('V5 QA entrypoint gerçek production gameplay widgetını kullanır', () {
    final source = File(mainPath).readAsStringSync();

    expect(source, contains('WordHuntLevelProductionScreen'));
    expect(source, contains('WordHuntStarterContent.baslangicLimani'));
    expect(source, contains('const <int>[1, 5, 8, 10]'));
    expect(source, contains("child: const Text('QA B5+65')"));
    expect(source, contains('timeOffsetSeconds: 65'));
    expect(source, isNot(contains('WordHuntLevelPlayResult(')));
    expect(source, isNot(contains('recordLevelResult(')));
  });

  test(
    'V5 QA workflow Android 16 ve exact gameplay artifact sözleşmesidir',
    () {
      final workflow = File(workflowPath).readAsStringSync();

      expect(workflow, contains('workflow_dispatch:'));
      expect(workflow, contains('api-level: 36'));
      expect(workflow, contains('target: aosp_atd'));
      expect(workflow, contains('profile: pixel_2'));
      expect(workflow, contains('adb shell wm size 1080x1920'));
      expect(workflow, contains('adb shell wm density 420'));
      expect(workflow, contains('-t tools/word_hunt_v5_gameplay_qa_main.dart'));
      expect(
        workflow,
        contains('bash tools/word_hunt_v5_gameplay_android16.sh'),
      );
      expect(workflow, contains('create_word_hunt_v5_comparisons.py'));
      expect(workflow, contains('retention-days: 21'));
      expect(workflow, isNot(contains('flutter build appbundle')));
      expect(workflow, isNot(contains('firebase deploy')));
    },
  );

  test('V5 QA shell gerçek adb swipe ve zorunlu kanıtları üretir', () {
    final shell = File(shellPath).readAsStringSync();

    for (final file in <String>[
      '01_B1_INITIAL.png',
      '02_B5_INITIAL.png',
      '03_B8_INITIAL.png',
      '04_B10_INITIAL.png',
      '05_B5_ANKARA_FOUND.png',
      '06_B5_BASKENT_REVERSE_FOUND.png',
      '07_B5_AFTER_65_SECONDS.png',
      'ANDROID_DISPLAY.txt',
      'LOGCAT.txt',
      'QA_SUMMARY.txt',
      'SHA256SUMS.txt',
    ]) {
      expect(
        shell,
        contains(file),
        reason: '$file artifact sözleşmesinde yok.',
      );
    }

    expect(shell, contains('adb shell input swipe'));
    expect(shell, contains('log-cell-center'));
    expect(shell, contains('assert-log-grid'));
    expect(shell, contains('assert-grid-visual-change'));
    expect(shell, isNot(contains('uiautomator dump')));
    expect(shell, contains('Gameplay level did not open after bounded taps'));
    expect(shell, contains("timeout 10s adb logcat -d -s flutter:I '*:S'"));
    expect(shell, contains('cell-center'));
    expect(shell, contains("5 2"));
    expect(shell, contains("0 7"));
    expect(shell, contains("0 4"));
    expect(shell, contains("6 4"));
    expect(shell, contains('ANKARA'));
    expect(shell, contains('BASKENT_REVERSE'));
    expect(shell, isNot(contains('_foundTargets')));
    expect(shell, isNot(contains('WordHuntLevelPlayResult')));
    expect(
      File('tools/qa/kelime_avi_v5_gameplay_reference.jpg').existsSync(),
      isTrue,
    );
  });

  test('V5 QA gerçek referans ile B1 ve B10 karşılaştırmalarını üretir', () {
    final source = File(comparisonPath).readAsStringSync();

    expect(source, contains('kelime_avi_v5_gameplay_reference.jpg'));
    expect(source, contains('V5_GAMEPLAY_REFERENCE_1080x1920.png'));
    expect(source, contains('REFERENCE_VS_B1.png'));
    expect(source, contains('REFERENCE_VS_B10.png'));
    expect(source, contains('CANVAS = (1080, 1920)'));
  });
}
