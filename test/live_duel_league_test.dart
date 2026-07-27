import 'package:bilgi_rotasi/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Canlı düello BR lig sistemi', () {
    test('lig eşikleri doğru çalışır', () {
      expect(BrLeagueResolver.fromRating(999), BrLeague.bronze);
      expect(BrLeagueResolver.fromRating(1000), BrLeague.silver);
      expect(BrLeagueResolver.fromRating(1400), BrLeague.gold);
      expect(BrLeagueResolver.fromRating(3000), BrLeague.legend);
    });

    test('eşit rakip normal maçta artı 18 eksi 7 verir', () {
      final win = LiveDuelRatingEngine.calculate(
        playerRating: 1200,
        opponentRating: 1200,
        result: LiveDuelResult.win,
        matchesPlayed: 10,
      );
      final loss = LiveDuelRatingEngine.calculate(
        playerRating: 1200,
        opponentRating: 1200,
        result: LiveDuelResult.loss,
        matchesPlayed: 10,
      );
      expect(win.delta, 18);
      expect(loss.delta, -7);
    });

    test('güçlü rakip artı 22 eksi 5 verir', () {
      final win = LiveDuelRatingEngine.calculate(
        playerRating: 1000,
        opponentRating: 1200,
        result: LiveDuelResult.win,
        matchesPlayed: 10,
      );
      final loss = LiveDuelRatingEngine.calculate(
        playerRating: 1000,
        opponentRating: 1200,
        result: LiveDuelResult.loss,
        matchesPlayed: 10,
      );
      expect(win.delta, 22);
      expect(loss.delta, -5);
    });

    test('zayıf rakip artı 14 eksi 8 verir', () {
      final win = LiveDuelRatingEngine.calculate(
        playerRating: 1200,
        opponentRating: 1000,
        result: LiveDuelResult.win,
        matchesPlayed: 10,
      );
      final loss = LiveDuelRatingEngine.calculate(
        playerRating: 1200,
        opponentRating: 1000,
        result: LiveDuelResult.loss,
        matchesPlayed: 10,
      );
      expect(win.delta, 14);
      expect(loss.delta, -8);
    });

    test('ilk 5 maç artı 20 eksi 4 verir', () {
      final win = LiveDuelRatingEngine.calculate(
        playerRating: 1000,
        opponentRating: 1000,
        result: LiveDuelResult.win,
        matchesPlayed: 3,
      );
      final loss = LiveDuelRatingEngine.calculate(
        playerRating: 1000,
        opponentRating: 1000,
        result: LiveDuelResult.loss,
        matchesPlayed: 3,
      );
      expect(win.delta, 20);
      expect(loss.delta, -4);
    });

    test('eski ağır mağlubiyetler eksi 8 olur ve fark iade edilir', () {
      final profile = LiveDuelProfile.fromJson(<String, dynamic>{
        'rating': 994,
        'matchesPlayed': 4,
        'wins': 2,
        'losses': 2,
        'draws': 0,
        'currentWinStreak': 0,
        'bestWinStreak': 1,
        'highestRating': 1024,
        'recentMatches': <Map<String, dynamic>>[
          <String, dynamic>{
            'opponentName': 'Emel',
            'result': 'loss',
            'ratingDelta': -27,
            'playedAt': '2026-07-26T12:00:00.000',
          },
          <String, dynamic>{
            'opponentName': 'Emel',
            'result': 'win',
            'ratingDelta': 24,
            'playedAt': '2026-07-26T11:00:00.000',
          },
          <String, dynamic>{
            'opponentName': 'Işıl',
            'result': 'loss',
            'ratingDelta': -27,
            'playedAt': '2026-07-26T10:00:00.000',
          },
          <String, dynamic>{
            'opponentName': 'Işıl',
            'result': 'win',
            'ratingDelta': 24,
            'playedAt': '2026-07-26T09:00:00.000',
          },
        ],
      });
      expect(profile.rating, 1032);
      expect(profile.ratingPolicyVersion, 2);
      expect(
        profile.recentMatches
            .where((match) => match.result == LiveDuelResult.loss)
            .every((match) => match.ratingDelta == -8),
        isTrue,
      );
      final restored = LiveDuelProfile.fromJson(profile.toJson());
      expect(restored.rating, 1032);
    });

    test('beraberlik puanı değiştirmez', () {
      final change = LiveDuelRatingEngine.calculate(
        playerRating: 1200,
        opponentRating: 1500,
        result: LiveDuelResult.draw,
        matchesPlayed: 10,
      );
      expect(change.delta, 0);
    });
  });
}
