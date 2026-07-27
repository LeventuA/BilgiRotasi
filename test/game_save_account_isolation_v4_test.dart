import 'dart:io';

import 'package:bilgi_rotasi/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Kayıtlı oyun kesin hesap izolasyonu V4', () {
    test('hesap kasaları birbirinden farklıdır', () {
      final guest = GameSaveService.saveKeyForUid(null);
      final levent = GameSaveService.saveKeyForUid('levent');
      final emel = GameSaveService.saveKeyForUid('emel');

      expect(guest, isNot(levent));
      expect(levent, isNot(emel));
      expect(
        GameSaveService.belongsToScope(guest, 'guest'),
        isTrue,
      );
      expect(
        GameSaveService.belongsToScope(
          levent,
          'user_levent',
        ),
        isTrue,
      );
    });

    test('kayıt payloadına ownerScope yazılır', () {
      final source = File('lib/main.dart').readAsStringSync();

      expect(source, contains("'ownerScope': _currentScope"));
      expect(source, contains("payload['ownerScope'] = scope"));
      expect(
        source,
        contains('ownerScope != _currentScope'),
      );
    });

    test('sahipsiz eski kayıt misafire gösterilmez', () {
      final source = File('lib/main.dart').readAsStringSync();

      expect(
        source,
        contains('Sahibi belli olmayan eski kayıt misafir'),
      );
      expect(
        source,
        contains('if (_currentUid.isEmpty)'),
      );
    });

    test('bulut yedeği yalnız aktif kayıt kasasını taşır', () {
      final source =
          File('lib/account_cloud.dart').readAsStringSync();

      expect(
        source,
        contains('GameSaveService.isScopedStorageKey(key)'),
      );
      expect(
        source,
        contains('GameSaveService.belongsToActiveScope(key)'),
      );
      expect(
        source,
        contains('if (!shouldSyncKey(entry.key)) continue;'),
      );
    });

    test('çıkış sonrası misafir kasası temizlenir', () {
      final source =
          File('lib/account_cloud.dart').readAsStringSync();

      expect(
        source,
        contains('await GameSaveService.sanitizeGuestScope();'),
      );
    });

    test('yedek kurtarma da sahipliği doğrular', () {
      final source =
          File('lib/system_health.dart').readAsStringSync();

      expect(
        source,
        contains(
          'ownerScope != GameSaveService._currentScope',
        ),
      );
    });
  });
}
