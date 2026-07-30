import 'dart:io';

import 'package:bilgi_rotasi/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Oyuncu bildirme ve engelleme güvenliği', () {
    test('rapor notu düz metin ve 300 karakter ile sınırlıdır', () {
      final sanitized = PlayerSafetyPolicy.sanitizeNote('${'a' * 350}\u0000');

      expect(sanitized.length, PlayerSafetyPolicy.reportNoteMaxLength);
      expect(sanitized, isNot(contains('\u0000')));
    });

    test('aynı rapor aynı sunucu belge kimliğini üretir', () {
      final first = PlayerSafetyPolicy.reportId(
        reporterUid: 'reporter',
        targetUid: 'target',
        reason: PlayerReportReason.cheating,
      );
      final second = PlayerSafetyPolicy.reportId(
        reporterUid: 'reporter',
        targetUid: 'target',
        reason: PlayerReportReason.cheating,
      );

      expect(first, second);
      expect(first, 'reporter_target_cheating');
    });

    test('Firestore raporları gizler ve engelleri sınırlar', () {
      final rules = File('firestore.rules').readAsStringSync();
      final compact = rules.replaceAll(RegExp(r'\s+'), '');

      expect(rules, contains('match /player_reports/{reportId}'));
      expect(compact, contains('allowread,write:iffalse'));
      expect(
        rules,
        contains('match /player_blocks/{ownerUid}/blocked/{targetUid}'),
      );
      expect(compact, contains('request.auth.uid==ownerUid'));
      expect(compact, contains('request.auth.uid==targetUid'));
    });

    test('sıralama, sonuç ve eşleştirme güvenlik hizmetini kullanır', () {
      final leaderboard =
          File('lib/live_duel_leaderboard.dart').readAsStringSync();
      final matchmaking =
          File('lib/live_duel_matchmaking.dart').readAsStringSync();

      expect(leaderboard, contains('PlayerSafetyDialogs.showActions'));
      expect(matchmaking, contains('LiveDuelServerGateway.findMatch'));
      expect(
        File('functions/live_duel.js').readAsStringSync(),
        contains('blocked(uid, candidate.id)'),
      );
      expect(
        File('lib/account_cloud.dart').readAsStringSync(),
        contains('BlockedPlayersScreen'),
      );
      expect(
        File('lib/account_cloud.dart').readAsStringSync(),
        contains('clearLocalDataForAccountDeletion'),
      );
    });
  });
}
