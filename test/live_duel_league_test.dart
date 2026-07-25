import 'package:bilgi_rotasi/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Canlı düello BR lig sistemi', () {
    test('lig eşikleri doğru çalışır', () {
      expect(BrLeagueResolver.fromRating(0), BrLeague.bronze);
      expect(BrLeagueResolver.fromRating(999), BrLeague.bronze);
      expect(BrLeagueResolver.fromRating(1000), BrLeague.silver);
      expect(BrLeagueResolver.fromRating(1400), BrLeague.gold);
      expect(BrLeagueResolver.fromRating(1800), BrLeague.platinum);
      expect(BrLeagueResolver.fromRating(2200), BrLeague.diamond);
      expect(BrLeagueResolver.fromRating(2600), BrLeague.master);
      expect(BrLeagueResolver.fromRating(3000), BrLeague.legend);
    });

    test('galibiyet BR puanını artırır', () {
      final change = LiveDuelRatingEngine.calculate(
        playerRating: 1000,
        opponentRating: 1000,
        result: LiveDuelResult.win,
        matchesPlayed: 10,
      );

      expect(change.delta, greaterThan(0));
      expect(change.newRating, greaterThan(1000));
    });

    test('mağlubiyet BR puanını azaltır', () {
      final change = LiveDuelRatingEngine.calculate(
        playerRating: 1000,
        opponentRating: 1000,
        result: LiveDuelResult.loss,
        matchesPlayed: 10,
      );

      expect(change.delta, lessThan(0));
      expect(change.newRating, lessThan(1000));
    });

    test('ilk 5 yerleştirme maçı daha yüksek etkilidir', () {
      final placement = LiveDuelRatingEngine.calculate(
        playerRating: 1000,
        opponentRating: 1000,
        result: LiveDuelResult.win,
        matchesPlayed: 0,
      );

      final normal = LiveDuelRatingEngine.calculate(
        playerRating: 1000,
        opponentRating: 1000,
        result: LiveDuelResult.win,
        matchesPlayed: 10,
      );

      expect(placement.delta, greaterThan(normal.delta));
    });

    test('profil galibiyeti ve seriyi kaydeder', () {
      final profile = const LiveDuelProfile().applyResult(
        opponentName: 'Test Rakibi',
        opponentRating: 1000,
        result: LiveDuelResult.win,
        playedAt: DateTime(2026, 7, 25),
      );

      expect(profile.matchesPlayed, 1);
      expect(profile.wins, 1);
      expect(profile.losses, 0);
      expect(profile.currentWinStreak, 1);
      expect(profile.bestWinStreak, 1);
      expect(profile.recentMatches.length, 1);
    });

    test('son maç geçmişi en fazla 10 kayıt tutar', () {
      var profile = const LiveDuelProfile();

      for (var index = 0; index < 15; index++) {
        profile = profile.applyResult(
          opponentName: 'Rakip $index',
          opponentRating: 1000,
          result: LiveDuelResult.win,
          playedAt: DateTime(2026, 7, index + 1),
        );
      }

      expect(profile.recentMatches.length, 10);
    });

    test('profil JSON dönüşümünde korunur', () {
      final original = const LiveDuelProfile().applyResult(
        opponentName: 'Rakip',
        opponentRating: 1200,
        result: LiveDuelResult.draw,
        playedAt: DateTime(2026, 7, 25),
      );

      final restored = LiveDuelProfile.fromJson(original.toJson());

      expect(restored.rating, original.rating);
      expect(restored.matchesPlayed, original.matchesPlayed);
      expect(restored.draws, 1);
      expect(restored.recentMatches.single.opponentName, 'Rakip');
    });
  });
}
