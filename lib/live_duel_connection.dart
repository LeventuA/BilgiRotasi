part of 'main.dart';

enum LiveDuelPresenceState { active, background, left }

class LiveDuelConnectionException implements Exception {
  const LiveDuelConnectionException(this.message);

  final String message;

  @override
  String toString() => message;
}

class LiveDuelPresence {
  const LiveDuelPresence({
    required this.uid,
    required this.state,
    required this.connected,
    required this.leaveRequested,
    this.updatedAt,
    this.disconnectedAt,
    this.graceUntil,
  });

  final String uid;
  final LiveDuelPresenceState state;
  final bool connected;
  final bool leaveRequested;
  final DateTime? updatedAt;
  final DateTime? disconnectedAt;
  final DateTime? graceUntil;

  factory LiveDuelPresence.fromMap({
    required String uid,
    required Map<String, dynamic> data,
  }) {
    DateTime? readDate(Object? value) {
      if (value is Timestamp) return value.toDate();
      if (value is DateTime) return value;
      if (value is String) return DateTime.tryParse(value);
      return null;
    }

    return LiveDuelPresence(
      uid: data['uid']?.toString() ?? uid,
      state: LiveDuelPresenceState.values.firstWhere(
        (item) => item.name == data['state']?.toString(),
        orElse: () => LiveDuelPresenceState.background,
      ),
      connected: data['connected'] == true,
      leaveRequested: data['leaveRequested'] == true,
      updatedAt: readDate(data['updatedAt']),
      disconnectedAt: readDate(data['disconnectedAt']),
      graceUntil: readDate(data['graceUntil']),
    );
  }

  factory LiveDuelPresence.fromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    return LiveDuelPresence.fromMap(
      uid: snapshot.id,
      data: snapshot.data() ?? <String, dynamic>{},
    );
  }
}

class LiveDuelResumeMatch {
  const LiveDuelResumeMatch({
    required this.matchId,
    required this.questionCount,
    this.createdAt,
  });

  final String matchId;
  final int questionCount;
  final DateTime? createdAt;
}

class LiveDuelConnectionPolicy {
  LiveDuelConnectionPolicy._();

  static const Duration reconnectGrace = Duration(minutes: 3);
  static const Duration heartbeatInterval = Duration(seconds: 20);
  static const Duration resolutionInterval = Duration(seconds: 5);
  static const Duration countdownInterval = Duration(seconds: 1);

  static bool shouldMarkBackground(AppLifecycleState? state) {
    return state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached;
  }

  static bool canForfeit(LiveDuelPresence presence, DateTime now) {
    if (presence.state == LiveDuelPresenceState.left &&
        presence.leaveRequested) {
      return true;
    }

    final graceUntil = presence.graceUntil;
    return presence.state == LiveDuelPresenceState.background &&
        !presence.connected &&
        graceUntil != null &&
        !graceUntil.isAfter(now);
  }

  static Duration remaining(LiveDuelPresence presence, DateTime now) {
    final graceUntil = presence.graceUntil;
    if (graceUntil == null || !graceUntil.isAfter(now)) {
      return Duration.zero;
    }
    return graceUntil.difference(now);
  }

  static String? forfeitLoser({
    required List<String> playerUids,
    required List<LiveDuelPresence> presences,
    required DateTime now,
  }) {
    if (playerUids.length != 2 || playerUids.toSet().length != 2) {
      throw const LiveDuelConnectionException(
        'Hükmen sonuç için iki farklı oyuncu gerekir.',
      );
    }

    final eligible = presences
        .where(
          (presence) =>
              playerUids.contains(presence.uid) && canForfeit(presence, now),
        )
        .toList(growable: false);

    if (eligible.isEmpty) return null;
    if (eligible.length == 1) return eligible.first.uid;

    final ordered =
        eligible.toList()..sort((first, second) {
          final firstAt =
              first.state == LiveDuelPresenceState.left
                  ? first.disconnectedAt
                  : first.graceUntil;
          final secondAt =
              second.state == LiveDuelPresenceState.left
                  ? second.disconnectedAt
                  : second.graceUntil;

          final timeCompare = (firstAt ??
                  DateTime.fromMillisecondsSinceEpoch(0))
              .compareTo(secondAt ?? DateTime.fromMillisecondsSinceEpoch(0));
          if (timeCompare != 0) return timeCompare;
          return first.uid.compareTo(second.uid);
        });

    return ordered.first.uid;
  }
}

class LiveDuelConnectionService {
  LiveDuelConnectionService._();

  static FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  static CollectionReference<Map<String, dynamic>> get _matches =>
      _firestore.collection('live_duel_matches');

  static User _requireUser() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw const LiveDuelConnectionException(
        'Canlı düello için Google hesabıyla giriş yapmalısın.',
      );
    }
    return user;
  }

  static DocumentReference<Map<String, dynamic>> _matchReference(
    String matchId,
  ) {
    if (matchId.trim().isEmpty) {
      throw const LiveDuelConnectionException('Maç kimliği boş olamaz.');
    }
    return _matches.doc(matchId);
  }

  static DocumentReference<Map<String, dynamic>> _presenceReference({
    required String matchId,
    required String uid,
  }) {
    return _matchReference(matchId).collection('presence').doc(uid);
  }

  static Future<void> markActive({required String matchId}) async {
    final user = _requireUser();

    await _presenceReference(
      matchId: matchId,
      uid: user.uid,
    ).set(<String, dynamic>{
      'uid': user.uid,
      'state': LiveDuelPresenceState.active.name,
      'connected': true,
      'leaveRequested': false,
      'disconnectedAt': null,
      'graceUntil': null,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  static Future<void> markBackground({required String matchId}) async {
    if (!LiveDuelConnectionPolicy.shouldMarkBackground(
      WidgetsBinding.instance.lifecycleState,
    )) {
      return;
    }

    final user = _requireUser();
    final now = DateTime.now().toUtc();

    await _presenceReference(
      matchId: matchId,
      uid: user.uid,
    ).set(<String, dynamic>{
      'uid': user.uid,
      'state': LiveDuelPresenceState.background.name,
      'connected': false,
      'leaveRequested': false,
      'disconnectedAt': FieldValue.serverTimestamp(),
      'graceUntil': Timestamp.fromDate(
        now.add(LiveDuelConnectionPolicy.reconnectGrace),
      ),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  static Future<void> requestLeave({required String matchId}) async {
    final user = _requireUser();
    final now = DateTime.now().toUtc();

    await _presenceReference(
      matchId: matchId,
      uid: user.uid,
    ).set(<String, dynamic>{
      'uid': user.uid,
      'state': LiveDuelPresenceState.left.name,
      'connected': false,
      'leaveRequested': true,
      'disconnectedAt': FieldValue.serverTimestamp(),
      'graceUntil': Timestamp.fromDate(now),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  static Stream<List<LiveDuelPresence>> watchPresence(String matchId) {
    _requireUser();

    return _matchReference(matchId)
        .collection('presence')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(LiveDuelPresence.fromSnapshot)
              .toList(growable: false),
        );
  }

  static Future<LiveDuelResumeMatch?> findResumableMatch() async {
    final user = _requireUser();

    final snapshot = await _matches
        .where('playerUids', arrayContains: user.uid)
        .limit(20)
        .get(const GetOptions(source: Source.server));

    final candidates = <LiveDuelResumeMatch>[];

    for (final document in snapshot.docs) {
      final data = document.data();
      if (data['resultProcessed'] == true || data['status'] == 'completed') {
        continue;
      }

      if (!LiveDuelQuestionSetService.supportsQuestionSetVersion(
        data['questionSetVersion'],
      )) {
        continue;
      }

      final questionCount = (data['questionCount'] as num?)?.toInt() ?? 0;
      if (!LiveDuelMatchmakingPolicy.supportsQuestionCount(questionCount)) {
        continue;
      }

      final createdAt = data['createdAt'];
      candidates.add(
        LiveDuelResumeMatch(
          matchId: document.id,
          questionCount: questionCount,
          createdAt: createdAt is Timestamp ? createdAt.toDate() : null,
        ),
      );
    }

    candidates.sort((first, second) {
      final firstAt = first.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final secondAt =
          second.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return secondAt.compareTo(firstAt);
    });

    return candidates.isEmpty ? null : candidates.first;
  }

  static Future<LiveDuelCompletedMatch?> resolveForfeit({
    required String matchId,
  }) async {
    _requireUser();
    final matchReference = _matchReference(matchId);
    final complete = await LiveDuelServerGateway.resolveForfeit(matchId);
    if (!complete) return null;
    final matchSnapshot = await matchReference.get();
    if (!matchSnapshot.exists) {
      throw const LiveDuelConnectionException('Canlı düello maçı bulunamadı.');
    }
    return LiveDuelCompletedMatch.fromMap(
      matchId: matchId,
      data: matchSnapshot.data() ?? <String, dynamic>{},
    );
  }
}
