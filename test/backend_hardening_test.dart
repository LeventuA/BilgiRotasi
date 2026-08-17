import 'dart:convert';
import 'dart:io';

import 'package:bilgi_rotasi/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Firebase ortam ve App Check kapısı', () {
    test('varsayılan test profili production Firebase açmaz', () {
      expect(FirebaseRuntimePolicy.environment, FirebaseEnvironment.test);
      expect(FirebaseRuntimePolicy.remoteFirebaseEnabled, isFalse);
      expect(FirebaseRuntimePolicy.androidAppCheckProvider, isNull);
    });

    test('provider ve callable ayrımı kaynakta sabittir', () {
      final source = File('lib/firebase_security.dart').readAsStringSync();
      expect(source, contains('AndroidProvider.playIntegrity'));
      expect(source, contains('AndroidProvider.debug'));
      expect(source, contains('limitedUseAppCheckToken: true'));
      expect(source, contains("defaultValue: 'test'"));
    });

    test('production workflow AdMob ve Firebase profilini birlikte seçer', () {
      final production =
          File(
            '.github/workflows/apply-permanent-admob-v7.yml',
          ).readAsStringSync();
      final ci =
          File('.github/workflows/admob-pr-validation.yml').readAsStringSync();
      expect(production, contains('ADMOB_ENVIRONMENT=production'));
      expect(production, contains('FIREBASE_ENVIRONMENT=production'));
      expect(ci, contains('ADMOB_ENVIRONMENT=test'));
      expect(ci, isNot(contains('FIREBASE_ENVIRONMENT=production')));
    });
  });

  group('Bulut snapshot güvenliği', () {
    test('schema 1 migration ile okunur ve schema 2 yazılır', () {
      const legacy = '{"schema":1,"values":{"x":{"type":"int","value":7}}}';
      expect(AccountSnapshotCodec.decode(legacy)['x'], 7);
      expect(
        AccountSnapshotCodec.encode(<String, Object?>{'x': 8}),
        contains('"schema":2'),
      );
    });

    test('bilinmeyen şema ve aşırı alan reddedilir', () {
      expect(
        () => AccountSnapshotCodec.decode('{"schema":99,"values":{}}'),
        throwsFormatException,
      );
      final values = <String, dynamic>{
        for (var index = 0; index < 501; index++)
          'k$index': <String, dynamic>{'type': 'int', 'value': index},
      };
      expect(
        () => AccountSnapshotCodec.decode(
          jsonEncode(<String, dynamic>{'schema': 2, 'values': values}),
        ),
        throwsFormatException,
      );
    });

    test('restore journal, revision ve conflict ekranı bağlıdır', () {
      final source = File('lib/account_cloud.dart').readAsStringSync();
      expect(source, contains('_restoreJournalKey'));
      expect(source, contains('recoverInterruptedRestore'));
      expect(source, contains('expectedRevision'));
      expect(source, contains('AccountCloudConflictScreen'));
      expect(source, contains('Bu telefonun kaydı'));
      expect(source, contains('Bulut kaydı'));
    });
  });

  group('Sunucu yetkili Canlı Düello', () {
    test('kritik callable ve tekrar işleme kapıları vardır', () {
      final server = File('functions/live_duel.js').readAsStringSync();
      for (final name in <String>[
        'joinLiveDuelQueue',
        'findLiveDuelMatch',
        'cancelLiveDuelQueue',
        'submitLiveDuelAnswer',
        'finalizeLiveDuel',
        'resolveLiveDuelForfeit',
        'cleanupLiveDuelData',
      ]) {
        expect(server, contains(name));
      }
      expect(server, contains('resultProcessed'));
      expect(server, contains('deterministicMatchId'));
      expect(server, contains('blocked'));
    });

    test('istemci kritik işlemleri yalnız sunucu gateway üzerinden yapar', () {
      final matchmaking =
          File('lib/live_duel_matchmaking.dart').readAsStringSync();
      final progress = File('lib/live_duel_progress.dart').readAsStringSync();
      final result = File('lib/live_duel_result.dart').readAsStringSync();
      expect(matchmaking, contains('LiveDuelServerGateway.joinQueue'));
      expect(matchmaking, contains('LiveDuelServerGateway.findMatch'));
      expect(matchmaking, contains('LiveDuelServerGateway.cancelQueue'));
      expect(progress, contains('LiveDuelServerGateway.submitAnswer'));
      expect(result, contains('LiveDuelServerGateway.finalize'));
      expect(
        File('lib/live_duel_connection.dart').readAsStringSync(),
        contains('LiveDuelServerGateway.resolveForfeit'),
      );
      expect(matchmaking, isNot(contains('runTransaction')));
      expect(progress, isNot(contains('runTransaction')));
      expect(result, isNot(contains('transaction.update(matchReference')));
    });

    test('Firestore istemci BR, kuyruk, maç ve sonuç yazımını kapatır', () {
      final rules = File('firestore.rules').readAsStringSync();
      final compact = rules.replaceAll(RegExp(r'\s+'), '');
      expect(compact, contains('match/live_duel_leaderboard/{publicPlayerId}'));
      expect(compact, contains('match/live_duel_queue/{userId}'));
      expect(compact, contains('match/live_duel_matches/{matchId}'));
      expect(compact, contains('allowwrite:iffalse'));
      expect(rules, contains('changesServerManaged'));
    });

    test('genel sıralama yeni kayıtta UID yerine publicPlayerId kullanır', () {
      final server = File('functions/live_duel.js').readAsStringSync();
      final migration =
          File(
            'functions/scripts/migrate_public_player_ids.js',
          ).readAsStringSync();
      expect(server, contains('publicPlayerId'));
      expect(server, contains('public_player_directory'));
      expect(migration, contains('DRY-RUN'));
      expect(migration, contains('APPLY_PUBLIC_ID_MIGRATION'));
    });
  });

  group('SSV ve retention güvenliği', () {
    test('ödül varsayılan kapalı, imzalı ve oyun başına idempotent hazırlanır', () {
      final source = File('functions/rewarded_ssv.js').readAsStringSync();
      final client = File('lib/ad_monetization.dart').readAsStringSync();
      expect(source, contains('ssvEnabled !== true'));
      expect(source, contains('verifier-keys.json'));
      expect(source, contains('signedContentFromOriginalUrl'));
      expect(source, contains('rewarded_transactions'));
      expect(source, contains('rewarded_game_claims'));
      expect(source, contains('gameClaim.exists'));
      expect(source, contains('gameId'));
      expect(source, isNot(contains('rewarded_daily')));
      expect(source, isNot(contains('daily-limit')));
      expect(source, isNot(contains('count >= 3')));
      expect(client, contains('FirebaseRuntimePolicy.productionEnabled'));
      expect(
        client,
        contains('Sunucu doğrulaması tamamlanana kadar +10 XP ödülü kapalı.'),
      );
    });

    test('saklama süreleri kod ve dokümanda bulunur', () {
      final helper = File('functions/duel_helpers.js').readAsStringSync();
      final policy =
          File('docs/live-duel-data-retention.md').readAsStringSync();
      expect(helper, contains('90 * day'));
      expect(helper, contains('365 * day'));
      expect(policy, contains('30 gün'));
      expect(policy, contains('90 gün'));
      expect(policy, contains('365 gün'));
    });
  });
}
