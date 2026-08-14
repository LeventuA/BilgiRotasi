import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Android 16 analytics consent kapanmadan auth ekrani sayilmaz', () {
    final script = File(
      'tools/validate_android16_closed_test.sh',
    ).readAsStringSync().replaceAll('\r\n', '\n');

    final consentStart = script.indexOf('analytics_consent_seen=false');
    final exactEntryGuest = script.indexOf(
      'find_word "ENTRY_\${attempt}" \'^Misafir\$\'',
      consentStart,
    );
    final consentDetection = script.indexOf(
      "grep -Eqi 'Kullanim|Kullanım|Analizine'",
      exactEntryGuest,
    );
    final declineLookup = script.indexOf(
      "find_word \"ENTRY_\${attempt}\" 'Degil|Değil'",
      consentDetection,
    );
    final retryContinue = script.indexOf('continue', declineLookup);
    final authVerification = script.indexOf(
      "if wait_for_word AUTH '^Misafir\$' 20; then",
      retryContinue,
    );
    final exactGoogleVerification = script.indexOf(
      'find_word AUTH \'^Google\$\'',
      authVerification,
    );
    final exactGuestVerification = script.indexOf(
      'find_word AUTH \'^Misafir\$\'',
      exactGoogleVerification,
    );
    final handledPass = script.indexOf(
      "echo 'ANALYTICS_CONSENT_HANDLED=PASS'",
      authVerification,
    );

    expect(consentStart, greaterThanOrEqualTo(0));
    expect(exactEntryGuest, greaterThan(consentStart));
    expect(consentDetection, greaterThan(exactEntryGuest));
    expect(declineLookup, greaterThan(consentDetection));
    expect(retryContinue, greaterThan(declineLookup));
    expect(authVerification, greaterThan(retryContinue));
    expect(exactGoogleVerification, greaterThan(authVerification));
    expect(exactGuestVerification, greaterThan(exactGoogleVerification));
    expect(handledPass, greaterThan(authVerification));

    final authFlow = script.substring(consentStart, exactGuestVerification + 40);
    expect(
      authFlow,
      isNot(contains("'Google|Misafir'")),
      reason:
          'Google/Firebase aciklama metni gevsek Google eslesmesiyle auth sayilmamali.',
    );
    expect(
      script,
      contains("find_word \"ENTRY_\${attempt}\" 'Simdi|Şimdi'"),
      reason: 'Degil OCR bulunamazsa Simdi ikinci tercih olmali.',
    );
    expect(
      script,
      contains('adb_retry 15 shell input tap 785 1240'),
      reason: '#323/#324 fallback gercek aksiyon bolgesinde kalmali.',
    );
    expect(
      script,
      contains('if [ "\$auth_status" -eq 75 ]; then'),
      reason: 'Emulator altyapi hatasi uygulama kapisi hatasina cevrilmemeli.',
    );
  });

  test('RC2 324 Google Firebase OCR metni auth ekrani sayilmaz', () {
    // RC2 #324 UI_ENTRY_2 / UI_AUTH OCR kanitindaki ayirt edici tokenlar.
    const popupWords = <String>[
      'Kullanim',
      'Analizine',
      'Google/Firebase',
      'Simdi',
      'Degil',
    ];
    const realAuthWords = <String>['Google', 'Misafir'];

    final oldLooseAuth = RegExp(r'Google|Misafir', caseSensitive: false);
    final exactGuest = RegExp(r'^Misafir$', caseSensitive: false);
    final exactGoogle = RegExp(r'^Google$', caseSensitive: false);
    final decline = RegExp(r'Degil|Değil', caseSensitive: false);

    expect(
      popupWords.firstWhere(oldLooseAuth.hasMatch),
      'Google/Firebase',
      reason: '#324 eski gevsek matcher ile tam burada yanlis pozitif verdi.',
    );
    expect(
      popupWords.where(exactGuest.hasMatch),
      isEmpty,
      reason: 'Consent popup gercek Misafir butonu icermiyor.',
    );
    expect(
      popupWords.any(decline.hasMatch),
      isTrue,
      reason: '#324 popupinda reddetme aksiyonu OCR ile goruluyor.',
    );
    expect(realAuthWords.any(exactGoogle.hasMatch), isTrue);
    expect(realAuthWords.any(exactGuest.hasMatch), isTrue);
  });
}
