import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'word_hunt_models.dart';
import 'word_hunt_path.dart';
import 'word_hunt_screens.dart';
import 'word_hunt_starter_content.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const _WordHuntAndroid16QaApp());
}

class _WordHuntAndroid16QaApp extends StatelessWidget {
  const _WordHuntAndroid16QaApp();

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: _WordHuntAndroid16QaHost(),
    );
  }
}

class _WordHuntAndroid16QaHost extends StatefulWidget {
  const _WordHuntAndroid16QaHost();

  @override
  State<_WordHuntAndroid16QaHost> createState() =>
      _WordHuntAndroid16QaHostState();
}

class _WordHuntAndroid16QaHostState extends State<_WordHuntAndroid16QaHost> {
  static const _qaLevelIndexes = <int>[1, 5, 8, 10];
  static const _markerHold = Duration(milliseconds: 2500);

  DateTime _qaNow = DateTime.utc(2026, 8, 28, 12);
  int _nextPointer = 1;
  String _status = 'Android 16 QA hazırlanıyor…';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => unawaited(_runQa()));
  }

  Future<void> _runQa() async {
    try {
      for (final levelIndex in _qaLevelIndexes) {
        await _runLevel(levelIndex);
      }
      _log('ALL_PASS');
      if (mounted) setState(() => _status = 'QA PASS');
    } catch (error, stackTrace) {
      debugPrint('[WORD_HUNT_6X10_QA_FAIL] $error');
      debugPrintStack(stackTrace: stackTrace);
      if (mounted) setState(() => _status = 'QA FAIL: $error');
    }
  }

  Future<void> _runLevel(int levelIndex) async {
    final level = WordHuntStarterContent.baslangicLimani.levels[levelIndex - 1];
    _qaNow = DateTime.utc(2026, 8, 28, 12);

    final resultFuture = Navigator.of(context).push<WordHuntLevelPlayResult>(
      MaterialPageRoute<WordHuntLevelPlayResult>(
        builder: (_) => WordHuntLevelProductionScreen(
          level: level,
          infoCards: WordHuntStarterContent.infoCards,
          now: () => _qaNow,
        ),
      ),
    );

    await _waitForKey(const Key('word_hunt_production_screen'));
    await _waitForKey(const Key('word_hunt_production_grid'));
    _log('B${level.index}_OPEN');
    await Future<void>.delayed(_markerHold);

    if (level.index == 5) {
      _qaNow = _qaNow.add(const Duration(seconds: 61));
      await Future<void>.delayed(const Duration(milliseconds: 1100));
      _expect(
        _textForKey(const Key('word_hunt_production_elapsed_text')) == '61s',
        'B5 soft-time elapsed 61s görünmedi',
      );
    } else if (level.index == 10) {
      _qaNow = _qaNow.add(const Duration(seconds: 121));
      await Future<void>.delayed(const Duration(milliseconds: 1100));
      _expect(
        _textForKey(const Key('word_hunt_production_elapsed_text')) == '121s',
        'B10 soft-time elapsed 121s görünmedi',
      );
    }

    for (final word in level.targetWords) {
      await _dragPath(_uniquePathFor(level, word));
      await _waitForKey(Key('word_hunt_production_target_${word}_found'));
    }

    await _waitForKey(const Key('word_hunt_production_finish'));
    final frozenElapsed =
        _textForKey(const Key('word_hunt_production_elapsed_text'));

    _qaNow = _qaNow.add(const Duration(seconds: 200));
    await Future<void>.delayed(const Duration(milliseconds: 1100));
    _expect(
      _textForKey(const Key('word_hunt_production_elapsed_text')) ==
          frozenElapsed,
      'B${level.index} completion elapsed donmadı',
    );

    await _dragPath(_findWrongStraightPath(level));
    await Future<void>.delayed(const Duration(milliseconds: 350));

    for (final word in level.bonusWords) {
      await _dragPath(_uniquePathFor(level, word));
      await _waitForKey(Key('word_hunt_production_bonus_${word}_found'));
    }

    _expect(
      _textForKey(const Key('word_hunt_production_elapsed_text')) ==
          frozenElapsed,
      'B${level.index} bonus sonrası elapsed değişti',
    );

    _log('B${level.index}_READY');
    await Future<void>.delayed(_markerHold);

    await _tapKey(const Key('word_hunt_production_finish'));
    await _waitForKey(const Key('word_hunt_production_result_dialog'));
    _expect(
      _textForKey(const Key('word_hunt_production_result_mistakes')) ==
          '0 hata',
      'B${level.index} target sonrası yanlış seçim skora hata ekledi',
    );

    _log('B${level.index}_RESULT');
    await Future<void>.delayed(_markerHold);

    await _tapKey(const Key('word_hunt_production_return_route'));
    final result = await resultFuture.timeout(const Duration(seconds: 10));
    _expect(result != null, 'B${level.index} result null');
    _expect(result!.levelId == level.id, 'B${level.index} result levelId yanlış');

    final expectedStars = switch (level.index) {
      5 || 10 => 1,
      _ => 3,
    };
    _expect(
      result.stars == expectedStars,
      'B${level.index} yıldız ${result.stars}, beklenen $expectedStars',
    );

    _log('B${level.index}_PASS');
    await Future<void>.delayed(const Duration(milliseconds: 400));
  }

  List<WordHuntCell> _uniquePathFor(
    WordHuntLevelDefinition level,
    String word,
  ) {
    final matches = <String, List<WordHuntCell>>{};
    final wordLength = word.runes.length;
    const directions = <(int, int)>[
      (-1, -1),
      (-1, 0),
      (-1, 1),
      (0, -1),
      (0, 1),
      (1, -1),
      (1, 0),
      (1, 1),
    ];

    for (var row = 0; row < level.rowCount; row++) {
      for (var column = 0; column < level.columnCount; column++) {
        for (final (rowStep, columnStep) in directions) {
          final endRow = row + rowStep * (wordLength - 1);
          final endColumn = column + columnStep * (wordLength - 1);
          if (endRow < 0 ||
              endRow >= level.rowCount ||
              endColumn < 0 ||
              endColumn >= level.columnCount) {
            continue;
          }
          final path = List<WordHuntCell>.generate(
            wordLength,
            (index) => WordHuntCell(
              row + rowStep * index,
              column + columnStep * index,
            ),
            growable: false,
          );
          final result = WordHuntPathEngine.evaluate(
            level: level,
            path: path,
            foundTargetWords: const <String>{},
            foundBonusWords: const <String>{},
          );
          if (result.canonicalWord != word) continue;
          final forward = path.map((cell) => '${cell.row}:${cell.column}').join('|');
          final reverse = path.reversed
              .map((cell) => '${cell.row}:${cell.column}')
              .join('|');
          final physicalKey = forward.compareTo(reverse) <= 0 ? forward : reverse;
          matches.putIfAbsent(physicalKey, () => path);
        }
      }
    }

    _expect(matches.length == 1, '${level.id} $word occurrence=${matches.length}');
    return matches.values.single;
  }

  List<WordHuntCell> _findWrongStraightPath(WordHuntLevelDefinition level) {
    for (var row = 0; row < level.rowCount; row++) {
      for (var column = 0; column <= level.columnCount - 3; column++) {
        final path = <WordHuntCell>[
          WordHuntCell(row, column),
          WordHuntCell(row, column + 1),
          WordHuntCell(row, column + 2),
        ];
        final result = WordHuntPathEngine.evaluate(
          level: level,
          path: path,
          foundTargetWords: level.targetWords.toSet(),
          foundBonusWords: const <String>{},
        );
        if (result.kind == WordHuntSelectionKind.notAWord) return path;
      }
    }
    throw StateError('${level.id} için yanlış düz 3-hücre yolu bulunamadı');
  }

  Future<void> _dragPath(List<WordHuntCell> path) async {
    final middle = path[path.length ~/ 2];
    final middleElement = await _waitForKey(
      Key('word_hunt_production_cell_${middle.row}_${middle.column}'),
    );
    await Scrollable.ensureVisible(
      middleElement,
      alignment: 0.5,
      duration: const Duration(milliseconds: 180),
    );
    await Future<void>.delayed(const Duration(milliseconds: 120));

    final positions = <Offset>[];
    for (final cell in path) {
      final element = await _waitForKey(
        Key('word_hunt_production_cell_${cell.row}_${cell.column}'),
      );
      final box = element.renderObject! as RenderBox;
      positions.add(box.localToGlobal(box.size.center(Offset.zero)));
    }

    final viewSize = MediaQuery.sizeOf(context);
    for (final position in positions) {
      _expect(
        position.dx > 0 &&
            position.dx < viewSize.width &&
            position.dy > 0 &&
            position.dy < viewSize.height,
        'gesture hücresi viewport dışında: $position / $viewSize',
      );
    }

    final pointer = _nextPointer++;
    GestureBinding.instance.handlePointerEvent(
      PointerDownEvent(
        pointer: pointer,
        position: positions.first,
        kind: PointerDeviceKind.touch,
      ),
    );
    var previous = positions.first;
    for (final position in positions.skip(1)) {
      await Future<void>.delayed(const Duration(milliseconds: 55));
      GestureBinding.instance.handlePointerEvent(
        PointerMoveEvent(
          pointer: pointer,
          position: position,
          delta: position - previous,
          kind: PointerDeviceKind.touch,
        ),
      );
      previous = position;
    }
    await Future<void>.delayed(const Duration(milliseconds: 55));
    GestureBinding.instance.handlePointerEvent(
      PointerUpEvent(
        pointer: pointer,
        position: positions.last,
        kind: PointerDeviceKind.touch,
      ),
    );
    await Future<void>.delayed(const Duration(milliseconds: 220));
  }

  Future<void> _tapKey(Key key) async {
    final element = await _waitForKey(key);
    await Scrollable.ensureVisible(
      element,
      alignment: 0.7,
      duration: const Duration(milliseconds: 160),
    );
    await Future<void>.delayed(const Duration(milliseconds: 100));
    final box = element.renderObject! as RenderBox;
    final position = box.localToGlobal(box.size.center(Offset.zero));
    final pointer = _nextPointer++;
    GestureBinding.instance.handlePointerEvent(
      PointerDownEvent(
        pointer: pointer,
        position: position,
        kind: PointerDeviceKind.touch,
      ),
    );
    await Future<void>.delayed(const Duration(milliseconds: 70));
    GestureBinding.instance.handlePointerEvent(
      PointerUpEvent(
        pointer: pointer,
        position: position,
        kind: PointerDeviceKind.touch,
      ),
    );
    await Future<void>.delayed(const Duration(milliseconds: 220));
  }

  Future<Element> _waitForKey(Key key) async {
    for (var attempt = 0; attempt < 120; attempt++) {
      final element = _findElementByKey(key);
      if (element != null && element.mounted && element.renderObject != null) {
        return element;
      }
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }
    throw StateError('Key bulunamadı: $key');
  }

  Element? _findElementByKey(Key key) {
    Element? match;
    void visit(Element element) {
      if (match != null) return;
      if (element.widget.key == key) {
        match = element;
        return;
      }
      element.visitChildren(visit);
    }

    final root = WidgetsBinding.instance.rootElement;
    if (root != null) visit(root);
    return match;
  }

  String? _textForKey(Key key) {
    final element = _findElementByKey(key);
    final widget = element?.widget;
    return widget is Text ? widget.data : null;
  }

  void _expect(bool condition, String message) {
    if (!condition) throw StateError(message);
  }

  void _log(String marker) {
    debugPrint('[WORD_HUNT_6X10_QA_$marker]');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF06142E),
      body: Center(
        child: Text(
          _status,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white, fontSize: 20),
        ),
      ),
    );
  }
}
