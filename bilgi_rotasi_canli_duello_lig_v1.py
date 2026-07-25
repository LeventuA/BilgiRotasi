from pathlib import Path
import re
import subprocess
import sys

ROOT = Path.cwd()
PUBSPEC = ROOT / "pubspec.yaml"
MAIN = ROOT / "lib" / "main.dart"
TARGET = ROOT / "lib" / "live_duel_league.dart"
TEST = ROOT / "test" / "live_duel_league_test.dart"

def fail(msg):
    print(f"\nHATA: {msg}")
    sys.exit(1)

for path in [PUBSPEC, MAIN]:
    if not path.exists():
        fail(f"{path} bulunamadı.")

pubspec = PUBSPEC.read_text(encoding="utf-8")
main = MAIN.read_text(encoding="utf-8")

if "version: 1.48.5+69" not in pubspec:
    fail("Beklenen sürüm 1.48.5+69 değil. Güncel sürümü kontrol et.")

if "part 'live_duel_league.dart';" not in main:
    anchor = "part 'account_cloud.dart';"
    if anchor not in main:
        fail("main.dart içinde account_cloud.dart bağlantısı bulunamadı.")
    main = main.replace(
        anchor,
        anchor + "\npart 'live_duel_league.dart';",
        1,
    )

target_code = r"""part of 'main.dart';

enum BrLeague {
  bronze,
  silver,
  gold,
  platinum,
  diamond,
  master,
  legend,
}

extension BrLeaguePresentation on BrLeague {
  String get title {
    return switch (this) {
      BrLeague.bronze => 'Bronz',
      BrLeague.silver => 'Gümüş',
      BrLeague.gold => 'Altın',
      BrLeague.platinum => 'Platin',
      BrLeague.diamond => 'Elmas',
      BrLeague.master => 'Usta',
      BrLeague.legend => 'Efsane',
    };
  }

  String get emoji {
    return switch (this) {
      BrLeague.bronze => '🟤',
      BrLeague.silver => '⚪',
      BrLeague.gold => '🟡',
      BrLeague.platinum => '💠',
      BrLeague.diamond => '💎',
      BrLeague.master => '👑',
      BrLeague.legend => '🌟',
    };
  }

  int get minimumRating {
    return switch (this) {
      BrLeague.bronze => 0,
      BrLeague.silver => 1000,
      BrLeague.gold => 1400,
      BrLeague.platinum => 1800,
      BrLeague.diamond => 2200,
      BrLeague.master => 2600,
      BrLeague.legend => 3000,
    };
  }

  int? get nextThreshold {
    return switch (this) {
      BrLeague.bronze => 1000,
      BrLeague.silver => 1400,
      BrLeague.gold => 1800,
      BrLeague.platinum => 2200,
      BrLeague.diamond => 2600,
      BrLeague.master => 3000,
      BrLeague.legend => null,
    };
  }
}

class BrLeagueResolver {
  BrLeagueResolver._();

  static BrLeague fromRating(int rating) {
    final safe = max(0, rating);

    if (safe >= 3000) return BrLeague.legend;
    if (safe >= 2600) return BrLeague.master;
    if (safe >= 2200) return BrLeague.diamond;
    if (safe >= 1800) return BrLeague.platinum;
    if (safe >= 1400) return BrLeague.gold;
    if (safe >= 1000) return BrLeague.silver;
    return BrLeague.bronze;
  }

  static int progressToNextLeague(int rating) {
    final league = fromRating(rating);
    final next = league.nextThreshold;
    if (next == null) return 0;
    return max(0, next - max(0, rating));
  }
}

enum LiveDuelResult {
  win,
  loss,
  draw,
}

class LiveDuelRatingChange {
  const LiveDuelRatingChange({
    required this.oldRating,
    required this.newRating,
    required this.delta,
    required this.oldLeague,
    required this.newLeague,
  });

  final int oldRating;
  final int newRating;
  final int delta;
  final BrLeague oldLeague;
  final BrLeague newLeague;

  bool get promoted => newLeague.index > oldLeague.index;
  bool get relegated => newLeague.index < oldLeague.index;
}

class LiveDuelRatingEngine {
  LiveDuelRatingEngine._();

  static const int initialRating = 1000;
  static const int placementMatchCount = 5;

  static LiveDuelRatingChange calculate({
    required int playerRating,
    required int opponentRating,
    required LiveDuelResult result,
    required int matchesPlayed,
  }) {
    final safePlayer = max(0, playerRating);
    final safeOpponent = max(0, opponentRating);
    final expected = 1 / (1 + pow(10, (safeOpponent - safePlayer) / 400));

    final actual = switch (result) {
      LiveDuelResult.win => 1.0,
      LiveDuelResult.draw => 0.5,
      LiveDuelResult.loss => 0.0,
    };

    final isPlacement = matchesPlayed < placementMatchCount;
    final kFactor = isPlacement ? 48.0 : 28.0;

    var delta = (kFactor * (actual - expected)).round();

    if (result == LiveDuelResult.win) {
      delta = max(delta, isPlacement ? 12 : 8);
    } else if (result == LiveDuelResult.loss) {
      delta = min(delta, isPlacement ? -12 : -8);
    }

    final newRating = max(0, safePlayer + delta);

    return LiveDuelRatingChange(
      oldRating: safePlayer,
      newRating: newRating,
      delta: newRating - safePlayer,
      oldLeague: BrLeagueResolver.fromRating(safePlayer),
      newLeague: BrLeagueResolver.fromRating(newRating),
    );
  }
}

class LiveDuelRecentMatch {
  const LiveDuelRecentMatch({
    required this.opponentName,
    required this.result,
    required this.ratingDelta,
    required this.playedAt,
  });

  final String opponentName;
  final LiveDuelResult result;
  final int ratingDelta;
  final DateTime playedAt;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'opponentName': opponentName,
        'result': result.name,
        'ratingDelta': ratingDelta,
        'playedAt': playedAt.toIso8601String(),
      };

  factory LiveDuelRecentMatch.fromJson(Map<String, dynamic> json) {
    return LiveDuelRecentMatch(
      opponentName: json['opponentName']?.toString() ?? 'Rakip',
      result: LiveDuelResult.values.firstWhere(
        (item) => item.name == json['result']?.toString(),
        orElse: () => LiveDuelResult.draw,
      ),
      ratingDelta: (json['ratingDelta'] as num?)?.toInt() ?? 0,
      playedAt: DateTime.tryParse(json['playedAt']?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}

class LiveDuelProfile {
  const LiveDuelProfile({
    this.rating = LiveDuelRatingEngine.initialRating,
    this.matchesPlayed = 0,
    this.wins = 0,
    this.losses = 0,
    this.draws = 0,
    this.currentWinStreak = 0,
    this.bestWinStreak = 0,
    this.highestRating = LiveDuelRatingEngine.initialRating,
    this.recentMatches = const <LiveDuelRecentMatch>[],
  });

  final int rating;
  final int matchesPlayed;
  final int wins;
  final int losses;
  final int draws;
  final int currentWinStreak;
  final int bestWinStreak;
  final int highestRating;
  final List<LiveDuelRecentMatch> recentMatches;

  BrLeague get league => BrLeagueResolver.fromRating(rating);
  BrLeague get highestLeague => BrLeagueResolver.fromRating(highestRating);
  bool get placementsComplete =>
      matchesPlayed >= LiveDuelRatingEngine.placementMatchCount;
  int get placementMatchesRemaining =>
      max(0, LiveDuelRatingEngine.placementMatchCount - matchesPlayed);

  double get winRate {
    if (matchesPlayed == 0) return 0;
    return wins / matchesPlayed;
  }

  LiveDuelProfile applyResult({
    required String opponentName,
    required int opponentRating,
    required LiveDuelResult result,
    DateTime? playedAt,
  }) {
    final change = LiveDuelRatingEngine.calculate(
      playerRating: rating,
      opponentRating: opponentRating,
      result: result,
      matchesPlayed: matchesPlayed,
    );

    final nextStreak = result == LiveDuelResult.win
        ? currentWinStreak + 1
        : 0;

    final updatedRecent = <LiveDuelRecentMatch>[
      LiveDuelRecentMatch(
        opponentName:
            opponentName.trim().isEmpty ? 'Rakip' : opponentName.trim(),
        result: result,
        ratingDelta: change.delta,
        playedAt: playedAt ?? DateTime.now(),
      ),
      ...recentMatches,
    ].take(10).toList(growable: false);

    return LiveDuelProfile(
      rating: change.newRating,
      matchesPlayed: matchesPlayed + 1,
      wins: wins + (result == LiveDuelResult.win ? 1 : 0),
      losses: losses + (result == LiveDuelResult.loss ? 1 : 0),
      draws: draws + (result == LiveDuelResult.draw ? 1 : 0),
      currentWinStreak: nextStreak,
      bestWinStreak: max(bestWinStreak, nextStreak),
      highestRating: max(highestRating, change.newRating),
      recentMatches: updatedRecent,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'rating': rating,
        'matchesPlayed': matchesPlayed,
        'wins': wins,
        'losses': losses,
        'draws': draws,
        'currentWinStreak': currentWinStreak,
        'bestWinStreak': bestWinStreak,
        'highestRating': highestRating,
        'recentMatches':
            recentMatches.map((item) => item.toJson()).toList(growable: false),
      };

  factory LiveDuelProfile.fromJson(Map<String, dynamic> json) {
    final rawRecent = json['recentMatches'];
    final recent = rawRecent is List
        ? rawRecent
            .whereType<Map>()
            .map((item) => LiveDuelRecentMatch.fromJson(
                  Map<String, dynamic>.from(item),
                ))
            .take(10)
            .toList(growable: false)
        : const <LiveDuelRecentMatch>[];

    return LiveDuelProfile(
      rating: max(
        0,
        (json['rating'] as num?)?.toInt() ??
            LiveDuelRatingEngine.initialRating,
      ),
      matchesPlayed:
          max(0, (json['matchesPlayed'] as num?)?.toInt() ?? 0),
      wins: max(0, (json['wins'] as num?)?.toInt() ?? 0),
      losses: max(0, (json['losses'] as num?)?.toInt() ?? 0),
      draws: max(0, (json['draws'] as num?)?.toInt() ?? 0),
      currentWinStreak:
          max(0, (json['currentWinStreak'] as num?)?.toInt() ?? 0),
      bestWinStreak:
          max(0, (json['bestWinStreak'] as num?)?.toInt() ?? 0),
      highestRating: max(
        0,
        (json['highestRating'] as num?)?.toInt() ??
            LiveDuelRatingEngine.initialRating,
      ),
      recentMatches: recent,
    );
  }
}

class LiveDuelProfileService {
  LiveDuelProfileService._();

  static const String _key = 'bilgi_rotasi_live_duel_profile_v1';
  static final SharedPreferencesAsync _preferences =
      SharedPreferencesAsync();

  static Future<LiveDuelProfile> load() async {
    try {
      final raw = await _preferences.getString(_key);
      if (raw == null || raw.isEmpty) {
        return const LiveDuelProfile();
      }

      final decoded = jsonDecode(raw);
      if (decoded is Map) {
        return LiveDuelProfile.fromJson(
          Map<String, dynamic>.from(decoded),
        );
      }
    } catch (_) {
      // Bozuk kayıt canlı düello profilini engellememeli.
    }

    return const LiveDuelProfile();
  }

  static Future<void> save(LiveDuelProfile profile) async {
    await _preferences.setString(
      _key,
      jsonEncode(profile.toJson()),
    );
  }

  static Future<LiveDuelProfile> applyResult({
    required String opponentName,
    required int opponentRating,
    required LiveDuelResult result,
    DateTime? playedAt,
  }) async {
    final current = await load();
    final updated = current.applyResult(
      opponentName: opponentName,
      opponentRating: opponentRating,
      result: result,
      playedAt: playedAt,
    );
    await save(updated);
    return updated;
  }
}
"""

test_code = r"""import 'package:bilgi_rotasi/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BR lig sistemi', () {
    test('lig eşikleri doğru çözülür', () {
      expect(BrLeagueResolver.fromRating(0), BrLeague.bronze);
      expect(BrLeagueResolver.fromRating(999), BrLeague.bronze);
      expect(BrLeagueResolver.fromRating(1000), BrLeague.silver);
      expect(BrLeagueResolver.fromRating(1400), BrLeague.gold);
      expect(BrLeagueResolver.fromRating(1800), BrLeague.platinum);
      expect(BrLeagueResolver.fromRating(2200), BrLeague.diamond);
      expect(BrLeagueResolver.fromRating(2600), BrLeague.master);
      expect(BrLeagueResolver.fromRating(3000), BrLeague.legend);
    });

    test('eşit rakibe karşı galibiyet puan kazandırır', () {
      final change = LiveDuelRatingEngine.calculate(
        playerRating: 1000,
        opponentRating: 1000,
        result: LiveDuelResult.win,
        matchesPlayed: 10,
      );

      expect(change.delta, greaterThan(0));
      expect(change.newRating, greaterThan(1000));
    });

    test('eşit rakibe karşı mağlubiyet puan kaybettirir', () {
      final change = LiveDuelRatingEngine.calculate(
        playerRating: 1000,
        opponentRating: 1000,
        result: LiveDuelResult.loss,
        matchesPlayed: 10,
      );

      expect(change.delta, lessThan(0));
      expect(change.newRating, lessThan(1000));
    });

    test('yerleştirme maçları daha yüksek etkilidir', () {
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

    test('profil sonucu ve seriyi günceller', () {
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

    test('son maç listesi en fazla 10 kayıt tutar', () {
      var profile = const LiveDuelProfile();

      for (var i = 0; i < 15; i++) {
        profile = profile.applyResult(
          opponentName: 'Rakip $i',
          opponentRating: 1000,
          result: LiveDuelResult.win,
          playedAt: DateTime(2026, 7, 1 + i),
        );
      }

      expect(profile.recentMatches.length, 10);
    });

    test('profil json dönüşümü korunur', () {
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
"""

TARGET.write_text(target_code, encoding="utf-8")
TEST.write_text(test_code, encoding="utf-8")
MAIN.write_text(main, encoding="utf-8")
PUBSPEC.write_text(
    pubspec.replace("version: 1.48.5+69", "version: 1.49.0+70", 1),
    encoding="utf-8",
)

commands = [
    ["dart", "format", "lib/main.dart", "lib/live_duel_league.dart", "test/live_duel_league_test.dart"],
    ["git", "diff", "--check"],
]

for command in commands:
    print("\n>", " ".join(command))
    result = subprocess.run(command)
    if result.returncode != 0:
        fail("Komut başarısız oldu: " + " ".join(command))

if subprocess.run(["which", "flutter"], capture_output=True).returncode == 0:
    for command in [
        ["flutter", "pub", "get"],
        ["flutter", "analyze"],
        ["flutter", "test"],
    ]:
        print("\n>", " ".join(command))
        result = subprocess.run(command)
        if result.returncode != 0:
            fail("Flutter kontrolü başarısız oldu: " + " ".join(command))

subprocess.run([
    "git", "add",
    "pubspec.yaml",
    "lib/main.dart",
    "lib/live_duel_league.dart",
    "test/live_duel_league_test.dart",
], check=True)

subprocess.run([
    "git", "commit",
    "-m", "Canli duello BR puani ve lig altyapisini ekle",
], check=True)

subprocess.run(["git", "push", "origin", "main"], check=True)

print("\nTAMAMLANDI")
print("Sürüm: 1.49.0+70")
print("BR puanı, ligler, yerleştirme maçları ve profil istatistikleri eklendi.")
