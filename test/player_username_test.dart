import 'dart:io';

import 'package:bilgi_rotasi/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Oyuncu kullanıcı adı sistemi', () {
    test('kullanıcı adı küçük harfe çevrilir', () {
      expect(PlayerUsernamePolicy.normalize(' LeventuA '), 'leventua');
      expect(PlayerUsernamePolicy.normalize('İPEK'), 'ipek');
      expect(PlayerUsernamePolicy.normalize('İrem'), 'irem');
      expect(PlayerUsernamePolicy.normalize('IŞIL'), 'isil');
      expect(PlayerUsernamePolicy.normalize('Şule'), 'sule');
      expect(
        PlayerUsernamePolicy.suggestionFromDisplayName('Şule Yılmaz'),
        'sule',
      );
    });

    test('geçerli kullanıcı adlarını kabul eder', () {
      expect(PlayerUsernamePolicy.validate('leventua'), isNull);
      expect(PlayerUsernamePolicy.validate('mila_23'), isNull);
      expect(PlayerUsernamePolicy.validate('oyuncu7'), isNull);
      expect(PlayerUsernamePolicy.validate('aquaman'), isNull);
      expect(PlayerUsernamePolicy.validate('epicoyuncu'), isNull);
      expect(PlayerUsernamePolicy.validate('nazim'), isNull);
    });

    test('geçersiz kullanıcı adlarını reddeder', () {
      expect(PlayerUsernamePolicy.validate('ab'), isNotNull);
      expect(PlayerUsernamePolicy.validate('_levent'), isNotNull);
      expect(PlayerUsernamePolicy.validate('levent ünal'), isNotNull);
      expect(PlayerUsernamePolicy.validate('admin'), isNotNull);
      expect(PlayerUsernamePolicy.validate('adm1n'), isNotNull);
      expect(PlayerUsernamePolicy.validate('destek_ekibi'), isNotNull);
      expect(PlayerUsernamePolicy.validate('05321234567'), isNotNull);
      expect(PlayerUsernamePolicy.validate('ad@example.com'), isNotNull);
      expect(PlayerUsernamePolicy.validate('oyuncu.com'), isNotNull);
      expect(PlayerUsernamePolicy.validate('pic'), isNotNull);
      expect(PlayerUsernamePolicy.validate('nazi'), isNotNull);
      expect(PlayerUsernamePolicy.validate('or0spu'), isNotNull);
      expect(PlayerUsernamePolicy.validate('s1ktir'), isNotNull);
    });

    test('migration ve ilk gün düzeltme hakları bir defalıktır', () {
      final migration = PlayerUsernameProfile(
        uid: 'u1',
        username: 'levetua',
        changedAt: DateTime.now().subtract(const Duration(days: 2)),
        correctionUsed: false,
        policyVersion: 1,
      );
      final newAccount = PlayerUsernameProfile(
        uid: 'u2',
        username: 'yenioyuncu',
        changedAt: DateTime.now(),
        firstSetAt: DateTime.now().subtract(const Duration(hours: 2)),
        correctionUsed: false,
        policyVersion: PlayerUsernamePolicy.currentPolicyVersion,
      );
      final used = PlayerUsernameProfile(
        uid: 'u3',
        username: 'oyuncu',
        changedAt: DateTime.now(),
        firstSetAt: DateTime.now(),
        correctionUsed: true,
        policyVersion: PlayerUsernamePolicy.currentPolicyVersion,
      );

      expect(migration.hasMigrationCorrection, isTrue);
      expect(newAccount.hasNewAccountCorrection, isTrue);
      expect(used.hasFreeCorrection, isFalse);
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
      final server = File('functions/live_duel.js').readAsStringSync();

      expect(leaderboard, isNot(contains("collection('users')")));
      expect(matchmaking, contains('LiveDuelServerGateway.joinQueue'));
      expect(server, contains('identity.username'));
      expect(
        File('functions/index.js').readAsStringSync(),
        contains('syncUsernameToLeaderboard'),
      );
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
      expect(compactRules, contains('allowcreate,update,delete:iffalse'));
      expect(compactRules, contains('&&!changesUsername'));
      expect(rules, contains('usernameCorrectionUsed'));
      expect(rules, contains('usernamePolicyVersion'));
      final server = File('functions/index.js').readAsStringSync();
      expect(server, contains("'username-attempt'"));
      expect(server, contains("'username-change'"));
      expect(server, contains('30 * 24 * 60 * 60 * 1000'));
      expect(server, contains('24 * 60 * 60 * 1000'));
    });
  });
}
