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

class _LiveDuelPlayScreenState extends State<LiveDuelPlayScreen> {
  StreamSubscription<List<LiveDuelPlayerProgress>>? _progressSubscription;

  User? _user;
  LiveDuelMatchViewData? _match;
  LiveDuelQuestionSet? _questionSet;
  LiveDuelPlayerProgress? _ownProgress;
  LiveDuelPlayerProgress? _opponentProgress;

  bool _loading = true;
  bool _submitting = false;
  int _questionIndex = 0;
  int? _selectedOptionIndex;
  bool? _selectedAnswerCorrect;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
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

      final match = LiveDuelMatchViewData.fromMap(
        matchSnapshot.data() ?? <String, dynamic>{},
      );

      if (match.questionCount != widget.questionCount) {
        throw const LiveDuelPlayException('Eşleşme soru sayısı uyuşmuyor.');
      }

      final questionSet = await LiveDuelQuestionSetService.resolveQuestionIds(
        match.questionIds,
      );

      await LiveDuelProgressService.initializeProgress(matchId: widget.matchId);

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
    } on LiveDuelPlayException catch (error) {
      _showFatalError(error.message);
    } on LiveDuelQuestionSetException catch (error) {
      _showFatalError(error.message);
    } on LiveDuelProgressException catch (error) {
      _showFatalError(error.message);
    } on LiveDuelMatchmakingException catch (error) {
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

  @override
  void dispose() {
    _progressSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fatal = !_loading && _questionSet == null && _errorMessage != null;
    final canLeave = _bothFinished || fatal;

    return PopScope(
      canPop: canLeave,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop || !mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Dereceli düello tamamlanmadan maçtan ayrılamazsın.'),
          ),
        );
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: canLeave,
          title: const Text('Canlı Düello'),
        ),
        body: SafeArea(child: _buildBody()),
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
        if (_bothFinished)
          _buildResultView(own, opponent)
        else if (_ownFinished)
          _buildWaitingView(opponent, match.questionCount)
        else
          _buildQuestionView(questionSet),
      ],
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

  Widget _buildResultView(
    LiveDuelPlayerProgress own,
    LiveDuelPlayerProgress opponent,
  ) {
    final outcome = LiveDuelResultCalculator.outcome(
      own: own,
      opponent: opponent,
    );

    final icon = switch (outcome) {
      LiveDuelOutcome.victory => Icons.emoji_events,
      LiveDuelOutcome.draw => Icons.handshake,
      LiveDuelOutcome.defeat => Icons.replay,
    };

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(icon, size: 72),
            const SizedBox(height: 16),
            Text(
              LiveDuelResultCalculator.title(outcome),
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              LiveDuelResultCalculator.description(outcome),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 22),
            Text(
              '${own.correctCount} - ${opponent.correctCount}',
              style: Theme.of(context).textTheme.displaySmall,
            ),
            const SizedBox(height: 6),
            const Text('Doğru cevap skoru'),
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
