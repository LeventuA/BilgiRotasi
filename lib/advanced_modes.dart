part of 'main.dart';

class AdvancedStanding {
  const AdvancedStanding({
    required this.name,
    required this.score,
    required this.detail,
  });

  final String name;
  final int score;
  final String detail;
}

class AdvancedLeaderboardResultScreen extends StatelessWidget {
  const AdvancedLeaderboardResultScreen({
    required this.title,
    required this.emoji,
    required this.headline,
    required this.subtitle,
    required this.standings,
    required this.bonusXp,
    required this.replayBuilder,
    super.key,
  });

  final String title;
  final String emoji;
  final String headline;
  final String subtitle;
  final List<AdvancedStanding> standings;
  final int bonusXp;
  final WidgetBuilder replayBuilder;

  @override
  Widget build(BuildContext context) {
    final ordered = List<AdvancedStanding>.from(standings)
      ..sort((a, b) => b.score.compareTo(a.score));

    return PopScope<Object?>(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      },
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(0, -0.45),
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
              padding: const EdgeInsets.fromLTRB(20, 26, 20, 28),
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
                  padding: const EdgeInsets.all(23),
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
                        emoji,
                        style: const TextStyle(fontSize: 65),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        headline,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          height: 1.08,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        subtitle,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFFD8CCEA),
                          height: 1.35,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 18),
                      for (var index = 0;
                          index < ordered.length;
                          index++) ...[
                        _standingRow(
                          ordered[index],
                          index,
                        ),
                        if (index < ordered.length - 1)
                          const SizedBox(height: 8),
                      ],
                      const SizedBox(height: 16),
                      Text(
                        '🏆 Tamamlama bonusu: +$bonusXp XP',
                        textAlign: TextAlign.center,
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
                      MaterialPageRoute(
                        builder: replayBuilder,
                      ),
                    );
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFFFE082),
                    foregroundColor: const Color(0xFF3A2448),
                  ),
                  icon: const Icon(Icons.replay_rounded),
                  label: const Text(
                    'Tekrar Oyna',
                    style: TextStyle(fontWeight: FontWeight.w900),
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
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _standingRow(
    AdvancedStanding standing,
    int index,
  ) {
    final medal = switch (index) {
      0 => '🥇',
      1 => '🥈',
      2 => '🥉',
      _ => '${index + 1}.',
    };

    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: index == 0
            ? const Color(0x22FFE082)
            : const Color(0x16FFFFFF),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: index == 0
              ? const Color(0x88FFE082)
              : const Color(0x33FFFFFF),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 35,
            child: Text(
              medal,
              style: const TextStyle(fontSize: 22),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  standing.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  standing.detail,
                  style: const TextStyle(
                    color: Color(0xFFD8CCEA),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${standing.score}',
            style: const TextStyle(
              color: Color(0xFFFFE082),
              fontSize: 23,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class FamilyModePlayer {
  FamilyModePlayer({
    required this.name,
    required this.isChild,
  });

  final String name;
  final bool isChild;
  final JokerWallet jokers = JokerWallet.starter();

  int correct = 0;
  int wrong = 0;
  int streak = 0;
  int bestStreak = 0;
}

class FamilyModeSetupScreen extends StatefulWidget {
  const FamilyModeSetupScreen({
    required this.questionBank,
    super.key,
  });

  final QuestionBank questionBank;

  @override
  State<FamilyModeSetupScreen> createState() =>
      _FamilyModeSetupScreenState();
}

class _FamilyModeSetupScreenState
    extends State<FamilyModeSetupScreen> {
  int _playerCount = 3;

  final List<TextEditingController> _controllers =
      List<TextEditingController>.generate(
    6,
    (index) => TextEditingController(
      text: index == 0
          ? 'Levent'
          : index == 1
              ? 'Mila'
              : 'Oyuncu ${index + 1}',
    ),
  );

  final List<bool> _childFlags = <bool>[
    false,
    true,
    false,
    false,
    false,
    false,
  ];

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Aile Modu')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 28),
          children: [
            _setupHero(
              emoji: '👨‍👩‍👧‍👦',
              title: 'Herkese kendi seviyesinde soru',
              text:
                  'Çocuklara Kolay, yetişkinlere ilerledikçe '
                  'Orta ve Zor sorular gelir. Her oyuncu 5 soru cevaplar.',
              colors: const [
                Color(0xFF0F766E),
                Color(0xFF2563EB),
              ],
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Oyuncu sayısı: $_playerCount',
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Slider(
                      min: 2,
                      max: 6,
                      divisions: 4,
                      value: _playerCount.toDouble(),
                      label: '$_playerCount',
                      onChanged: (value) {
                        setState(() {
                          _playerCount = value.round();
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            for (var index = 0;
                index < _playerCount;
                index++) ...[
              Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    children: [
                      TextField(
                        controller: _controllers[index],
                        maxLength: 16,
                        textCapitalization:
                            TextCapitalization.words,
                        decoration: InputDecoration(
                          counterText: '',
                          labelText:
                              '${index + 1}. oyuncunun adı',
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 7),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        value: _childFlags[index],
                        onChanged: (value) {
                          setState(() {
                            _childFlags[index] = value;
                          });
                        },
                        secondary: Text(
                          _childFlags[index] ? '🧒' : '🧑',
                          style: const TextStyle(fontSize: 29),
                        ),
                        title: Text(
                          _childFlags[index]
                              ? 'Çocuk oyuncu'
                              : 'Yetişkin oyuncu',
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        subtitle: Text(
                          _childFlags[index]
                              ? 'Kolay sorular gelir.'
                              : 'Orta ve Zor sorular gelir.',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: _start,
              icon: const Icon(Icons.family_restroom_rounded),
              label: const Text(
                'Aile Turunu Başlat',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _start() {
    final players = <FamilyModePlayer>[
      for (var index = 0; index < _playerCount; index++)
        FamilyModePlayer(
          name: _controllers[index].text.trim().isEmpty
              ? 'Oyuncu ${index + 1}'
              : _controllers[index].text.trim(),
          isChild: _childFlags[index],
        ),
    ];

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => FamilyModeGameScreen(
          questionBank: widget.questionBank,
          players: players,
        ),
      ),
    );
  }
}

class FamilyModeGameScreen extends StatefulWidget {
  const FamilyModeGameScreen({
    required this.questionBank,
    required this.players,
    super.key,
  });

  final QuestionBank questionBank;
  final List<FamilyModePlayer> players;

  @override
  State<FamilyModeGameScreen> createState() =>
      _FamilyModeGameScreenState();
}

class _FamilyModeGameScreenState
    extends State<FamilyModeGameScreen> {
  final Random _random = Random();
  final Set<String> _usedQuestionIds = <String>{};

  int _turn = 0;
  bool _busy = false;
  bool _finished = false;
  bool _exitDialogOpen = false;

  int get _playerIndex => _turn % widget.players.length;
  int get _round => (_turn ~/ widget.players.length) + 1;
  int get _totalTurns => widget.players.length * 5;

  FamilyModePlayer get _current =>
      widget.players[_playerIndex];

  String get _difficulty {
    if (_current.isChild) return 'Kolay';
    return _round <= 2 ? 'Orta' : 'Zor';
  }

  @override
  Widget build(BuildContext context) {
    return PopScope<Object?>(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) unawaited(_confirmExit());
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Aile Modu'),
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
                Color(0xFF102A43),
                Color(0xFF0F766E),
                Color(0xFF3B1F4D),
              ],
            ),
          ),
          child: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 28),
              children: [
                LinearProgressIndicator(
                  value: _turn / _totalTurns,
                  minHeight: 10,
                  backgroundColor: const Color(0x33FFFFFF),
                  color: const Color(0xFFFFE082),
                ),
                const SizedBox(height: 9),
                Text(
                  'Tur $_round / 5 • '
                  '${_turn + 1}. soru / $_totalTurns',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFFD8CCEA),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 16),
                _familyScoreStrip(),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(23),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Column(
                    children: [
                      Text(
                        _current.isChild ? '🧒' : '🧑',
                        style: const TextStyle(fontSize: 58),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${_current.name} sırası',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${_current.isChild ? 'Çocuk' : 'Yetişkin'} '
                        '• $_difficulty soru',
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 14),
                      JokerWalletMiniBar(
                        wallet: _current.jokers,
                      ),
                      const SizedBox(height: 18),
                      FilledButton.icon(
                        onPressed:
                            _busy ? null : _openQuestion,
                        icon: const Icon(Icons.quiz_rounded),
                        label: Text(
                          _busy
                              ? 'Soru hazırlanıyor…'
                              : '${_current.name} Soruyu Aç',
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                const LiveStreakPill(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _familyScoreStrip() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (var index = 0;
              index < widget.players.length;
              index++) ...[
            Container(
              width: 118,
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                color: index == _playerIndex
                    ? const Color(0x33FFE082)
                    : const Color(0x16FFFFFF),
                borderRadius: BorderRadius.circular(17),
                border: Border.all(
                  color: index == _playerIndex
                      ? const Color(0xFFFFE082)
                      : const Color(0x33FFFFFF),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    widget.players[index].isChild
                        ? '🧒'
                        : '🧑',
                  ),
                  Text(
                    widget.players[index].name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    '${widget.players[index].correct} doğru',
                    style: const TextStyle(
                      color: Color(0xFFFFE082),
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            if (index < widget.players.length - 1)
              const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }

  Future<void> _openQuestion() async {
    if (_busy || _finished) return;
    setState(() => _busy = true);

    final player = _current;
    final baseCategory =
        _random.nextInt(GameCategory.values.length);

    QuestionRiskPlan plan;

    if (player.isChild) {
      plan = QuestionRiskPlan(
        categoryIndex: baseCategory,
        preferredDifficulty: 'Kolay',
        xpMultiplier: 1,
        risky: false,
        categoryChanged: false,
      );
    } else {
      plan = await GameplayBoostDialogs.chooseQuestionPlan(
        context,
        baseCategoryIndex: baseCategory,
        normalDifficulty: _difficulty,
        wallet: player.jokers,
      );
    }

    if (!mounted) return;

    final question = widget.questionBank
        .nextQuestion(
          categoryIndex: plan.categoryIndex,
          random: _random,
          usedQuestionIds: _usedQuestionIds,
          preferredDifficulty: plan.preferredDifficulty,
        )
        .question;

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
                  usedQuestionIds: _usedQuestionIds,
                );
              },
            ),
          ),
        ) ??
        false;

    if (!mounted) return;

    setState(() {
      if (correct) {
        player.correct++;
        player.streak++;
        player.bestStreak = max(
          player.bestStreak,
          player.streak,
        );
      } else {
        player.wrong++;
        player.streak = 0;
      }
    });

    final gain = await CareerStatsService.recordAnswer(
      categoryIndex: question.categoryIndex,
      difficulty: question.difficulty,
      correct: correct,
      xpMultiplier: plan.xpMultiplier,
    );

    if (mounted) {
      await XpCelebration.show(context, gain);
    }

    if (!mounted) return;

    _turn++;

    if (_turn >= _totalTurns) {
      await _finish();
      return;
    }

    setState(() => _busy = false);
  }

  Future<void> _finish() async {
    if (_finished) return;
    _finished = true;

    final bestScore = widget.players
        .map((player) => player.correct)
        .fold<int>(0, max);

    final winners = widget.players
        .where((player) => player.correct == bestScore)
        .map((player) => player.name)
        .toList();

    const bonusXp = 120;
    final bonus = await XpProgressService._award(
      bonusXp,
      'Aile Modu tamamlandı',
    );

    if (!mounted) return;
    await XpCelebration.show(context, bonus);
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => AdvancedLeaderboardResultScreen(
          title: '👨‍👩‍👧‍👦 AİLE TURU TAMAMLANDI',
          emoji: winners.length == 1 ? '🏆' : '🤝',
          headline: winners.length == 1
              ? '${winners.first} kazandı!'
              : 'Beraberlik!',
          subtitle:
              'Ailede herkes kendi seviyesine göre yarıştı.',
          standings: [
            for (final player in widget.players)
              AdvancedStanding(
                name: player.name,
                score: player.correct,
                detail:
                    '${player.isChild ? 'Çocuk' : 'Yetişkin'} • '
                    '${player.wrong} yanlış • '
                    'En iyi seri ${player.bestStreak}',
              ),
          ],
          bonusXp: bonusXp,
          replayBuilder: (_) => FamilyModeSetupScreen(
            questionBank: widget.questionBank,
          ),
        ),
      ),
    );
  }

  Future<void> _confirmExit() async {
    if (_exitDialogOpen || !mounted) return;
    _exitDialogOpen = true;

    final exit = await _confirmModeExit(
      context,
      title: 'Aile Modundan çıkılsın mı?',
      message: 'Bu aile turunun mevcut skoru kaydedilmeyecek.',
    );

    _exitDialogOpen = false;

    if (exit && mounted) {
      Navigator.of(context).pop();
    }
  }
}

class TeamModeState {
  TeamModeState(this.name);

  final String name;
  final JokerWallet jokers = JokerWallet.starter();

  int correct = 0;
  int wrong = 0;
  int streak = 0;
  int bestStreak = 0;
}

class TeamModeSetupScreen extends StatefulWidget {
  const TeamModeSetupScreen({
    required this.questionBank,
    super.key,
  });

  final QuestionBank questionBank;

  @override
  State<TeamModeSetupScreen> createState() =>
      _TeamModeSetupScreenState();
}

class _TeamModeSetupScreenState
    extends State<TeamModeSetupScreen> {
  final TextEditingController _first =
      TextEditingController(text: 'Mor Takım');
  final TextEditingController _second =
      TextEditingController(text: 'Turkuaz Takım');

  @override
  void dispose() {
    _first.dispose();
    _second.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Takım Modu')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 28),
          children: [
            _setupHero(
              emoji: '🤝',
              title: 'Bilginizi takımınızla birleştirin',
              text:
                  'İki takım altı kategorinin tamamından birer '
                  'soru cevaplar. Jokerler takımca paylaşılır.',
              colors: const [
                Color(0xFF6D28D9),
                Color(0xFF0F766E),
              ],
            ),
            const SizedBox(height: 16),
            _teamNameCard(
              controller: _first,
              number: 1,
              emoji: '🟣',
              color: const Color(0xFF7C3AED),
            ),
            const SizedBox(height: 12),
            _teamNameCard(
              controller: _second,
              number: 2,
              emoji: '🔵',
              color: const Color(0xFF0891B2),
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: _start,
              icon: const Icon(Icons.groups_rounded),
              label: const Text(
                'Takım Yarışını Başlat',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _teamNameCard({
    required TextEditingController controller,
    required int number,
    required String emoji,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Text(
              emoji,
              style: const TextStyle(fontSize: 38),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: controller,
                maxLength: 18,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  counterText: '',
                  labelText: '$number. takımın adı',
                  border: const OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: color,
                      width: 2,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _start() {
    final teams = [
      TeamModeState(
        _first.text.trim().isEmpty
            ? 'Mor Takım'
            : _first.text.trim(),
      ),
      TeamModeState(
        _second.text.trim().isEmpty
            ? 'Turkuaz Takım'
            : _second.text.trim(),
      ),
    ];

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => TeamModeGameScreen(
          questionBank: widget.questionBank,
          teams: teams,
        ),
      ),
    );
  }
}

class TeamModeGameScreen extends StatefulWidget {
  const TeamModeGameScreen({
    required this.questionBank,
    required this.teams,
    super.key,
  });

  final QuestionBank questionBank;
  final List<TeamModeState> teams;

  @override
  State<TeamModeGameScreen> createState() =>
      _TeamModeGameScreenState();
}

class _TeamModeGameScreenState
    extends State<TeamModeGameScreen> {
  final Random _random = Random();
  final Set<String> _usedQuestionIds = <String>{};

  int _turn = 0;
  bool _busy = false;
  bool _finished = false;
  bool _exitDialogOpen = false;

  int get _teamIndex => _turn % 2;
  int get _categoryIndex => _turn ~/ 2;
  TeamModeState get _current => widget.teams[_teamIndex];

  String get _difficulty =>
      _categoryIndex < 3 ? 'Orta' : 'Zor';

  @override
  Widget build(BuildContext context) {
    final category =
        GameCategory.values[_categoryIndex.clamp(0, 5).toInt()];

    return PopScope<Object?>(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) unawaited(_confirmExit());
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Takım Modu'),
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
                Color(0xFF24122F),
                Color(0xFF3B1F4D),
                Color(0xFF0F5661),
              ],
            ),
          ),
          child: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 28),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _teamScoreCard(
                        widget.teams[0],
                        const Color(0xFF7C3AED),
                        _teamIndex == 0,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        'VS',
                        style: TextStyle(
                          color: Color(0xFFFFE082),
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    Expanded(
                      child: _teamScoreCard(
                        widget.teams[1],
                        const Color(0xFF0891B2),
                        _teamIndex == 1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                LinearProgressIndicator(
                  value: _turn / 12,
                  minHeight: 10,
                  backgroundColor: const Color(0x33FFFFFF),
                  color: const Color(0xFFFFE082),
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
                      Text(
                        category.emoji,
                        style: const TextStyle(fontSize: 58),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${_current.name} sırası',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${category.label} • $_difficulty',
                        style: TextStyle(
                          color: category.darkColor,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 14),
                      JokerWalletMiniBar(
                        wallet: _current.jokers,
                      ),
                      const SizedBox(height: 18),
                      FilledButton.icon(
                        onPressed:
                            _busy ? null : _openQuestion,
                        style: FilledButton.styleFrom(
                          backgroundColor: category.color,
                        ),
                        icon: const Icon(Icons.quiz_rounded),
                        label: Text(
                          _busy
                              ? 'Soru hazırlanıyor…'
                              : 'Takım Sorusunu Aç',
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                const LiveStreakPill(),
                const SizedBox(height: 14),
                const Text(
                  'Her kategori iki kez oynanır: önce 1. takım, '
                  'sonra 2. takım. Böylece iki takım da aynı '
                  'kategori dağılımıyla yarışır.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFFD8CCEA),
                    height: 1.4,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _teamScoreCard(
    TeamModeState team,
    Color color,
    bool active,
  ) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: active
            ? color.withOpacity(0.36)
            : const Color(0x16FFFFFF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: active
              ? const Color(0xFFFFE082)
              : const Color(0x33FFFFFF),
          width: active ? 2 : 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            team.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            '${team.correct}',
            style: const TextStyle(
              color: Color(0xFFFFE082),
              fontSize: 29,
              fontWeight: FontWeight.w900,
            ),
          ),
          const Text(
            'doğru',
            style: TextStyle(
              color: Color(0xFFD8CCEA),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openQuestion() async {
    if (_busy || _finished) return;
    setState(() => _busy = true);

    final team = _current;
    final plan =
        await GameplayBoostDialogs.chooseQuestionPlan(
      context,
      baseCategoryIndex: _categoryIndex,
      normalDifficulty: _difficulty,
      wallet: team.jokers,
      allowCategoryChange: false,
    );

    if (!mounted) return;

    final question = widget.questionBank
        .nextQuestion(
          categoryIndex: _categoryIndex,
          random: _random,
          usedQuestionIds: _usedQuestionIds,
          preferredDifficulty: plan.preferredDifficulty,
        )
        .question;

    final correct = await Navigator.of(context).push<bool>(
          MaterialPageRoute(
            fullscreenDialog: true,
            builder: (_) => QuestionScreen(
              question: question,
              jokers: team.jokers,
              riskMode: plan.risky,
              xpMultiplier: plan.xpMultiplier,
              onChangeQuestion: (current) async {
                return GameplayBoostQuestionPicker.replacement(
                  questionBank: widget.questionBank,
                  current: current,
                  usedQuestionIds: _usedQuestionIds,
                );
              },
            ),
          ),
        ) ??
        false;

    if (!mounted) return;

    setState(() {
      if (correct) {
        team.correct++;
        team.streak++;
        team.bestStreak = max(
          team.bestStreak,
          team.streak,
        );
      } else {
        team.wrong++;
        team.streak = 0;
      }
    });

    final gain = await CareerStatsService.recordAnswer(
      categoryIndex: question.categoryIndex,
      difficulty: question.difficulty,
      correct: correct,
      xpMultiplier: plan.xpMultiplier,
    );

    if (mounted) {
      await XpCelebration.show(context, gain);
    }

    if (!mounted) return;

    _turn++;

    if (_turn >= 12) {
      await _finish();
      return;
    }

    setState(() => _busy = false);
  }

  Future<void> _finish() async {
    if (_finished) return;
    _finished = true;

    final first = widget.teams[0];
    final second = widget.teams[1];
    final tied = first.correct == second.correct;
    final winner = tied
        ? null
        : first.correct > second.correct
            ? first
            : second;

    const bonusXp = 150;
    final bonus = await XpProgressService._award(
      bonusXp,
      tied ? 'Takım Modu beraberliği' : 'Takım Modu tamamlandı',
    );

    if (!mounted) return;
    await XpCelebration.show(context, bonus);
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => AdvancedLeaderboardResultScreen(
          title: '🤝 TAKIM YARIŞI BİTTİ',
          emoji: tied ? '🤝' : '🏆',
          headline: tied
              ? '${first.correct} - ${second.correct} Berabere'
              : '${winner!.name} kazandı!',
          subtitle:
              'Altı kategorinin tamamında takım bilgisi sınandı.',
          standings: [
            for (final team in widget.teams)
              AdvancedStanding(
                name: team.name,
                score: team.correct,
                detail:
                    '${team.wrong} yanlış • '
                    'En iyi seri ${team.bestStreak}',
              ),
          ],
          bonusXp: bonusXp,
          replayBuilder: (_) => TeamModeSetupScreen(
            questionBank: widget.questionBank,
          ),
        ),
      ),
    );
  }

  Future<void> _confirmExit() async {
    if (_exitDialogOpen || !mounted) return;
    _exitDialogOpen = true;

    final exit = await _confirmModeExit(
      context,
      title: 'Takım Modundan çıkılsın mı?',
      message: 'Bu takım yarışının skoru kaydedilmeyecek.',
    );

    _exitDialogOpen = false;

    if (exit && mounted) {
      Navigator.of(context).pop();
    }
  }
}

class TournamentSetupScreen extends StatefulWidget {
  const TournamentSetupScreen({
    required this.questionBank,
    super.key,
  });

  final QuestionBank questionBank;

  @override
  State<TournamentSetupScreen> createState() =>
      _TournamentSetupScreenState();
}

class _TournamentSetupScreenState
    extends State<TournamentSetupScreen> {
  int _playerCount = 4;

  final List<TextEditingController> _controllers =
      List<TextEditingController>.generate(
    8,
    (index) => TextEditingController(
      text: 'Oyuncu ${index + 1}',
    ),
  );

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Turnuva Modu')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 28),
          children: [
            _setupHero(
              emoji: '🏆',
              title: 'Tek kaybeden elenir',
              text:
                  '4 veya 8 oyunculu eleme turnuvası. '
                  'Her eşleşmede oyuncular üçer soru cevaplar.',
              colors: const [
                Color(0xFF92400E),
                Color(0xFF7C3AED),
              ],
            ),
            const SizedBox(height: 16),
            SegmentedButton<int>(
              segments: const [
                ButtonSegment<int>(
                  value: 4,
                  label: Text('4 oyuncu'),
                  icon: Icon(Icons.looks_4_rounded),
                ),
                ButtonSegment<int>(
                  value: 8,
                  label: Text('8 oyuncu'),
                  icon: Icon(Icons.group_rounded),
                ),
              ],
              selected: <int>{_playerCount},
              onSelectionChanged: (selection) {
                setState(() {
                  _playerCount = selection.first;
                });
              },
            ),
            const SizedBox(height: 14),
            for (var index = 0;
                index < _playerCount;
                index++) ...[
              TextField(
                controller: _controllers[index],
                maxLength: 16,
                textCapitalization:
                    TextCapitalization.words,
                decoration: InputDecoration(
                  counterText: '',
                  labelText: '${index + 1}. oyuncu',
                  prefixText: '${index + 1}.  ',
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 9),
            ],
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: _start,
              icon: const Icon(Icons.account_tree_rounded),
              label: const Text(
                'Turnuvayı Başlat',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _start() {
    final players = <String>[
      for (var index = 0; index < _playerCount; index++)
        _controllers[index].text.trim().isEmpty
            ? 'Oyuncu ${index + 1}'
            : _controllers[index].text.trim(),
    ];

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => TournamentGameScreen(
          questionBank: widget.questionBank,
          players: players,
        ),
      ),
    );
  }
}

class TournamentGameScreen extends StatefulWidget {
  const TournamentGameScreen({
    required this.questionBank,
    required this.players,
    super.key,
  });

  final QuestionBank questionBank;
  final List<String> players;

  @override
  State<TournamentGameScreen> createState() =>
      _TournamentGameScreenState();
}

class _TournamentGameScreenState
    extends State<TournamentGameScreen> {
  final Random _random = Random();
  final Set<String> _usedQuestionIds = <String>{};

  late List<String> _roundPlayers;
  final List<String> _nextRoundWinners = <String>[];

  int _matchIndex = 0;
  int _turnInMatch = 0;
  int _suddenTurn = 0;
  int _firstScore = 0;
  int _secondScore = 0;
  bool _suddenDeath = false;
  bool _busy = false;
  bool _finished = false;
  bool _exitDialogOpen = false;

  @override
  void initState() {
    super.initState();
    _roundPlayers = List<String>.from(widget.players);
  }

  String get _first =>
      _roundPlayers[_matchIndex * 2];
  String get _second =>
      _roundPlayers[_matchIndex * 2 + 1];

  int get _activeIndex => _suddenDeath
      ? _suddenTurn % 2
      : _turnInMatch % 2;

  String get _current =>
      _activeIndex == 0 ? _first : _second;

  String get _stage {
    return switch (_roundPlayers.length) {
      8 => 'Çeyrek Final',
      4 => 'Yarı Final',
      _ => 'Final',
    };
  }

  String get _difficulty =>
      _roundPlayers.length == 2 ? 'Zor' : 'Orta';

  @override
  Widget build(BuildContext context) {
    return PopScope<Object?>(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) unawaited(_confirmExit());
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Turnuva • $_stage'),
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
                Color(0xFF2D1606),
                Color(0xFF5B2C70),
                Color(0xFF123B4A),
              ],
            ),
          ),
          child: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 28),
              children: [
                Text(
                  '$_stage • ${_matchIndex + 1}. eşleşme / '
                  '${_roundPlayers.length ~/ 2}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFFFFE082),
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _tournamentPlayerCard(
                        _first,
                        _firstScore,
                        _activeIndex == 0,
                        const Color(0xFF2563EB),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 9),
                      child: Text(
                        '⚔️',
                        style: TextStyle(fontSize: 28),
                      ),
                    ),
                    Expanded(
                      child: _tournamentPlayerCard(
                        _second,
                        _secondScore,
                        _activeIndex == 1,
                        const Color(0xFFE11D48),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.all(23),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Column(
                    children: [
                      Text(
                        _suddenDeath ? '🔥' : '🏆',
                        style: const TextStyle(fontSize: 58),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$_current sırası',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _suddenDeath
                            ? 'Ani ölüm • Eşitlik bozulana kadar'
                            : '$_difficulty • '
                                '${(_turnInMatch ~/ 2) + 1}. soru turu',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 18),
                      FilledButton.icon(
                        onPressed:
                            _busy ? null : _openQuestion,
                        icon: const Icon(Icons.quiz_rounded),
                        label: Text(
                          _busy
                              ? 'Soru hazırlanıyor…'
                              : 'Turnuva Sorusunu Aç',
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                const LiveStreakPill(),
                const SizedBox(height: 14),
                const Text(
                  'Her oyuncu üç soru cevaplar. Eşitlik olursa '
                  'iki oyuncu da birer soru cevaplayarak ani ölüme gider.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFFD8CCEA),
                    height: 1.4,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _tournamentPlayerCard(
    String name,
    int score,
    bool active,
    Color color,
  ) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: active
            ? color.withOpacity(0.37)
            : const Color(0x16FFFFFF),
        borderRadius: BorderRadius.circular(19),
        border: Border.all(
          color: active
              ? const Color(0xFFFFE082)
              : const Color(0x33FFFFFF),
          width: active ? 2 : 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            '$score',
            style: const TextStyle(
              color: Color(0xFFFFE082),
              fontSize: 32,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openQuestion() async {
    if (_busy || _finished) return;
    setState(() => _busy = true);

    final category =
        _random.nextInt(GameCategory.values.length);

    final question = widget.questionBank
        .nextQuestion(
          categoryIndex: category,
          random: _random,
          usedQuestionIds: _usedQuestionIds,
          preferredDifficulty: _difficulty,
        )
        .question;

    final correct = await Navigator.of(context).push<bool>(
          MaterialPageRoute(
            fullscreenDialog: true,
            builder: (_) => QuestionScreen(
              question: question,
            ),
          ),
        ) ??
        false;

    if (!mounted) return;

    setState(() {
      if (correct) {
        if (_activeIndex == 0) {
          _firstScore++;
        } else {
          _secondScore++;
        }
      }
    });

    final gain = await CareerStatsService.recordAnswer(
      categoryIndex: question.categoryIndex,
      difficulty: question.difficulty,
      correct: correct,
    );

    if (mounted) {
      await XpCelebration.show(context, gain);
    }

    if (!mounted) return;

    if (_suddenDeath) {
      _suddenTurn++;

      if (_suddenTurn.isEven &&
          _firstScore != _secondScore) {
        await _completeMatch();
        return;
      }
    } else {
      _turnInMatch++;

      if (_turnInMatch >= 6) {
        if (_firstScore == _secondScore) {
          setState(() {
            _suddenDeath = true;
            _suddenTurn = 0;
            _busy = false;
          });
          return;
        }

        await _completeMatch();
        return;
      }
    }

    setState(() => _busy = false);
  }

  Future<void> _completeMatch() async {
    final winner =
        _firstScore > _secondScore ? _first : _second;

    _nextRoundWinners.add(winner);

    final hasMoreMatches =
        _matchIndex + 1 < _roundPlayers.length ~/ 2;

    if (hasMoreMatches) {
      setState(() {
        _matchIndex++;
        _resetMatch();
      });
      return;
    }

    final winners =
        List<String>.from(_nextRoundWinners);
    _nextRoundWinners.clear();

    if (winners.length == 1) {
      await _finishTournament(winners.first);
      return;
    }

    setState(() {
      _roundPlayers = winners;
      _matchIndex = 0;
      _resetMatch();
    });
  }

  void _resetMatch() {
    _turnInMatch = 0;
    _suddenTurn = 0;
    _firstScore = 0;
    _secondScore = 0;
    _suddenDeath = false;
    _busy = false;
  }

  Future<void> _finishTournament(
    String champion,
  ) async {
    if (_finished) return;
    _finished = true;

    const bonusXp = 250;
    final bonus = await XpProgressService._award(
      bonusXp,
      'Turnuva şampiyonluğu',
    );

    if (!mounted) return;
    await XpCelebration.show(context, bonus);
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => AdvancedLeaderboardResultScreen(
          title: '🏆 TURNUVA TAMAMLANDI',
          emoji: '👑',
          headline: '$champion şampiyon!',
          subtitle:
              '${widget.players.length} oyunculu eleme turnuvasının '
              'zirvesine çıktı.',
          standings: [
            AdvancedStanding(
              name: champion,
              score: 1,
              detail: 'Turnuva şampiyonu',
            ),
            for (final player in widget.players)
              if (player != champion)
                AdvancedStanding(
                  name: player,
                  score: 0,
                  detail: 'Turnuvaya katıldı',
                ),
          ],
          bonusXp: bonusXp,
          replayBuilder: (_) => TournamentSetupScreen(
            questionBank: widget.questionBank,
          ),
        ),
      ),
    );
  }

  Future<void> _confirmExit() async {
    if (_exitDialogOpen || !mounted) return;
    _exitDialogOpen = true;

    final exit = await _confirmModeExit(
      context,
      title: 'Turnuvadan çıkılsın mı?',
      message: 'Turnuva ağacı ve mevcut skorlar kaybolacak.',
    );

    _exitDialogOpen = false;

    if (exit && mounted) {
      Navigator.of(context).pop();
    }
  }
}

enum MadnessRule {
  doubleXp,
  tripleXp,
  hardQuestion,
  shuffledOptions,
  fiftyGift,
  secondChanceGift,
  calmRound,
}

extension MadnessRuleX on MadnessRule {
  String get emoji {
    return switch (this) {
      MadnessRule.doubleXp => '⚡',
      MadnessRule.tripleXp => '👑',
      MadnessRule.hardQuestion => '🧠',
      MadnessRule.shuffledOptions => '🔀',
      MadnessRule.fiftyGift => '✂️',
      MadnessRule.secondChanceGift => '🍀',
      MadnessRule.calmRound => '🛡️',
    };
  }

  String get title {
    return switch (this) {
      MadnessRule.doubleXp => 'Çifte XP',
      MadnessRule.tripleXp => 'Üç Kat XP',
      MadnessRule.hardQuestion => 'Zor Soru',
      MadnessRule.shuffledOptions => 'Şıklar Karıştı',
      MadnessRule.fiftyGift => '50:50 Hediyesi',
      MadnessRule.secondChanceGift => 'İkinci Şans Hediyesi',
      MadnessRule.calmRound => 'Sakin Tur',
    };
  }

  String get description {
    return switch (this) {
      MadnessRule.doubleXp =>
        'Bu soruyu bilirsen temel kazanç 2 kat XP.',
      MadnessRule.tripleXp =>
        'Bu turda doğru cevap 3 kat XP kazandırır.',
      MadnessRule.hardQuestion =>
        'Kategori ne olursa olsun Zor soru gelir.',
      MadnessRule.shuffledOptions =>
        'Cevap seçeneklerinin sırası yeniden karıştırılır.',
      MadnessRule.fiftyGift =>
        'Joker cüzdanına bir 50:50 hakkı eklenir.',
      MadnessRule.secondChanceGift =>
        'Joker cüzdanına bir İkinci Şans hakkı eklenir.',
      MadnessRule.calmRound =>
        'Ekstra kural yok; standart soru ve standart XP.',
    };
  }
}

class MixedMadnessIntroScreen extends StatelessWidget {
  const MixedMadnessIntroScreen({
    required this.questionBank,
    super.key,
  });

  final QuestionBank questionBank;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Karışık Çılgınlık')),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF7C2D12),
              Color(0xFF6D28D9),
              Color(0xFF0F766E),
            ],
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
            children: [
              const Text(
                '🎭🎲⚡',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 67),
              ),
              const SizedBox(height: 10),
              const Text(
                'Her soruda başka bir sürpriz',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  height: 1.1,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 15),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0x18FFFFFF),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: const Color(0x33FFFFFF),
                  ),
                ),
                child: const Text(
                  '15 soruluk turda her sorudan önce rastgele '
                  'bir kural açılır:\n\n'
                  '⚡ Çifte XP   👑 Üç Kat XP\n'
                  '🧠 Zor Soru   🔀 Karışık Şıklar\n'
                  '✂️ 50:50 Hediyesi   🍀 İkinci Şans\n'
                  '🛡️ Sakin Tur\n\n'
                  'Bütün cevaplar genel XP ve istatistiklerine eklenir.',
                  style: TextStyle(
                    color: Color(0xFFF3E8FF),
                    height: 1.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (_) => MixedMadnessGameScreen(
                        questionBank: questionBank,
                      ),
                    ),
                  );
                },
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFFFE082),
                  foregroundColor: const Color(0xFF3A2448),
                ),
                icon: const Icon(Icons.shuffle_rounded),
                label: const Text(
                  'Çılgınlığı Başlat',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MixedMadnessGameScreen extends StatefulWidget {
  const MixedMadnessGameScreen({
    required this.questionBank,
    super.key,
  });

  final QuestionBank questionBank;

  @override
  State<MixedMadnessGameScreen> createState() =>
      _MixedMadnessGameScreenState();
}

class _MixedMadnessGameScreenState
    extends State<MixedMadnessGameScreen> {
  final Random _random = Random();
  final Set<String> _usedQuestionIds = <String>{};
  final JokerWallet _jokers = JokerWallet.starter();

  int _turn = 0;
  int _correct = 0;
  int _wrong = 0;
  int _streak = 0;
  int _bestStreak = 0;
  bool _busy = false;
  bool _finished = false;
  bool _exitDialogOpen = false;

  static const int _questionCount = 15;

  @override
  Widget build(BuildContext context) {
    return PopScope<Object?>(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) unawaited(_confirmExit());
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Karışık Çılgınlık'),
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
                Color(0xFF24122F),
                Color(0xFF7C2D12),
                Color(0xFF0F5661),
              ],
            ),
          ),
          child: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 28),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _madnessScore(
                        '✅',
                        '$_correct',
                        'Doğru',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _madnessScore(
                        '🔥',
                        '$_streak',
                        'Seri',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _madnessScore(
                        '❌',
                        '$_wrong',
                        'Yanlış',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                LinearProgressIndicator(
                  value: _turn / _questionCount,
                  minHeight: 10,
                  backgroundColor: const Color(0x33FFFFFF),
                  color: const Color(0xFFFFE082),
                ),
                const SizedBox(height: 9),
                Text(
                  'Soru ${_turn + 1} / $_questionCount',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFFD8CCEA),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 17),
                Container(
                  padding: const EdgeInsets.all(23),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        '🎭',
                        style: TextStyle(fontSize: 64),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Sıradaki kural gizli',
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 7),
                      const Text(
                        'Soruyu açtığında bu turun sürprizi belli olacak.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 14),
                      JokerWalletMiniBar(wallet: _jokers),
                      const SizedBox(height: 18),
                      FilledButton.icon(
                        onPressed:
                            _busy ? null : _openQuestion,
                        icon: const Icon(Icons.casino_rounded),
                        label: Text(
                          _busy
                              ? 'Kural seçiliyor…'
                              : 'Sürpriz Kuralı Aç',
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                const LiveStreakPill(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _madnessScore(
    String emoji,
    String value,
    String label,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 4,
        vertical: 11,
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
          Text(emoji),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 23,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFFCBC1D6),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openQuestion() async {
    if (_busy || _finished) return;
    setState(() => _busy = true);

    final rule = MadnessRule.values[
        _random.nextInt(MadnessRule.values.length)];

    await _showRule(rule);
    if (!mounted) return;

    if (rule == MadnessRule.fiftyGift) {
      _jokers.fiftyFifty++;
    }

    if (rule == MadnessRule.secondChanceGift) {
      _jokers.secondChance++;
    }

    final category =
        _random.nextInt(GameCategory.values.length);

    final normalDifficulty = _turn < 5
        ? 'Kolay'
        : _turn < 10
            ? 'Orta'
            : 'Zor';

    final preferredDifficulty =
        rule == MadnessRule.hardQuestion
            ? 'Zor'
            : normalDifficulty;

    final multiplier = switch (rule) {
      MadnessRule.doubleXp => 2,
      MadnessRule.tripleXp => 3,
      _ => 1,
    };

    var question = widget.questionBank
        .nextQuestion(
          categoryIndex: category,
          random: _random,
          usedQuestionIds: _usedQuestionIds,
          preferredDifficulty: preferredDifficulty,
        )
        .question;

    if (rule == MadnessRule.shuffledOptions) {
      question = _shuffleQuestion(question);
    }

    final correct = await Navigator.of(context).push<bool>(
          MaterialPageRoute(
            fullscreenDialog: true,
            builder: (_) => QuestionScreen(
              question: question,
              jokers: _jokers,
              riskMode: multiplier > 1,
              xpMultiplier: multiplier,
              onChangeQuestion: (current) async {
                return GameplayBoostQuestionPicker.replacement(
                  questionBank: widget.questionBank,
                  current: current,
                  usedQuestionIds: _usedQuestionIds,
                );
              },
            ),
          ),
        ) ??
        false;

    if (!mounted) return;

    setState(() {
      if (correct) {
        _correct++;
        _streak++;
        _bestStreak = max(_bestStreak, _streak);
      } else {
        _wrong++;
        _streak = 0;
      }
    });

    final gain = await CareerStatsService.recordAnswer(
      categoryIndex: question.categoryIndex,
      difficulty: question.difficulty,
      correct: correct,
      xpMultiplier: multiplier,
    );

    if (mounted) {
      await XpCelebration.show(context, gain);
    }

    if (!mounted) return;

    _turn++;

    if (_turn >= _questionCount) {
      await _finish();
      return;
    }

    setState(() => _busy = false);
  }

  QuizQuestion _shuffleQuestion(
    QuizQuestion question,
  ) {
    final order = List<int>.generate(
      question.options.length,
      (index) => index,
    )..shuffle(_random);

    return QuizQuestion(
      id: question.id,
      categoryIndex: question.categoryIndex,
      text: question.text,
      options: [
        for (final index in order)
          question.options[index],
      ],
      answerIndex: order.indexOf(
        question.answerIndex,
      ),
      difficulty: question.difficulty,
      explanation: question.explanation,
    );
  }

  Future<void> _showRule(
    MadnessRule rule,
  ) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          icon: Text(
            rule.emoji,
            style: const TextStyle(fontSize: 52),
          ),
          title: Text(rule.title),
          content: Text(
            rule.description,
            textAlign: TextAlign.center,
          ),
          actions: [
            FilledButton(
              onPressed: () =>
                  Navigator.pop(dialogContext),
              child: const Text('Soruyu Aç'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _finish() async {
    if (_finished) return;
    _finished = true;

    final bonusXp = max(100, _correct * 9);
    final bonus = await XpProgressService._award(
      bonusXp,
      'Karışık Çılgınlık tamamlandı',
    );

    if (!mounted) return;
    await XpCelebration.show(context, bonus);
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => QuickModeResultScreen(
          title: '🎭 ÇILGINLIK BİTTİ',
          emoji: _correct >= 12 ? '👑⚡' : '🎲',
          score: '$_correct / $_questionCount',
          detail:
              '$_wrong yanlış • En iyi seri $_bestStreak',
          bonusXp: bonusXp,
          replayBuilder: (_) => MixedMadnessGameScreen(
            questionBank: widget.questionBank,
          ),
        ),
      ),
    );
  }

  Future<void> _confirmExit() async {
    if (_exitDialogOpen || !mounted) return;
    _exitDialogOpen = true;

    final exit = await _confirmModeExit(
      context,
      title: 'Karışık Çılgınlıktan çıkılsın mı?',
      message: 'Bu turun mevcut skoru kaydedilmeyecek.',
    );

    _exitDialogOpen = false;

    if (exit && mounted) {
      Navigator.of(context).pop();
    }
  }
}

Widget _setupHero({
  required String emoji,
  required String title,
  required String text,
  required List<Color> colors,
}) {
  return Container(
    padding: const EdgeInsets.all(21),
    decoration: BoxDecoration(
      gradient: LinearGradient(colors: colors),
      borderRadius: BorderRadius.circular(27),
      border: Border.all(
        color: const Color(0x66FFFFFF),
      ),
    ),
    child: Column(
      children: [
        Text(
          emoji,
          style: const TextStyle(fontSize: 52),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 23,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 7),
        Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFFE7E1F0),
            height: 1.35,
          ),
        ),
      ],
    ),
  );
}

Future<bool> _confirmModeExit(
  BuildContext context, {
  required String title,
  required String message,
}) async {
  return await showDialog<bool>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () =>
                    Navigator.pop(dialogContext, false),
                child: const Text('Devam Et'),
              ),
              FilledButton(
                onPressed: () =>
                    Navigator.pop(dialogContext, true),
                child: const Text('Moddan Çık'),
              ),
            ],
          );
        },
      ) ??
      false;
}
