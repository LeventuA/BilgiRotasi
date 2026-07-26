part of 'main.dart';

class LiveDuelPlayException implements Exception {
  const LiveDuelPlayException(this.message);

  final String message;

  @override
  String toString() => message;
}

enum LiveDuelOutcome { victory, draw, defeat }

class LiveDuelResultCalculator {
  LiveDuelResultCalculator._();

  static LiveDuelOutcome outcome({
    required LiveDuelPlayerProgress own,
    required LiveDuelPlayerProgress opponent,
  }) {
    final comparison = own.correctCount.compareTo(opponent.correctCount);
    if (comparison > 0) return LiveDuelOutcome.victory;
    if (comparison < 0) return LiveDuelOutcome.defeat;
    return LiveDuelOutcome.draw;
  }

  static String title(LiveDuelOutcome outcome) => switch (outcome) {
    LiveDuelOutcome.victory => 'Düelloyu Kazandın!',
    LiveDuelOutcome.draw => 'Düello Berabere!',
    LiveDuelOutcome.defeat => 'Bu Düelloyu Rakibin Kazandı',
  };

  static String description(LiveDuelOutcome outcome) => switch (outcome) {
    LiveDuelOutcome.victory =>
      'Bilgin, hızın ve soğukkanlılığın rakibini geçti.',
    LiveDuelOutcome.draw => 'İki taraf da aynı sayıda doğru cevap verdi.',
    LiveDuelOutcome.defeat => 'Rövanş için Bilgi Rotası seni bekliyor.',
  };
}

class LiveDuelMatchViewData {
  const LiveDuelMatchViewData({
    required this.questionCount,
    required this.questionIds,
    required this.playerUids,
    required this.playerNames,
  });

  final int questionCount;
  final List<String> questionIds;
  final List<String> playerUids;
  final Map<String, String> playerNames;

  factory LiveDuelMatchViewData.fromMap(Map<String, dynamic> data) {
    final questionCount = (data['questionCount'] as num?)?.toInt() ?? 0;
    final questionIds = LiveDuelQuestionSetService.questionIdsFromMatchData(
      data,
    );

    final rawPlayerUids = data['playerUids'];
    final playerUids =
        rawPlayerUids is List
            ? rawPlayerUids
                .map((item) => item.toString().trim())
                .where((item) => item.isNotEmpty)
                .toList(growable: false)
            : const <String>[];

    if (!LiveDuelMatchmakingPolicy.supportsQuestionCount(questionCount)) {
      throw const LiveDuelPlayException('Canlı düello soru sayısı geçersiz.');
    }

    if (questionIds.length != questionCount) {
      throw const LiveDuelPlayException(
        'Maçın soru sayısı ile soru listesi uyuşmuyor.',
      );
    }

    if (questionIds.toSet().length != questionIds.length) {
      throw const LiveDuelPlayException(
        'Maç soru listesinde tekrar bulunuyor.',
      );
    }

    if (playerUids.length != 2 || playerUids.toSet().length != 2) {
      throw const LiveDuelPlayException(
        'Canlı düello oyuncu bilgileri geçersiz.',
      );
    }

    final playerNames = <String, String>{};
    final rawPlayers = data['players'];

    if (rawPlayers is List) {
      for (final item in rawPlayers) {
        if (item is! Map) continue;

        final player = Map<String, dynamic>.from(item);
        final uid = player['uid']?.toString().trim() ?? '';
        final displayName = player['displayName']?.toString().trim() ?? '';

        if (uid.isNotEmpty) {
          playerNames[uid] =
              displayName.isEmpty ? 'Bilgi Yolcusu' : displayName;
        }
      }
    }

    for (final uid in playerUids) {
      playerNames.putIfAbsent(uid, () => 'Bilgi Yolcusu');
    }

    return LiveDuelMatchViewData(
      questionCount: questionCount,
      questionIds: List<String>.unmodifiable(questionIds),
      playerUids: List<String>.unmodifiable(playerUids),
      playerNames: Map<String, String>.unmodifiable(playerNames),
    );
  }

  String opponentUidFor(String ownUid) {
    if (!playerUids.contains(ownUid)) {
      throw const LiveDuelPlayException('Bu maçın oyuncusu değilsin.');
    }

    return playerUids.firstWhere((uid) => uid != ownUid);
  }

  String playerName(String uid) {
    return playerNames[uid] ?? 'Bilgi Yolcusu';
  }
}

class LiveDuelPlayScreen extends StatefulWidget {
  const LiveDuelPlayScreen({
    required this.matchId,
    required this.questionCount,
    super.key,
  });

  final String matchId;
  final int questionCount;

  @override
  State<LiveDuelPlayScreen> createState() => _LiveDuelPlayScreenState();
}

class _LiveDuelPlayScreenState extends State<LiveDuelPlayScreen>
    with WidgetsBindingObserver {
  StreamSubscription<List<LiveDuelPlayerProgress>>? _progressSubscription;
  StreamSubscription<List<LiveDuelPresence>>? _presenceSubscription;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>?
  _matchSubscription;
  Timer? _heartbeatTimer;
  Timer? _resolutionTimer;
  Timer? _countdownTimer;

  User? _user;
  LiveDuelMatchViewData? _match;
  LiveDuelQuestionSet? _questionSet;
  LiveDuelPlayerProgress? _ownProgress;
  LiveDuelPlayerProgress? _opponentProgress;
  LiveDuelPresence? _opponentPresence;
  LiveDuelOwnResultAward? _ownAward;

  bool _loading = true;
  bool _submitting = false;
  bool _finalizingResult = false;
  bool _leavingMatch = false;
  int _questionIndex = 0;
  int? _selectedOptionIndex;
  bool? _selectedAnswerCorrect;
  String? _errorMessage;
  String? _resultError;
  String? _connectionMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeMatch();
  }

  Future<void> _initializeMatch() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        throw const LiveDuelPlayException(
          'Canlı düello için Google hesabıyla giriş yapmalısın.',
        );
      }

      final matchSnapshot =
          await LiveDuelMatchmakingService.watchMatch(widget.matchId).first;

      if (!matchSnapshot.exists) {
        throw const LiveDuelPlayException('Canlı düello maçı bulunamadı.');
      }

      final matchData = matchSnapshot.data() ?? <String, dynamic>{};
      final match = LiveDuelMatchViewData.fromMap(matchData);

      if (match.questionCount != widget.questionCount) {
        throw const LiveDuelPlayException('Eşleşme soru sayısı uyuşmuyor.');
      }

      final questionSet = await LiveDuelQuestionSetService.resolveQuestionIds(
        match.questionIds,
      );

      await LiveDuelProgressService.initializeProgress(matchId: widget.matchId);
      await LiveDuelConnectionService.markActive(matchId: widget.matchId);

      if (!mounted) return;

      setState(() {
        _user = user;
        _match = match;
        _questionSet = questionSet;
        _loading = false;
      });

      _progressSubscription = LiveDuelProgressService.watchMatchProgress(
        widget.matchId,
      ).listen(
        _handleProgress,
        onError: (Object error, StackTrace stack) {
          unawaited(
            AppErrorLogService.record(
              source: 'Canlı düello ilerleme takibi',
              error: error,
              stack: stack,
            ),
          );

          if (!mounted) return;
          setState(() {
            _errorMessage = 'Canlı skor bağlantısı geçici olarak kesildi.';
          });
        },
      );

      _presenceSubscription = LiveDuelConnectionService.watchPresence(
        widget.matchId,
      ).listen(
        _handlePresence,
        onError: (Object error, StackTrace stack) {
          unawaited(
            AppErrorLogService.record(
              source: 'Canlı düello bağlantı takibi',
              error: error,
              stack: stack,
            ),
          );

          if (!mounted) return;
          setState(() {
            _connectionMessage = 'Rakip bağlantısı kontrol ediliyor...';
          });
        },
      );

      _matchSubscription = LiveDuelMatchmakingService.watchMatch(
        widget.matchId,
      ).listen(_handleMatchSnapshot);

      _startConnectionTimers();

      if (matchData['resultProcessed'] == true) {
        unawaited(_loadProcessedResult());
      }
    } on LiveDuelPlayException catch (error) {
      _showFatalError(error.message);
    } on LiveDuelQuestionSetException catch (error) {
      _showFatalError(error.message);
    } on LiveDuelProgressException catch (error) {
      _showFatalError(error.message);
    } on LiveDuelMatchmakingException catch (error) {
      _showFatalError(error.message);
    } on LiveDuelConnectionException catch (error) {
      _showFatalError(error.message);
    } catch (error, stack) {
      await AppErrorLogService.record(
        source: 'Canlı düello soru ekranı hazırlığı',
        error: error,
        stack: stack,
      );

      _showFatalError('Canlı düello hazırlanamadı. Lütfen tekrar dene.');
    }
  }

  void _startConnectionTimers() {
    _heartbeatTimer?.cancel();
    _resolutionTimer?.cancel();
    _countdownTimer?.cancel();

    _heartbeatTimer = Timer.periodic(
      LiveDuelConnectionPolicy.heartbeatInterval,
      (_) {
        if (_ownAward != null ||
            _leavingMatch ||
            WidgetsBinding.instance.lifecycleState !=
                AppLifecycleState.resumed) {
          return;
        }
        unawaited(_markActiveQuietly());
      },
    );

    _resolutionTimer = Timer.periodic(
      LiveDuelConnectionPolicy.resolutionInterval,
      (_) {
        if (_ownAward == null && !_leavingMatch) {
          unawaited(_tryResolveForfeit());
        }
      },
    );

    _countdownTimer = Timer.periodic(
      LiveDuelConnectionPolicy.countdownInterval,
      (_) {
        if (mounted && _opponentPresence != null) {
          setState(() {});
        }
      },
    );
  }

  Future<void> _markActiveQuietly() async {
    try {
      await LiveDuelConnectionService.markActive(matchId: widget.matchId);
      if (!mounted) return;
      setState(() {
        _connectionMessage = null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _connectionMessage = 'Bağlantın yeniden kurulmaya çalışılıyor...';
      });
    }
  }

  Future<void> _markBackgroundQuietly() async {
    if (_ownAward != null || _leavingMatch) return;

    try {
      await LiveDuelConnectionService.markBackground(matchId: widget.matchId);
    } catch (_) {
      // Yaşam döngüsü değişimi ekranı kilitlememeli.
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_ownAward != null || _leavingMatch) return;

    if (state == AppLifecycleState.resumed) {
      unawaited(_markActiveQuietly());
      unawaited(_tryResolveForfeit());
    } else if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      unawaited(_markBackgroundQuietly());
    }
  }

  void _showFatalError(String message) {
    if (!mounted) return;

    setState(() {
      _loading = false;
      _errorMessage = message;
    });
  }

  LiveDuelPlayerProgress? _findProgress(
    List<LiveDuelPlayerProgress> progressList,
    String uid,
  ) {
    for (final progress in progressList) {
      if (progress.uid == uid) return progress;
    }
    return null;
  }

  LiveDuelPresence? _findPresence(
    List<LiveDuelPresence> presences,
    String uid,
  ) {
    for (final presence in presences) {
      if (presence.uid == uid) return presence;
    }
    return null;
  }

  void _handleProgress(List<LiveDuelPlayerProgress> progressList) {
    final user = _user;
    final match = _match;

    if (!mounted || user == null || match == null) return;

    final opponentUid = match.opponentUidFor(user.uid);
    final own = _findProgress(progressList, user.uid);
    final opponent = _findProgress(progressList, opponentUid);

    setState(() {
      _ownProgress = own;
      _opponentProgress = opponent;

      if (!_submitting && own != null) {
        _questionIndex = own.answeredCount;
      }
    });

    if (own?.finished == true && opponent?.finished == true) {
      unawaited(_finalizeResult());
    }
  }

  void _handlePresence(List<LiveDuelPresence> presences) {
    final user = _user;
    final match = _match;
    if (!mounted || user == null || match == null) return;

    final opponentUid = match.opponentUidFor(user.uid);
    final opponent = _findPresence(presences, opponentUid);

    setState(() {
      _opponentPresence = opponent;
    });

    if (opponent != null &&
        LiveDuelConnectionPolicy.canForfeit(opponent, DateTime.now().toUtc())) {
      unawaited(_tryResolveForfeit());
    }
  }

  void _handleMatchSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data();
    if (!mounted || data == null) return;

    if (data['resultProcessed'] == true && _ownAward == null) {
      unawaited(_loadProcessedResult());
    }
  }

  Future<void> _loadProcessedResult() async {
    if (_finalizingResult || _ownAward != null) return;

    setState(() {
      _finalizingResult = true;
      _resultError = null;
    });

    try {
      final award = await LiveDuelResultService.applyOwnResult(
        matchId: widget.matchId,
      );

      if (!mounted) return;

      setState(() {
        _ownAward = award;
        _finalizingResult = false;
      });
    } on LiveDuelResultException catch (error) {
      if (!mounted) return;
      setState(() {
        _resultError = error.message;
        _finalizingResult = false;
      });
    } catch (error, stack) {
      await AppErrorLogService.record(
        source: 'Canlı düello işlenmiş sonuç yükleme',
        error: error,
        stack: stack,
      );

      if (!mounted) return;
      setState(() {
        _resultError = 'Maç sonucu yüklenemedi. Tekrar dene.';
        _finalizingResult = false;
      });
    }
  }

  Future<void> _tryResolveForfeit() async {
    if (_finalizingResult || _ownAward != null || _leavingMatch) {
      return;
    }

    try {
      final completed = await LiveDuelConnectionService.resolveForfeit(
        matchId: widget.matchId,
      );

      if (completed == null) return;

      await _loadProcessedResult();
    } on LiveDuelConnectionException {
      // Hükmen sonuç şartı henüz oluşmamış olabilir.
    } catch (_) {
      // Periyodik kontrol ekranda gürültü oluşturmamalı.
    }
  }

  Future<void> _finalizeResult() async {
    if (_finalizingResult || _ownAward != null) return;

    setState(() {
      _finalizingResult = true;
      _resultError = null;
    });

    try {
      await LiveDuelResultService.finalizeMatch(matchId: widget.matchId);
      final award = await LiveDuelResultService.applyOwnResult(
        matchId: widget.matchId,
      );

      if (!mounted) return;

      setState(() {
        _ownAward = award;
        _finalizingResult = false;
      });
    } on LiveDuelResultException catch (error) {
      if (!mounted) return;

      setState(() {
        _resultError = error.message;
        _finalizingResult = false;
      });
    } catch (error, stack) {
      await AppErrorLogService.record(
        source: 'Canlı düello sonuç işleme',
        error: error,
        stack: stack,
      );

      if (!mounted) return;

      setState(() {
        _resultError =
            'Maç sonucu işlenemedi. Bağlantını kontrol edip tekrar dene.';
        _finalizingResult = false;
      });
    }
  }

  bool get _ownFinished => _ownProgress?.finished == true;

  bool get _opponentFinished => _opponentProgress?.finished == true;

  bool get _bothFinished => _ownFinished && _opponentFinished;

  Future<void> _submitAnswer(int optionIndex) async {
    final questionSet = _questionSet;

    if (_submitting ||
        questionSet == null ||
        _ownFinished ||
        _questionIndex < 0 ||
        _questionIndex >= questionSet.length) {
      return;
    }

    final question = questionSet.questions[_questionIndex];
    final correct = optionIndex == question.answerIndex;

    setState(() {
      _submitting = true;
      _selectedOptionIndex = optionIndex;
      _selectedAnswerCorrect = correct;
      _errorMessage = null;
    });

    try {
      final next = await LiveDuelProgressService.submitAnswer(
        matchId: widget.matchId,
        questionId: question.id,
        correct: correct,
      );

      if (!mounted) return;

      setState(() {
        _ownProgress = next;
      });

      await Future<void>.delayed(const Duration(milliseconds: 850));

      if (!mounted) return;

      setState(() {
        _questionIndex = next.answeredCount;
        _selectedOptionIndex = null;
        _selectedAnswerCorrect = null;
        _submitting = false;
      });
    } on LiveDuelProgressException catch (error) {
      if (!mounted) return;

      setState(() {
        _errorMessage = error.message;
        _selectedOptionIndex = null;
        _selectedAnswerCorrect = null;
        _submitting = false;
      });
    } catch (error, stack) {
      await AppErrorLogService.record(
        source: 'Canlı düello cevap gönderme',
        error: error,
        stack: stack,
      );

      if (!mounted) return;

      setState(() {
        _errorMessage =
            'Cevap gönderilemedi. Bağlantını kontrol edip tekrar dene.';
        _selectedOptionIndex = null;
        _selectedAnswerCorrect = null;
        _submitting = false;
      });
    }
  }

  Future<void> _confirmLeave() async {
    if (_leavingMatch || _ownAward != null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: const Text('Düellodan Ayrıl?'),
            content: const Text(
              'Maçtan ayrılırsan hükmen yenilmiş sayılacak '
              've BR puanın buna göre güncellenecek.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: const Text('Maça Dön'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: const Text('Ayrıl ve Yenilgiyi Kabul Et'),
              ),
            ],
          ),
    );

    if (confirmed != true || !mounted) return;

    setState(() {
      _leavingMatch = true;
      _errorMessage = null;
    });

    try {
      await LiveDuelConnectionService.requestLeave(matchId: widget.matchId);
      await LiveDuelConnectionService.resolveForfeit(matchId: widget.matchId);
      await LiveDuelResultService.applyOwnResult(matchId: widget.matchId);

      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (error, stack) {
      await AppErrorLogService.record(
        source: 'Canlı düellodan ayrılma',
        error: error,
        stack: stack,
      );

      if (!mounted) return;
      setState(() {
        _leavingMatch = false;
        _errorMessage =
            'Maçtan ayrılma kaydedilemedi. İnternet bağlantını kontrol edip tekrar dene.';
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _heartbeatTimer?.cancel();
    _resolutionTimer?.cancel();
    _countdownTimer?.cancel();
    _progressSubscription?.cancel();
    _presenceSubscription?.cancel();
    _matchSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fatal = !_loading && _questionSet == null && _errorMessage != null;
    final canLeave = _ownAward != null || fatal;

    return PopScope(
      canPop: canLeave,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop || !mounted) return;
        unawaited(_confirmLeave());
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: true,
          title: const Text('Canlı Düello'),
        ),
        body: SafeArea(
          child: Stack(
            children: [
              _buildBody(),
              if (_leavingMatch)
                const Positioned.fill(
                  child: ColoredBox(
                    color: Color(0x66000000),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 18),
            Text('Ortak sorular hazırlanıyor...'),
          ],
        ),
      );
    }

    final user = _user;
    final match = _match;
    final questionSet = _questionSet;

    if (user == null || match == null || questionSet == null) {
      return _FatalDuelErrorView(
        message: _errorMessage ?? 'Canlı düello bilgileri yüklenemedi.',
      );
    }

    final opponentUid = match.opponentUidFor(user.uid);
    final own = _ownProgress ?? LiveDuelPlayerProgress.initial(user.uid);
    final opponent =
        _opponentProgress ?? LiveDuelPlayerProgress.initial(opponentUid);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Expanded(
              child: _LiveDuelScoreCard(
                name: match.playerName(user.uid),
                progress: own,
                questionCount: match.questionCount,
                ownPlayer: true,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _LiveDuelScoreCard(
                name: match.playerName(opponentUid),
                progress: opponent,
                questionCount: match.questionCount,
                ownPlayer: false,
              ),
            ),
          ],
        ),
        if (_buildConnectionBanner() case final banner?) ...[
          const SizedBox(height: 12),
          banner,
        ],
        if (_connectionMessage != null) ...[
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  const Icon(Icons.wifi_off),
                  const SizedBox(width: 10),
                  Expanded(child: Text(_connectionMessage!)),
                ],
              ),
            ),
          ),
        ],
        if (_errorMessage != null) ...[
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.error_outline,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: Text(_errorMessage!)),
                ],
              ),
            ),
          ),
        ],
        const SizedBox(height: 18),
        if (_ownAward != null)
          _buildResultView(_ownAward!)
        else if (_bothFinished)
          _buildFinalizingView()
        else if (_ownFinished)
          _buildWaitingView(opponent, match.questionCount)
        else
          _buildQuestionView(questionSet),
      ],
    );
  }

  Widget? _buildConnectionBanner() {
    final presence = _opponentPresence;
    if (presence == null || presence.state == LiveDuelPresenceState.active) {
      return null;
    }

    final now = DateTime.now().toUtc();
    final remaining = LiveDuelConnectionPolicy.remaining(presence, now);
    final seconds = remaining.inSeconds + 1;

    final text =
        presence.state == LiveDuelPresenceState.left
            ? 'Rakibin maçtan ayrıldı. Hükmen sonuç işleniyor.'
            : remaining > Duration.zero
            ? 'Rakibin bağlantısı kesildi. '
                '$seconds saniye içinde dönebilir.'
            : 'Rakibin geri dönüş süresi doldu. '
                'Hükmen sonuç işleniyor.';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            const Icon(Icons.signal_wifi_connected_no_internet_4),
            const SizedBox(width: 10),
            Expanded(child: Text(text)),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionView(LiveDuelQuestionSet questionSet) {
    final index = _questionIndex.clamp(0, questionSet.length - 1);

    final question = questionSet.questions[index];
    final categoryLabel =
        question.categoryIndex >= 0 &&
                question.categoryIndex < GameCategory.values.length
            ? GameCategory.values[question.categoryIndex].label
            : 'Karışık';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Soru ${index + 1}/${questionSet.length}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            Chip(label: Text(categoryLabel)),
            const SizedBox(width: 6),
            Chip(label: Text(question.difficulty)),
          ],
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              question.text,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
          ),
        ),
        const SizedBox(height: 14),
        ...List<Widget>.generate(
          question.options.length,
          (optionIndex) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _LiveDuelAnswerOption(
              index: optionIndex,
              text: question.options[optionIndex],
              answerIndex: question.answerIndex,
              selectedIndex: _selectedOptionIndex,
              enabled: !_submitting,
              onTap: () => _submitAnswer(optionIndex),
            ),
          ),
        ),
        if (_selectedOptionIndex != null) ...[
          const SizedBox(height: 4),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                children: [
                  Text(
                    _selectedAnswerCorrect == true ? 'Doğru!' : 'Yanlış!',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  if (_selectedAnswerCorrect != true) ...[
                    const SizedBox(height: 6),
                    Text(
                      'Doğru cevap: '
                      '${question.options[question.answerIndex]}',
                      textAlign: TextAlign.center,
                    ),
                  ],
                  if (question.explanation.trim().isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(question.explanation, textAlign: TextAlign.center),
                  ],
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildWaitingView(LiveDuelPlayerProgress opponent, int questionCount) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox.square(
              dimension: 58,
              child: CircularProgressIndicator(strokeWidth: 6),
            ),
            const SizedBox(height: 22),
            Text(
              'Soruları Tamamladın!',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'Rakibin cevapları bekleniyor: '
              '${opponent.answeredCount}/$questionCount',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: opponent.progressRatio(questionCount),
              minHeight: 10,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinalizingView() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            if (_resultError == null) ...[
              const SizedBox.square(
                dimension: 58,
                child: CircularProgressIndicator(strokeWidth: 6),
              ),
              const SizedBox(height: 22),
              Text(
                'Maç Sonucu Kesinleştiriliyor',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              const Text(
                'Skorlar ve BR değişimi güvenli biçimde işleniyor.',
                textAlign: TextAlign.center,
              ),
            ] else ...[
              Icon(
                Icons.cloud_off,
                size: 62,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(_resultError!, textAlign: TextAlign.center),
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed:
                    _finalizingResult
                        ? null
                        : () {
                          if (_bothFinished) {
                            _finalizeResult();
                          } else {
                            _tryResolveForfeit();
                          }
                        },
                icon: const Icon(Icons.refresh),
                label: const Text('Sonucu Tekrar İşle'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildResultView(LiveDuelOwnResultAward award) {
    final user = _user!;
    final opponentUid = award.match.opponentUidFor(user.uid);
    final ownScore = award.match.scoreFor(user.uid);
    final opponentScore = award.match.scoreFor(opponentUid);
    final outcome = switch (award.result) {
      LiveDuelResult.win => LiveDuelOutcome.victory,
      LiveDuelResult.draw => LiveDuelOutcome.draw,
      LiveDuelResult.loss => LiveDuelOutcome.defeat,
    };
    final icon = switch (outcome) {
      LiveDuelOutcome.victory => Icons.emoji_events,
      LiveDuelOutcome.draw => Icons.handshake,
      LiveDuelOutcome.defeat => Icons.replay,
    };
    final change = award.ratingChange;
    final deltaLabel =
        change.delta > 0 ? '+${change.delta} BR' : '${change.delta} BR';

    final title =
        award.match.forfeited
            ? award.result == LiveDuelResult.win
                ? 'Hükmen Kazandın!'
                : 'Hükmen Kaybettin'
            : LiveDuelResultCalculator.title(outcome);

    final description =
        award.match.forfeited
            ? award.result == LiveDuelResult.win
                ? 'Rakibin geri dönmedi veya maçtan ayrıldı.'
                : 'Maçtan ayrıldığın ya da süresinde dönmediğin için yenildin.'
            : LiveDuelResultCalculator.description(outcome);

    String? leagueMessage;
    if (change.promoted) {
      leagueMessage =
          '${change.newLeague.emoji} '
          '${change.newLeague.title} ligine yükseldin!';
    } else if (change.relegated) {
      leagueMessage =
          '${change.newLeague.emoji} '
          '${change.newLeague.title} ligine düştün.';
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(icon, size: 72),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(description, textAlign: TextAlign.center),
            const SizedBox(height: 22),
            Text(
              '$ownScore - $opponentScore',
              style: Theme.of(context).textTheme.displaySmall,
            ),
            const SizedBox(height: 6),
            Text(
              award.match.forfeited
                  ? 'Ayrılma anındaki skor'
                  : 'Doğru cevap skoru',
            ),
            const SizedBox(height: 20),
            Chip(
              avatar: Icon(
                change.delta >= 0 ? Icons.trending_up : Icons.trending_down,
              ),
              label: Text(
                deltaLabel,
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${change.oldRating} BR → '
              '${change.newRating} BR',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (leagueMessage != null) ...[
              const SizedBox(height: 10),
              Text(
                leagueMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ],
            if (award.alreadyApplied) ...[
              const SizedBox(height: 10),
              const Text(
                'Bu maçın BR sonucu daha önce işlendi; tekrar puan eklenmedi.',
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Düello Menüsüne Dön'),
            ),
          ],
        ),
      ),
    );
  }
}

class _LiveDuelScoreCard extends StatelessWidget {
  const _LiveDuelScoreCard({
    required this.name,
    required this.progress,
    required this.questionCount,
    required this.ownPlayer,
  });

  final String name;
  final LiveDuelPlayerProgress progress;
  final int questionCount;
  final bool ownPlayer;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Icon(ownPlayer ? Icons.person : Icons.sports_kabaddi, size: 20),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    ownPlayer ? 'Sen' : name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              '${progress.correctCount} Doğru',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text('${progress.answeredCount}/$questionCount soru'),
            const SizedBox(height: 9),
            LinearProgressIndicator(
              value: progress.progressRatio(questionCount),
              minHeight: 8,
            ),
          ],
        ),
      ),
    );
  }
}

class _LiveDuelAnswerOption extends StatelessWidget {
  const _LiveDuelAnswerOption({
    required this.index,
    required this.text,
    required this.answerIndex,
    required this.selectedIndex,
    required this.enabled,
    required this.onTap,
  });

  final int index;
  final String text;
  final int answerIndex;
  final int? selectedIndex;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final revealing = selectedIndex != null;
    final correctOption = revealing && index == answerIndex;
    final wrongSelection =
        revealing && index == selectedIndex && index != answerIndex;

    var borderColor = colorScheme.outlineVariant;
    var backgroundColor = colorScheme.surfaceContainerHighest.withOpacity(0.45);
    IconData? trailingIcon;
    Color? trailingColor;

    if (correctOption) {
      borderColor = Colors.green.shade700;
      backgroundColor = Colors.green.withOpacity(0.14);
      trailingIcon = Icons.check_circle;
      trailingColor = Colors.green.shade700;
    } else if (wrongSelection) {
      borderColor = colorScheme.error;
      backgroundColor = colorScheme.errorContainer.withOpacity(0.55);
      trailingIcon = Icons.cancel;
      trailingColor = colorScheme.error;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: borderColor,
          width: correctOption || wrongSelection ? 2 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled && !revealing ? onTap : null,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    String.fromCharCode(65 + index),
                    style: TextStyle(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    text,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (trailingIcon != null)
                  Icon(trailingIcon, color: trailingColor),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FatalDuelErrorView extends StatelessWidget {
  const _FatalDuelErrorView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 62,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(height: 16),
                Text(message, textAlign: TextAlign.center),
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Geri Dön'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
