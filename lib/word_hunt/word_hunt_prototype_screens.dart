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

/// İzole Kelime Avı rota prototipi.
///
/// Bu ekran mevcut Bilgi Rotası ana navigasyonuna bilinçli olarak bağlı değildir.
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
        builder: (_) => WordHuntLevelPrototypeScreen(
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
            Container(
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
                    widget.route.title,
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
                        '$routeStars / ${widget.route.maximumStars}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        routeComplete
                            ? 'ROTA TAMAMLANDI'
                            : 'Kapı: ${widget.route.unlockStarsRequired} ⭐',
                        style: TextStyle(
                          color: routeComplete
                              ? const Color(0xFF5EEAD4)
                              : const Color(0xFFA7B0C9),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            for (var index = 1; index <= widget.route.levels.length; index++) ...[
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
              color: unlocked ? accent.withValues(alpha: 0.75) : const Color(0xFF26354D),
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
                  color: unlocked ? accent.withValues(alpha: 0.18) : const Color(0xFF172238),
                  border: Border.all(color: unlocked ? accent : const Color(0xFF445066)),
                ),
                child: unlocked
                    ? Text(
                        '${level.index}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      )
                    : const Icon(Icons.lock_rounded, color: Color(0xFF77829A)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bölüm ${level.index}',
                      style: TextStyle(
                        color: unlocked ? Colors.white : const Color(0xFF77829A),
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
                      color: starIndex < stars
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

/// Parmağı grid üzerinde sürükleyerek kelime seçilebilen izole bölüm prototipi.
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
  int _mistakes = 0;
  bool _timeExpired = false;
  String _status = 'Bir kelimenin ilk harfinden başlayıp parmağını sürükle.';

  @override
  void initState() {
    super.initState();
    _startAttempt();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startAttempt() {
    _timer?.cancel();
    _foundTargets.clear();
    _foundBonus.clear();
    _foundPaths.clear();
    _unlockedInfoCards.clear();
    _selectedPath = const <WordHuntCell>[];
    _dragStart = null;
    _mistakes = 0;
    _elapsedSeconds = 0;
    _timeExpired = false;
    _startedAt = DateTime.now();
    _status = 'Bir kelimenin ilk harfinden başlayıp parmağını sürükle.';

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || _timeExpired) return;
      final elapsed = DateTime.now().difference(_startedAt).inSeconds;
      final limit = widget.level.timeLimitSeconds;
      if (limit != null && elapsed >= limit && !_allTargetsFound) {
        setState(() {
          _elapsedSeconds = limit;
          _timeExpired = true;
          _selectedPath = const <WordHuntCell>[];
          _status = 'Süre doldu. Tekrar deneyebilirsin.';
        });
        _timer?.cancel();
        return;
      }
      setState(() => _elapsedSeconds = elapsed);
    });
  }

  bool get _allTargetsFound =>
      _foundTargets.length >= widget.level.targetWords.length;

  WordHuntCell? _cellForPosition(Offset position, Size size) {
    if (position.dx < 0 ||
        position.dy < 0 ||
        position.dx >= size.width ||
        position.dy >= size.height) {
      return null;
    }
    final rowHeight = size.height / widget.level.rowCount;
    final columnWidth = size.width / widget.level.columnCount;
    final row = (position.dy / rowHeight).floor();
    final column = (position.dx / columnWidth).floor();
    return WordHuntCell(row, column);
  }

  List<WordHuntCell>? _straightPathBetween(
    WordHuntCell start,
    WordHuntCell end,
  ) {
    final rowDelta = end.row - start.row;
    final columnDelta = end.column - start.column;
    if (rowDelta == 0 && columnDelta == 0) return <WordHuntCell>[start];

    final straight = rowDelta == 0 ||
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

  void _beginDrag(Offset position, Size size) {
    if (_timeExpired) return;
    final cell = _cellForPosition(position, size);
    if (cell == null) return;
    setState(() {
      _dragStart = cell;
      _selectedPath = <WordHuntCell>[cell];
    });
  }

  void _updateDrag(Offset position, Size size) {
    if (_timeExpired || _dragStart == null) return;
    final cell = _cellForPosition(position, size);
    if (cell == null) return;
    final path = _straightPathBetween(_dragStart!, cell);
    if (path == null) return;

    final read = WordHuntPathEngine.readWord(
      grid: widget.level.grid,
      path: path,
    );
    if (!read.isValid) return;

    setState(() => _selectedPath = path);
  }

  void _endDrag() {
    if (_selectedPath.isEmpty || _timeExpired) return;

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
          _unlockInfoCardFor(word);
          _status = 'Harika! $word bulundu.';
        case WordHuntSelectionKind.bonus:
          final word = result.canonicalWord!;
          _foundBonus.add(word);
          _foundPaths[word] = selectedPath;
          _unlockInfoCardFor(word);
          _status = 'Bonus kelime: $word ✨';
        case WordHuntSelectionKind.alreadyFound:
          _status = '${result.canonicalWord} zaten bulundu.';
        case WordHuntSelectionKind.notAWord:
          _mistakes++;
          _status = 'Bu seçim listede yok. Başka bir yol dene.';
        case WordHuntSelectionKind.invalidPath:
          _status = result.error ?? 'Bu yol geçerli değil.';
      }
    });
  }

  void _unlockInfoCardFor(String word) {
    final normalized = WordHuntPathEngine.normalizeWord(word);
    for (final card in widget.infoCards) {
      if (!widget.level.infoCardIds.contains(card.id)) continue;
      if (WordHuntPathEngine.normalizeWord(card.word) == normalized) {
        _unlockedInfoCards.add(card.id);
        _status = 'Bilgi kartı açıldı: ${card.title}';
      }
    }
  }

  Future<void> _finishLevel() async {
    if (!_allTargetsFound) return;
    _timer?.cancel();
    final elapsed = DateTime.now().difference(_startedAt).inSeconds;
    final score = WordHuntScoringEngine.calculate(
      level: widget.level,
      foundTargetCount: _foundTargets.length,
      mistakes: _mistakes,
      elapsedSeconds: elapsed,
    );

    if (!mounted) return;
    final leave = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF102443),
        title: const Text('Bölüm Tamamlandı', style: TextStyle(color: Colors.white)),
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
                  color: index < score.stars
                      ? const Color(0xFFFFD166)
                      : const Color(0xFF3B465C),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '${elapsed}s • $_mistakes hata • ${_foundBonus.length} bonus',
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

  bool _isSelected(WordHuntCell cell) => _selectedPath.contains(cell);

  bool _isFound(WordHuntCell cell) {
    return _foundPaths.values.any((path) => path.contains(cell));
  }

  @override
  Widget build(BuildContext context) {
    final remaining = widget.level.timeLimitSeconds == null
        ? null
        : math.max(0, widget.level.timeLimitSeconds! - _elapsedSeconds);

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
                      label: '${_foundTargets.length}/${widget.level.targetWords.length}',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _MetricChip(
                      icon: Icons.close_rounded,
                      label: '$_mistakes hata',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _MetricChip(
                      icon: Icons.timer_outlined,
                      label: remaining == null ? '${_elapsedSeconds}s' : '${remaining}s',
                      warning: remaining != null && remaining <= 10,
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
                    _WordChip(
                      word: word,
                      found: _foundTargets.contains(word),
                    ),
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
                aspectRatio: 1,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final gridSize = Size(
                      constraints.maxWidth,
                      constraints.maxHeight,
                    );
                    return GestureDetector(
                      key: const Key('word_hunt_grid'),
                      behavior: HitTestBehavior.opaque,
                      onPanStart: (details) => _beginDrag(details.localPosition, gridSize),
                      onPanUpdate: (details) => _updateDrag(details.localPosition, gridSize),
                      onPanEnd: (_) => _endDrag(),
                      child: GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: widget.level.columnCount,
                          crossAxisSpacing: 7,
                          mainAxisSpacing: 7,
                        ),
                        itemCount: widget.level.rowCount * widget.level.columnCount,
                        itemBuilder: (context, index) {
                          final row = index ~/ widget.level.columnCount;
                          final column = index % widget.level.columnCount;
                          final cell = WordHuntCell(row, column);
                          final rune = widget.level.grid[row].runes.elementAt(column);
                          final selected = _isSelected(cell);
                          final found = _isFound(cell);
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 120),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: selected
                                  ? const Color(0xFF8B5CF6)
                                  : found
                                      ? const Color(0xFF0F766E)
                                      : const Color(0xFF142A4C),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: selected
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
              if (_timeExpired)
                FilledButton.icon(
                  onPressed: () => setState(_startAttempt),
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Tekrar Dene'),
                )
              else if (_allTargetsFound)
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
    required this.icon,
    required this.label,
    this.warning = false,
  });

  final IconData icon;
  final String label;
  final bool warning;

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
