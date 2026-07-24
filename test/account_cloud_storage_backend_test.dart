import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'bulut yedeği oyunla aynı SharedPreferencesAsync deposunu kullanır',
    () {
      final source =
          File('lib/account_cloud.dart').readAsStringSync();
      final start =
          source.indexOf('class AccountLocalSnapshot');
      final end =
          source.indexOf('class AccountCloudService');
      expect(start, greaterThanOrEqualTo(0));
      expect(end, greaterThan(start));

      final block = source.substring(start, end);
      expect(block, contains('SharedPreferencesAsync'));
      expect(block, contains('await _preferences.getAll()'));
      expect(block, contains('await _preferences.getKeys()'));
      expect(
        block,
        isNot(contains('SharedPreferences.getInstance()')),
      );
    },
  );

  test('bulut yazımı sunucu üzerinden doğrulanır', () {
    final source =
        File('lib/account_cloud.dart').readAsStringSync();
    expect(
      source,
      contains('GetOptions(source: Source.server)'),
    );
    expect(source, contains('snapshotValueCount'));
    expect(
      source,
      contains('Bulut kaydı sunucuda doğrulanamadı.'),
    );
  });
}
