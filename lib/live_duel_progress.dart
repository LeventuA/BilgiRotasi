part of 'main.dart';

class LiveDuelProgressException implements Exception {
  const LiveDuelProgressException(this.message);

  final String message;

  @override
  String toString() => message;
}

class LiveDuelPlayerProgress {
  const LiveDuelPlayerProgress({
    required this.uid,
    required this.currentQuestionIndex,
    required this.answeredCount,
    required this.correctCount,
    required this.wrongCount,
    required this.finished,
    this.lastAnswerCorrect,
    this.lastQuestionId,
    this.lastSelectedOptionIndex,
    this.updatedAt,
    this.finishedAt,
  });

  final String uid;
  final int currentQuestionIndex;
  final int answeredCount;
  final int correctCount;
  final int wrongCount;
  final bool finished;
  final bool? lastAnswerCorrect;
  final String? lastQuestionId;
  final int? lastSelectedOptionIndex;
  final DateTime? updatedAt;
  final DateTime? finishedAt;

  double progressRatio(int questionCount) {
    if (questionCount <= 0) return 0;

    return (answeredCount / questionCount).clamp(0, 1);
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'uid': uid,
    'currentQuestionIndex': currentQuestionIndex,
    'answeredCount': answeredCount,
    'correctCount': correctCount,
    'wrongCount': wrongCount,
    'finished': finished,
    'lastAnswerCorrect': lastAnswerCorrect,
    'lastQuestionId': lastQuestionId,
    'lastSelectedOptionIndex': lastSelectedOptionIndex,
  };

  factory LiveDuelPlayerProgress.initial(String uid) {
    return LiveDuelPlayerProgress(
      uid: uid,
      currentQuestionIndex: 0,
      answeredCount: 0,
      correctCount: 0,
      wrongCount: 0,
      finished: false,
    );
  }

  factory LiveDuelPlayerProgress.fromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data() ?? <String, dynamic>{};
    final updatedAt = data['updatedAt'];
    final finishedAt = data['finishedAt'];

    return LiveDuelPlayerProgress(
      uid: data['uid']?.toString() ?? snapshot.id,
      currentQuestionIndex: max(
        0,
        (data['currentQuestionIndex'] as num?)?.toInt() ?? 0,
      ),
      answeredCount: max(0, (data['answeredCount'] as num?)?.toInt() ?? 0),
      correctCount: max(0, (data['correctCount'] as num?)?.toInt() ?? 0),
      wrongCount: max(0, (data['wrongCount'] as num?)?.toInt() ?? 0),
      finished: data['finished'] == true,
      lastAnswerCorrect: data['lastAnswerCorrect'] as bool?,
      lastQuestionId: data['lastQuestionId']?.toString(),
      lastSelectedOptionIndex:
          (data['lastSelectedOptionIndex'] as num?)?.toInt(),
      updatedAt: updatedAt is Timestamp ? updatedAt.toDate() : null,
      finishedAt: finishedAt is Timestamp ? finishedAt.toDate() : null,
    );
  }
}

class LiveDuelProgressCalculator {
  LiveDuelProgressCalculator._();

  static LiveDuelPlayerProgress applyAnswer({
    required LiveDuelPlayerProgress current,
    required String questionId,
    required int selectedOptionIndex,
    required bool correct,
    required int questionCount,
  }) {
    if (selectedOptionIndex < 0) {
      throw const LiveDuelProgressException('Seçilen şık geçersiz.');
    }

    if (questionCount <= 0) {
      throw const LiveDuelProgressException(
        'Canlı düello soru sayısı geçersiz.',
      );
    }

    if (current.finished) {
      throw const LiveDuelProgressException(
        'Bitmiş maça yeni cevap gönderilemez.',
      );
    }

    if (current.answeredCount >= questionCount) {
      throw const LiveDuelProgressException('Tüm sorular zaten cevaplandı.');
    }

    final answeredCount = current.answeredCount + 1;
    final finished = answeredCount >= questionCount;

    return LiveDuelPlayerProgress(
      uid: current.uid,
      currentQuestionIndex: finished ? questionCount : answeredCount,
      answeredCount: answeredCount,
      correctCount: current.correctCount + (correct ? 1 : 0),
      wrongCount: current.wrongCount + (correct ? 0 : 1),
      finished: finished,
      lastAnswerCorrect: correct,
      lastQuestionId: questionId,
      lastSelectedOptionIndex: selectedOptionIndex,
    );
  }

  static int compare(
    LiveDuelPlayerProgress first,
    LiveDuelPlayerProgress second,
  ) {
    final correctCompare = first.correctCount.compareTo(second.correctCount);

    if (correctCompare != 0) return correctCompare;

    final answeredCompare = first.answeredCount.compareTo(second.answeredCount);

    if (answeredCompare != 0) return answeredCompare;

    return 0;
  }
}

class LiveDuelProgressService {
  LiveDuelProgressService._();

  static FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  static User _requireUser() {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw const LiveDuelProgressException(
        'Canlı düello için Google hesabıyla giriş yapmalısın.',
      );
    }

    return user;
  }

  static DocumentReference<Map<String, dynamic>> _matchReference(
    String matchId,
  ) {
    if (matchId.trim().isEmpty) {
      throw const LiveDuelProgressException('Maç kimliği boş olamaz.');
    }

    return _firestore.collection('live_duel_matches').doc(matchId);
  }

  static DocumentReference<Map<String, dynamic>> _progressReference({
    required String matchId,
    required String uid,
  }) {
    return _matchReference(matchId).collection('progress').doc(uid);
  }

  static Future<void> initializeProgress({required String matchId}) async {
    final user = _requireUser();
    final reference = _progressReference(matchId: matchId, uid: user.uid);

    await _firestore.runTransaction<void>((transaction) async {
      final snapshot = await transaction.get(reference);

      if (snapshot.exists) return;

      transaction.set(reference, <String, dynamic>{
        ...LiveDuelPlayerProgress.initial(user.uid).toJson(),
        'updatedAt': FieldValue.serverTimestamp(),
        'finishedAt': null,
      });
    });
  }

  static Future<LiveDuelPlayerProgress> submitAnswer({
    required String matchId,
    required String questionId,
    required int selectedOptionIndex,
    required bool correct,
  }) async {
    final user = _requireUser();
    final matchReference = _matchReference(matchId);
    final progressReference = _progressReference(
      matchId: matchId,
      uid: user.uid,
    );

    return _firestore.runTransaction<LiveDuelPlayerProgress>((
      transaction,
    ) async {
      final matchSnapshot = await transaction.get(matchReference);

      if (!matchSnapshot.exists) {
        throw const LiveDuelProgressException('Canlı düello maçı bulunamadı.');
      }

      final matchData = matchSnapshot.data() ?? <String, dynamic>{};

      final rawPlayerUids = matchData['playerUids'];
      final playerUids =
          rawPlayerUids is List
              ? rawPlayerUids.map((item) => item.toString()).toList()
              : const <String>[];

      if (!playerUids.contains(user.uid)) {
        throw const LiveDuelProgressException('Bu maçın oyuncusu değilsin.');
      }

      final questionCount = (matchData['questionCount'] as num?)?.toInt() ?? 0;

      final questionIds = LiveDuelQuestionSetService.questionIdsFromMatchData(
        matchData,
      );

      final progressSnapshot = await transaction.get(progressReference);

      final current =
          progressSnapshot.exists
              ? LiveDuelPlayerProgress.fromSnapshot(progressSnapshot)
              : LiveDuelPlayerProgress.initial(user.uid);

      if (current.answeredCount >= questionIds.length) {
        throw const LiveDuelProgressException('Tüm sorular zaten cevaplandı.');
      }

      final expectedQuestionId = questionIds[current.answeredCount];

      if (questionId != expectedQuestionId) {
        throw const LiveDuelProgressException(
          'Sorular doğru sırada cevaplanmalı.',
        );
      }

      final next = LiveDuelProgressCalculator.applyAnswer(
        current: current,
        questionId: questionId,
        selectedOptionIndex: selectedOptionIndex,
        correct: correct,
        questionCount: questionCount,
      );

      transaction.set(progressReference, <String, dynamic>{
        ...next.toJson(),
        'updatedAt': FieldValue.serverTimestamp(),
        'finishedAt': next.finished ? FieldValue.serverTimestamp() : null,
      });

      return next;
    });
  }

  static Stream<List<LiveDuelPlayerProgress>> watchMatchProgress(
    String matchId,
  ) {
    _requireUser();

    return _matchReference(matchId)
        .collection('progress')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(LiveDuelPlayerProgress.fromSnapshot)
              .toList(growable: false),
        );
  }

  static Stream<LiveDuelPlayerProgress?> watchOwnProgress(String matchId) {
    final user = _requireUser();

    return _progressReference(matchId: matchId, uid: user.uid).snapshots().map(
      (snapshot) =>
          snapshot.exists
              ? LiveDuelPlayerProgress.fromSnapshot(snapshot)
              : null,
    );
  }
}
