part of 'main.dart';

class LiveDuelScreenText {
  LiveDuelScreenText._();

  static String questionCountLabel(int questionCount) {
    return '$questionCount Soru';
  }

  static String leagueSummary(LiveDuelProfile profile) {
    return '${profile.league.emoji} ${profile.league.title} • '
        '${profile.rating} BR';
  }

  static String queueStatus(int questionCount) {
    return '$questionCount soruluk düello için rakip aranıyor...';
  }
}

class LiveDuelScreen extends StatefulWidget {
  const LiveDuelScreen({super.key});

  @override
  State<LiveDuelScreen> createState() => _LiveDuelScreenState();
}

class _LiveDuelScreenState extends State<LiveDuelScreen> {
  int _selectedQuestionCount = 10;
  bool _loadingProfile = true;
  bool _loadingResume = true;
  bool _startingQueue = false;
  bool _openingResume = false;
  LiveDuelProfile _profile = const LiveDuelProfile();
  LiveDuelResumeMatch? _resumeMatch;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _loadResumeMatch();
  }

  Future<void> _loadProfile() async {
    final profile = await LiveDuelProfileService.load();

    if (!mounted) return;

    setState(() {
      _profile = profile;
      _loadingProfile = false;
    });
  }

  Future<void> _loadResumeMatch() async {
    try {
      final match = await LiveDuelConnectionService.findResumableMatch();

      if (!mounted) return;

      setState(() {
        _resumeMatch = match;
        _loadingResume = false;
      });
    } on LiveDuelConnectionException catch (error) {
      if (!mounted) return;

      setState(() {
        _loadingResume = false;
        _errorMessage = error.message;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _loadingResume = false;
      });
    }
  }

  Future<void> _resumeDuel() async {
    final match = _resumeMatch;
    if (match == null || _openingResume) return;

    setState(() {
      _openingResume = true;
      _errorMessage = null;
    });

    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder:
            (context) => LiveDuelPlayScreen(
              matchId: match.matchId,
              questionCount: match.questionCount,
            ),
      ),
    );

    if (!mounted) return;

    setState(() {
      _openingResume = false;
    });

    await _loadProfile();
    await _loadResumeMatch();
  }

  Future<void> _openLeaderboard() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (context) => const LiveDuelLeaderboardScreen(),
      ),
    );

    if (!mounted) return;
    await _loadProfile();
  }

  Future<void> _startMatchmaking() async {
    if (_startingQueue) return;

    if (_resumeMatch != null) {
      setState(() {
        _errorMessage =
            'Yeni rakip aramadan önce yarım kalan düelloya dönmelisin.';
      });
      return;
    }

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      setState(() {
        _errorMessage = 'Canlı düello için Google hesabıyla giriş yapmalısın.';
      });
      return;
    }

    setState(() {
      _startingQueue = true;
      _errorMessage = null;
    });

    try {
      await LiveDuelMatchmakingService.enterQueue(
        questionCount: _selectedQuestionCount,
      );

      if (!mounted) return;

      await Navigator.of(context).push<void>(
        MaterialPageRoute<void>(
          builder:
              (context) => LiveDuelSearchingScreen(
                questionCount: _selectedQuestionCount,
              ),
        ),
      );

      await _loadProfile();
      await _loadResumeMatch();
    } on LiveDuelMatchmakingException catch (error) {
      if (!mounted) return;

      setState(() {
        _errorMessage = error.message;
      });
    } catch (error, stack) {
      await AppErrorLogService.record(
        source: 'Canlı düello eşleştirme başlangıcı',
        error: error,
        stack: stack,
      );

      if (!mounted) return;

      setState(() {
        _errorMessage = 'Eşleştirme başlatılamadı. Lütfen tekrar dene.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _startingQueue = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Canlı Düello')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child:
                    _loadingProfile
                        ? const Center(child: CircularProgressIndicator())
                        : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Rekabet Profilin',
                              style: theme.textTheme.titleMedium,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              LiveDuelScreenText.leagueSummary(_profile),
                              style: theme.textTheme.headlineSmall,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _profile.placementsComplete
                                  ? '${_profile.matchesPlayed} dereceli maç'
                                  : 'Yerleştirme maçları: '
                                      '${_profile.placementMatchesRemaining} kaldı',
                            ),
                            const SizedBox(height: 14),
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton.tonalIcon(
                                onPressed: _openLeaderboard,
                                icon: const Icon(Icons.emoji_events_rounded),
                                label: const Text('Lig ve Sıralama'),
                              ),
                            ),
                          ],
                        ),
              ),
            ),
            if (_loadingResume) ...[
              const SizedBox(height: 16),
              const LinearProgressIndicator(),
            ] else if (_resumeMatch != null) ...[
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.restore),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Yarım Kalan Düello',
                              style: theme.textTheme.titleMedium,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '${_resumeMatch!.questionCount} soruluk maçın devam ediyor.',
                      ),
                      const SizedBox(height: 14),
                      FilledButton.icon(
                        onPressed: _openingResume ? null : _resumeDuel,
                        icon:
                            _openingResume
                                ? const SizedBox.square(
                                  dimension: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                                : const Icon(Icons.play_arrow),
                        label: const Text('Maça Dön'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),
            Text('Düello Uzunluğu', style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            const Text(
              'Seninle aynı soru sayısını seçen ve BR puanı '
              'yakın olan bir rakip aranır.',
            ),
            const SizedBox(height: 18),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: LiveDuelMatchmakingPolicy.questionCountOptions
                  .map((questionCount) {
                    return ChoiceChip(
                      label: Text(
                        LiveDuelScreenText.questionCountLabel(questionCount),
                      ),
                      selected: _selectedQuestionCount == questionCount,
                      onSelected:
                          _startingQueue || _resumeMatch != null
                              ? null
                              : (selected) {
                                if (!selected) return;

                                setState(() {
                                  _selectedQuestionCount = questionCount;
                                  _errorMessage = null;
                                });
                              },
                    );
                  })
                  .toList(growable: false),
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 18),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.error_outline, color: theme.colorScheme.error),
                      const SizedBox(width: 10),
                      Expanded(child: Text(_errorMessage!)),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 28),
            FilledButton.icon(
              onPressed:
                  _startingQueue || _resumeMatch != null
                      ? null
                      : _startMatchmaking,
              icon:
                  _startingQueue
                      ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                      : const Icon(Icons.sports_kabaddi),
              label: Text(
                _startingQueue
                    ? 'Sıraya Giriliyor...'
                    : _resumeMatch != null
                    ? 'Önce Yarım Maça Dön'
                    : 'Rakip Bul',
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Canlı düello maçları BR puanını ve ligini etkiler. '
              'Pasaport ilerlemesini etkilemez.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class LiveDuelSearchingScreen extends StatefulWidget {
  const LiveDuelSearchingScreen({required this.questionCount, super.key});

  final int questionCount;

  @override
  State<LiveDuelSearchingScreen> createState() =>
      _LiveDuelSearchingScreenState();
}

class _LiveDuelSearchingScreenState extends State<LiveDuelSearchingScreen> {
  StreamSubscription<LiveDuelQueueEntry?>? _subscription;
  Timer? _retryTimer;
  bool _cancelling = false;
  bool _matchHandled = false;
  String? _statusMessage;

  @override
  void initState() {
    super.initState();
    _listenQueue();

    _retryTimer = Timer.periodic(
      const Duration(seconds: 4),
      (_) => _retryMatch(),
    );
  }

  void _listenQueue() {
    _subscription = LiveDuelMatchmakingService.watchOwnQueue().listen(
      (entry) {
        if (!mounted || entry == null) return;

        if (entry.matched && !_matchHandled) {
          _matchHandled = true;
          _openMatchFound(entry.matchId!);
          return;
        }

        if (entry.status == LiveDuelQueueStatus.cancelled) {
          setState(() {
            _statusMessage = 'Eşleştirme iptal edildi.';
          });
        }
      },
      onError: (Object error, StackTrace stack) async {
        await AppErrorLogService.record(
          source: 'Canlı düello kuyruk takibi',
          error: error,
          stack: stack,
        );

        if (!mounted) return;

        setState(() {
          _statusMessage = 'Bağlantı kontrol ediliyor...';
        });
      },
    );
  }

  Future<void> _retryMatch() async {
    if (_matchHandled || _cancelling) return;

    try {
      final matchId = await LiveDuelMatchmakingService.tryMatch();

      if (matchId != null && matchId.isNotEmpty && !_matchHandled) {
        _matchHandled = true;
        await _openMatchFound(matchId);
      }
    } catch (_) {
      // Periyodik deneme ekranı kesmemeli.
    }
  }

  Future<void> _openMatchFound(String matchId) async {
    _retryTimer?.cancel();

    if (!mounted) return;

    await Navigator.of(context).pushReplacement<void, void>(
      MaterialPageRoute<void>(
        builder:
            (context) => LiveDuelMatchFoundScreen(
              matchId: matchId,
              questionCount: widget.questionCount,
            ),
      ),
    );
  }

  Future<void> _cancel() async {
    if (_cancelling || _matchHandled) return;

    setState(() {
      _cancelling = true;
    });

    try {
      await LiveDuelMatchmakingService.cancelQueue();

      if (!mounted) return;

      Navigator.of(context).pop();
    } on LiveDuelMatchmakingException catch (error) {
      if (!mounted) return;

      setState(() {
        _statusMessage = error.message;
        _cancelling = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _statusMessage = 'Arama iptal edilemedi. Tekrar dene.';
        _cancelling = false;
      });
    }
  }

  @override
  void dispose() {
    _retryTimer?.cancel();
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _cancel();
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('Rakip Aranıyor'),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox.square(
                  dimension: 84,
                  child: CircularProgressIndicator(strokeWidth: 8),
                ),
                const SizedBox(height: 30),
                Text(
                  LiveDuelScreenText.queueStatus(widget.questionCount),
                  style: theme.textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                const Text(
                  'Önce yakın BR puanındaki oyuncular aranıyor.',
                  textAlign: TextAlign.center,
                ),
                if (_statusMessage != null) ...[
                  const SizedBox(height: 18),
                  Text(_statusMessage!, textAlign: TextAlign.center),
                ],
                const SizedBox(height: 36),
                OutlinedButton.icon(
                  onPressed: _cancelling ? null : _cancel,
                  icon: const Icon(Icons.close),
                  label: Text(
                    _cancelling ? 'İptal Ediliyor...' : 'Aramayı İptal Et',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class LiveDuelMatchFoundScreen extends StatefulWidget {
  const LiveDuelMatchFoundScreen({
    required this.matchId,
    required this.questionCount,
    super.key,
  });

  final String matchId;
  final int questionCount;

  @override
  State<LiveDuelMatchFoundScreen> createState() =>
      _LiveDuelMatchFoundScreenState();
}

class _LiveDuelMatchFoundScreenState extends State<LiveDuelMatchFoundScreen> {
  int _countdown = 3;
  Timer? _timer;
  bool _openingMatch = false;

  @override
  void initState() {
    super.initState();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;

      if (_countdown <= 1) {
        timer.cancel();

        setState(() {
          _countdown = 0;
        });

        Future<void>.delayed(const Duration(milliseconds: 450), _openMatch);
        return;
      }

      setState(() {
        _countdown--;
      });
    });
  }

  Future<void> _openMatch() async {
    if (!mounted || _openingMatch) return;

    _openingMatch = true;

    await Navigator.of(context).pushReplacement<void, void>(
      MaterialPageRoute<void>(
        builder:
            (context) => LiveDuelPlayScreen(
              matchId: widget.matchId,
              questionCount: widget.questionCount,
            ),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(26),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.flash_on, size: 84),
                const SizedBox(height: 20),
                Text('Rakip Bulundu!', style: theme.textTheme.headlineMedium),
                const SizedBox(height: 10),
                Text(
                  '${widget.questionCount} soruluk düello',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 34),
                Text(
                  _countdown > 0 ? '$_countdown' : 'Hazır!',
                  style: theme.textTheme.displayLarge,
                ),
                const SizedBox(height: 26),
                Text(
                  _countdown > 0 ? 'Maç hazırlanıyor...' : 'Düello başlıyor!',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
