import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'word_hunt_models.dart';
import 'word_hunt_path.dart';
import 'word_hunt_progress.dart';
import 'word_hunt_scoring.dart';
import 'word_hunt_starter_content.dart';

class WordHuntLevelPlayResult {
  const WordHuntLevelPlayResult({
    required this.levelId,
    required this.stars,
    required this.unlockedInfoCardIds,
  });

  final String levelId;
  final int stars;
  final Set<String> unlockedInfoCardIds;
}

/// Başlangıç Limanı Bölüm 1 için production oynanış ekranı.
///
/// Prototype ekran korunur; bu ekran aynı path/scoring motorlarını production
/// akış sözleşmesindeki timer freeze, güvenli çıkış ve idempotent sonuç
/// davranışlarıyla kullanır.
class WordHuntLevelProductionScreen extends StatefulWidget {
  const WordHuntLevelProductionScreen({
    super.key,
    required this.level,
    required this.infoCards,
    this.now,
  });

  final WordHuntLevelDefinition level;
  final List<WordHuntInfoCard> infoCards;
  final DateTime Function()? now;

  @override
  State<WordHuntLevelProductionScreen> createState() =>
      _WordHuntLevelProductionScreenState();
}

class _WordHuntLevelProductionScreenState
    extends State<WordHuntLevelProductionScreen> {
  final Set<String> _foundTargets = <String>{};
  final Set<String> _foundBonus = <String>{};
  final Map<String, List<WordHuntCell>> _foundPaths =
      <String, List<WordHuntCell>>{};
  final Set<String> _unlockedInfoCards = <String>{};

  List<WordHuntCell> _selectedPath = const <WordHuntCell>[];
  WordHuntCell? _dragStart;
  Timer? _timer;
  Timer? _errorFeedbackTimer;
  late final DateTime _startedAt;
  int _elapsedSeconds = 0;
  int? _completionElapsedSeconds;
  int? _completionMistakes;
  int _mistakes = 0;
  bool _selectionInvalid = false;
  bool _completionDialogOpen = false;
  bool _resultDelivered = false;
  bool _exitDialogOpen = false;
  bool _allowPop = false;
  Set<WordHuntCell> _errorCells = const <WordHuntCell>{};
  String _status = 'İlk harfe dokun, parmağını kelimenin üzerinde sürükle.';

  bool get _allTargetsFound =>
      _foundTargets.length >= widget.level.targetWords.length;

  bool get _hasMeaningfulAttempt =>
      _foundTargets.isNotEmpty || _foundBonus.isNotEmpty || _mistakes > 0;

  int get _displayedElapsedSeconds =>
      _completionElapsedSeconds ?? _elapsedSeconds;

  int get _scoredMistakes => _completionMistakes ?? _mistakes;

  DateTime _now() => widget.now?.call() ?? DateTime.now();

  int _wallClockElapsedSeconds() =>
      math.max(0, _now().difference(_startedAt).inSeconds);

  @override
  void initState() {
    super.initState();
    _startedAt = _now();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || _completionElapsedSeconds != null) return;
      final elapsed = _wallClockElapsedSeconds();
      if (elapsed == _elapsedSeconds) return;
      setState(() => _elapsedSeconds = elapsed);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _errorFeedbackTimer?.cancel();
    super.dispose();
  }

  void _startErrorFeedback(Iterable<WordHuntCell> cells) {
    _errorFeedbackTimer?.cancel();
    _errorCells = cells.where((cell) => !_isFound(cell)).toSet();
    if (_errorCells.isEmpty) return;
    _errorFeedbackTimer = Timer(const Duration(milliseconds: 280), () {
      if (!mounted) return;
      setState(() => _errorCells = const <WordHuntCell>{});
    });
  }

  WordHuntCell? _cellForPosition(Offset position, Size size) {
    if (position.dx < 0 ||
        position.dy < 0 ||
        position.dx >= size.width ||
        position.dy >= size.height) {
      return null;
    }
    final row = (position.dy / (size.height / widget.level.rowCount)).floor();
    final column =
        (position.dx / (size.width / widget.level.columnCount)).floor();
    return WordHuntCell(row, column);
  }

  List<WordHuntCell>? _straightPathBetween(
    WordHuntCell start,
    WordHuntCell end,
  ) {
    final rowDelta = end.row - start.row;
    final columnDelta = end.column - start.column;
    if (rowDelta == 0 && columnDelta == 0) return <WordHuntCell>[start];

    final straight =
        rowDelta == 0 ||
        columnDelta == 0 ||
        rowDelta.abs() == columnDelta.abs();
    if (!straight) return null;

    final steps = math.max(rowDelta.abs(), columnDelta.abs());
    final rowStep = rowDelta.sign;
    final columnStep = columnDelta.sign;
    return List<WordHuntCell>.generate(
      steps + 1,
      (index) => WordHuntCell(
        start.row + rowStep * index,
        start.column + columnStep * index,
      ),
      growable: false,
    );
  }

  void _pointerDown(Offset position, Size size) {
    if (_resultDelivered || _completionDialogOpen) return;
    final cell = _cellForPosition(position, size);
    if (cell == null) return;
    setState(() {
      _errorFeedbackTimer?.cancel();
      _errorCells = const <WordHuntCell>{};
      _dragStart = cell;
      _selectedPath = <WordHuntCell>[cell];
      _selectionInvalid = false;
    });
  }

  void _pointerMove(Offset position, Size size) {
    final start = _dragStart;
    if (_resultDelivered || _completionDialogOpen || start == null) return;
    final end = _cellForPosition(position, size);
    if (end == null) return;
    final path = _straightPathBetween(start, end);
    if (path == null) {
      setState(() {
        _selectionInvalid = true;
        _selectedPath = <WordHuntCell>[start, end];
      });
      return;
    }

    final read = WordHuntPathEngine.readWord(
      grid: widget.level.grid,
      path: path,
    );
    if (!read.isValid) {
      setState(() => _selectionInvalid = true);
      return;
    }
    setState(() {
      _selectionInvalid = false;
      _selectedPath = path;
    });
  }

  void _pointerCancel() {
    if (!mounted) return;
    setState(() {
      _selectedPath = const <WordHuntCell>[];
      _dragStart = null;
      _selectionInvalid = false;
    });
  }

  void _pointerUp() {
    if (_dragStart == null || _resultDelivered || _completionDialogOpen) return;
    if (_selectionInvalid) {
      setState(() {
        _startErrorFeedback(_selectedPath);
        _selectedPath = const <WordHuntCell>[];
        _dragStart = null;
        _selectionInvalid = false;
        _status = 'Bu yol düz bir çizgi oluşturmuyor.';
      });
      return;
    }
    if (_selectedPath.isEmpty) return;

    final selectedPath = List<WordHuntCell>.unmodifiable(_selectedPath);
    final result = WordHuntPathEngine.evaluate(
      level: widget.level,
      path: selectedPath,
      foundTargetWords: _foundTargets,
      foundBonusWords: _foundBonus,
    );

    setState(() {
      _selectedPath = const <WordHuntCell>[];
      _dragStart = null;

      switch (result.kind) {
        case WordHuntSelectionKind.target:
          final word = result.canonicalWord!;
          _foundTargets.add(word);
          _foundPaths[word] = selectedPath;
          final cardTitle = _unlockInfoCardFor(word);
          _status =
              cardTitle == null
                  ? '$word bulundu!'
                  : 'Bilgi kartı açıldı: $cardTitle';
          if (_allTargetsFound && _completionElapsedSeconds == null) {
            final elapsed = _wallClockElapsedSeconds();
            _elapsedSeconds = elapsed;
            _completionElapsedSeconds = elapsed;
            _completionMistakes = _mistakes;
            _timer?.cancel();
          }
        case WordHuntSelectionKind.bonus:
          final word = result.canonicalWord!;
          _foundBonus.add(word);
          _foundPaths[word] = selectedPath;
          final cardTitle = _unlockInfoCardFor(word);
          _status =
              cardTitle == null
                  ? 'Bonus kelime: $word ✨'
                  : 'Bilgi kartı açıldı: $cardTitle';
        case WordHuntSelectionKind.alreadyFound:
          _status = '${result.canonicalWord} zaten bulundu.';
        case WordHuntSelectionKind.notAWord:
          _startErrorFeedback(selectedPath);
          if (_completionElapsedSeconds == null) {
            _mistakes++;
            _status = 'Bu seçim listede yok. Başka bir yol dene.';
          } else {
            _status = 'Ana hedefler tamam. İstersen bonus kelimeyi ara.';
          }
        case WordHuntSelectionKind.invalidPath:
          _status = result.error ?? 'Bu yol geçerli değil.';
      }
    });
  }

  String? _unlockInfoCardFor(String word) {
    final normalized = WordHuntPathEngine.normalizeWord(word);
    for (final card in widget.infoCards) {
      if (!widget.level.infoCardIds.contains(card.id)) continue;
      if (WordHuntPathEngine.normalizeWord(card.word) == normalized) {
        _unlockedInfoCards.add(card.id);
        return card.title;
      }
    }
    return null;
  }

  Future<void> _finishLevel() async {
    if (!_allTargetsFound || _completionDialogOpen || _resultDelivered) return;
    _completionDialogOpen = true;
    final elapsed = _displayedElapsedSeconds;
    final score = WordHuntScoringEngine.calculate(
      level: widget.level,
      foundTargetCount: _foundTargets.length,
      mistakes: _scoredMistakes,
      elapsedSeconds: elapsed,
    );

    if (!mounted) return;
    final leave = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            key: const Key('word_hunt_production_result_dialog'),
            backgroundColor: const Color(0xFF102443),
            title: const Text(
              'Bölüm Tamamlandı',
              style: TextStyle(color: Colors.white),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List<Widget>.generate(
                    3,
                    (index) => Icon(
                      index < score.stars
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      key: Key('word_hunt_production_result_star_${index + 1}'),
                      size: 42,
                      color:
                          index < score.stars
                              ? const Color(0xFFFFD166)
                              : const Color(0xFF77829A),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '$elapsed saniye',
                  key: const Key('word_hunt_production_result_elapsed'),
                  style: const TextStyle(color: Color(0xFFD6D9E8)),
                ),
                Text(
                  '$_scoredMistakes hata',
                  key: const Key('word_hunt_production_result_mistakes'),
                  style: const TextStyle(color: Color(0xFFD6D9E8)),
                ),
                if (_foundBonus.isNotEmpty)
                  Text(
                    'Bonus: ${_foundBonus.join(', ')}',
                    style: const TextStyle(color: Color(0xFFFFD166)),
                  ),
              ],
            ),
            actions: [
              FilledButton(
                key: const Key('word_hunt_production_return_route'),
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Rotaya Dön'),
              ),
            ],
          ),
    );

    if (!mounted) return;
    if (leave == true && !_resultDelivered) {
      _resultDelivered = true;
      Navigator.of(context).pop(
        WordHuntLevelPlayResult(
          levelId: widget.level.id,
          stars: score.stars,
          unlockedInfoCardIds: Set<String>.unmodifiable(_unlockedInfoCards),
        ),
      );
      return;
    }
    _completionDialogOpen = false;
  }

  Future<void> _requestExit() async {
    if (_allowPop || _exitDialogOpen || _resultDelivered) return;
    if (!_hasMeaningfulAttempt) {
      _popWithoutResult();
      return;
    }

    _exitDialogOpen = true;
    final leave = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            key: const Key('word_hunt_production_exit_dialog'),
            title: const Text('Bölümden çıkılsın mı?'),
            content: const Text('Bu denemedeki ilerleme kaybolacak.'),
            actions: [
              TextButton(
                key: const Key('word_hunt_production_exit_continue'),
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Devam Et'),
              ),
              FilledButton(
                key: const Key('word_hunt_production_exit_confirm'),
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Çık'),
              ),
            ],
          ),
    );
    _exitDialogOpen = false;
    if (leave == true && mounted) _popWithoutResult();
  }

  void _popWithoutResult() {
    if (!mounted || _allowPop) return;
    setState(() => _allowPop = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) Navigator.of(context).pop();
    });
  }

  bool _isFound(WordHuntCell cell) =>
      _foundPaths.values.any((path) => path.contains(cell));

  @override
  Widget build(BuildContext context) {
    return PopScope<Object?>(
      canPop: _allowPop,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _requestExit();
      },
      child: Scaffold(
        key: const Key('word_hunt_production_screen'),
        backgroundColor: const Color(0xFF06142E),
        appBar: AppBar(
          backgroundColor: const Color(0xFF06142E),
          foregroundColor: Colors.white,
          leading: IconButton(
            key: const Key('word_hunt_production_back'),
            onPressed: _requestExit,
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bölüm ${widget.level.index}',
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              const Text(
                'Başlangıç Limanı',
                style: TextStyle(fontSize: 12, color: Color(0xFFA7B0C9)),
              ),
            ],
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _MetricChip(
                        icon: Icons.search_rounded,
                        label:
                            '${_foundTargets.length}/${widget.level.targetWords.length}',
                        key: const Key('word_hunt_production_progress'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _MetricChip(
                        icon: Icons.close_rounded,
                        label: '$_scoredMistakes hata',
                        key: const Key('word_hunt_production_mistakes'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _MetricChip(
                        icon: Icons.timer_outlined,
                        label: '${_displayedElapsedSeconds}s',
                        textKey: const Key('word_hunt_production_elapsed_text'),
                        key: const Key('word_hunt_production_elapsed'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final word in widget.level.targetWords)
                      KeyedSubtree(
                        key: Key(
                          'word_hunt_production_target_${word}_${_foundTargets.contains(word) ? 'found' : 'pending'}',
                        ),
                        child: _WordChip(
                          word: word,
                          found: _foundTargets.contains(word),
                        ),
                      ),
                    for (final word in widget.level.bonusWords)
                      KeyedSubtree(
                        key: Key(
                          'word_hunt_production_bonus_${word}_${_foundBonus.contains(word) ? 'found' : 'pending'}',
                        ),
                        child: _WordChip(
                          word: word,
                          found: _foundBonus.contains(word),
                          bonus: true,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final spacing = constraints.maxHeight < 380 ? 3.0 : 5.0;
                      final columns = widget.level.columnCount;
                      final rows = widget.level.rowCount;
                      final availableWidth = math.max(
                        1.0,
                        constraints.maxWidth - ((columns - 1) * spacing),
                      );
                      final availableHeight = math.max(
                        1.0,
                        constraints.maxHeight - ((rows - 1) * spacing),
                      );
                      final cellSize = math.max(
                        1.0,
                        math.min(
                          availableWidth / columns,
                          availableHeight / rows,
                        ),
                      );
                      final gridWidth =
                          (cellSize * columns) + ((columns - 1) * spacing);
                      final gridHeight =
                          (cellSize * rows) + ((rows - 1) * spacing);
                      final gridSize = Size(gridWidth, gridHeight);
                      final letterSize = math.min(
                        22.0,
                        math.max(16.0, cellSize * 0.56),
                      );
                      final cornerRadius = math.min(
                        12.0,
                        math.max(8.0, cellSize * 0.28),
                      );

                      return Center(
                        child: SizedBox(
                          width: gridWidth,
                          height: gridHeight,
                          child: Listener(
                            key: const Key('word_hunt_production_grid'),
                            behavior: HitTestBehavior.opaque,
                            onPointerDown:
                                (event) => _pointerDown(
                                  event.localPosition,
                                  gridSize,
                                ),
                            onPointerMove:
                                (event) => _pointerMove(
                                  event.localPosition,
                                  gridSize,
                                ),
                            onPointerUp: (_) => _pointerUp(),
                            onPointerCancel: (_) => _pointerCancel(),
                            child: GridView.builder(
                              padding: EdgeInsets.zero,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: columns,
                                    crossAxisSpacing: spacing,
                                    mainAxisSpacing: spacing,
                                    childAspectRatio: 1,
                                  ),
                              itemCount: rows * columns,
                              itemBuilder: (context, index) {
                                final row = index ~/ columns;
                                final column = index % columns;
                                final cell = WordHuntCell(row, column);
                                final rune = widget.level.grid[row].runes
                                    .elementAt(column);
                                final selected = _selectedPath.contains(cell);
                                final found = _isFound(cell);
                                final error = _errorCells.contains(cell);
                                return AnimatedContainer(
                                  key: Key(
                                    'word_hunt_production_cell_${row}_$column',
                                  ),
                                  duration: const Duration(milliseconds: 120),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color:
                                        selected
                                            ? const Color(0xFF8B5CF6)
                                            : error
                                            ? const Color(0xFF9A3412)
                                            : found
                                            ? const Color(0xFF0F766E)
                                            : const Color(0xFF142A4C),
                                    borderRadius: BorderRadius.circular(
                                      cornerRadius,
                                    ),
                                    border: Border.all(
                                      color:
                                          selected
                                              ? const Color(0xFFD8B4FE)
                                              : error
                                              ? const Color(0xFFF97316)
                                              : found
                                              ? const Color(0xFF5EEAD4)
                                              : const Color(0xFF34527A),
                                    ),
                                  ),
                                  child: Stack(
                                    fit: StackFit.expand,
                                    alignment: Alignment.center,
                                    children: [
                                      Center(
                                        child: Text(
                                          String.fromCharCode(rune),
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: letterSize,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                      ),
                                      if (error)
                                        IgnorePointer(
                                          child: SizedBox.expand(
                                            key: Key(
                                              'word_hunt_production_error_cell_${row}_$column',
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  constraints: const BoxConstraints(minHeight: 44),
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D203D),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    _status,
                    key: const Key('word_hunt_production_status'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFFD6D9E8),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                if (_allTargetsFound)
                  FilledButton.icon(
                    key: const Key('word_hunt_production_finish'),
                    onPressed:
                        _completionDialogOpen || _resultDelivered
                            ? null
                            : _finishLevel,
                    icon: const Icon(Icons.flag_rounded),
                    label: const Text('Bölümü Tamamla'),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// İzole rota ekranı. Mevcut Bilgi Rotası ana navigasyonuna bağlı değildir.
class WordHuntRoutePrototypeScreen extends StatefulWidget {
  const WordHuntRoutePrototypeScreen({
    super.key,
    this.route = WordHuntStarterContent.baslangicLimani,
    this.infoCards = WordHuntStarterContent.infoCards,
    this.initialProgress = const WordHuntProgressSnapshot(),
  });

  final WordHuntRouteDefinition route;
  final List<WordHuntInfoCard> infoCards;
  final WordHuntProgressSnapshot initialProgress;

  @override
  State<WordHuntRoutePrototypeScreen> createState() =>
      _WordHuntRoutePrototypeScreenState();
}

class _WordHuntRoutePrototypeScreenState
    extends State<WordHuntRoutePrototypeScreen> {
  late WordHuntProgressSnapshot _progress;

  @override
  void initState() {
    super.initState();
    _progress = widget.initialProgress;
  }

  Future<void> _openLevel(int index) async {
    if (!WordHuntRouteProgressEngine.isLevelUnlocked(
      widget.route,
      _progress,
      index,
    )) {
      return;
    }

    final level = widget.route.levels[index - 1];
    final result = await Navigator.of(context).push<WordHuntLevelPlayResult>(
      MaterialPageRoute<WordHuntLevelPlayResult>(
        builder:
            (_) => WordHuntLevelPrototypeScreen(
              level: level,
              infoCards: widget.infoCards,
            ),
      ),
    );
    if (!mounted || result == null) return;

    setState(() {
      _progress = _progress.recordLevelResult(
        levelId: result.levelId,
        stars: result.stars,
        unlockedInfoCards: result.unlockedInfoCardIds,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final routeStars = WordHuntRouteProgressEngine.totalStars(
      widget.route,
      _progress,
    );
    final routeComplete = WordHuntRouteProgressEngine.isRouteComplete(
      widget.route,
      _progress,
    );

    return Scaffold(
      backgroundColor: const Color(0xFF06142E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF06142E),
        foregroundColor: Colors.white,
        title: const Text('Kelime Avı'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
          children: [
            _RouteHeader(
              title: widget.route.title,
              stars: routeStars,
              maximumStars: widget.route.maximumStars,
              unlockStarsRequired: widget.route.unlockStarsRequired,
              complete: routeComplete,
            ),
            const SizedBox(height: 22),
            for (
              var index = 1;
              index <= widget.route.levels.length;
              index++
            ) ...[
              _RouteLevelNode(
                key: Key('word_hunt_level_$index'),
                level: widget.route.levels[index - 1],
                stars: _progress.starsFor(widget.route.levels[index - 1].id),
                unlocked: WordHuntRouteProgressEngine.isLevelUnlocked(
                  widget.route,
                  _progress,
                  index,
                ),
                onTap: () => _openLevel(index),
              ),
              if (index != widget.route.levels.length)
                Center(
                  child: Container(
                    width: 3,
                    height: 22,
                    color: const Color(0x5560A5FA),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _RouteHeader extends StatelessWidget {
  const _RouteHeader({
    required this.title,
    required this.stars,
    required this.maximumStars,
    required this.unlockStarsRequired,
    required this.complete,
  });

  final String title;
  final int stars;
  final int maximumStars;
  final int unlockStarsRequired;
  final bool complete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: <Color>[Color(0xFF25104B), Color(0xFF111F4D)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF8B5CF6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🧭 1. ROTA',
            style: TextStyle(
              color: Color(0xFFFFD166),
              fontSize: 13,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Kelimeleri bul, yıldızları topla ve limanın son kapısını aç.',
            style: TextStyle(color: Color(0xFFD6D9E8), height: 1.4),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.star_rounded, color: Color(0xFFFFD166)),
              const SizedBox(width: 6),
              Text(
                '$stars / $maximumStars',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              Text(
                complete ? 'ROTA TAMAMLANDI' : 'Kapı: $unlockStarsRequired ⭐',
                style: TextStyle(
                  color:
                      complete
                          ? const Color(0xFF5EEAD4)
                          : const Color(0xFFA7B0C9),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RouteLevelNode extends StatelessWidget {
  const _RouteLevelNode({
    super.key,
    required this.level,
    required this.stars,
    required this.unlocked,
    required this.onTap,
  });

  final WordHuntLevelDefinition level;
  final int stars;
  final bool unlocked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accent = switch (level.type) {
      WordHuntLevelType.normal => const Color(0xFF14B8A6),
      WordHuntLevelType.challenge => const Color(0xFFF59E0B),
      WordHuntLevelType.bonus => const Color(0xFF8B5CF6),
      WordHuntLevelType.routeFinal => const Color(0xFFFFD166),
    };
    final typeLabel = switch (level.type) {
      WordHuntLevelType.normal => 'Normal',
      WordHuntLevelType.challenge => 'Meydan Okuma',
      WordHuntLevelType.bonus => 'Bonus Durak',
      WordHuntLevelType.routeFinal => 'Rota Finali',
    };

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: unlocked ? onTap : null,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: unlocked ? const Color(0xFF102443) : const Color(0xFF0B1730),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color:
                  unlocked
                      ? accent.withValues(alpha: 0.75)
                      : const Color(0xFF26354D),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color:
                      unlocked
                          ? accent.withValues(alpha: 0.18)
                          : const Color(0xFF172238),
                  border: Border.all(
                    color: unlocked ? accent : const Color(0xFF445066),
                  ),
                ),
                child:
                    unlocked
                        ? Text(
                          '${level.index}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                          ),
                        )
                        : const Icon(
                          Icons.lock_rounded,
                          color: Color(0xFF77829A),
                        ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bölüm ${level.index}',
                      style: TextStyle(
                        color:
                            unlocked ? Colors.white : const Color(0xFF77829A),
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      typeLabel,
                      style: TextStyle(
                        color: unlocked ? accent : const Color(0xFF66738A),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              if (stars > 0)
                Row(
                  children: List<Widget>.generate(
                    3,
                    (starIndex) => Icon(
                      Icons.star_rounded,
                      size: 20,
                      color:
                          starIndex < stars
                              ? const Color(0xFFFFD166)
                              : const Color(0xFF3B465C),
                    ),
                  ),
                )
              else if (unlocked)
                const Icon(Icons.chevron_right_rounded, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}

/// Parmağı grid üzerinde sürükleyerek kelime seçilebilen izole oyun ekranı.
class WordHuntLevelPrototypeScreen extends StatefulWidget {
  const WordHuntLevelPrototypeScreen({
    super.key,
    required this.level,
    required this.infoCards,
  });

  final WordHuntLevelDefinition level;
  final List<WordHuntInfoCard> infoCards;

  @override
  State<WordHuntLevelPrototypeScreen> createState() =>
      _WordHuntLevelPrototypeScreenState();
}

class _WordHuntLevelPrototypeScreenState
    extends State<WordHuntLevelPrototypeScreen> {
  final Set<String> _foundTargets = <String>{};
  final Set<String> _foundBonus = <String>{};
  final Map<String, List<WordHuntCell>> _foundPaths =
      <String, List<WordHuntCell>>{};
  final Set<String> _unlockedInfoCards = <String>{};

  List<WordHuntCell> _selectedPath = const <WordHuntCell>[];
  WordHuntCell? _dragStart;
  Timer? _timer;
  late DateTime _startedAt;
  int _elapsedSeconds = 0;
  int? _completionElapsedSeconds;
  int? _completionMistakes;
  int _mistakes = 0;
  String _status = 'Bir kelimenin ilk harfinden başlayıp parmağını sürükle.';

  @override
  void initState() {
    super.initState();
    _resetAttempt();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  bool get _allTargetsFound =>
      _foundTargets.length >= widget.level.targetWords.length;

  int get _displayedElapsedSeconds =>
      _completionElapsedSeconds ?? _elapsedSeconds;

  int get _scoredMistakes => _completionMistakes ?? _mistakes;

  void _resetAttempt() {
    _timer?.cancel();
    _foundTargets.clear();
    _foundBonus.clear();
    _foundPaths.clear();
    _unlockedInfoCards.clear();
    _selectedPath = const <WordHuntCell>[];
    _dragStart = null;
    _elapsedSeconds = 0;
    _completionElapsedSeconds = null;
    _completionMistakes = null;
    _mistakes = 0;
    _status = 'Bir kelimenin ilk harfinden başlayıp parmağını sürükle.';
    _startedAt = DateTime.now();

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || _completionElapsedSeconds != null) return;
      final elapsed = DateTime.now().difference(_startedAt).inSeconds;
      if (elapsed == _elapsedSeconds) return;
      setState(() => _elapsedSeconds = elapsed);
    });
  }

  WordHuntCell? _cellForPosition(Offset position, Size size) {
    if (position.dx < 0 ||
        position.dy < 0 ||
        position.dx >= size.width ||
        position.dy >= size.height) {
      return null;
    }
    final row = (position.dy / (size.height / widget.level.rowCount)).floor();
    final column =
        (position.dx / (size.width / widget.level.columnCount)).floor();
    return WordHuntCell(row, column);
  }

  List<WordHuntCell>? _straightPathBetween(
    WordHuntCell start,
    WordHuntCell end,
  ) {
    final rowDelta = end.row - start.row;
    final columnDelta = end.column - start.column;
    if (rowDelta == 0 && columnDelta == 0) return <WordHuntCell>[start];

    final straight =
        rowDelta == 0 ||
        columnDelta == 0 ||
        rowDelta.abs() == columnDelta.abs();
    if (!straight) return null;

    final steps = math.max(rowDelta.abs(), columnDelta.abs());
    final rowStep = rowDelta.sign;
    final columnStep = columnDelta.sign;
    return List<WordHuntCell>.generate(
      steps + 1,
      (index) => WordHuntCell(
        start.row + rowStep * index,
        start.column + columnStep * index,
      ),
      growable: false,
    );
  }

  void _pointerDown(Offset position, Size size) {
    final cell = _cellForPosition(position, size);
    if (cell == null) return;
    setState(() {
      _dragStart = cell;
      _selectedPath = <WordHuntCell>[cell];
    });
  }

  void _pointerMove(Offset position, Size size) {
    if (_dragStart == null) return;
    final end = _cellForPosition(position, size);
    if (end == null) return;
    final path = _straightPathBetween(_dragStart!, end);
    if (path == null) return;

    final read = WordHuntPathEngine.readWord(
      grid: widget.level.grid,
      path: path,
    );
    if (!read.isValid) return;
    setState(() => _selectedPath = path);
  }

  void _pointerUp() {
    if (_selectedPath.isEmpty) return;

    final selectedPath = List<WordHuntCell>.unmodifiable(_selectedPath);
    final result = WordHuntPathEngine.evaluate(
      level: widget.level,
      path: selectedPath,
      foundTargetWords: _foundTargets,
      foundBonusWords: _foundBonus,
    );

    setState(() {
      _selectedPath = const <WordHuntCell>[];
      _dragStart = null;

      switch (result.kind) {
        case WordHuntSelectionKind.target:
          final word = result.canonicalWord!;
          _foundTargets.add(word);
          _foundPaths[word] = selectedPath;
          final cardTitle = _unlockInfoCardFor(word);
          _status =
              cardTitle == null
                  ? 'Harika! $word bulundu.'
                  : 'Bilgi kartı açıldı: $cardTitle';
          if (_allTargetsFound && _completionElapsedSeconds == null) {
            final elapsed = DateTime.now().difference(_startedAt).inSeconds;
            _elapsedSeconds = elapsed;
            _completionElapsedSeconds = elapsed;
            _completionMistakes = _mistakes;
            _timer?.cancel();
          }
        case WordHuntSelectionKind.bonus:
          final word = result.canonicalWord!;
          _foundBonus.add(word);
          _foundPaths[word] = selectedPath;
          final cardTitle = _unlockInfoCardFor(word);
          _status =
              cardTitle == null
                  ? 'Bonus kelime: $word ✨'
                  : 'Bilgi kartı açıldı: $cardTitle';
        case WordHuntSelectionKind.alreadyFound:
          _status = '${result.canonicalWord} zaten bulundu.';
        case WordHuntSelectionKind.notAWord:
          if (_completionElapsedSeconds == null) {
            _mistakes++;
            _status = 'Bu seçim listede yok. Başka bir yol dene.';
          } else {
            _status = 'Ana hedefler tamam. İstersen bonus kelimeyi ara.';
          }
        case WordHuntSelectionKind.invalidPath:
          _status = result.error ?? 'Bu yol geçerli değil.';
      }
    });
  }

  String? _unlockInfoCardFor(String word) {
    final normalized = WordHuntPathEngine.normalizeWord(word);
    for (final card in widget.infoCards) {
      if (!widget.level.infoCardIds.contains(card.id)) continue;
      if (WordHuntPathEngine.normalizeWord(card.word) == normalized) {
        _unlockedInfoCards.add(card.id);
        return card.title;
      }
    }
    return null;
  }

  Future<void> _finishLevel() async {
    if (!_allTargetsFound) return;
    _timer?.cancel();
    final elapsed = _displayedElapsedSeconds;
    final score = WordHuntScoringEngine.calculate(
      level: widget.level,
      foundTargetCount: _foundTargets.length,
      mistakes: _scoredMistakes,
      elapsedSeconds: elapsed,
    );

    if (!mounted) return;
    final leave = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            backgroundColor: const Color(0xFF102443),
            title: const Text(
              'Bölüm Tamamlandı',
              style: TextStyle(color: Colors.white),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List<Widget>.generate(
                    3,
                    (index) => Icon(
                      Icons.star_rounded,
                      size: 42,
                      color:
                          index < score.stars
                              ? const Color(0xFFFFD166)
                              : const Color(0xFF3B465C),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '${elapsed}s • $_scoredMistakes hata • ${_foundBonus.length} bonus',
                  style: const TextStyle(color: Color(0xFFD6D9E8)),
                ),
              ],
            ),
            actions: [
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Rotaya Dön'),
              ),
            ],
          ),
    );

    if (leave == true && mounted) {
      Navigator.of(context).pop(
        WordHuntLevelPlayResult(
          levelId: widget.level.id,
          stars: score.stars,
          unlockedInfoCardIds: Set<String>.unmodifiable(_unlockedInfoCards),
        ),
      );
    }
  }

  bool _isFound(WordHuntCell cell) =>
      _foundPaths.values.any((path) => path.contains(cell));

  @override
  Widget build(BuildContext context) {
    final challengeSeconds = widget.level.timeLimitSeconds;

    return Scaffold(
      backgroundColor: const Color(0xFF06142E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF06142E),
        foregroundColor: Colors.white,
        title: Text('Bölüm ${widget.level.index}'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _MetricChip(
                      icon: Icons.search_rounded,
                      label:
                          '${_foundTargets.length}/${widget.level.targetWords.length}',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _MetricChip(
                      icon: Icons.close_rounded,
                      label: '$_scoredMistakes hata',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _MetricChip(
                      icon: Icons.timer_outlined,
                      label: '${_displayedElapsedSeconds}s',
                      warning:
                          challengeSeconds != null &&
                          _displayedElapsedSeconds > challengeSeconds,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final word in widget.level.targetWords)
                    _WordChip(word: word, found: _foundTargets.contains(word)),
                  for (final word in widget.level.bonusWords)
                    _WordChip(
                      word: word,
                      found: _foundBonus.contains(word),
                      bonus: true,
                    ),
                ],
              ),
              const SizedBox(height: 18),
              AspectRatio(
                aspectRatio: widget.level.columnCount / widget.level.rowCount,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final gridSize = Size(
                      constraints.maxWidth,
                      constraints.maxHeight,
                    );
                    return Listener(
                      key: const Key('word_hunt_grid'),
                      behavior: HitTestBehavior.opaque,
                      onPointerDown:
                          (event) =>
                              _pointerDown(event.localPosition, gridSize),
                      onPointerMove:
                          (event) =>
                              _pointerMove(event.localPosition, gridSize),
                      onPointerUp: (_) => _pointerUp(),
                      onPointerCancel: (_) {
                        setState(() {
                          _selectedPath = const <WordHuntCell>[];
                          _dragStart = null;
                        });
                      },
                      child: GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: widget.level.columnCount,
                          crossAxisSpacing: 7,
                          mainAxisSpacing: 7,
                        ),
                        itemCount:
                            widget.level.rowCount * widget.level.columnCount,
                        itemBuilder: (context, index) {
                          final row = index ~/ widget.level.columnCount;
                          final column = index % widget.level.columnCount;
                          final cell = WordHuntCell(row, column);
                          final rune = widget.level.grid[row].runes.elementAt(
                            column,
                          );
                          final selected = _selectedPath.contains(cell);
                          final found = _isFound(cell);
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 120),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color:
                                  selected
                                      ? const Color(0xFF8B5CF6)
                                      : found
                                      ? const Color(0xFF0F766E)
                                      : const Color(0xFF142A4C),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color:
                                    selected
                                        ? const Color(0xFFD8B4FE)
                                        : found
                                        ? const Color(0xFF5EEAD4)
                                        : const Color(0xFF34527A),
                              ),
                            ),
                            child: Text(
                              String.fromCharCode(rune),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(
                  color: const Color(0xFF0D203D),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  _status,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFFD6D9E8),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              if (_allTargetsFound)
                FilledButton.icon(
                  key: const Key('word_hunt_finish_button'),
                  onPressed: _finishLevel,
                  icon: const Icon(Icons.flag_rounded),
                  label: const Text('Bölümü Tamamla'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  const _MetricChip({
    super.key,
    required this.icon,
    required this.label,
    this.warning = false,
    this.textKey,
  });

  final IconData icon;
  final String label;
  final bool warning;
  final Key? textKey;

  @override
  Widget build(BuildContext context) {
    final color = warning ? const Color(0xFFF97316) : const Color(0xFF22D3EE);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 9),
      decoration: BoxDecoration(
        color: const Color(0xFF102443),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.55)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              label,
              key: textKey,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WordChip extends StatelessWidget {
  const _WordChip({
    required this.word,
    required this.found,
    this.bonus = false,
  });

  final String word;
  final bool found;
  final bool bonus;

  @override
  Widget build(BuildContext context) {
    final accent = bonus ? const Color(0xFFFFD166) : const Color(0xFF5EEAD4);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: found ? accent.withValues(alpha: 0.2) : const Color(0xFF102443),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: found ? accent : const Color(0xFF354966)),
      ),
      child: Text(
        '${bonus ? '✦ ' : ''}$word',
        style: TextStyle(
          color: found ? accent : const Color(0xFFD6D9E8),
          fontWeight: FontWeight.w800,
          decoration: found ? TextDecoration.lineThrough : null,
        ),
      ),
    );
  }
}
