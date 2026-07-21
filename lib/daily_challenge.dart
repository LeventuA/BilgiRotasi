part of 'main.dart';

class DailyChallengeResult {
  const DailyChallengeResult({
    required this.dateKey,
    required this.correct,
    required this.questionCount,
    required this.elapsedSeconds,
    required this.maxAnswerStreak,
    required this.completedAt,
  });

  final String dateKey;
  final int correct;
  final int questionCount;
  final int elapsedSeconds;
  final int maxAnswerStreak;
  final DateTime completedAt;

  int get wrong => questionCount - correct;

  int get accuracy {
    if (questionCount == 0) return 0;
    return (correct / questionCount * 100).round();
  }

  bool get isPerfect =>
      questionCount > 0 && correct == questionCount;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'dateKey': dateKey,
      'correct': correct,
      'questionCount': questionCount,
      'elapsedSeconds': elapsedSeconds,
      'maxAnswerStreak': maxAnswerStreak,
      'completedAt': completedAt.toIso8601String(),
    };
  }

  factory DailyChallengeResult.fromJson(
    Map<String, dynamic> json,
  ) {
    return DailyChallengeResult(
      dateKey: json['dateKey']?.toString() ?? '',
      correct: (json['correct'] as num?)?.toInt() ?? 0,
      questionCount:
          (json['questionCount'] as num?)?.toInt() ?? 10,
      elapsedSeconds:
          (json['elapsedSeconds'] as num?)?.toInt() ?? 0,
      maxAnswerStreak:
          (json['maxAnswerStreak'] as num?)?.toInt() ?? 0,
      completedAt: DateTime.tryParse(
            json['completedAt']?.toString() ?? '',
          ) ??
          DateTime.now(),
    );
  }
}

class DailyChallengeSummary {
  const DailyChallengeSummary({
    required this.todayResult,
    required this.history,
    required this.currentStreak,
    required this.bestStreak,
    required this.completedDays,
    required this.perfectDays,
  });

  final DailyChallengeResult? todayResult;
  final List<DailyChallengeResult> history;
  final int currentStreak;
  final int bestStreak;
  final int completedDays;
  final int perfectDays;
}

class DailyChallengeService {
  DailyChallengeService._();

  static const String _key =
      'bilgi_rotasi_daily_challenge_v1';
  static final SharedPreferencesAsync _preferences =
      SharedPreferencesAsync();

  static String dateKey([DateTime? value]) {
    final date = (value ?? DateTime.now()).toLocal();
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');

    return '$year-$month-$day';
  }

  static DateTime dateFromKey(String value) {
    final parts = value.split('-');

    if (parts.length != 3) {
      return DateTime(2000);
    }

    return DateTime(
      int.tryParse(parts[0]) ?? 2000,
      int.tryParse(parts[1]) ?? 1,
      int.tryParse(parts[2]) ?? 1,
    );
  }

  static String longDateLabel([DateTime? value]) {
    const weekdays = [
      'Pazartesi',
      'Salı',
      'Çarşamba',
      'Perşembe',
      'Cuma',
      'Cumartesi',
      'Pazar',
    ];
    const months = [
      'Ocak',
      'Şubat',
      'Mart',
      'Nisan',
      'Mayıs',
      'Haziran',
      'Temmuz',
      'Ağustos',
      'Eylül',
      'Ekim',
      'Kasım',
      'Aralık',
    ];

    final date = (value ?? DateTime.now()).toLocal();

    return '${date.day} ${months[date.month - 1]} '
        '${weekdays[date.weekday - 1]}';
  }

  static Future<List<DailyChallengeResult>>
      _loadResults() async {
    try {
      final raw = await _preferences.getString(_key);

      if (raw == null || raw.trim().isEmpty) {
        return <DailyChallengeResult>[];
      }

      final decoded = jsonDecode(raw);

      if (decoded is! List) {
        return <DailyChallengeResult>[];
      }

      final results = <DailyChallengeResult>[];

      for (final item in decoded) {
        if (item is Map<String, dynamic>) {
          results.add(
            DailyChallengeResult.fromJson(item),
          );
        } else if (item is Map) {
          results.add(
            DailyChallengeResult.fromJson(
              Map<String, dynamic>.from(item),
            ),
          );
        }
      }

      results.removeWhere(
        (result) => result.dateKey.isEmpty,
      );
      results.sort(
        (a, b) => b.dateKey.compareTo(a.dateKey),
      );

      return results;
    } catch (_) {
      return <DailyChallengeResult>[];
    }
  }

  static Future<void> _saveResults(
    List<DailyChallengeResult> results,
  ) async {
    try {
      final sorted =
          List<DailyChallengeResult>.from(results)
            ..sort(
              (a, b) => b.dateKey.compareTo(a.dateKey),
            );

      final limited = sorted.take(120).toList();

      await _preferences.setString(
        _key,
        jsonEncode(
          limited
              .map((result) => result.toJson())
              .toList(),
        ),
      );
    } catch (_) {
      // Günlük görev kaydı oyunu durdurmamalı.
    }
  }

  static Future<DailyChallengeSummary>
      loadSummary() async {
    final results = await _loadResults();
    final todayKey = dateKey();

    DailyChallengeResult? todayResult;

    for (final result in results) {
      if (result.dateKey == todayKey) {
        todayResult = result;
        break;
      }
    }

    final uniqueDates = results
        .map((result) => result.dateKey)
        .toSet()
        .map(dateFromKey)
        .toList()
      ..sort();

    var bestStreak = 0;
    var runningStreak = 0;
    DateTime? previous;

    for (final date in uniqueDates) {
      if (previous != null &&
          date.difference(previous).inDays == 1) {
        runningStreak++;
      } else {
        runningStreak = 1;
      }

      bestStreak = max(bestStreak, runningStreak);
      previous = date;
    }

    var currentStreak = 0;

    if (uniqueDates.isNotEmpty) {
      final today = dateFromKey(todayKey);
      final latest = uniqueDates.last;
      final distance = today.difference(latest).inDays;

      if (distance == 0 || distance == 1) {
        currentStreak = 1;
        var cursor = latest;

        for (var index = uniqueDates.length - 2;
            index >= 0;
            index--) {
          final candidate = uniqueDates[index];

          if (cursor.difference(candidate).inDays != 1) {
            break;
          }

          currentStreak++;
          cursor = candidate;
        }
      }
    }

    return DailyChallengeSummary(
      todayResult: todayResult,
      history: List<DailyChallengeResult>.unmodifiable(
        results,
      ),
      currentStreak: currentStreak,
      bestStreak: bestStreak,
      completedDays: results.length,
      perfectDays:
          results.where((result) => result.isPerfect).length,
    );
  }

  static Future<bool> saveOfficialResult(
    DailyChallengeResult result,
  ) async {
    final results = await _loadResults();

    if (results.any(
      (item) => item.dateKey == result.dateKey,
    )) {
      return false;
    }

    results.add(result);
    await _saveResults(results);
    return true;
  }

  static Future<void> clear() async {
    try {
      await _preferences.remove(_key);
    } catch (_) {
      // Sıfırlama sorunu ekranı kilitlememeli.
    }
  }

  static List<QuizQuestion> questionsForDate(
    QuestionBank questionBank,
    DateTime date,
  ) {
    final key = dateKey(date);
    final seed = _stableSeed(key);
    final random = Random(seed);

    final allCategories = List<int>.generate(
      GameCategory.values.length,
      (index) => index,
    )..shuffle(random);

    final extras = List<int>.generate(
      GameCategory.values.length,
      (index) => index,
    )..shuffle(Random(seed ^ 0x45D9F3B));

    final categoryPlan = <int>[
      ...allCategories,
      ...extras.take(4),
    ]..shuffle(Random(seed ^ 0x27D4EB2D));

    final selected = <QuizQuestion>[];
    final usedIds = <String>{};

    for (final categoryIndex in categoryPlan) {
      final pool = List<QuizQuestion>.from(
        questionBank.questionsByCategory[categoryIndex] ??
            const <QuizQuestion>[],
      )..sort(
          (a, b) => a.id.compareTo(b.id),
        );

      final available = pool
          .where(
            (question) => !usedIds.contains(question.id),
          )
          .toList();

      if (available.isEmpty) continue;

      final question =
          available[random.nextInt(available.length)];

      usedIds.add(question.id);
      selected.add(question);
    }

    return List<QuizQuestion>.unmodifiable(selected);
  }

  static int _stableSeed(String value) {
    var hash = 0x811C9DC5;

    for (final codeUnit in value.codeUnits) {
      hash ^= codeUnit;
      hash = (hash * 0x01000193) & 0x7FFFFFFF;
    }

    return hash;
  }
}

class DailyChallengeHomeCard extends StatefulWidget {
  const DailyChallengeHomeCard({
    required this.questionBank,
    super.key,
  });

  final QuestionBank questionBank;

  @override
  State<DailyChallengeHomeCard> createState() =>
      _DailyChallengeHomeCardState();
}

class _DailyChallengeHomeCardState
    extends State<DailyChallengeHomeCard> {
  late Future<DailyChallengeSummary> _summaryFuture;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    _summaryFuture = DailyChallengeService.loadSummary();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DailyChallengeSummary>(
      future: _summaryFuture,
      builder: (context, snapshot) {
        final summary = snapshot.data;
        final completed = summary?.todayResult != null;

        return Container(
          padding: const EdgeInsets.all(19),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: completed
                  ? const [
                      Color(0xFF365314),
                      Color(0xFF0F766E),
                    ]
                  : const [
                      Color(0xFF7C2D12),
                      Color(0xFF6D28D9),
                    ],
            ),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(
              color: const Color(0x99FFE082),
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x44000000),
                blurRadius: 16,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Text(
                    completed ? '✅' : '📅',
                    style: const TextStyle(fontSize: 40),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'GÜNLÜK GÖREV',
                          style: TextStyle(
                            color: Color(0xFFFFE082),
                            fontSize: 11,
                            letterSpacing: 1,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          completed
                              ? 'Bugünün görevi tamamlandı'
                              : 'Bugünün 10 sorusu hazır',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            height: 1.05,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          completed
                              ? '${summary!.todayResult!.correct}/10 doğru • '
                                  '${summary.currentStreak} günlük seri'
                              : '${DailyChallengeService.longDateLabel()} • '
                                  'İlk sonuç resmî skor',
                          style: const TextStyle(
                            color: Color(0xFFE6DEF0),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              FilledButton.icon(
                onPressed: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => DailyChallengeHubScreen(
                        questionBank: widget.questionBank,
                      ),
                    ),
                  );

                  if (!mounted) return;
                  setState(_reload);
                },
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFFFE082),
                  foregroundColor: const Color(0xFF3A2448),
                ),
                icon: Icon(
                  completed
                      ? Icons.bar_chart_rounded
                      : Icons.play_arrow_rounded,
                ),
                label: Text(
                  completed
                      ? 'Bugünkü Sonucu Gör'
                      : 'Günlük Göreve Başla',
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class DailyChallengeHubScreen extends StatefulWidget {
  const DailyChallengeHubScreen({
    required this.questionBank,
    super.key,
  });

  final QuestionBank questionBank;

  @override
  State<DailyChallengeHubScreen> createState() =>
      _DailyChallengeHubScreenState();
}

class _DailyChallengeHubScreenState
    extends State<DailyChallengeHubScreen> {
  late Future<DailyChallengeSummary> _summaryFuture;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    _summaryFuture = DailyChallengeService.loadSummary();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Günlük Görev'),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF8FAFC),
              Color(0xFFEDE9FE),
            ],
          ),
        ),
        child: SafeArea(
          child: FutureBuilder<DailyChallengeSummary>(
            future: _summaryFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState !=
                  ConnectionState.done) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              final summary = snapshot.data ??
                  const DailyChallengeSummary(
                    todayResult: null,
                    history: <DailyChallengeResult>[],
                    currentStreak: 0,
                    bestStreak: 0,
                    completedDays: 0,
                    perfectDays: 0,
                  );

              return ListView(
                padding:
                    const EdgeInsets.fromLTRB(18, 14, 18, 28),
                children: [
                  _buildTodayCard(summary),
                  const SizedBox(height: 16),
                  _buildStreakCard(summary),
                  const SizedBox(height: 16),
                  _buildHistoryCard(summary),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTodayCard(
    DailyChallengeSummary summary,
  ) {
    final result = summary.todayResult;
    final completed = result != null;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: completed
              ? const [
                  Color(0xFF166534),
                  Color(0xFF0F766E),
                ]
              : const [
                  Color(0xFF4C1D95),
                  Color(0xFF155E75),
                ],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Color(0x44000000),
            blurRadius: 18,
            offset: Offset(0, 9),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            completed ? '🏆' : '📅',
            style: const TextStyle(fontSize: 52),
          ),
          const SizedBox(height: 8),
          Text(
            DailyChallengeService.longDateLabel(),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFFFFE082),
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            completed
                ? '${result.correct} / ${result.questionCount}'
                : '10 karışık soru',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 31,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            completed
                ? '%${result.accuracy} başarı • '
                    '${_durationText(result.elapsedSeconds)}'
                : 'Her gün aynı tarihe özel yeni bir görev. '
                    'İlk tamamlanan tur resmî skor sayılır.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFFE4DCEB),
              height: 1.35,
            ),
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: () => _openChallenge(
              practice: completed,
            ),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFFFE082),
              foregroundColor: const Color(0xFF3A2448),
            ),
            icon: Icon(
              completed
                  ? Icons.replay_rounded
                  : Icons.play_arrow_rounded,
            ),
            label: Text(
              completed
                  ? 'Tekrar Çöz • Alıştırma'
                  : 'Resmî Turu Başlat',
              style: const TextStyle(
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStreakCard(
    DailyChallengeSummary summary,
  ) {
    return Row(
      children: [
        Expanded(
          child: _miniStat(
            emoji: '🔥',
            value: '${summary.currentStreak}',
            label: 'Günlük seri',
          ),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: _miniStat(
            emoji: '🏅',
            value: '${summary.bestStreak}',
            label: 'En iyi seri',
          ),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: _miniStat(
            emoji: '💯',
            value: '${summary.perfectDays}',
            label: 'Tam puan',
          ),
        ),
      ],
    );
  }

  Widget _miniStat({
    required String emoji,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 5,
        vertical: 13,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFD8DEE9),
        ),
      ),
      child: Column(
        children: [
          Text(
            emoji,
            style: const TextStyle(fontSize: 24),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(
    DailyChallengeSummary summary,
  ) {
    final history = summary.history.take(7).toList();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFD8DEE9),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Son 7 görev',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          if (history.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Center(
                child: Text(
                  'Henüz tamamlanan günlük görev yok.',
                  style: TextStyle(
                    color: Color(0xFF64748B),
                  ),
                ),
              ),
            )
          else
            for (final result in history)
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: result.isPerfect
                      ? const Color(0xFFFFF7D6)
                      : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: result.isPerfect
                        ? const Color(0xFFEAB308)
                        : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      result.isPerfect ? '👑' : '📘',
                      style: const TextStyle(fontSize: 23),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _shortDate(result.dateKey),
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Text(
                      '${result.correct}/${result.questionCount} • '
                      '%${result.accuracy}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
        ],
      ),
    );
  }

  Future<void> _openChallenge({
    required bool practice,
  }) async {
    final date = DateTime.now();
    final questions =
        DailyChallengeService.questionsForDate(
      widget.questionBank,
      date,
    );

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DailyChallengeScreen(
          questionBank: widget.questionBank,
          questions: questions,
          challengeDateKey:
              DailyChallengeService.dateKey(date),
          isOfficial: !practice,
        ),
      ),
    );

    if (!mounted) return;
    setState(_reload);
  }

  String _shortDate(String key) {
    final date = DailyChallengeService.dateFromKey(key);
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');

    return '$day.$month.${date.year}';
  }

  String _durationText(int secondsValue) {
    final minutes = secondsValue ~/ 60;
    final seconds = secondsValue % 60;

    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}

class DailyAnswerRecord {
  const DailyAnswerRecord({
    required this.categoryIndex,
    required this.correct,
  });

  final int categoryIndex;
  final bool correct;
}

class DailyChallengeScreen extends StatefulWidget {
  const DailyChallengeScreen({
    required this.questionBank,
    required this.questions,
    required this.challengeDateKey,
    required this.isOfficial,
    super.key,
  });

  final QuestionBank questionBank;
  final List<QuizQuestion> questions;
  final String challengeDateKey;
  final bool isOfficial;

  @override
  State<DailyChallengeScreen> createState() =>
      _DailyChallengeScreenState();
}

class _DailyChallengeScreenState
    extends State<DailyChallengeScreen> {
  final Stopwatch _stopwatch = Stopwatch();
  final List<DailyAnswerRecord> _answers =
      <DailyAnswerRecord>[];

  int _questionIndex = 0;
  int _correct = 0;
  int _wrong = 0;
  int _answerStreak = 0;
  int _maxAnswerStreak = 0;
  bool _busy = false;
  bool _exitDialogOpen = false;

  QuizQuestion get _question =>
      widget.questions[_questionIndex];

  @override
  void initState() {
    super.initState();
    _stopwatch.start();
  }

  @override
  Widget build(BuildContext context) {
    final progress = widget.questions.isEmpty
        ? 0.0
        : _questionIndex / widget.questions.length;
    final category =
        GameCategory.values[_question.categoryIndex];

    return PopScope<Object?>(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          unawaited(_confirmExit());
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.isOfficial
                ? 'Günlük Görev'
                : 'Günlük Görev • Alıştırma',
          ),
          leading: IconButton(
            onPressed: _confirmExit,
            icon: const Icon(Icons.close_rounded),
          ),
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF1E1029),
                Color(0xFF123B4A),
              ],
            ),
          ),
          child: SafeArea(
            child: ListView(
              padding:
                  const EdgeInsets.fromLTRB(18, 16, 18, 26),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _scoreCard(
                        '✅',
                        '$_correct',
                        'Doğru',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _scoreCard(
                        '🔥',
                        '$_answerStreak',
                        'Seri',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _scoreCard(
                        '❌',
                        '$_wrong',
                        'Yanlış',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 10,
                    backgroundColor:
                        const Color(0x33FFFFFF),
                    color: const Color(0xFFFFE082),
                  ),
                ),
                const SizedBox(height: 9),
                Text(
                  'Soru ${_questionIndex + 1} / '
                  '${widget.questions.length}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFFD8CCEA),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 22),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x55000000),
                        blurRadius: 20,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        category.emoji,
                        style: const TextStyle(fontSize: 55),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        category.label,
                        style: TextStyle(
                          color: category.darkColor,
                          fontSize: 21,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 7),
                      Text(
                        widget.isOfficial
                            ? 'İlk sonuç resmî skoruna yazılır'
                            : 'Bu tur istatistiklere yazılmaz',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 22),
                      FilledButton.icon(
                        onPressed:
                            _busy ? null : _openQuestion,
                        style: FilledButton.styleFrom(
                          backgroundColor: category.color,
                        ),
                        icon: const Icon(Icons.quiz_rounded),
                        label: Text(
                          _busy ? 'Bekle…' : 'Soruyu Aç',
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _scoreCard(
    String emoji,
    String value,
    String label,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 5,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: const Color(0x16FFFFFF),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: const Color(0x33FFFFFF),
        ),
      ),
      child: Column(
        children: [
          Text(
            emoji,
            style: const TextStyle(fontSize: 22),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFFCBC1D6),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openQuestion() async {
    if (_busy || widget.questions.isEmpty) return;

    setState(() => _busy = true);

    final correct = await Navigator.of(context).push<bool>(
          MaterialPageRoute(
            fullscreenDialog: true,
            builder: (_) => QuestionScreen(
              question: _question,
            ),
          ),
        ) ??
        false;

    if (!mounted) return;

    _answers.add(
      DailyAnswerRecord(
        categoryIndex: _question.categoryIndex,
        correct: correct,
      ),
    );

    if (correct) {
      _correct++;
      _answerStreak++;
      _maxAnswerStreak = max(
        _maxAnswerStreak,
        _answerStreak,
      );
      unawaited(SoundFx.correct());
    } else {
      _wrong++;
      _answerStreak = 0;
      unawaited(SoundFx.wrong());
    }

    final finished =
        _questionIndex + 1 >= widget.questions.length;

    if (finished) {
      await _finishChallenge();
      return;
    }

    setState(() {
      _questionIndex++;
      _busy = false;
    });
  }

  Future<void> _finishChallenge() async {
    _stopwatch.stop();

    final result = DailyChallengeResult(
      dateKey: widget.challengeDateKey,
      correct: _correct,
      questionCount: widget.questions.length,
      elapsedSeconds: _stopwatch.elapsed.inSeconds,
      maxAnswerStreak: _maxAnswerStreak,
      completedAt: DateTime.now(),
    );

    var officialSaved = false;

    if (widget.isOfficial) {
      officialSaved =
          await DailyChallengeService.saveOfficialResult(
        result,
      );
    }

    if (officialSaved) {
      for (final answer in _answers) {
        await CareerStatsService.recordAnswer(
          categoryIndex: answer.categoryIndex,
          correct: answer.correct,
        );
      }
    }

    if (!mounted) return;

    if (result.isPerfect) {
      unawaited(SoundFx.win());
      HapticFeedback.heavyImpact();
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => DailyChallengeResultScreen(
          result: result,
          isOfficial: officialSaved,
        ),
      ),
    );
  }

  Future<void> _confirmExit() async {
    if (_exitDialogOpen || !mounted) return;

    _exitDialogOpen = true;

    final exit = await showDialog<bool>(
          context: context,
          builder: (dialogContext) {
            return AlertDialog(
              title: const Text(
                'Günlük görevden çıkılsın mı?',
              ),
              content: Text(
                widget.isOfficial
                    ? 'Tur tamamlanmadığı için bugünkü '
                        'resmî hakkın yanmaz; daha sonra '
                        'yeniden başlayabilirsin.'
                    : 'Alıştırma turunun mevcut ilerlemesi '
                        'kaydedilmeyecek.',
              ),
              actions: [
                TextButton(
                  onPressed: () =>
                      Navigator.pop(dialogContext, false),
                  child: const Text('Devam Et'),
                ),
                FilledButton(
                  onPressed: () =>
                      Navigator.pop(dialogContext, true),
                  child: const Text('Turdan Çık'),
                ),
              ],
            );
          },
        ) ??
        false;

    _exitDialogOpen = false;

    if (exit && mounted) {
      Navigator.of(context).pop();
    }
  }
}

class DailyChallengeResultScreen
    extends StatelessWidget {
  const DailyChallengeResultScreen({
    required this.result,
    required this.isOfficial,
    super.key,
  });

  final DailyChallengeResult result;
  final bool isOfficial;

  @override
  Widget build(BuildContext context) {
    return PopScope<Object?>(
      canPop: false,
      onPopInvokedWithResult: (didPop, value) {
        if (!didPop) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(0, -0.5),
              radius: 1.25,
              colors: [
                Color(0xFF5B2C70),
                Color(0xFF21132D),
                Color(0xFF0B3440),
              ],
            ),
          ),
          child: SafeArea(
            child: ListView(
              padding:
                  const EdgeInsets.fromLTRB(20, 26, 20, 28),
              children: [
                Text(
                  result.isPerfect
                      ? '👑 GÜNÜN BİLGESİ!'
                      : isOfficial
                          ? '📅 GÜNLÜK GÖREV TAMAM'
                          : '🧠 ALIŞTIRMA TAMAM',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFFFFE082),
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xE61D1027),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: const Color(0xFFFFD978),
                      width: 2,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        result.isPerfect ? '💯' : '⚡',
                        style: const TextStyle(fontSize: 60),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${result.correct} / '
                        '${result.questionCount}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 45,
                          height: 1,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 7),
                      Text(
                        '%${result.accuracy} başarı',
                        style: const TextStyle(
                          color: Color(0xFFD8CCEA),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: _resultStat(
                              '🔥',
                              '${result.maxAnswerStreak}',
                              'En iyi seri',
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _resultStat(
                              '⏱️',
                              _durationText(
                                result.elapsedSeconds,
                              ),
                              'Süre',
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _resultStat(
                              '❌',
                              '${result.wrong}',
                              'Yanlış',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        isOfficial
                            ? 'Bu sonuç bugünün resmî '
                                'skoru olarak kaydedildi.'
                            : 'Alıştırma sonucu resmî skoru '
                                've kariyer istatistiklerini '
                                'değiştirmedi.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFFFFE082),
                          fontSize: 12,
                          height: 1.35,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                FilledButton.icon(
                  onPressed: () =>
                      Navigator.of(context).pop(),
                  style: FilledButton.styleFrom(
                    backgroundColor:
                        const Color(0xFFFFE082),
                    foregroundColor:
                        const Color(0xFF3A2448),
                  ),
                  icon: const Icon(
                    Icons.calendar_month_rounded,
                  ),
                  label: const Text(
                    'Günlük Görev Ekranı',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context)
                        .popUntil((route) => route.isFirst);
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(
                      color: Color(0x99FFE082),
                    ),
                    minimumSize: const Size.fromHeight(54),
                  ),
                  icon: const Icon(Icons.home_rounded),
                  label: const Text(
                    'Ana Menü',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _resultStat(
    String emoji,
    String value,
    String label,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 4,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: const Color(0x16FFFFFF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0x33FFFFFF),
        ),
      ),
      child: Column(
        children: [
          Text(
            emoji,
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFFCBC1D6),
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }

  String _durationText(int secondsValue) {
    final minutes = secondsValue ~/ 60;
    final seconds = secondsValue % 60;

    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}

class DailyChallengeStatsCard extends StatelessWidget {
  const DailyChallengeStatsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DailyChallengeSummary>(
      future: DailyChallengeService.loadSummary(),
      builder: (context, snapshot) {
        final summary = snapshot.data;

        if (snapshot.connectionState !=
            ConnectionState.done) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(18),
              child: CircularProgressIndicator(),
            ),
          );
        }

        final safeSummary = summary ??
            const DailyChallengeSummary(
              todayResult: null,
              history: <DailyChallengeResult>[],
              currentStreak: 0,
              bestStreak: 0,
              completedDays: 0,
              perfectDays: 0,
            );

        return Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFF4C1D95),
                Color(0xFF155E75),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: const Color(0x55FFE082),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '📅 Günlük görev kariyeri',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 13),
              Row(
                children: [
                  Expanded(
                    child: _stat(
                      '${safeSummary.currentStreak}',
                      'Güncel seri',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _stat(
                      '${safeSummary.bestStreak}',
                      'En iyi seri',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _stat(
                      '${safeSummary.completedDays}',
                      'Tamamlandı',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 13),
              _achievement(
                emoji: '🔥',
                title: '3 Günlük Seri',
                description:
                    'Üç gün art arda günlük görevi tamamla.',
                unlocked: safeSummary.bestStreak >= 3,
              ),
              _achievement(
                emoji: '📆',
                title: '7 Günlük Seri',
                description:
                    'Yedi gün art arda günlük görevi tamamla.',
                unlocked: safeSummary.bestStreak >= 7,
              ),
              _achievement(
                emoji: '👑',
                title: 'Günün Bilgesi',
                description:
                    'Bir günlük görevde 10/10 yap.',
                unlocked: safeSummary.perfectDays >= 1,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _stat(String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 4,
        vertical: 11,
      ),
      decoration: BoxDecoration(
        color: const Color(0x16FFFFFF),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: const Color(0x33FFFFFF),
        ),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 21,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFFD8CCEA),
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }

  Widget _achievement({
    required String emoji,
    required String title,
    required String description,
    required bool unlocked,
  }) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: unlocked
            ? const Color(0x22FFE082)
            : const Color(0x0FFFFFFF),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: unlocked
              ? const Color(0x88FFE082)
              : const Color(0x22FFFFFF),
        ),
      ),
      child: Row(
        children: [
          Text(
            unlocked ? emoji : '🔒',
            style: const TextStyle(fontSize: 25),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: unlocked
                        ? const Color(0xFFFFE082)
                        : const Color(0xFFD0C6D7),
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  description,
                  style: const TextStyle(
                    color: Color(0xFFD8CCEA),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            unlocked
                ? Icons.check_circle_rounded
                : Icons.lock_outline_rounded,
            color: unlocked
                ? const Color(0xFF4ADE80)
                : const Color(0xFF8B7E94),
          ),
        ],
      ),
    );
  }
}
