import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Kullanıcı adı sunucu bağı', () {
    test('genel bulut yedeği kullanıcı adı kimliğini taşımaz', () {
      final source = File('lib/account_cloud.dart').readAsStringSync();
      expect(source, contains("lower.contains('player_username')"));
    });

    test('Canlı Düello öncesi sunucu adı doğrulanır', () {
      final source = File('lib/player_username.dart').readAsStringSync();
      expect(source, contains('_remoteUsernameMatches'));
      expect(
        source,
        contains('final repaired = await claim(current.username);'),
      );
      expect(source, contains('current.username != username'));
    });
  });
}
