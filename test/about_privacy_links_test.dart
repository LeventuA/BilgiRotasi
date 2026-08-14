import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('about privacy links use ZMila Studio endpoints', () {
    final source = File('lib/about_privacy.dart').readAsStringSync();

    expect(source, contains('https://zmilastudio.github.io/BilgiRotasi/'));
    expect(source, contains('privacy-policy.html'));
    expect(source, contains('account-deletion.html'));
    expect(source, contains('terms-of-use.html'));
    expect(source, contains('community-guidelines.html'));
    expect(source, contains('BilgiRotasidestek@gmail.com'));
    expect(source, isNot(contains('https://leventua.github.io/BilgiRotasi/')));
    expect(source, isNot(contains('BilgiRotasi10@gmail.com')));
  });
}
