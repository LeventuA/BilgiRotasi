import 'package:bilgi_rotasi/word_hunt/word_hunt_screens.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_starter_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
    DeviceOrientation.portraitUp,
  ]);
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Kelime Avı V5 Android 16 QA',
      home: _V5GameplayQaSelector(),
    ),
  );

  WidgetsBinding.instance.addPostFrameCallback((_) {
    _logSelectorGeometry();
    debugPrint('[WORD_HUNT_V5_QA_SELECTOR_READY]');
  });
}

void _logSelectorGeometry() {
  var buttonCount = 0;
  final pixelRatio =
      WidgetsBinding.instance.platformDispatcher.views.first.devicePixelRatio;

  void visit(Element element) {
    final key = element.widget.key;
    final value = key is ValueKey<String> ? key.value : '';
    final match = RegExp(r'^word_hunt_v5_qa_open_(.+)$').firstMatch(value);
    final renderObject = element.renderObject;
    if (match != null && renderObject is RenderBox && renderObject.hasSize) {
      final center = renderObject.localToGlobal(
        renderObject.size.center(Offset.zero),
      );
      debugPrint(
        '[WORD_HUNT_V5_QA_SELECTOR] id=${match.group(1)} '
        'x=${(center.dx * pixelRatio).round()} '
        'y=${(center.dy * pixelRatio).round()}',
      );
      buttonCount += 1;
    }
    element.visitChildren(visit);
  }

  WidgetsBinding.instance.rootElement?.visitChildren(visit);
  debugPrint('[WORD_HUNT_V5_QA_SELECTOR_GEOMETRY] buttons=$buttonCount');
}

class _V5GameplayQaSelector extends StatelessWidget {
  const _V5GameplayQaSelector();

  void _openLevel(
    BuildContext context, {
    required int levelIndex,
    int timeOffsetSeconds = 0,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder:
            (_) => _V5GameplayQaLevel(
              levelIndex: levelIndex,
              timeOffsetSeconds: timeOffsetSeconds,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF061425),
      body: SafeArea(
        child: Center(
          child: SizedBox(
            width: 320,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const Text(
                  'Kelime Avı V5 Gameplay QA',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFFFFF1D0),
                    fontFamily: 'serif',
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 28),
                for (final levelIndex in const <int>[1, 5, 8, 10]) ...[
                  FilledButton(
                    key: Key('word_hunt_v5_qa_open_$levelIndex'),
                    onPressed:
                        () => _openLevel(context, levelIndex: levelIndex),
                    child: Text('QA B$levelIndex'),
                  ),
                  const SizedBox(height: 12),
                ],
                OutlinedButton(
                  key: const Key('word_hunt_v5_qa_open_5_soft_time'),
                  onPressed:
                      () => _openLevel(
                        context,
                        levelIndex: 5,
                        timeOffsetSeconds: 65,
                      ),
                  child: const Text('QA B5+65'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _V5GameplayQaLevel extends StatefulWidget {
  const _V5GameplayQaLevel({
    required this.levelIndex,
    required this.timeOffsetSeconds,
  });

  final int levelIndex;
  final int timeOffsetSeconds;

  @override
  State<_V5GameplayQaLevel> createState() => _V5GameplayQaLevelState();
}

class _V5GameplayQaLevelState extends State<_V5GameplayQaLevel> {
  late final DateTime _startedAt;
  var _firstClockRead = true;

  @override
  void initState() {
    super.initState();
    _startedAt = DateTime.now();
    final level =
        WordHuntStarterContent.baslangicLimani.levels[widget.levelIndex - 1];
    debugPrint(
      '[WORD_HUNT_V5_QA_CONFIG] '
      'level=${widget.levelIndex} rows=${level.rowCount} '
      'cols=${level.columnCount} targets=${level.targetWords.length} '
      'bonus=${level.bonusWords.length} '
      'timeOffset=${widget.timeOffsetSeconds}',
    );
    _scheduleProductionCellGeometryProbe();
  }

  void _scheduleProductionCellGeometryProbe([int attempt = 1]) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final cellCount = _logProductionCellGeometry();
      if (cellCount == 64) {
        debugPrint(
          '[WORD_HUNT_V5_QA_READY] level=${widget.levelIndex} '
          'timeOffset=${widget.timeOffsetSeconds} cells=64',
        );
        return;
      }
      if (attempt < 20) {
        Future<void>.delayed(const Duration(milliseconds: 250), () {
          if (mounted) _scheduleProductionCellGeometryProbe(attempt + 1);
        });
      }
    });
  }

  int _logProductionCellGeometry() {
    var cellCount = 0;
    final pixelRatio =
        WidgetsBinding.instance.platformDispatcher.views.first.devicePixelRatio;

    void visit(Element element) {
      final key = element.widget.key;
      final match = RegExp(
        r'^word_hunt_production_cell_(\d+)_(\d+)$',
      ).firstMatch(key is ValueKey<String> ? key.value : '');
      final renderObject = element.renderObject;
      if (match != null && renderObject is RenderBox && renderObject.hasSize) {
        final center = renderObject.localToGlobal(
          renderObject.size.center(Offset.zero),
        );
        debugPrint(
          '[WORD_HUNT_V5_QA_CELL] level=${widget.levelIndex} '
          'row=${match.group(1)} col=${match.group(2)} '
          'x=${(center.dx * pixelRatio).round()} '
          'y=${(center.dy * pixelRatio).round()}',
        );
        cellCount += 1;
      }
      element.visitChildren(visit);
    }

    WidgetsBinding.instance.rootElement?.visitChildren(visit);
    debugPrint(
      '[WORD_HUNT_V5_QA_GEOMETRY] '
      'level=${widget.levelIndex} cells=$cellCount',
    );
    return cellCount;
  }

  DateTime _qaNow() {
    if (_firstClockRead) {
      _firstClockRead = false;
      return _startedAt;
    }
    return _startedAt
        .add(Duration(seconds: widget.timeOffsetSeconds))
        .add(DateTime.now().difference(_startedAt));
  }

  @override
  Widget build(BuildContext context) {
    final level =
        WordHuntStarterContent.baslangicLimani.levels[widget.levelIndex - 1];
    return WordHuntLevelProductionScreen(
      level: level,
      infoCards: WordHuntStarterContent.infoCards,
      now: _qaNow,
    );
  }
}
