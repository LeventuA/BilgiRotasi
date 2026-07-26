part of 'main.dart';

enum BrLeague { bronze, silver, gold, platinum, diamond, master, legend }

extension BrLeaguePresentation on BrLeague {
  String get title => switch (this) {
    BrLeague.bronze => 'Bronz',
    BrLeague.silver => 'Gümüş',
    BrLeague.gold => 'Altın',
    BrLeague.platinum => 'Platin',
    BrLeague.diamond => 'Elmas',
    BrLeague.master => 'Usta',
    BrLeague.legend => 'Efsane',
  };

  String get emoji => switch (this) {
    BrLeague.bronze => '🟤',
    BrLeague.silver => '⚪',
    BrLeague.gold => '🟡',
    BrLeague.platinum => '💠',
    BrLeague.diamond => '💎',
    BrLeague.master => '👑',
    BrLeague.legend => '🌟',
  };

  int get minimumRating => switch (this) {
    BrLeague.bronze => 0,
    BrLeague.silver => 1000,
    BrLeague.gold => 1400,
    BrLeague.platinum => 1800,
    BrLeague.diamond => 2200,
    BrLeague.master => 2600,
    BrLeague.legend => 3000,
  };

  int? get nextThreshold => switch (this) {
    BrLeague.bronze => 1000,
    BrLeague.silver => 1400,
    BrLeague.gold => 1800,
    BrLeague.platinum => 2200,
    BrLeague.diamond => 2600,
    BrLeague.master => 3000,
    BrLeague.legend => null,
  };
}

class BrLeagueResolver {
  BrLeagueResolver._();

  static BrLeague fromRating(int rating) {
    final safeRating = max(0, rating);

    if (safeRating >= 3000) return BrLeague.legend;
    if (safeRating >= 2600) return BrLeague.master;
    if (safeRating >= 2200) return BrLeague.diamond;
    if (safeRating >= 1800) return BrLeague.platinum;
    if (safeRating >= 1400) return BrLeague.gold;
    if (safeRating >= 1000) return BrLeague.silver;
    return BrLeague.bronze;
  }

  static int pointsToNextLeague(int rating) {
    final next = fromRating(rating).nextThreshold;
    if (next == null) return 0;
    return max(0, next - max(0, rating));
  }
}

enum LiveDuelResult { win, loss, draw }

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

    final expectedScore =
        1.0 / (1.0 + pow(10.0, (safeOpponent - safePlayer) / 400.0));

    final actualScore = switch (result) {
      LiveDuelResult.win => 1.0,
      LiveDuelResult.draw => 0.5,
      LiveDuelResult.loss => 0.0,
    };

    final placement = matchesPlayed < LiveDuelRatingEngine.placementMatchCount;
    final kFactor = placement ? 48.0 : 28.0;

    var delta = (kFactor * (actualScore - expectedScore)).round();

    if (result == LiveDuelResult.win) {
      delta = max(delta, placement ? 12 : 8);
    } else if (result == LiveDuelResult.loss) {
      delta = min(delta, placement ? -12 : -8);
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
      playedAt:
          DateTime.tryParse(json['playedAt']?.toString() ?? '') ??
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

    final nextStreak = result == LiveDuelResult.win ? currentWinStreak + 1 : 0;

    final updatedRecentMatches = <LiveDuelRecentMatch>[
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
      recentMatches: updatedRecentMatches,
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
    'recentMatches': recentMatches
        .map((match) => match.toJson())
        .toList(growable: false),
  };

  factory LiveDuelProfile.fromJson(Map<String, dynamic> json) {
    final rawMatches = json['recentMatches'];

    final matches =
        rawMatches is List
            ? rawMatches
                .whereType<Map>()
                .map(
                  (item) => LiveDuelRecentMatch.fromJson(
                    Map<String, dynamic>.from(item),
                  ),
                )
                .take(10)
                .toList(growable: false)
            : const <LiveDuelRecentMatch>[];

    return LiveDuelProfile(
      rating: max(
        0,
        (json['rating'] as num?)?.toInt() ?? LiveDuelRatingEngine.initialRating,
      ),
      matchesPlayed: max(0, (json['matchesPlayed'] as num?)?.toInt() ?? 0),
      wins: max(0, (json['wins'] as num?)?.toInt() ?? 0),
      losses: max(0, (json['losses'] as num?)?.toInt() ?? 0),
      draws: max(0, (json['draws'] as num?)?.toInt() ?? 0),
      currentWinStreak: max(
        0,
        (json['currentWinStreak'] as num?)?.toInt() ?? 0,
      ),
      bestWinStreak: max(0, (json['bestWinStreak'] as num?)?.toInt() ?? 0),
      highestRating: max(
        0,
        (json['highestRating'] as num?)?.toInt() ??
            LiveDuelRatingEngine.initialRating,
      ),
      recentMatches: matches,
    );
  }
}

class LiveDuelProfileService {
  LiveDuelProfileService._();

  static const String _storageKey = 'bilgi_rotasi_live_duel_profile_v1';

  static final SharedPreferencesAsync _preferences = SharedPreferencesAsync();

  static Future<LiveDuelProfile> _loadLocal() async {
    try {
      final raw = await _preferences.getString(_storageKey);

      if (raw == null || raw.isEmpty) {
        return const LiveDuelProfile();
      }

      final decoded = jsonDecode(raw);

      if (decoded is Map) {
        return LiveDuelProfile.fromJson(Map<String, dynamic>.from(decoded));
      }
    } catch (_) {
      // Bozuk yerel kayıt canlı düello profilini engellememeli.
    }

    return const LiveDuelProfile();
  }

  static Future<void> saveLocal(LiveDuelProfile profile) async {
    await _preferences.setString(_storageKey, jsonEncode(profile.toJson()));
  }

  static Future<LiveDuelProfile> load() async {
    final local = await _loadLocal();
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return local;

    try {
      final reference = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid);
      final snapshot = await reference.get(GetOptions(source: Source.server));
      final rawProfile = snapshot.data()?['liveDuelProfile'];

      if (rawProfile is Map) {
        final remote = LiveDuelProfile.fromJson(
          Map<String, dynamic>.from(rawProfile),
        );
        await saveLocal(remote);
        await LiveDuelLeaderboardService.publish(remote);
        return remote;
      }

      await reference.set(<String, dynamic>{
        'liveDuelProfile': local.toJson(),
        'liveDuelProfileUpdatedAt': FieldValue.serverTimestamp(),
        'appVersion': AppBuildInfo.version,
      }, SetOptions(merge: true));
      await LiveDuelLeaderboardService.publish(local);
    } catch (_) {
      // Bulut profil erişimi yerel profili engellememeli.
    }

    return local;
  }

  static Future<void> save(LiveDuelProfile profile) async {
    await saveLocal(profile);

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set(<String, dynamic>{
            'liveDuelProfile': profile.toJson(),
            'liveDuelProfileUpdatedAt': FieldValue.serverTimestamp(),
            'appVersion': AppBuildInfo.version,
          }, SetOptions(merge: true));
      await LiveDuelLeaderboardService.publish(profile);
    } catch (_) {
      // Yerel profil korunur; sonraki yüklemede bulut tekrar denenir.
    }
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
