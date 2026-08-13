import 'dart:io';

import 'package:bilgi_rotasi/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('hesap silme bulut ve kimlik adımlarını içerir', () {
    final source = File('lib/account_cloud.dart').readAsStringSync();
    final compactSource = source.replaceAll(RegExp(r'\s+'), '');

    expect(source, contains('deleteAccountAndCloudData'));
    expect(source, contains('reauthenticateWithCredential'));
    expect(source, contains("'requestAccountDeletion'"));
    expect(source, contains('clearLocalDataForAccountDeletion'));

    final backend = File('functions/index.js').readAsStringSync();
    expect(backend, contains('operationId'));
    expect(backend, contains("stage: 'authentication'"));
    expect(backend, contains('deleteUser(uid)'));
    expect(compactSource, isNot(contains('awaituser.delete();')));
  });

  test('gizlilik ekranı güncel veri kullanımını açıklar', () {
    final source = File('lib/about_privacy.dart').readAsStringSync();

    expect(source, contains('Google hesabı ve bulut kaydı'));
    expect(source, contains('Hesabı ve bulut verilerini sil'));
    expect(source, contains('BilgiRotasidestek@gmail.com'));
    expect(source, contains('privacy-policy.html'));
  });

  test('gizlilik eylemleri gerçek bağlantı ve yönlendirme içerir', () {
    final source = File('lib/about_privacy.dart').readAsStringSync();

    expect(source, contains('launchUrl('));
    expect(source, contains("scheme: 'mailto'"));
    expect(source, contains('AccountSettingsScreen'));
    expect(source, contains('Tarayıcıda aç'));
    expect(source, contains('E-posta gönder'));
    expect(source, contains('Silme ekranını aç'));
  });

  test('sunucu silmesinden sonra iki oturum da kapatılır', () async {
    var localCleanup = 0;
    var firebaseSignedOut = false;
    var googleSignedOut = false;

    final result = await AccountDeletionSessionFinalizer.run(
      localCleanupTasks: <Future<void> Function()>[() async => localCleanup++],
      firebaseSignOut: () async => firebaseSignedOut = true,
      googleSignOut: () async => googleSignedOut = true,
    );

    expect(result.isPartial, isFalse);
    expect(localCleanup, 1);
    expect(firebaseSignedOut, isTrue);
    expect(googleSignedOut, isTrue);
  });

  test('yerel temizlik kısmi başarısız olsa da oturumlar kapatılır', () async {
    var laterCleanupRan = false;
    var firebaseSignedOut = false;
    var googleSignedOut = false;

    final result = await AccountDeletionSessionFinalizer.run(
      localCleanupTasks: <Future<void> Function()>[
        () async => throw StateError('yerel hata'),
        () async => laterCleanupRan = true,
      ],
      firebaseSignOut: () async => firebaseSignedOut = true,
      googleSignOut: () async => googleSignedOut = true,
    );

    expect(result.isPartial, isTrue);
    expect(laterCleanupRan, isTrue);
    expect(firebaseSignedOut, isTrue);
    expect(googleSignedOut, isTrue);
  });
}
