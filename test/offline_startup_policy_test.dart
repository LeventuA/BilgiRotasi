import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Çevrimdışı açılış politikası', () {
    test('uygulama bulut başlatmasını beklemeden açılır', () {
      final source = File('lib/main.dart').readAsStringSync();
      final runAppIndex = source.indexOf('runApp(const BilgiRotasiApp());');
      final cloudIndex = source.indexOf(
        'unawaited(_initializeAccountCloudInBackground());',
      );
      expect(runAppIndex, greaterThanOrEqualTo(0));
      expect(cloudIndex, greaterThan(runAppIndex));
    });

    test('mevcut hesap bulut cevabını beklemez', () {
      final source = File('lib/account_cloud.dart').readAsStringSync();
      expect(
        source,
        contains('unawaited(_activateExistingUser(currentUser));'),
      );
      expect(
        source,
        isNot(contains('await _activateExistingUser(currentUser);')),
      );
    });

    test('sunucu okumasında zaman aşımı vardır', () {
      final source = File('lib/account_cloud.dart').readAsStringSync();
      expect(source, contains('.timeout(const Duration(seconds: 6));'));
    });
  });
}
