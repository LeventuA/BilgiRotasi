import 'package:bilgi_rotasi/word_hunt/word_hunt_models.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_path.dart';
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
  runApp(const _AutoCompletionQaApp());
}

class _AutoCompletionQaApp extends StatelessWidget {
  const _AutoCompletionQaApp();

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Kelime Avı V6 Auto QA',
      home: _Selector(),
    );
  }
}

class _Selector extends StatefulWidget {
  const _Selector();

  @override
  State<_Selector> createState() => _SelectorState();
}

class _SelectorState extends State<_Selector> {
  @override
  void initState() {
    super.initState();
    _scheduleGeometry();
  }

  void _scheduleGeometry([int attempt = 1]) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final centers = _centersForKeys(<String>{
        'word_hunt_v6_auto_open_5',
        'word_hunt_v6_auto_open_10',
      });
      if (centers.length == 2) {
        final ratio = WidgetsBinding
            .instance.platformDispatcher.views.first.devicePixelRatio;
        for (final level in <int>[5, 10]) {
          final center = centers['word_hunt_v6_auto_open_$level']!;
          debugPrint(
            '[WORD_HUNT_V6_AUTO_QA_BUTTON] level=$level '
            'x=${(center.dx * ratio).round()} y=${(center.dy * ratio).round()}',
          );
        }
        debugPrint('[WORD_HUNT_V6_AUTO_QA_SELECTOR_READY]');
        return;
      }
      if (attempt < 30) {
        Future<void>.delayed(const Duration(milliseconds: 200), () {
          if (mounted) _scheduleGeometry(attempt + 1);
        });
      }
    });
  }

  Future<void> _open(int levelIndex) async {
    debugPrint('[WORD_HUNT_V6_AUTO_QA_OPEN] level=$levelIndex');
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => _QaLevel(levelIndex: levelIndex),
      ),
    );
    if (mounted) _scheduleGeometry();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF061425),
      body: SafeArea(
        child: Center(
          child: SizedBox(
            width: 340,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const Text(
                  'Kelime Avı V6 Auto QA',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFFFFF1D0),
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  key: const Key('word_hunt_v6_auto_open_5'),
                  onPressed: () => _open(5),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text('Bölüm 5'),
                  ),
                ),
                const SizedBox(height: 14),
                FilledButton(
                  key: const Key('word_hunt_v6_auto_open_10'),
                  onPressed: () => _open(10),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text('Bölüm 10'),
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

class _QaLevel extends StatefulWidget {
  const _QaLevel({required this.levelIndex});

  final int levelIndex;

  @override
  State<_QaLevel> createState() => _QaLevelState();
}

class _QaLevelState extends State<_QaLevel> {
  late final WordHuntLevelDefinition level;

  @override
  void initState() {
    super.initState();
    level = WordHuntStarterContent.baslangicLimani.levels[widget.levelIndex - 1];
    _scheduleGeometry();
  }

  void _scheduleGeometry([int attempt = 1]) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final wanted = <String>{
        for (var row = 0; row < 8; row++)
          for (var column = 0; column < 8; column++)
            'word_hunt_production_cell_${row}_$column',
      };
      final centers = _centersForKeys(wanted);
      if (centers.length == 64) {
        final ratio = WidgetsBinding
            .instance.platformDispatcher.views.first.devicePixelRatio;
        for (final word in level.targetWords) {
          final endpoints = _findStraightPath(level, word);
          final start = centers[
            'word_hunt_production_cell_${endpoints[0]}_${endpoints[1]}'
          ]!;
          final end = centers[
            'word_hunt_production_cell_${endpoints[2]}_${endpoints[3]}'
          ]!;
          debugPrint(
            '[WORD_HUNT_V6_AUTO_QA_SWIPE] level=${widget.levelIndex} '
            'word=$word x1=${(start.dx * ratio).round()} '
            'y1=${(start.dy * ratio).round()} '
            'x2=${(end.dx * ratio).round()} '
            'y2=${(end.dy * ratio).round()}',
          );
        }
        debugPrint(
          '[WORD_HUNT_V6_AUTO_QA_READY] level=${widget.levelIndex} '
          'cells=64 targets=${level.targetWords.length}',
        );
        return;
      }
      if (attempt < 40) {
        Future<void>.delayed(const Duration(milliseconds: 200), () {
          if (mounted) _scheduleGeometry(attempt + 1);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WordHuntLevelProductionScreen(
      level: level,
      infoCards: WordHuntStarterContent.infoCards,
    );
  }
}

Map<String, Offset> _centersForKeys(Set<String> wanted) {
  final result = <String, Offset>{};

  void visit(Element element) {
    final key = element.widget.key;
    if (key is ValueKey<String> && wanted.contains(key.value)) {
      final renderObject = element.renderObject;
      if (renderObject is RenderBox && renderObject.hasSize) {
        result[key.value] = renderObject.localToGlobal(
          renderObject.size.center(Offset.zero),
        );
      }
    }
    element.visitChildren(visit);
  }

  WidgetsBinding.instance.rootElement?.visitChildren(visit);
  return result;
}

List<int> _findStraightPath(WordHuntLevelDefinition level, String word) {
  final target = WordHuntPathEngine.normalizeWord(word);
  final length = word.runes.length;
  const directions = <List<int>>[
    [-1, -1],
    [-1, 0],
    [-1, 1],
    [0, -1],
    [0, 1],
    [1, -1],
    [1, 0],
    [1, 1],
  ];

  for (var row = 0; row < level.rowCount; row++) {
    for (var column = 0; column < level.columnCount; column++) {
      for (final direction in directions) {
        final endRow = row + direction[0] * (length - 1);
        final endColumn = column + direction[1] * (length - 1);
        if (endRow < 0 ||
            endRow >= level.rowCount ||
            endColumn < 0 ||
            endColumn >= level.columnCount) {
          continue;
        }

        final buffer = StringBuffer();
        for (var step = 0; step < length; step++) {
          final currentRow = row + direction[0] * step;
          final currentColumn = column + direction[1] * step;
          buffer.write(
            String.fromCharCode(
              level.grid[currentRow].runes.elementAt(currentColumn),
            ),
          );
        }
        if (WordHuntPathEngine.normalizeWord(buffer.toString()) == target) {
          return <int>[row, column, endRow, endColumn];
        }
      }
    }
  }
  throw StateError('Straight path bulunamadı: ${level.id} / $word');
}
