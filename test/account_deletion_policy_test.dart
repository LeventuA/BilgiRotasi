import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('hesap silme bulut ve kimlik adımlarını içerir', () {
    final source = File(
      'lib/account_cloud.dart',
    ).readAsStringSync();

    expect(
      source,
      contains('deleteAccountAndCloudData'),
    );
    expect(
      source,
      contains('reauthenticateWithCredential'),
    );
    expect(
      source,
      contains(".collection('users')"),
    );
    expect(
      source,
      contains('.doc(user.uid).delete()'),
    );
    expect(
      source,
      contains('await user.delete();'),
    );
  });

  test('gizlilik ekranı güncel veri kullanımını açıklar', () {
    final source = File(
      'lib/about_privacy.dart',
    ).readAsStringSync();

    expect(
      source,
      contains('Google hesabı ve bulut kaydı'),
    );
    expect(
      source,
      contains('Hesabı ve bulut verilerini sil'),
    );
    expect(
      source,
      contains('BilgiRotasi10@gmail.com'),
    );
    expect(
      source,
      contains('privacy-policy.html'),
    );
  });
}
