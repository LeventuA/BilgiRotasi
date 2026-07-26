import 'package:bilgi_rotasi/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Canlı düello resmi maç sonucu', () {
    test('yüksek skor kazanan oyuncuyu belirler', () {
      final winner = LiveDuelMatchResultResolver.winnerUid(
        playerUids: const <String>['levent', 'emel'],
        scores: const <String, int>{'levent': 8, 'emel': 6},
      );

      expect(winner, 'levent');
    });

    test('eşit skor beraberlik üretir', () {
      final winner = LiveDuelMatchResultResolver.winnerUid(
        playerUids: const <String>['levent', 'emel'],
        scores: const <String, int>{'levent': 7, 'emel': 7},
      );

      expect(winner, isNull);
    });

    test('kesinleşmiş maç verisi doğru çözümlenir', () {
      final completed = LiveDuelCompletedMatch.fromMap(
        matchId: 'match-1',
        data: <String, dynamic>{
          'resultProcessed': true,
          'playerUids': const <String>['levent', 'emel'],
          'scores': const <String, int>{'levent': 9, 'emel': 5},
          'winnerUid': 'levent',
          'draw': false,
        },
      );

      expect(completed.resultFor('levent'), LiveDuelResult.win);
      expect(completed.resultFor('emel'), LiveDuelResult.loss);
      expect(completed.scoreFor('levent'), 9);
    });

    test('uyuşmayan skor ve kazanan reddedilir', () {
      expect(
        () => LiveDuelCompletedMatch.fromMap(
          matchId: 'match-2',
          data: <String, dynamic>{
            'resultProcessed': true,
            'playerUids': const <String>['levent', 'emel'],
            'scores': const <String, int>{'levent': 4, 'emel': 8},
            'winnerUid': 'levent',
            'draw': false,
          },
        ),
        throwsA(isA<LiveDuelResultException>()),
      );
    });
  });

  group('Canlı düello BR sonucu', () {
    test('galibiyet profili ve seriyi günceller', () {
      const current = LiveDuelProfile(
        rating: 1450,
        matchesPlayed: 8,
        wins: 4,
        losses: 3,
        draws: 1,
        currentWinStreak: 2,
        bestWinStreak: 3,
        highestRating: 1500,
      );

      final plan = LiveDuelOwnResultPlanner.plan(
        current: current,
        opponentName: 'Rakip',
        opponentRating: 1500,
        result: LiveDuelResult.win,
        playedAt: DateTime.utc(2026, 7, 26),
      );

      expect(plan.profile.matchesPlayed, 9);
      expect(plan.profile.wins, 5);
      expect(plan.profile.currentWinStreak, 3);
      expect(plan.profile.rating, plan.ratingChange.newRating);
      expect(plan.ratingChange.delta, greaterThan(0));
    });

    test('yenilgi galibiyet serisini sıfırlar', () {
      const current = LiveDuelProfile(
        rating: 1450,
        matchesPlayed: 8,
        currentWinStreak: 4,
        bestWinStreak: 4,
      );

      final plan = LiveDuelOwnResultPlanner.plan(
        current: current,
        opponentName: 'Rakip',
        opponentRating: 1450,
        result: LiveDuelResult.loss,
        playedAt: DateTime.utc(2026, 7, 26),
      );

      expect(plan.profile.losses, 1);
      expect(plan.profile.currentWinStreak, 0);
      expect(plan.ratingChange.delta, lessThan(0));
    });
  });
}
