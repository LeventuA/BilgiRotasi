import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Android 16 guest girisinden sonra HOME gozlemi dokunus uretmez', () {
    final script = File(
      'tools/validate_android16_closed_test.sh',
    ).readAsStringSync().replaceAll('\r\n', '\n');

    const guestTap = r"tap_word AUTH '^Misafir$'";
    final authTap = script.indexOf(guestTap);
    final homeLoop = script.indexOf(
      r'for attempt in $(seq 1 40); do',
      authTap + guestTap.length,
    );
    final homeFailure = script.indexOf(
      'Guest button did not reach the home screen.',
      homeLoop,
    );

    expect(authTap, greaterThanOrEqualTo(0));
    expect(homeLoop, greaterThan(authTap));
    expect(homeFailure, greaterThan(homeLoop));
    expect(script.indexOf(guestTap, authTap + guestTap.length), -1);

    final homeObservation = script.substring(homeLoop, homeFailure);
    expect(
      homeObservation,
      contains(r'''find_word "HOME_${attempt}" 'Oyna' '''.trim()),
      reason: 'Guest sonrasi zorunlu Home/Oyna kapisi korunmali.',
    );
    expect(
      homeObservation,
      isNot(contains('guest_point=')),
      reason: '#325 sonrasi HOME dongusu Misafir koordinati cikarmamali.',
    );
    expect(
      homeObservation,
      isNot(contains(r'''find_word "HOME_${attempt}" '^Misafir$' '''.trim())),
      reason: 'AUTH sonrasi Misafir OCR tokeni yeniden tiklanmamalidir.',
    );
    expect(
      homeObservation,
      isNot(contains('shell input tap')),
      reason: 'HOME bekleme dongusu salt-okunur kalmali.',
    );

    expect(script, contains("echo 'GUEST_LOGIN=PASS'"));
    expect(script, contains("echo 'HOME_OYNA=PASS'"));
    expect(
      script,
      contains('if emulator_is_unhealthy; then\n      exit 75'),
      reason: 'Emulator altyapi siniflandirmasi korunmali.',
    );
  });
}
