import 'package:bilgi_rotasi/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Bilgi Rotası hesap ve bulut kuralları', () {
    test('Misafir Günlük Görev göremez', () {
      expect(
        AccountAccessPolicy.dailyVisible(
          AccountMode.guest,
        ),
        isFalse,
      );
      expect(
        AccountAccessPolicy.dailyVisible(
          AccountMode.undecided,
        ),
        isFalse,
      );
      expect(
        AccountAccessPolicy.dailyVisible(
          AccountMode.google,
        ),
        isTrue,
      );
    });

    test('Bulut kayıt kodlayıcısı veri türlerini korur', () {
      final original = <String, Object?>{
        'bilgi_rotasi_string': 'değer',
        'bilgi_rotasi_int': 42,
        'bilgi_rotasi_double': 2.5,
        'bilgi_rotasi_bool': true,
        'bilgi_rotasi_list': <String>['a', 'b'],
      };

      final encoded = AccountSnapshotCodec.encode(
        original,
      );
      final decoded = AccountSnapshotCodec.decode(
        encoded,
      );

      expect(decoded['bilgi_rotasi_string'], 'değer');
      expect(decoded['bilgi_rotasi_int'], 42);
      expect(decoded['bilgi_rotasi_double'], 2.5);
      expect(decoded['bilgi_rotasi_bool'], isTrue);
      expect(
        decoded['bilgi_rotasi_list'],
        <String>['a', 'b'],
      );
    });

    test('Hesap kontrol anahtarları buluta gitmez', () {
      expect(
        AccountLocalSnapshot.shouldSyncKey(
          'bilgi_rotasi_xp_progress_v1',
        ),
        isTrue,
      );
      expect(
        AccountLocalSnapshot.shouldSyncKey(
          'bilgi_rotasi_account_guest_selected_v1',
        ),
        isFalse,
      );
      expect(
        AccountLocalSnapshot.shouldSyncKey(
          'bilgi_rotasi_system_health_log_v1',
        ),
        isFalse,
      );
    });
  });
}
