part of 'main.dart';

class QuickModeRecords {
  const QuickModeRecords({
    this.bestSurvival = 0,
    this.bestSpeed = 0,
    this.duelsPlayed = 0,
  });

  final int bestSurvival;
  final int bestSpeed;
  final int duelsPlayed;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'bestSurvival': bestSurvival,
        'bestSpeed': bestSpeed,
        'duelsPlayed': duelsPlayed,
      };

  factory QuickModeRecords.fromJson(Map<String, dynamic> json) {
    return QuickModeRecords(
      bestSurvival:
          max(0, (json['bestSurvival'] as num?)?.toInt() ?? 0),
      bestSpeed: max(0, (json['bestSpeed'] as num?)?.toInt() ?? 0),
      duelsPlayed:
          max(0, (json['duelsPlayed'] as num?)?.toInt() ?? 0),
    );
  }

  QuickModeRecords copyWith({
    int? bestSurvival,
    int? bestSpeed,
    int? duelsPlayed,
  }) {
    return QuickModeRecords(
      bestSurvival: bestSurvival ?? this.bestSurvival,
      bestSpeed: bestSpeed ?? this.bestSpeed,
      duelsPlayed: duelsPlayed ?? this.duelsPlayed,
    );
  }
}

class QuickModeRecordService {
  QuickModeRecordService._();

  static const String _key = 'bilgi_rotasi_quick_modes_v1';
  static final SharedPreferencesAsync _prefs = SharedPreferencesAsync();

  static Future<QuickModeRecords> load() async {
    try {
      final raw = await _prefs.getString(_key);
      if (raw == null || raw.isEmpty) return const QuickModeRecords();
      final decoded = jsonDecode(raw);
      if (decoded is Map) {
        return QuickModeRecords.fromJson(
          Map<String, dynamic>.from(decoded),
        );
      }
    } catch (_) {
      // Bozuk rekor kaydı modları engellememeli.
    }
    return const QuickModeRecords();
  }

  static Future<void> _save(QuickModeRecords records) async {
    try {
      await _prefs.setString(_key, jsonEncode(records.toJson()));
    } catch (_) {
      // Rekor kaydı oyunu durdurmamalı.
    }
  }

  static Future<void> saveSurvival(int score) async {
    final current = await load();
    if (score > current.bestSurvival) {
      await _save(current.copyWith(bestSurvival: score));
    }
  }

  static Future<void> saveSpeed(int score) async {
    final current = await load();
    if (score > current.bestSpeed) {
      await _save(current.copyWith(bestSpeed: score));
    }
  }

  static Future<void> saveDuel() async {
    final current = await load();
    await _save(current.copyWith(duelsPlayed: current.duelsPlayed + 1));
  }
}

class QuickModesHomeButton extends StatelessWidget {
  const QuickModesHomeButton({
    required this.questionBank,
    super.key,
  });

  final QuestionBank questionBank;

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => QuickModesHubScreen(
              questionBank: questionBank,
            ),
          ),
        );
      },
      style: FilledButton.styleFrom(
        backgroundColor: const Color(0xFF7C3AED),
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(54),
      ),
      icon: const Icon(Icons.sports_esports_rounded),
      label: const Text(
        'Yeni Modlar • Hayatta Kal, 60 Saniye, Düello',
        textAlign: TextAlign.center,
        style: TextStyle(fontWeight: FontWeight.w900),
      ),
    );
  }
}

class QuickModesHubScreen extends StatefulWidget {
  const QuickModesHubScreen({
    required this.questionBank,
    super.key,
  });

  final QuestionBank questionBank;

  @override
  State<QuickModesHubScreen> createState() => _QuickModesHubScreenState();
}

class _QuickModesHubScreenState extends State<QuickModesHubScreen> {
  late Future<QuickModeRecords> _records;

  @override
  void initState() {
    super.initState();
    _records = QuickModeRecordService.load();
  }

  Future<void> _open(Widget screen) async {
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
    if (!mounted) return;
    setState(() => _records = QuickModeRecordService.load());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Yeni Oyun Modları')),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1D1027),
              Color(0xFF3B1F4D),
              Color(0xFF0F5661),
            ],
          ),
        ),
        child: SafeArea(
          child: FutureBuilder<QuickModeRecords>(
            future: _records,
            builder: (context, snapshot) {
              final records = snapshot.data ?? const QuickModeRecords();
              return ListView(
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 28),
                children: [
                  _hero(),
                  const SizedBox(height: 16),
                  _modeCard(
                    emoji: '❤️',
                    title: 'Hayatta Kalma',
                    description: '3 canla başla. Yanlış cevap can götürür, sorular giderek zorlaşır.',
                    record: records.bestSurvival == 0
                        ? 'Henüz rekor yok'
                        : 'Rekor: ${records.bestSurvival} doğru',
                    colors: const [Color(0xFFB91C1C), Color(0xFF7F1D1D)],
                    onTap: () => _open(
                      SurvivalModeScreen(questionBank: widget.questionBank),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _modeCard(
                    emoji: '⏱️',
                    title: '60 Saniye',
                    description: 'Bir dakika içinde olabildiğince çok doğru cevap ver.',
                    record: records.bestSpeed == 0
                        ? 'Henüz rekor yok'
                        : 'Rekor: ${records.bestSpeed} doğru',
                    colors: const [Color(0xFFEA580C), Color(0xFF7C2D12)],
                    onTap: () => _open(
                      SpeedModeScreen(questionBank: widget.questionBank),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _modeCard(
                    emoji: '⚔️',
                    title: 'Kategori Düellosu',
                    description: 'İki oyuncu kategorisini seçer; beşer soruluk karşılaşma oynar.',
                    record: records.duelsPlayed == 0
                        ? 'Henüz düello yok'
                        : '${records.duelsPlayed} düello oynandı',
                    colors: const [Color(0xFF4338CA), Color(0xFF312E81)],
                    onTap: () => _open(
                      CategoryDuelSetupScreen(questionBank: widget.questionBank),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: const Color(0x16FFFFFF),
                      borderRadius: BorderRadius.circular(19),
                      border: Border.all(color: const Color(0x33FFFFFF)),
                    ),
                    child: const Text(
                      'Bu modlardaki cevaplar genel XP ve istatistiklerine eklenir.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFFD8CCEA),
                        height: 1.4,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _hero() {
    return Container(
      padding: const EdgeInsets.all(21),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6D28D9), Color(0xFF0F766E)],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0x99FFE082)),
      ),
      child: const Column(
        children: [
          Text('❤️⚡⚔️', style: TextStyle(fontSize: 48)),
          SizedBox(height: 8),
          Text(
            'Üç farklı mücadele',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 7),
          Text(
            'Canlarını koru, zamana karşı yarış ve rakibine meydan oku.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFFE7E1F0), height: 1.35),
          ),
        ],
      ),
    );
  }

  Widget _modeCard({
    required String emoji,
    required String title,
    required String description,
    required String record,
    required List<Color> colors,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(25),
        child: Ink(
          padding: const EdgeInsets.all(19),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: colors),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: const Color(0x66FFFFFF)),
          ),
          child: Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 46)),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 21,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: const TextStyle(
                        color: Color(0xFFEDE9FE),
                        height: 1.3,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      record,
                      style: const TextStyle(
                        color: Color(0xFFFFE082),
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}

class QuickModeResultScreen extends StatelessWidget {
  const QuickModeResultScreen({
    required this.title,
    required this.emoji,
    required this.score,
    required this.detail,
    required this.bonusXp,
    required this.replayBuilder,
    super.key,
  });

  final String title;
  final String emoji;
  final String score;
  final String detail;
  final int bonusXp;
  final WidgetBuilder replayBuilder;

  @override
  Widget build(BuildContext context) {
    return PopScope<Object?>(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) Navigator.of(context).popUntil((route) => route.isFirst);
      },
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(0, -0.45),
              radius: 1.25,
              colors: [Color(0xFF5B2C70), Color(0xFF21132D), Color(0xFF0B3440)],
            ),
          ),
          child: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 28),
              children: [
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFFFFE082),
                    fontSize: 25,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    color: const Color(0xE61D1027),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: const Color(0xFFFFD978), width: 2),
                  ),
                  child: Column(
                    children: [
                      Text(emoji, style: const TextStyle(fontSize: 68)),
                      const SizedBox(height: 8),
                      Text(
                        score,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 38,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        detail,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFFD8CCEA),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '🏆 Tamamlama bonusu: +$bonusXp XP',
                        style: const TextStyle(
                          color: Color(0xFFFFE082),
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                FilledButton.icon(
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: replayBuilder),
                    );
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFFFE082),
                    foregroundColor: const Color(0xFF3A2448),
                  ),
                  icon: const Icon(Icons.replay_rounded),
                  label: const Text('Tekrar Oyna', style: TextStyle(fontWeight: FontWeight.w900)),
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Color(0x99FFE082)),
                    minimumSize: const Size.fromHeight(54),
                  ),
                  icon: const Icon(Icons.home_rounded),
                  label: const Text('Ana Menü', style: TextStyle(fontWeight: FontWeight.w800)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SurvivalModeScreen extends StatefulWidget {
  const SurvivalModeScreen({required this.questionBank, super.key});

  final QuestionBank questionBank;

  @override
  State<SurvivalModeScreen> createState() => _SurvivalModeScreenState();
}

class _SurvivalModeScreenState extends State<SurvivalModeScreen> {
  final Random _random = Random();
  final Set<String> _used = <String>{};
  final JokerWallet _jokers = JokerWallet.starter();

  int _lives = 3;
  int _correct = 0;
  int _wrong = 0;
  int _streak = 0;
  int _bestStreak = 0;
  bool _busy = false;
  bool _finished = false;

  String get _difficulty {
    if (_correct < 5) return 'Kolay';
    if (_correct < 12) return 'Orta';
    return 'Zor';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hayatta Kalma')),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF2C0B14), Color(0xFF4A1724), Color(0xFF123B4A)],
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 28),
            children: [
              Row(
                children: [
                  Expanded(child: _scoreCard('❤️', '$_lives', 'Can')),
                  const SizedBox(width: 8),
                  Expanded(child: _scoreCard('✅', '$_correct', 'Doğru')),
                  const SizedBox(width: 8),
                  Expanded(child: _scoreCard('🔥', '$_streak', 'Seri')),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(23),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Column(
                  children: [
                    const Text('❤️', style: TextStyle(fontSize: 64)),
                    const SizedBox(height: 8),
                    const Text(
                      'Üç canını koru',
                      style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      'Sıradaki soru: $_difficulty\nYanlış cevap bir can götürür.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Color(0xFF64748B), height: 1.4),
                    ),
                    const SizedBox(height: 14),
                    JokerWalletMiniBar(wallet: _jokers),
                    const SizedBox(height: 18),
                    FilledButton.icon(
                      onPressed: _busy ? null : _openQuestion,
                      style: FilledButton.styleFrom(backgroundColor: const Color(0xFFB91C1C)),
                      icon: const Icon(Icons.favorite_rounded),
                      label: Text(
                        _busy ? 'Hazırlanıyor…' : 'Soruyu Aç',
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              const LiveStreakPill(),
              const SizedBox(height: 14),
              const Text(
                'İlk 5 doğru Kolay, sonraki 7 doğru Orta, ardından Zor sorular gelir.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFFD8CCEA), fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _scoreCard(String emoji, String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0x16FFFFFF),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: const Color(0x33FFFFFF)),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 22)),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 23, fontWeight: FontWeight.w900)),
          Text(label, style: const TextStyle(color: Color(0xFFCBC1D6), fontSize: 11)),
        ],
      ),
    );
  }

  Future<void> _openQuestion() async {
    if (_busy || _finished) return;
    setState(() => _busy = true);

    final baseCategory = _random.nextInt(GameCategory.values.length);
    final plan = await GameplayBoostDialogs.chooseQuestionPlan(
      context,
      baseCategoryIndex: baseCategory,
      normalDifficulty: _difficulty,
      wallet: _jokers,
    );
    if (!mounted) return;

    final question = widget.questionBank.nextQuestion(
      categoryIndex: plan.categoryIndex,
      random: _random,
      usedQuestionIds: _used,
      preferredDifficulty: plan.preferredDifficulty,
    ).question;

    final correct = await Navigator.of(context).push<bool>(
          MaterialPageRoute(
            fullscreenDialog: true,
            builder: (_) => QuestionScreen(
              question: question,
              jokers: _jokers,
              riskMode: plan.risky,
              xpMultiplier: plan.xpMultiplier,
              onChangeQuestion: (current) async {
                return GameplayBoostQuestionPicker.replacement(
                  questionBank: widget.questionBank,
                  current: current,
                  usedQuestionIds: _used,
                );
              },
            ),
          ),
        ) ??
        false;
    if (!mounted) return;

    if (correct) {
      _correct++;
      _streak++;
      _bestStreak = max(_bestStreak, _streak);
      unawaited(SoundFx.correct());
    } else {
      _wrong++;
      _lives--;
      _streak = 0;
      unawaited(SoundFx.wrong());
    }
    setState(() {});

    final gain = await CareerStatsService.recordAnswer(
      categoryIndex: question.categoryIndex,
      difficulty: question.difficulty,
      correct: correct,
      xpMultiplier: plan.xpMultiplier,
    );
    if (mounted) await XpCelebration.show(context, gain);
    if (!mounted) return;

    if (_lives <= 0) {
      await _finish();
    } else {
      setState(() => _busy = false);
    }
  }

  Future<void> _finish() async {
    if (_finished) return;
    _finished = true;
    final bonusXp = max(25, _correct * 4);
    final bonus = await XpProgressService._award(bonusXp, 'Hayatta Kalma tamamlandı');
    await QuickModeRecordService.saveSurvival(_correct);
    if (!mounted) return;
    await XpCelebration.show(context, bonus);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => QuickModeResultScreen(
          title: '❤️ HAYATTA KALMA BİTTİ',
          emoji: _correct >= 15 ? '👑' : '❤️',
          score: '$_correct doğru',
          detail: '$_wrong yanlış • En iyi seri $_bestStreak',
          bonusXp: bonusXp,
          replayBuilder: (_) => SurvivalModeScreen(questionBank: widget.questionBank),
        ),
      ),
    );
  }
}

class SpeedModeScreen extends StatefulWidget {
  const SpeedModeScreen({required this.questionBank, super.key});

  final QuestionBank questionBank;

  @override
  State<SpeedModeScreen> createState() => _SpeedModeScreenState();
}

class _SpeedModeScreenState extends State<SpeedModeScreen> {
  final Random _random = Random();
  final Set<String> _used = <String>{};
  final List<XpGainResult> _gains = <XpGainResult>[];

  late QuizQuestion _question;
  Timer? _timer;
  Future<void> _recording = Future<void>.value();
  int _seconds = 60;
  int _correct = 0;
  int _wrong = 0;
  int _streak = 0;
  int _bestStreak = 0;
  int? _selected;
  bool _locked = false;
  bool _finished = false;

  String get _difficulty {
    if (_seconds > 40) return 'Kolay';
    if (_seconds > 20) return 'Orta';
    return 'Zor';
  }

  @override
  void initState() {
    super.initState();
    _question = _nextQuestion();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || _finished) return;
      if (_seconds <= 1) {
        setState(() => _seconds = 0);
        unawaited(_finish());
      } else {
        setState(() => _seconds--);
      }
    });
  }

  QuizQuestion _nextQuestion() {
    final category = _random.nextInt(GameCategory.values.length);
    return widget.questionBank.nextQuestion(
      categoryIndex: category,
      random: _random,
      usedQuestionIds: _used,
      preferredDifficulty: _difficulty,
    ).question;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final category = GameCategory.values[_question.categoryIndex];
    return Scaffold(
      appBar: AppBar(title: const Text('60 Saniye')),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1E1029), Color(0xFF7C2D12), Color(0xFF123B4A)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(child: _topCard('⏱️', '$_seconds', 'Saniye')),
                    const SizedBox(width: 8),
                    Expanded(child: _topCard('✅', '$_correct', 'Doğru')),
                    const SizedBox(width: 8),
                    Expanded(child: _topCard('🔥', '$_streak', 'Seri')),
                  ],
                ),
                const SizedBox(height: 10),
                LinearProgressIndicator(
                  value: _seconds / 60,
                  minHeight: 9,
                  backgroundColor: const Color(0x33FFFFFF),
                  color: _seconds <= 10 ? const Color(0xFFEF4444) : const Color(0xFFFFE082),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${category.emoji} ${category.label} • ${_question.difficulty}',
                          style: TextStyle(color: category.darkColor, fontWeight: FontWeight.w900)),
                      const SizedBox(height: 12),
                      Text(_question.text,
                          style: const TextStyle(fontSize: 20, height: 1.22, fontWeight: FontWeight.w900)),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: ListView.separated(
                    itemCount: _question.options.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) => _option(index, category),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _topCard(String emoji, String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0x16FFFFFF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x33FFFFFF)),
      ),
      child: Column(
        children: [
          Text(emoji),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
          Text(label, style: const TextStyle(color: Color(0xFFCBC1D6), fontSize: 10)),
        ],
      ),
    );
  }

  Widget _option(int index, GameCategory category) {
    final correct = index == _question.answerIndex;
    final selected = index == _selected;
    Color background = Colors.white;
    Color border = const Color(0xFFCBD5E1);
    if (_locked && correct) {
      background = const Color(0xFFDCFCE7);
      border = const Color(0xFF16A34A);
    } else if (_locked && selected) {
      background = const Color(0xFFFEE2E2);
      border = const Color(0xFFDC2626);
    }
    return Material(
      color: background,
      borderRadius: BorderRadius.circular(17),
      child: InkWell(
        onTap: _locked || _finished ? null : () => _answer(index),
        borderRadius: BorderRadius.circular(17),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(17),
            border: Border.all(color: border, width: selected ? 2 : 1.1),
          ),
          child: Row(
            children: [
              Text(String.fromCharCode(65 + index),
                  style: TextStyle(color: category.darkColor, fontWeight: FontWeight.w900)),
              const SizedBox(width: 12),
              Expanded(child: Text(_question.options[index], style: const TextStyle(fontWeight: FontWeight.w700))),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _answer(int index) async {
    if (_locked || _finished) return;
    final answered = _question;
    final correct = index == answered.answerIndex;
    setState(() {
      _locked = true;
      _selected = index;
      if (correct) {
        _correct++;
        _streak++;
        _bestStreak = max(_bestStreak, _streak);
      } else {
        _wrong++;
        _streak = 0;
      }
    });
    correct ? unawaited(SoundFx.correct()) : unawaited(SoundFx.wrong());
    _recording = _recording.then((_) async {
      final gain = await CareerStatsService.recordAnswer(
        categoryIndex: answered.categoryIndex,
        difficulty: answered.difficulty,
        correct: correct,
      );
      _gains.add(gain);
    });
    await Future<void>.delayed(const Duration(milliseconds: 360));
    if (!mounted || _finished) return;
    setState(() {
      _question = _nextQuestion();
      _selected = null;
      _locked = false;
    });
  }

  Future<void> _finish() async {
    if (_finished) return;
    _finished = true;
    _timer?.cancel();
    await _recording;
    final bonusXp = max(30, _correct * 5);
    final bonus = await XpProgressService._award(bonusXp, '60 Saniye tamamlandı');
    _gains.add(bonus);
    await QuickModeRecordService.saveSpeed(_correct);
    if (!mounted) return;
    await XpCelebration.show(
      context,
      XpGainResult.combine(_gains, reason: '60 Saniye toplam kazancı'),
    );
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => QuickModeResultScreen(
          title: '⏱️ SÜRE DOLDU',
          emoji: _correct >= 15 ? '⚡👑' : '⚡',
          score: '$_correct doğru',
          detail: '$_wrong yanlış • En iyi seri $_bestStreak',
          bonusXp: bonusXp,
          replayBuilder: (_) => SpeedModeScreen(questionBank: widget.questionBank),
        ),
      ),
    );
  }
}

class DuelPlayerState {
  DuelPlayerState({
    required this.name,
    required this.categoryIndex,
  });

  final String name;
  final int categoryIndex;
  final JokerWallet jokers = JokerWallet.starter();
  int score = 0;
  int wrong = 0;
  int streak = 0;
  int bestStreak = 0;
}

class CategoryDuelSetupScreen extends StatefulWidget {
  const CategoryDuelSetupScreen({
    required this.questionBank,
    super.key,
  });

  final QuestionBank questionBank;

  @override
  State<CategoryDuelSetupScreen> createState() =>
      _CategoryDuelSetupScreenState();
}

class _CategoryDuelSetupScreenState
    extends State<CategoryDuelSetupScreen> {
  final TextEditingController _first =
      TextEditingController(text: 'Oyuncu 1');
  final TextEditingController _second =
      TextEditingController(text: 'Oyuncu 2');
  int _firstCategory = 0;
  int _secondCategory = 1;

  @override
  void dispose() {
    _first.dispose();
    _second.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kategori Düellosu')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 28),
          children: [
            Container(
              padding: const EdgeInsets.all(21),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4338CA), Color(0xFF7C3AED)],
                ),
                borderRadius: BorderRadius.circular(27),
              ),
              child: const Column(
                children: [
                  Text('⚔️', style: TextStyle(fontSize: 55)),
                  SizedBox(height: 8),
                  Text(
                    'Kategorini seç, rakibine meydan oku',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 23,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: 7),
                  Text(
                    'Her oyuncuya beş soru gelir. En çok doğru yapan kazanır.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Color(0xFFE7E1F0)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _setupCard(
              title: '1. Oyuncu',
              controller: _first,
              categoryIndex: _firstCategory,
              onCategoryChanged: (value) =>
                  setState(() => _firstCategory = value),
            ),
            const SizedBox(height: 12),
            _setupCard(
              title: '2. Oyuncu',
              controller: _second,
              categoryIndex: _secondCategory,
              onCategoryChanged: (value) =>
                  setState(() => _secondCategory = value),
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: _start,
              icon: const Icon(Icons.sports_martial_arts_rounded),
              label: const Text(
                'Düelloyu Başlat',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _setupCard({
    required String title,
    required TextEditingController controller,
    required int categoryIndex,
    required ValueChanged<int> onCategoryChanged,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              maxLength: 16,
              decoration: const InputDecoration(
                counterText: '',
                labelText: 'Oyuncu adı',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              initialValue: categoryIndex,
              decoration: const InputDecoration(
                labelText: 'Kategori',
                border: OutlineInputBorder(),
              ),
              items: [
                for (var index = 0;
                    index < GameCategory.values.length;
                    index++)
                  DropdownMenuItem<int>(
                    value: index,
                    child: Text(
                      '${GameCategory.values[index].emoji} '
                      '${GameCategory.values[index].label}',
                    ),
                  ),
              ],
              onChanged: (value) {
                if (value != null) onCategoryChanged(value);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _start() {
    final firstName = _first.text.trim();
    final secondName = _second.text.trim();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => CategoryDuelGameScreen(
          questionBank: widget.questionBank,
          players: [
            DuelPlayerState(
              name: firstName.isEmpty ? 'Oyuncu 1' : firstName,
              categoryIndex: _firstCategory,
            ),
            DuelPlayerState(
              name: secondName.isEmpty ? 'Oyuncu 2' : secondName,
              categoryIndex: _secondCategory,
            ),
          ],
        ),
      ),
    );
  }
}

class CategoryDuelGameScreen extends StatefulWidget {
  const CategoryDuelGameScreen({
    required this.questionBank,
    required this.players,
    super.key,
  });

  final QuestionBank questionBank;
  final List<DuelPlayerState> players;

  @override
  State<CategoryDuelGameScreen> createState() =>
      _CategoryDuelGameScreenState();
}

class _CategoryDuelGameScreenState
    extends State<CategoryDuelGameScreen> {
  final Random _random = Random();
  final Set<String> _used = <String>{};
  int _turn = 0;
  bool _busy = false;
  bool _finished = false;

  int get _playerIndex => _turn % 2;
  int get _round => (_turn ~/ 2) + 1;
  DuelPlayerState get _current => widget.players[_playerIndex];
  String get _difficulty => _round <= 2 ? 'Orta' : 'Zor';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kategori Düellosu')),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF17113C), Color(0xFF312E81), Color(0xFF4C1D95)],
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 28),
            children: [
              Row(
                children: [
                  Expanded(child: _scoreCard(widget.players[0], _playerIndex == 0)),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text('⚔️', style: TextStyle(fontSize: 28)),
                  ),
                  Expanded(child: _scoreCard(widget.players[1], _playerIndex == 1)),
                ],
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Column(
                  children: [
                    Text(
                      GameCategory.values[_current.categoryIndex].emoji,
                      style: const TextStyle(fontSize: 58),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${_current.name} sırası',
                      style: const TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${GameCategory.values[_current.categoryIndex].label} '
                      '• $_round. soru • $_difficulty',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 14),
                    JokerWalletMiniBar(wallet: _current.jokers),
                    const SizedBox(height: 18),
                    FilledButton.icon(
                      onPressed: _busy ? null : _openQuestion,
                      icon: const Icon(Icons.quiz_rounded),
                      label: Text(
                        _busy ? 'Hazırlanıyor…' : 'Soruyu Aç',
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              const LiveStreakPill(),
              const SizedBox(height: 14),
              const Text(
                'İlk iki tur Orta, son üç tur Zor sorudur. Riskli soru seçilebilir.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFFD8CCEA),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _scoreCard(DuelPlayerState player, bool active) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: active ? const Color(0x337C3AED) : const Color(0x16FFFFFF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: active ? const Color(0xFFFFE082) : const Color(0x33FFFFFF),
          width: active ? 2 : 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            player.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
          ),
          Text(
            '${player.score}',
            style: const TextStyle(
              color: Color(0xFFFFE082),
              fontSize: 29,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            GameCategory.values[player.categoryIndex].emoji,
            style: const TextStyle(fontSize: 19),
          ),
        ],
      ),
    );
  }

  Future<void> _openQuestion() async {
    if (_busy || _finished) return;
    setState(() => _busy = true);

    final player = _current;
    final plan = await GameplayBoostDialogs.chooseQuestionPlan(
      context,
      baseCategoryIndex: player.categoryIndex,
      normalDifficulty: _difficulty,
      wallet: player.jokers,
      allowCategoryChange: false,
    );
    if (!mounted) return;

    final question = widget.questionBank.nextQuestion(
      categoryIndex: player.categoryIndex,
      random: _random,
      usedQuestionIds: _used,
      preferredDifficulty: plan.preferredDifficulty,
    ).question;

    final correct = await Navigator.of(context).push<bool>(
          MaterialPageRoute(
            fullscreenDialog: true,
            builder: (_) => QuestionScreen(
              question: question,
              jokers: player.jokers,
              riskMode: plan.risky,
              xpMultiplier: plan.xpMultiplier,
              onChangeQuestion: (current) async {
                return GameplayBoostQuestionPicker.replacement(
                  questionBank: widget.questionBank,
                  current: current,
                  usedQuestionIds: _used,
                );
              },
            ),
          ),
        ) ??
        false;
    if (!mounted) return;

    if (correct) {
      player.score++;
      player.streak++;
      player.bestStreak = max(player.bestStreak, player.streak);
      unawaited(SoundFx.correct());
    } else {
      player.wrong++;
      player.streak = 0;
      unawaited(SoundFx.wrong());
    }
    setState(() {});

    final gain = await CareerStatsService.recordAnswer(
      categoryIndex: question.categoryIndex,
      difficulty: question.difficulty,
      correct: correct,
      xpMultiplier: plan.xpMultiplier,
    );
    if (mounted) await XpCelebration.show(context, gain);
    if (!mounted) return;

    _turn++;
    if (_turn >= 10) {
      await _finish();
    } else {
      setState(() => _busy = false);
    }
  }

  Future<void> _finish() async {
    if (_finished) return;
    _finished = true;
    final first = widget.players[0];
    final second = widget.players[1];
    final tie = first.score == second.score;
    final winner = tie
        ? null
        : first.score > second.score
            ? first
            : second;
    final bonusXp = tie ? 60 : 100;
    final bonus = await XpProgressService._award(
      bonusXp,
      tie ? 'Kategori Düellosu beraberliği' : 'Kategori Düellosu zaferi',
    );
    await QuickModeRecordService.saveDuel();
    if (!mounted) return;
    await XpCelebration.show(context, bonus);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => QuickModeResultScreen(
          title: tie ? '🤝 DÜELLO BERABERE' : '🏆 DÜELLO ŞAMPİYONU',
          emoji: tie ? '🤝' : '👑',
          score: tie ? '${first.score} - ${second.score}' : '${winner!.name} kazandı!',
          detail: '${first.name}: ${first.score}/5 • ${second.name}: ${second.score}/5',
          bonusXp: bonusXp,
          replayBuilder: (_) => CategoryDuelSetupScreen(questionBank: widget.questionBank),
        ),
      ),
    );
  }
}
