import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('hesap silme bulut ve kimlik adımlarını içerir', () {
    final source = File(
      'lib/account_cloud.dart',
    ).readAsStringSync();
    final compactSource = source.replaceAll(
      RegExp(r'\s+'),
      '',
    );

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
      compactSource,
      contains(".collection('users').doc(user.uid).delete()"),
    );
    expect(
      compactSource,
      contains('awaituser.delete();'),
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

  test('gizlilik eylemleri gerçek bağlantı ve yönlendirme içerir', () {
    final source = File(
      'lib/about_privacy.dart',
    ).readAsStringSync();

    expect(source, contains('launchUrl('));
    expect(source, contains("scheme: 'mailto'"));
    expect(source, contains('AccountSettingsScreen'));
    expect(source, contains('Tarayıcıda aç'));
    expect(source, contains('E-posta gönder'));
    expect(source, contains('Silme ekranını aç'));
  });
}
