part of 'main.dart';

enum LiveDuelQueueStatus { waiting, matched, cancelled }

class LiveDuelMatchmakingPolicy {
  LiveDuelMatchmakingPolicy._();

  static const List<int> questionCountOptions = <int>[10, 20, 30];
  static const int ratingBucketSize = 200;
  static const Duration queueLifetime = Duration(minutes: 3);

  static bool supportsQuestionCount(int count) {
    return questionCountOptions.contains(count);
  }

  static int ratingBucket(int rating) {
    return max(0, rating) ~/ ratingBucketSize;
  }

  static List<int> searchBuckets(int rating) {
    final bucket = ratingBucket(rating);

    return <int>[bucket, if (bucket > 0) bucket - 1, bucket + 1];
  }
}

class LiveDuelQueueEntry {
  const LiveDuelQueueEntry({
    required this.uid,
    required this.displayName,
    required this.rating,
    required this.ratingBucket,
    required this.questionCount,
    required this.status,
    this.matchId,
    this.claimedBy,
    this.joinedAt,
    this.expiresAt,
  });

  final String uid;
  final String displayName;
  final int rating;
  final int ratingBucket;
  final int questionCount;
  final LiveDuelQueueStatus status;
  final String? matchId;
  final String? claimedBy;
  final DateTime? joinedAt;
  final DateTime? expiresAt;

  bool get waiting => status == LiveDuelQueueStatus.waiting;
  bool get matched =>
      status == LiveDuelQueueStatus.matched &&
      matchId != null &&
      matchId!.isNotEmpty;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'uid': uid,
    'displayName': displayName,
    'rating': rating,
    'ratingBucket': ratingBucket,
    'questionCount': questionCount,
    'status': status.name,
    'matchId': matchId,
    'claimedBy': claimedBy,
  };

  factory LiveDuelQueueEntry.fromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data() ?? <String, dynamic>{};
    final joinedAt = data['joinedAt'];
    final expiresAt = data['expiresAt'];

    return LiveDuelQueueEntry(
      uid: data['uid']?.toString() ?? snapshot.id,
      displayName: data['displayName']?.toString() ?? 'Bilgi Yolcusu',
      rating: max(0, (data['rating'] as num?)?.toInt() ?? 1000),
      ratingBucket: max(0, (data['ratingBucket'] as num?)?.toInt() ?? 5),
      questionCount: (data['questionCount'] as num?)?.toInt() ?? 10,
      status: LiveDuelQueueStatus.values.firstWhere(
        (item) => item.name == data['status']?.toString(),
        orElse: () => LiveDuelQueueStatus.cancelled,
      ),
      matchId: data['matchId']?.toString(),
      claimedBy: data['claimedBy']?.toString(),
      joinedAt: joinedAt is Timestamp ? joinedAt.toDate() : null,
      expiresAt: expiresAt is Timestamp ? expiresAt.toDate() : null,
    );
  }
}

class LiveDuelMatchmakingException implements Exception {
  const LiveDuelMatchmakingException(this.message);

  final String message;

  @override
  String toString() => message;
}

class LiveDuelMatchmakingService {
  LiveDuelMatchmakingService._();

  static FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  static CollectionReference<Map<String, dynamic>> get _queue =>
      _firestore.collection('live_duel_queue');

  static CollectionReference<Map<String, dynamic>> get _matches =>
      _firestore.collection('live_duel_matches');

  static User _requireUser() {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw const LiveDuelMatchmakingException(
        'Canlı düello için Google hesabıyla giriş yapmalısın.',
      );
    }

    return user;
  }

  static Future<void> enterQueue({required int questionCount}) async {
    if (!LiveDuelMatchmakingPolicy.supportsQuestionCount(questionCount)) {
      throw const LiveDuelMatchmakingException(
        'Soru sayısı 10, 20 veya 30 olmalı.',
      );
    }

    final user = _requireUser();
    final profile = await LiveDuelProfileService.load();
    final username = await PlayerUsernameService.requireUsername();
    final now = DateTime.now().toUtc();

    await _queue.doc(user.uid).set(<String, dynamic>{
      'uid': user.uid,
      'displayName': username,
      'rating': profile.rating,
      'ratingBucket': LiveDuelMatchmakingPolicy.ratingBucket(profile.rating),
      'questionCount': questionCount,
      'status': LiveDuelQueueStatus.waiting.name,
      'matchId': null,
      'claimedBy': null,
      'joinedAt': FieldValue.serverTimestamp(),
      'expiresAt': Timestamp.fromDate(
        now.add(LiveDuelMatchmakingPolicy.queueLifetime),
      ),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await tryMatch();
  }

  static Future<String?> tryMatch() async {
    final user = _requireUser();
    final ownReference = _queue.doc(user.uid);
    final ownSnapshot = await ownReference.get();

    if (!ownSnapshot.exists) return null;

    final own = LiveDuelQueueEntry.fromSnapshot(ownSnapshot);

    if (!own.waiting) return own.matchId;

    for (final bucket in LiveDuelMatchmakingPolicy.searchBuckets(own.rating)) {
      final candidates =
          await _queue
              .where('questionCount', isEqualTo: own.questionCount)
              .where('ratingBucket', isEqualTo: bucket)
              .where('status', isEqualTo: LiveDuelQueueStatus.waiting.name)
              .limit(10)
              .get();

      for (final candidateSnapshot in candidates.docs) {
        if (candidateSnapshot.id == user.uid) continue;
        if (await PlayerSafetyService.isBlockedEitherDirection(
          candidateSnapshot.id,
        )) {
          continue;
        }

        final matchId = await _claimCandidate(
          ownReference: ownReference,
          candidateReference: candidateSnapshot.reference,
          questionCount: own.questionCount,
          opponentUid: candidateSnapshot.id,
        );

        if (matchId != null) return matchId;
      }
    }

    return null;
  }

  static Future<String?> _claimCandidate({
    required DocumentReference<Map<String, dynamic>> ownReference,
    required DocumentReference<Map<String, dynamic>> candidateReference,
    required int questionCount,
    required String opponentUid,
  }) async {
    final user = _requireUser();
    final matchReference = _matches.doc();

    final seed = LiveDuelQuestionSetService.seedForMatch(
      matchId: matchReference.id,
      firstPlayerUid: user.uid,
      secondPlayerUid: opponentUid,
    );

    final questionIds = await LiveDuelQuestionSetService.createQuestionIds(
      questionCount: questionCount,
      seed: seed,
    );

    return _firestore.runTransaction<String?>((transaction) async {
      final ownSnapshot = await transaction.get(ownReference);
      final candidateSnapshot = await transaction.get(candidateReference);

      if (!ownSnapshot.exists || !candidateSnapshot.exists) {
        return null;
      }

      final own = LiveDuelQueueEntry.fromSnapshot(ownSnapshot);
      final candidate = LiveDuelQueueEntry.fromSnapshot(candidateSnapshot);

      if (!own.waiting ||
          !candidate.waiting ||
          own.uid == candidate.uid ||
          own.questionCount != candidate.questionCount) {
        return null;
      }

      final now = DateTime.now();

      if (candidate.expiresAt != null && candidate.expiresAt!.isBefore(now)) {
        return null;
      }

      final playerUids = <String>[own.uid, candidate.uid];

      transaction.set(matchReference, <String, dynamic>{
        'status': 'preparing',
        'questionCount': own.questionCount,
        'questionIds': questionIds,
        'questionSetVersion': LiveDuelQuestionSetService.currentVersion,
        'playerUids': playerUids,
        'players': <Map<String, dynamic>>[
          <String, dynamic>{
            'uid': own.uid,
            'displayName': own.displayName,
            'rating': own.rating,
            'ready': false,
          },
          <String, dynamic>{
            'uid': candidate.uid,
            'displayName': candidate.displayName,
            'rating': candidate.rating,
            'ready': false,
          },
        ],
        'createdBy': user.uid,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      transaction.update(ownReference, <String, dynamic>{
        'status': LiveDuelQueueStatus.matched.name,
        'matchId': matchReference.id,
        'claimedBy': user.uid,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      transaction.update(candidateReference, <String, dynamic>{
        'status': LiveDuelQueueStatus.matched.name,
        'matchId': matchReference.id,
        'claimedBy': user.uid,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return matchReference.id;
    });
  }

  static Stream<LiveDuelQueueEntry?> watchOwnQueue() {
    final user = _requireUser();

    return _queue
        .doc(user.uid)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.exists
                  ? LiveDuelQueueEntry.fromSnapshot(snapshot)
                  : null,
        );
  }

  static Stream<DocumentSnapshot<Map<String, dynamic>>> watchMatch(
    String matchId,
  ) {
    final user = _requireUser();

    if (matchId.trim().isEmpty) {
      throw const LiveDuelMatchmakingException('Eşleşme kimliği boş olamaz.');
    }

    return _matches.doc(matchId).snapshots().map((snapshot) {
      final data = snapshot.data();
      final rawUids = data?['playerUids'];
      final playerUids =
          rawUids is List
              ? rawUids.map((item) => item.toString()).toList()
              : const <String>[];

      if (snapshot.exists && !playerUids.contains(user.uid)) {
        throw const LiveDuelMatchmakingException(
          'Bu eşleşmeye erişim yetkin yok.',
        );
      }

      return snapshot;
    });
  }

  static Future<void> cancelQueue() async {
    final user = _requireUser();
    final reference = _queue.doc(user.uid);
    final snapshot = await reference.get();

    if (!snapshot.exists) return;

    final entry = LiveDuelQueueEntry.fromSnapshot(snapshot);

    if (entry.matched) {
      throw const LiveDuelMatchmakingException(
        'Rakip bulunduğu için eşleştirme artık iptal edilemez.',
      );
    }

    await reference.delete();
  }
}
