import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Android 16 analytics consent kapanmadan PASS sayilmaz', () {
    final script = File(
      'tools/validate_android16_closed_test.sh',
    ).readAsStringSync().replaceAll('\r\n', '\n');

    final consentStart = script.indexOf('analytics_consent_seen=false');
    final consentDetection = script.indexOf(
      "grep -Eqi 'Kullanim|Kullanım|Analizine'",
      consentStart,
    );
    final declineLookup = script.indexOf(
      "find_word \"ENTRY_\${attempt}\" 'Degil|Değil'",
      consentDetection,
    );
    final retryContinue = script.indexOf('continue', declineLookup);
    final authVerification = script.indexOf(
      "if wait_for_word AUTH 'Google|Misafir' 20; then",
      retryContinue,
    );
    final handledPass = script.indexOf(
      "echo 'ANALYTICS_CONSENT_HANDLED=PASS'",
      authVerification,
    );

    expect(consentStart, greaterThanOrEqualTo(0));
    expect(consentDetection, greaterThan(consentStart));
    expect(declineLookup, greaterThan(consentDetection));
    expect(retryContinue, greaterThan(declineLookup));
    expect(authVerification, greaterThan(retryContinue));
    expect(handledPass, greaterThan(authVerification));

    final beforeAuthVerification = script.substring(
      consentDetection,
      authVerification,
    );
    expect(
      beforeAuthVerification,
      isNot(contains('ANALYTICS_CONSENT_HANDLED=PASS')),
      reason: 'Popup dokunusu tek basina basari sayilmamali.',
    );
    expect(
      script,
      contains("find_word \"ENTRY_\${attempt}\" 'Simdi|Şimdi'"),
      reason: 'Degil OCR bulunamazsa Simdi ikinci tercih olmali.',
    );
    expect(
      script,
      contains('adb_retry 15 shell input tap 785 1240'),
      reason: '#323 Pixel 2 ekraninda fallback gercek aksiyon bolgesinde olmali.',
    );
    expect(
      script,
      contains('if [ "\$auth_status" -eq 75 ]; then'),
      reason: 'Emulator altyapi hatasi uygulama kapisi hatasina cevrilmemeli.',
    );
  });
}
