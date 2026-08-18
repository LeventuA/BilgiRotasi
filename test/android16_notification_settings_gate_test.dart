import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('bildirim opt-in karti Ayarlar aramasindan once kapatilir', () {
    final source = File(
      'tools/validate_android16_closed_test.sh',
    ).readAsStringSync().replaceAll('\r\n', '\n');

    final diagnosticStart = source.indexOf(
      'run_settings_tutorial_diagnostic() {',
    );
    final diagnosticEnd = source.indexOf('\n}\n\ntap_word()', diagnosticStart);

    expect(diagnosticStart, greaterThanOrEqualTo(0));
    expect(diagnosticEnd, greaterThan(diagnosticStart));

    final diagnostic = source.substring(diagnosticStart, diagnosticEnd);
    const homeCapture = r'retry_capture_screen HOME_SETTINGS';
    const settingsNeedle =
        r'''settings_point="$(find_word HOME_SETTINGS 'Ayarlar')"''';
    final firstCapture = diagnostic.indexOf(homeCapture);
    final notificationDetection = diagnostic.indexOf(
      r"find_word HOME_SETTINGS 'Bildirimleri'",
    );
    final declineDetection = diagnostic.indexOf(
      r"find_word HOME_SETTINGS 'Degil|Değil'",
    );
    final declineTap = diagnostic.indexOf(
      r"tap_word HOME_SETTINGS 'Degil|Değil'",
    );
    final secondCapture = diagnostic.indexOf(
      homeCapture,
      firstCapture + homeCapture.length,
    );
    final settingsSearch = diagnostic.indexOf(settingsNeedle);

    expect(firstCapture, greaterThanOrEqualTo(0));
    expect(notificationDetection, greaterThan(firstCapture));
    expect(declineDetection, greaterThan(notificationDetection));
    expect(declineTap, greaterThan(declineDetection));
    expect(secondCapture, greaterThan(declineTap));
    expect(settingsSearch, greaterThan(secondCapture));

    expect(
      diagnostic,
      contains(r'adb_retry 15 shell input tap 540 1530 || return 1'),
      reason: 'Ayarlar OCR fallback sozlesmesi korunmali.',
    );
    expect(
      diagnostic,
      contains(r"wait_for_word SETTINGS 'Ayarlar' 6 || return 1"),
      reason: 'Zorunlu Ayarlar kapisi gevsetilmemeli.',
    );
  });
}
