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

  static void _validateFinishedProgress({
    required LiveDuelPlayerProgress progress,
    required int questionCount,
  }) {
    if (!progress.finished ||
        progress.answeredCount != questionCount ||
        progress.currentQuestionIndex != questionCount ||
        progress.correctCount + progress.wrongCount != questionCount) {
      throw const LiveDuelResultException(
        'İki oyuncu da maçı tamamlamadan sonuç kesinleştirilemez.',
      );
    }
  }

  static Future<LiveDuelCompletedMatch> finalizeMatch({
    required String matchId,
  }) async {
    final user = _requireUser();
    final matchReference = _matchReference(matchId);

    return _firestore.runTransaction<LiveDuelCompletedMatch>((
      transaction,
    ) async {
      final matchSnapshot = await transaction.get(matchReference);

      if (!matchSnapshot.exists) {
        throw const LiveDuelResultException('Canlı düello maçı bulunamadı.');
      }

      final matchData = matchSnapshot.data() ?? <String, dynamic>{};

      if (matchData['resultProcessed'] == true) {
        return LiveDuelCompletedMatch.fromMap(
          matchId: matchId,
          data: matchData,
        );
      }

      final rawPlayerUids = matchData['playerUids'];
      final playerUids =
          rawPlayerUids is List
              ? rawPlayerUids
                  .map((item) => item.toString())
                  .toList(growable: false)
              : const <String>[];

      if (playerUids.length != 2 ||
          playerUids.toSet().length != 2 ||
          !playerUids.contains(user.uid)) {
        throw const LiveDuelResultException('Maç oyuncu bilgileri geçersiz.');
      }

      final questionCount = (matchData['questionCount'] as num?)?.toInt() ?? 0;

      if (!LiveDuelMatchmakingPolicy.supportsQuestionCount(questionCount)) {
        throw const LiveDuelResultException('Maç soru sayısı geçersiz.');
      }

      final firstUid = playerUids[0];
      final secondUid = playerUids[1];
      final firstReference = matchReference
          .collection('progress')
          .doc(firstUid);
      final secondReference = matchReference
          .collection('progress')
          .doc(secondUid);

      final firstSnapshot = await transaction.get(firstReference);
      final secondSnapshot = await transaction.get(secondReference);

      if (!firstSnapshot.exists || !secondSnapshot.exists) {
        throw const LiveDuelResultException(
          'Maç ilerleme kayıtları tamamlanmadı.',
        );
      }

      final firstProgress = LiveDuelPlayerProgress.fromSnapshot(firstSnapshot);
      final secondProgress = LiveDuelPlayerProgress.fromSnapshot(
        secondSnapshot,
      );

      _validateFinishedProgress(
        progress: firstProgress,
        questionCount: questionCount,
      );
      _validateFinishedProgress(
        progress: secondProgress,
        questionCount: questionCount,
      );

      final scores = <String, int>{
        firstUid: firstProgress.correctCount,
        secondUid: secondProgress.correctCount,
      };
      final winnerUid = LiveDuelMatchResultResolver.winnerUid(
        playerUids: playerUids,
        scores: scores,
      );
      final completedAt = DateTime.now().toUtc();

      transaction.update(matchReference, <String, dynamic>{
        'status': 'completed',
        'resultProcessed': true,
        'resultVersion': 2,
        'completionType': LiveDuelCompletionType.completed.name,
        'forfeitLoserUid': null,
        'scores': scores,
        'winnerUid': winnerUid,
        'draw': winnerUid == null,
        'processedBy': user.uid,
        'completedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return LiveDuelCompletedMatch(
        matchId: matchId,
        playerUids: List<String>.unmodifiable(playerUids),
        scores: Map<String, int>.unmodifiable(scores),
        draw: winnerUid == null,
        winnerUid: winnerUid,
        completionType: LiveDuelCompletionType.completed,
        forfeitLoserUid: null,
        completedAt: completedAt,
      );
    });
  }

  static Map<String, dynamic> _playerData(
    Map<String, dynamic> matchData,
    String uid,
  ) {
    final rawPlayers = matchData['players'];

    if (rawPlayers is List) {
      for (final item in rawPlayers) {
        if (item is! Map) continue;
        final player = Map<String, dynamic>.from(item);
        if (player['uid']?.toString() == uid) {
          return player;
        }
      }
    }

    return <String, dynamic>{
      'uid': uid,
      'displayName': 'Bilgi Yolcusu',
      'rating': LiveDuelRatingEngine.initialRating,
    };
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

    final award = await _firestore.runTransaction<LiveDuelOwnResultAward>((
      transaction,
    ) async {
      final matchSnapshot = await transaction.get(matchReference);
      final claimSnapshot = await transaction.get(claimReference);
      final userSnapshot = await transaction.get(userReference);

      if (!matchSnapshot.exists) {
        throw const LiveDuelResultException('Canlı düello maçı bulunamadı.');
      }

      final matchData = matchSnapshot.data() ?? <String, dynamic>{};
      final completed = LiveDuelCompletedMatch.fromMap(
        matchId: matchId,
        data: matchData,
      );

      if (!completed.playerUids.contains(user.uid)) {
        throw const LiveDuelResultException('Bu maçın oyuncusu değilsin.');
      }

      final currentProfile = _profileFromUserData(
        userSnapshot.data(),
        fallbackProfile,
      );

      if (claimSnapshot.exists) {
        final claimData = claimSnapshot.data() ?? <String, dynamic>{};
        final result = LiveDuelResult.values.firstWhere(
          (item) => item.name == claimData['result']?.toString(),
          orElse: () => completed.resultFor(user.uid),
        );

        return LiveDuelOwnResultAward(
          match: completed,
          profile: currentProfile,
          ratingChange: _ratingChangeFromClaim(claimData),
          result: result,
          alreadyApplied: true,
        );
      }

      final opponentUid = completed.opponentUidFor(user.uid);
      final opponentData = _playerData(matchData, opponentUid);
      final opponentName = opponentData['displayName']?.toString().trim();
      final opponentRating = max(
        0,
        (opponentData['rating'] as num?)?.toInt() ??
            LiveDuelRatingEngine.initialRating,
      );
      final result = completed.resultFor(user.uid);
      final plan = LiveDuelOwnResultPlanner.plan(
        current: currentProfile,
        opponentName:
            opponentName == null || opponentName.isEmpty
                ? 'Bilgi Yolcusu'
                : opponentName,
        opponentRating: opponentRating,
        result: result,
        playedAt: completed.completedAt ?? DateTime.now().toUtc(),
      );

      transaction.set(userReference, <String, dynamic>{
        'liveDuelProfile': plan.profile.toJson(),
        'liveDuelProfileUpdatedAt': FieldValue.serverTimestamp(),
        'appVersion': AppBuildInfo.version,
      }, SetOptions(merge: true));

      transaction.set(claimReference, <String, dynamic>{
        'matchId': matchId,
        'uid': user.uid,
        'opponentUid': opponentUid,
        'result': result.name,
        'oldRating': plan.ratingChange.oldRating,
        'newRating': plan.ratingChange.newRating,
        'ratingDelta': plan.ratingChange.delta,
        'oldLeague': plan.ratingChange.oldLeague.name,
        'newLeague': plan.ratingChange.newLeague.name,
        'processedAt': FieldValue.serverTimestamp(),
        'appVersion': AppBuildInfo.version,
      });

      return LiveDuelOwnResultAward(
        match: completed,
        profile: plan.profile,
        ratingChange: plan.ratingChange,
        result: result,
        alreadyApplied: false,
      );
    });

    await LiveDuelProfileService.saveLocal(award.profile);
    return award;
  }
}
