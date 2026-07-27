import 'dart:io';

import 'package:bilgi_rotasi/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Kayıtlı oyun hesap izolasyonu', () {
    test('misafir ve kullanıcı farklı kayıt anahtarı kullanır', () {
      final guest = GameSaveService.saveKeyForUid(null);
      final levent = GameSaveService.saveKeyForUid('levent_uid');
      final emel = GameSaveService.saveKeyForUid('emel_uid');

      expect(guest, contains('guest'));
      expect(levent, contains('user_levent_uid'));
      expect(emel, contains('user_emel_uid'));
      expect(guest, isNot(levent));
      expect(levent, isNot(emel));
    });

    test('yedekler de hesaplara göre ayrılır', () {
      expect(
        GameSaveService.backupKeyForUid(null),
        isNot(GameSaveService.backupKeyForUid('levent_uid')),
      );
      expect(
        GameSaveService.backupKeyForUid('levent_uid'),
        isNot(GameSaveService.backupKeyForUid('emel_uid')),
      );
    });

    test('eski ortak kayıt yalnızca giriş yapan hesaba taşınır', () {
      final source = File('lib/main.dart').readAsStringSync();

      expect(source, contains('_migrateLegacyForSignedInUser'));
      expect(source, contains('if (user == null) return;'));
      expect(source, contains('await _preferences.remove(_legacySaveKey);'));
    });

    test('ana sayfa yalnızca aktif kapsamın kaydını yükler', () {
      final source = File('lib/main.dart').readAsStringSync();

      expect(source, contains('_savedGameFuture = GameSaveService.load();'));
      expect(
        source,
        contains(
          "static String get _saveKey => "
          "saveKeyForUid(_currentUid);",
        ),
      );
    });

    test('kurtarma yedeği aktif hesap anahtarını kullanır', () {
      final source = File('lib/system_health.dart').readAsStringSync();

      expect(
        source,
        contains(
          'static String get backupKey => '
          'GameSaveService._backupKey;',
        ),
      );
    });
  });
}
