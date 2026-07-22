part of 'main.dart';

const String _questionFeedbackEndpoint =
    'https://script.google.com/macros/s/AKfycbxIeKxzdekJ01LPWrIwD-jM-vwsXg0kMDXZkn-RXz8PRXWbc8CNHgiT0jb5odN1YYzH6w/exec';

class QuestionFeedbackPayload {
  const QuestionFeedbackPayload({
    required this.eventId,
    required this.questionId,
    required this.category,
    required this.systemDifficulty,
    required this.userDifficultyVote,
    required this.feedbackType,
    required this.errorReason,
    required this.userNote,
    required this.questionText,
    required this.options,
    required this.correctAnswer,
    required this.userAnswer,
    required this.wasCorrect,
    required this.gameMode,
    required this.playerName,
    required this.deviceId,
    required this.appVersion,
    required this.sentFromQueue,
  });

  final String eventId;
  final String questionId;
  final String category;
  final String systemDifficulty;
  final String userDifficultyVote;
  final String feedbackType;
  final String errorReason;
  final String userNote;
  final String questionText;
  final List<String> options;
  final String correctAnswer;
  final String userAnswer;
  final bool wasCorrect;
  final String gameMode;
  final String playerName;
  final String deviceId;
  final String appVersion;
  final bool sentFromQueue;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'eventId': eventId,
      'questionId': questionId,
      'category': category,
      'systemDifficulty': systemDifficulty,
      'userDifficultyVote': userDifficultyVote,
      'feedbackType': feedbackType,
      'errorReason': errorReason,
      'userNote': userNote,
      'questionText': questionText,
      'options': options,
      'correctAnswer': correctAnswer,
      'userAnswer': userAnswer,
      'wasCorrect': wasCorrect,
      'gameMode': gameMode,
      'playerName': playerName,
      'deviceId': deviceId,
      'appVersion': appVersion,
      'sentFromQueue': sentFromQueue,
    };
  }

  factory QuestionFeedbackPayload.fromJson(
    Map<String, dynamic> json,
  ) {
    return QuestionFeedbackPayload(
      eventId: json['eventId']?.toString() ?? '',
      questionId: json['questionId']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      systemDifficulty:
          json['systemDifficulty']?.toString() ?? '',
      userDifficultyVote:
          json['userDifficultyVote']?.toString() ?? '',
      feedbackType:
          json['feedbackType']?.toString() ?? '',
      errorReason: json['errorReason']?.toString() ?? '',
      userNote: json['userNote']?.toString() ?? '',
      questionText: json['questionText']?.toString() ?? '',
      options: (json['options'] as List?)
              ?.map((item) => item.toString())
              .toList() ??
          const <String>[],
      correctAnswer:
          json['correctAnswer']?.toString() ?? '',
      userAnswer: json['userAnswer']?.toString() ?? '',
      wasCorrect: json['wasCorrect'] == true,
      gameMode: json['gameMode']?.toString() ?? '',
      playerName: json['playerName']?.toString() ?? '',
      deviceId: json['deviceId']?.toString() ?? '',
      appVersion: json['appVersion']?.toString() ?? '',
      sentFromQueue: json['sentFromQueue'] == true,
    );
  }

  QuestionFeedbackPayload queuedCopy() {
    return QuestionFeedbackPayload(
      eventId: eventId,
      questionId: questionId,
      category: category,
      systemDifficulty: systemDifficulty,
      userDifficultyVote: userDifficultyVote,
      feedbackType: feedbackType,
      errorReason: errorReason,
      userNote: userNote,
      questionText: questionText,
      options: options,
      correctAnswer: correctAnswer,
      userAnswer: userAnswer,
      wasCorrect: wasCorrect,
      gameMode: gameMode,
      playerName: playerName,
      deviceId: deviceId,
      appVersion: appVersion,
      sentFromQueue: true,
    );
  }
}

class QuestionFeedbackService {
  QuestionFeedbackService._();

  static const String _queueKey =
      'bilgi_rotasi_question_feedback_queue_v1';
  static const String _difficultyVotesKey =
      'bilgi_rotasi_question_difficulty_votes_v1';
  static const String _errorReportsKey =
      'bilgi_rotasi_question_error_reports_v1';
  static const String _deviceIdKey =
      'bilgi_rotasi_feedback_device_id_v1';

  static final SharedPreferencesAsync _preferences =
      SharedPreferencesAsync();

  static Future<String> deviceId() async {
    final existing =
        await _preferences.getString(_deviceIdKey);

    if (existing != null && existing.isNotEmpty) {
      return existing;
    }

    final random = Random.secure();
    final value =
        'br-${DateTime.now().microsecondsSinceEpoch}-'
        '${random.nextInt(1 << 32)}';

    await _preferences.setString(_deviceIdKey, value);
    return value;
  }

  static Future<String?> difficultyVoteFor(
    String questionId,
  ) async {
    final map = await _loadStringMap(_difficultyVotesKey);
    return map[questionId];
  }

  static Future<bool> hasErrorReport(
    String questionId,
  ) async {
    final values = await _loadStringSet(_errorReportsKey);
    return values.contains(questionId);
  }

  static Future<bool> submitDifficultyVote({
    required QuizQuestion question,
    required int selectedIndex,
    required String vote,
    required String gameMode,
  }) async {
    final existing =
        await difficultyVoteFor(question.id);

    if (existing != null) return false;

    final votes =
        await _loadStringMap(_difficultyVotesKey);
    votes[question.id] = vote;
    await _saveStringMap(_difficultyVotesKey, votes);

    final payload = await _payload(
      question: question,
      selectedIndex: selectedIndex,
      userDifficultyVote: vote,
      feedbackType: 'Zorluk oyu',
      errorReason: '',
      userNote: '',
      gameMode: gameMode,
    );

    await _sendOrQueue(payload);
    return true;
  }

  static Future<bool> submitErrorReport({
    required QuizQuestion question,
    required int selectedIndex,
    required String reason,
    required String note,
    required String gameMode,
  }) async {
    final reported =
        await hasErrorReport(question.id);

    if (reported) return false;

    final reports =
        await _loadStringSet(_errorReportsKey);
    reports.add(question.id);
    await _saveStringSet(_errorReportsKey, reports);

    final payload = await _payload(
      question: question,
      selectedIndex: selectedIndex,
      userDifficultyVote: '',
      feedbackType: 'Soru hatalı',
      errorReason: reason,
      userNote: note,
      gameMode: gameMode,
    );

    await _sendOrQueue(payload);
    return true;
  }

  static Future<QuestionFeedbackPayload> _payload({
    required QuizQuestion question,
    required int selectedIndex,
    required String userDifficultyVote,
    required String feedbackType,
    required String errorReason,
    required String userNote,
    required String gameMode,
  }) async {
    final id = await deviceId();
    final now = DateTime.now();

    return QuestionFeedbackPayload(
      eventId:
          '${question.id}-${feedbackType.hashCode}-'
          '${now.microsecondsSinceEpoch}-$id',
      questionId: question.id,
      category:
          GameCategory.values[question.categoryIndex].label,
      systemDifficulty: question.difficulty,
      userDifficultyVote: userDifficultyVote,
      feedbackType: feedbackType,
      errorReason: errorReason,
      userNote: userNote.trim(),
      questionText: question.text,
      options: question.options,
      correctAnswer:
          question.options[question.answerIndex],
      userAnswer: selectedIndex >= 0 &&
              selectedIndex < question.options.length
          ? question.options[selectedIndex]
          : '',
      wasCorrect: selectedIndex == question.answerIndex,
      gameMode: gameMode,
      playerName: '',
      deviceId: id,
      appVersion: '1.22',
      sentFromQueue: false,
    );
  }

  static Future<void> flushPending() async {
    final queue = await _loadQueue();
    if (queue.isEmpty) return;

    final remaining = <QuestionFeedbackPayload>[];

    for (final item in queue) {
      final sent = await _send(item.queuedCopy());
      if (!sent) remaining.add(item);
    }

    await _saveQueue(remaining);
  }

  static Future<void> _sendOrQueue(
    QuestionFeedbackPayload payload,
  ) async {
    final sent = await _send(payload);
    if (sent) return;

    final queue = await _loadQueue();

    if (!queue.any(
      (item) => item.eventId == payload.eventId,
    )) {
      queue.add(payload);
    }

    await _saveQueue(queue);
  }

  static Future<bool> _send(
    QuestionFeedbackPayload payload,
  ) async {
    if (_questionFeedbackEndpoint.isEmpty ||
        !_questionFeedbackEndpoint.startsWith('https://')) {
      return false;
    }

    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 7);

    try {
      final request = await client.postUrl(
        Uri.parse(_questionFeedbackEndpoint),
      );

      request.headers.contentType =
          ContentType('text', 'plain', charset: 'utf-8');
      request.write(jsonEncode(payload.toJson()));

      final response = await request.close().timeout(
        const Duration(seconds: 10),
      );
      final body =
          await utf8.decoder.bind(response).join();

      if (response.statusCode < 200 ||
          response.statusCode >= 300) {
        return false;
      }

      final decoded = jsonDecode(body);

      return decoded is Map && decoded['ok'] == true;
    } catch (_) {
      return false;
    } finally {
      client.close(force: true);
    }
  }

  static Future<List<QuestionFeedbackPayload>>
      _loadQueue() async {
    try {
      final raw =
          await _preferences.getString(_queueKey);

      if (raw == null || raw.isEmpty) {
        return <QuestionFeedbackPayload>[];
      }

      final decoded = jsonDecode(raw);

      if (decoded is! List) {
        return <QuestionFeedbackPayload>[];
      }

      return decoded
          .whereType<Map>()
          .map(
            (item) => QuestionFeedbackPayload.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList();
    } catch (_) {
      return <QuestionFeedbackPayload>[];
    }
  }

  static Future<void> _saveQueue(
    List<QuestionFeedbackPayload> queue,
  ) async {
    await _preferences.setString(
      _queueKey,
      jsonEncode(
        queue.map((item) => item.toJson()).toList(),
      ),
    );
  }

  static Future<Map<String, String>> _loadStringMap(
    String key,
  ) async {
    try {
      final raw = await _preferences.getString(key);
      if (raw == null || raw.isEmpty) {
        return <String, String>{};
      }

      final decoded = jsonDecode(raw);
      if (decoded is! Map) {
        return <String, String>{};
      }

      return decoded.map(
        (key, value) =>
            MapEntry(key.toString(), value.toString()),
      );
    } catch (_) {
      return <String, String>{};
    }
  }

  static Future<void> _saveStringMap(
    String key,
    Map<String, String> value,
  ) async {
    await _preferences.setString(key, jsonEncode(value));
  }

  static Future<Set<String>> _loadStringSet(
    String key,
  ) async {
    try {
      final raw = await _preferences.getString(key);
      if (raw == null || raw.isEmpty) return <String>{};

      final decoded = jsonDecode(raw);
      if (decoded is! List) return <String>{};

      return decoded
          .map((item) => item.toString())
          .toSet();
    } catch (_) {
      return <String>{};
    }
  }

  static Future<void> _saveStringSet(
    String key,
    Set<String> value,
  ) async {
    await _preferences.setString(
      key,
      jsonEncode(value.toList()..sort()),
    );
  }
}
