part of 'main.dart';

class LiveDuelResultException implements Exception {
  const LiveDuelResultException(this.message);

  final String message;

  @override
  String toString() => message;
}

enum LiveDuelCompletionType { completed, forfeit }

class LiveDuelCompletedMatch {
  const LiveDuelCompletedMatch({
    required this.matchId,
    required this.playerUids,
    required this.scores,
    required this.draw,
    required this.winnerUid,
    this.completionType = LiveDuelCompletionType.completed,
    this.forfeitLoserUid,
    this.completedAt,
  });

  final String matchId;
  final List<String> playerUids;
  final Map<String, int> scores;
  final bool draw;
  final String? winnerUid;
  final LiveDuelCompletionType completionType;
  final String? forfeitLoserUid;
  final DateTime? completedAt;

  bool get forfeited => completionType == LiveDuelCompletionType.forfeit;

  factory LiveDuelCompletedMatch.fromMap({
    required String matchId,
    required Map<String, dynamic> data,
  }) {
    if (data['resultProcessed'] != true) {
      throw const LiveDuelResultException('Maç sonucu henüz kesinleşmedi.');
    }

    final rawPlayerUids = data['playerUids'];
    final playerUids =
        rawPlayerUids is List
            ? rawPlayerUids
                .map((item) => item.toString())
                .where((item) => item.isNotEmpty)
                .toList(growable: false)
            : const <String>[];

    if (playerUids.length != 2 || playerUids.toSet().length != 2) {
      throw const LiveDuelResultException('Maç oyuncu bilgileri geçersiz.');
    }

    final rawScores = data['scores'];
    if (rawScores is! Map) {
      throw const LiveDuelResultException('Maç skorları bulunamadı.');
    }

    final scores = <String, int>{};
    for (final uid in playerUids) {
      final rawScore = rawScores[uid];
      if (rawScore is! num || rawScore.toInt() < 0) {
        throw const LiveDuelResultException('Maç skorları geçersiz.');
      }
      scores[uid] = rawScore.toInt();
    }

    final completionType = LiveDuelCompletionType.values.firstWhere(
      (item) => item.name == data['completionType']?.toString(),
      orElse: () => LiveDuelCompletionType.completed,
    );
    final rawWinnerUid = data['winnerUid'];
    final winnerUid = rawWinnerUid == null ? null : rawWinnerUid.toString();
    final rawForfeitLoserUid = data['forfeitLoserUid'];
    final forfeitLoserUid =
        rawForfeitLoserUid == null ? null : rawForfeitLoserUid.toString();
    final draw = data['draw'] == true;

    if (completionType == LiveDuelCompletionType.forfeit) {
      if (draw ||
          forfeitLoserUid == null ||
          !playerUids.contains(forfeitLoserUid) ||
          winnerUid == null ||
          !playerUids.contains(winnerUid) ||
          winnerUid == forfeitLoserUid) {
        throw const LiveDuelResultException('Hükmen maç sonucu geçersiz.');
      }
    } else {
      final expectedWinner = LiveDuelMatchResultResolver.winnerUid(
        playerUids: playerUids,
        scores: scores,
      );

      if ((expectedWinner == null && (!draw || winnerUid != null)) ||
          (expectedWinner != null && (draw || winnerUid != expectedWinner))) {
        throw const LiveDuelResultException(
          'Maç sonucu ile skorlar uyuşmuyor.',
        );
      }
    }

    final completedAt = data['completedAt'];

    return LiveDuelCompletedMatch(
      matchId: matchId,
      playerUids: List<String>.unmodifiable(playerUids),
      scores: Map<String, int>.unmodifiable(scores),
      draw: draw,
      winnerUid: winnerUid,
      completionType: completionType,
      forfeitLoserUid: forfeitLoserUid,
      completedAt: completedAt is Timestamp ? completedAt.toDate() : null,
    );
  }

  int scoreFor(String uid) {
    final score = scores[uid];
    if (score == null) {
      throw const LiveDuelResultException('Oyuncunun maç skoru bulunamadı.');
    }
    return score;
  }

  String opponentUidFor(String ownUid) {
    if (!playerUids.contains(ownUid)) {
      throw const LiveDuelResultException('Bu maçın oyuncusu değilsin.');
    }
    return playerUids.firstWhere((uid) => uid != ownUid);
  }

  LiveDuelResult resultFor(String uid) {
    if (!playerUids.contains(uid)) {
      throw const LiveDuelResultException('Bu maçın oyuncusu değilsin.');
    }
    if (draw) return LiveDuelResult.draw;
    return winnerUid == uid ? LiveDuelResult.win : LiveDuelResult.loss;
  }
}

class LiveDuelMatchResultResolver {
  LiveDuelMatchResultResolver._();

  static String? winnerUid({
    required List<String> playerUids,
    required Map<String, int> scores,
  }) {
    if (playerUids.length != 2 || playerUids.toSet().length != 2) {
      throw const LiveDuelResultException(
        'Sonuç için iki farklı oyuncu gerekir.',
      );
    }

    final firstUid = playerUids[0];
    final secondUid = playerUids[1];
    final firstScore = scores[firstUid];
    final secondScore = scores[secondUid];

    if (firstScore == null || secondScore == null) {
      throw const LiveDuelResultException(
        'İki oyuncunun da skoru bulunmalıdır.',
      );
    }

    if (firstScore == secondScore) return null;
    return firstScore > secondScore ? firstUid : secondUid;
  }
}

class LiveDuelOwnResultPlan {
  const LiveDuelOwnResultPlan({
    required this.profile,
    required this.ratingChange,
    required this.result,
  });

  final LiveDuelProfile profile;
  final LiveDuelRatingChange ratingChange;
  final LiveDuelResult result;
}

class LiveDuelOwnResultPlanner {
  LiveDuelOwnResultPlanner._();

  static LiveDuelOwnResultPlan plan({
    required LiveDuelProfile current,
    String opponentUid = '',
    required String opponentName,
    required int opponentRating,
    required LiveDuelResult result,
    required DateTime playedAt,
  }) {
    final ratingChange = LiveDuelRatingEngine.calculate(
      playerRating: current.rating,
      opponentRating: opponentRating,
      result: result,
      matchesPlayed: current.matchesPlayed,
    );

    final profile = current.applyResult(
      opponentUid: opponentUid,
      opponentName: opponentName,
      opponentRating: opponentRating,
      result: result,
      playedAt: playedAt,
    );

    if (profile.rating != ratingChange.newRating) {
      throw const LiveDuelResultException(
        'BR hesabı tutarlı biçimde oluşturulamadı.',
      );
    }

    return LiveDuelOwnResultPlan(
      profile: profile,
      ratingChange: ratingChange,
      result: result,
    );
  }
}

class LiveDuelOwnResultAward {
  const LiveDuelOwnResultAward({
    required this.match,
    required this.profile,
    required this.ratingChange,
    required this.result,
    required this.alreadyApplied,
  });

  final LiveDuelCompletedMatch match;
  final LiveDuelProfile profile;
  final LiveDuelRatingChange ratingChange;
  final LiveDuelResult result;
  final bool alreadyApplied;
}

class LiveDuelResultService {
  LiveDuelResultService._();

  static FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  static User _requireUser() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw const LiveDuelResultException(
        'Canlı düello için Google hesabıyla giriş yapmalısın.',
      );
    }
    return user;
  }

  static DocumentReference<Map<String, dynamic>> _matchReference(
    String matchId,
  ) {
    if (matchId.trim().isEmpty) {
      throw const LiveDuelResultException('Maç kimliği boş olamaz.');
    }
    return _firestore.collection('live_duel_matches').doc(matchId);
  }

  static Future<LiveDuelCompletedMatch> finalizeMatch({
    required String matchId,
  }) async {
    _requireUser();
    final matchReference = _matchReference(matchId);
    await LiveDuelServerGateway.finalize(matchId);
    final matchSnapshot = await matchReference.get();
    if (!matchSnapshot.exists) {
      throw const LiveDuelResultException('Canlı düello maçı bulunamadı.');
    }
    return LiveDuelCompletedMatch.fromMap(
      matchId: matchId,
      data: matchSnapshot.data() ?? <String, dynamic>{},
    );
  }

  static LiveDuelProfile _profileFromUserData(
    Map<String, dynamic>? userData,
    LiveDuelProfile fallback,
  ) {
    final rawProfile = userData?['liveDuelProfile'];
    if (rawProfile is Map) {
      return LiveDuelProfile.fromJson(Map<String, dynamic>.from(rawProfile));
    }
    return fallback;
  }

  static LiveDuelRatingChange _ratingChangeFromClaim(
    Map<String, dynamic> claimData,
  ) {
    final oldRating = max(0, (claimData['oldRating'] as num?)?.toInt() ?? 0);
    final newRating = max(0, (claimData['newRating'] as num?)?.toInt() ?? 0);

    return LiveDuelRatingChange(
      oldRating: oldRating,
      newRating: newRating,
      delta:
          (claimData['ratingDelta'] as num?)?.toInt() ?? newRating - oldRating,
      oldLeague: BrLeague.values.firstWhere(
        (item) => item.name == claimData['oldLeague']?.toString(),
        orElse: () => BrLeagueResolver.fromRating(oldRating),
      ),
      newLeague: BrLeague.values.firstWhere(
        (item) => item.name == claimData['newLeague']?.toString(),
        orElse: () => BrLeagueResolver.fromRating(newRating),
      ),
    );
  }

  static Future<LiveDuelOwnResultAward> applyOwnResult({
    required String matchId,
  }) async {
    final user = _requireUser();
    final fallbackProfile = await LiveDuelProfileService.load();
    final matchReference = _matchReference(matchId);
    final userReference = _firestore.collection('users').doc(user.uid);
    final claimReference = userReference
        .collection('live_duel_results')
        .doc(matchId);

    final snapshots = await Future.wait<DocumentSnapshot<Map<String, dynamic>>>(
      [matchReference.get(), claimReference.get(), userReference.get()],
    );
    final matchSnapshot = snapshots[0];
    final claimSnapshot = snapshots[1];
    final userSnapshot = snapshots[2];
    if (!matchSnapshot.exists || !claimSnapshot.exists) {
      throw const LiveDuelResultException(
        'Sunucu tarafından kesinleştirilmiş maç sonucu bulunamadı.',
      );
    }
    final completed = LiveDuelCompletedMatch.fromMap(
      matchId: matchId,
      data: matchSnapshot.data() ?? <String, dynamic>{},
    );
    if (!completed.playerUids.contains(user.uid)) {
      throw const LiveDuelResultException('Bu maçın oyuncusu değilsin.');
    }
    final claimData = claimSnapshot.data() ?? <String, dynamic>{};
    final result = LiveDuelResult.values.firstWhere(
      (item) => item.name == claimData['result']?.toString(),
      orElse: () => completed.resultFor(user.uid),
    );
    final award = LiveDuelOwnResultAward(
      match: completed,
      profile: _profileFromUserData(userSnapshot.data(), fallbackProfile),
      ratingChange: _ratingChangeFromClaim(claimData),
      result: result,
      alreadyApplied: true,
    );

    await LiveDuelProfileService.saveLocal(award.profile);
    return award;
  }
}
