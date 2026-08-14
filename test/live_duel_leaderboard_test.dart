import 'dart:io';

import 'package:bilgi_rotasi/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Canlı Düello lig ve sıralama', () {
    test('lig ilerleme oranı eşiklere göre hesaplanır', () {
      expect(LiveDuelLeaderboardPresentation.leagueProgress(1000), 0);
      expect(LiveDuelLeaderboardPresentation.leagueProgress(1200), 0.5);
      expect(LiveDuelLeaderboardPresentation.leagueProgress(3000), 1);
    });

    test('sonraki lig ve sıra metinleri doğru üretilir', () {
      expect(
        LiveDuelLeaderboardPresentation.nextLeagueLabel(1200),
        contains('200 BR kaldı'),
      );
      expect(
        LiveDuelLeaderboardPresentation.nextLeagueLabel(3000),
        'En yüksek ligdesin',
      );
      expect(LiveDuelLeaderboardPresentation.rankLabel(7), '#7');
      expect(LiveDuelLeaderboardPresentation.rankLabel(null), '—');
    });

    test('kazanma oranı hesaplanır', () {
      expect(
        LiveDuelLeaderboardPresentation.winRatePercent(
          wins: 7,
          matchesPlayed: 10,
        ),
        70,
      );
      expect(
        LiveDuelLeaderboardPresentation.winRatePercent(
          wins: 0,
          matchesPlayed: 0,
        ),
        0,
      );
    });

    test('leaderboard belgesi olmayan kullanıcı sıralanmış gösterilmez', () {
      expect(
        LiveDuelLeaderboardPresentation.visibleRank(
          hasLeaderboardEntry: false,
          playersAbove: 0,
        ),
        isNull,
      );
      expect(LiveDuelLeaderboardPresentation.rankLabel(null), '—');
    });

    test('leaderboard belgesi olan kullanıcı gerçek sırayı alır', () {
      expect(
        LiveDuelLeaderboardPresentation.visibleRank(
          hasLeaderboardEntry: true,
          playersAbove: 0,
        ),
        1,
      );
      expect(
        LiveDuelLeaderboardPresentation.visibleRank(
          hasLeaderboardEntry: true,
          playersAbove: 6,
        ),
        7,
      );
    });

    test('kendi satırı publicPlayerId ile bulunur ve menü göstermez', () {
      expect(
        LiveDuelLeaderboardPresentation.isOwnEntry(
          entryPublicPlayerId: 'p_me',
          ownPublicPlayerId: 'p_me',
        ),
        isTrue,
      );
      expect(
        LiveDuelLeaderboardPresentation.isOwnEntry(
          entryPublicPlayerId: 'p_other',
          ownPublicPlayerId: 'p_me',
        ),
        isFalse,
      );

      final source = File('lib/live_duel_leaderboard.dart').readAsStringSync();
      expect(source, contains("data['publicPlayerId']"));
      expect(source, contains("collection('users').doc(user.uid).get()"));
      expect(source, contains('_leaderboard.doc(ownPublicPlayerId).get()'));
      expect(source, contains('if (!isOwn)'));
      expect(source, contains('targetUid: entry.publicPlayerId'));
    });

    test('sıralama ekranı uygulamaya bağlıdır', () {
      final mainSource = File('lib/main.dart').readAsStringSync();
      final duelSource = File('lib/live_duel_screen.dart').readAsStringSync();
      final rules = File('firestore.rules').readAsStringSync();

      expect(mainSource, contains("part 'live_duel_leaderboard.dart';"));
      expect(duelSource, contains('LiveDuelLeaderboardScreen'));
      expect(duelSource, contains('Lig ve Sıralama'));
      expect(rules, contains('match /live_duel_leaderboard/{publicPlayerId}'));
    });
  });
}
