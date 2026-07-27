import 'dart:io';

import 'package:bilgi_rotasi/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Oyuncu kullanıcı adı sistemi', () {
    test('kullanıcı adı küçük harfe çevrilir', () {
      expect(PlayerUsernamePolicy.normalize(' LeventuA '), 'leventua');
    });

    test('geçerli kullanıcı adlarını kabul eder', () {
      expect(PlayerUsernamePolicy.validate('leventua'), isNull);
      expect(PlayerUsernamePolicy.validate('mila_23'), isNull);
      expect(PlayerUsernamePolicy.validate('oyuncu7'), isNull);
    });

    test('geçersiz kullanıcı adlarını reddeder', () {
      expect(PlayerUsernamePolicy.validate('ab'), isNotNull);
      expect(PlayerUsernamePolicy.validate('_levent'), isNotNull);
      expect(PlayerUsernamePolicy.validate('levent ünal'), isNotNull);
      expect(PlayerUsernamePolicy.validate('admin'), isNotNull);
    });

    test('30 günlük değiştirme süresi hesaplanır', () {
      final changedAt = DateTime.utc(2026, 7, 1);

      expect(
        PlayerUsernamePolicy.remainingCooldown(
          changedAt: changedAt,
          now: DateTime.utc(2026, 7, 15),
        ),
        const Duration(days: 16),
      );

      expect(
        PlayerUsernamePolicy.remainingCooldown(
          changedAt: changedAt,
          now: DateTime.utc(2026, 8, 1),
        ),
        Duration.zero,
      );
    });

    test('Google adı yerine kullanıcı adı kullanılır', () {
      final leaderboard =
          File('lib/live_duel_leaderboard.dart').readAsStringSync();
      final matchmaking =
          File('lib/live_duel_matchmaking.dart').readAsStringSync();

      expect(leaderboard, contains('PlayerUsernameService.requireUsername()'));
      expect(matchmaking, contains('PlayerUsernameService.requireUsername()'));
      expect(matchmaking, isNot(contains('user.displayName')));
    });

    test('Google hesabı kullanıcı adı kapısından geçer', () {
      final account = File('lib/account_cloud.dart').readAsStringSync();

      expect(account, contains('PlayerUsernameGate'));
      expect(account, contains('PlayerUsernameSetupScreen'));
    });

    test('Firestore benzersiz adı ve mahremiyeti korur', () {
      final rules = File('firestore.rules').readAsStringSync();
      final compactRules = rules.replaceAll(RegExp(r'\s+'), '');

      expect(rules, contains('match /usernames/{username}'));
      expect(compactRules, contains('allowlist:iffalse'));
      expect(compactRules, contains("duration.value(30,'d')"));
      expect(
        compactRules,
        contains(
          'request.resource.data.displayName=='
          'userUsername(userId)',
        ),
      );
    });
  });
}
