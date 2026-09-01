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
      title: 'Kelime Avı V6 Süre Testi',
      home: _HumanTimingSelector(),
    ),
  );

  WidgetsBinding.instance.addPostFrameCallback((_) {
    _logSelectorGeometry();
    debugPrint('[WORD_HUNT_V6_HUMAN_QA_SELECTOR_READY]');
  });
}

void _logSelectorGeometry() {
  var buttonCount = 0;
  final pixelRatio =
      WidgetsBinding.instance.platformDispatcher.views.first.devicePixelRatio;

  void visit(Element element) {
    final key = element.widget.key;
    final value = key is ValueKey<String> ? key.value : '';
    final match = RegExp(r'^word_hunt_v6_human_open_(5|10)$').firstMatch(value);
    final renderObject = element.renderObject;
    if (match != null && renderObject is RenderBox && renderObject.hasSize) {
      final center = renderObject.localToGlobal(
        renderObject.size.center(Offset.zero),
      );
      debugPrint(
        '[WORD_HUNT_V6_HUMAN_QA_BUTTON] level=${match.group(1)} '
        'x=${(center.dx * pixelRatio).round()} '
        'y=${(center.dy * pixelRatio).round()}',
      );
      buttonCount += 1;
    }
    element.visitChildren(visit);
  }

  WidgetsBinding.instance.rootElement?.visitChildren(visit);
  debugPrint('[WORD_HUNT_V6_HUMAN_QA_SELECTOR_GEOMETRY] buttons=$buttonCount');
}

class _HumanTimingSelector extends StatelessWidget {
  const _HumanTimingSelector();

  Future<void> _openLevel(
    BuildContext context, {
    required int levelIndex,
    required int targetSeconds,
  }) async {
    debugPrint(
      '[WORD_HUNT_V6_HUMAN_QA_OPEN] '
      'level=$levelIndex targetSeconds=$targetSeconds',
    );
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => _HumanTimingLevel(levelIndex: levelIndex),
      ),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _logSelectorGeometry();
      debugPrint('[WORD_HUNT_V6_HUMAN_QA_SELECTOR_READY]');
    });
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
                  'Kelime Avı V6',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFFFFF1D0),
                    fontFamily: 'serif',
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Gerçek İnsan Süre Testi',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFFFFCA62),
                    fontFamily: 'serif',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Bölümü normal şekilde bitir. Sonuç penceresindeki saniye ve '
                  'hata sayısını not et. Süre dolunca oyun kapanmaz; hedef yalnız '
                  'zorluk ölçüsüdür.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFFD6D9E8),
                    fontSize: 14,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 28),
                FilledButton(
                  key: const Key('word_hunt_v6_human_open_5'),
                  onPressed:
                      () =>
                          _openLevel(context, levelIndex: 5, targetSeconds: 60),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text('B5 — hedef 60 saniye'),
                  ),
                ),
                const SizedBox(height: 14),
                FilledButton(
                  key: const Key('word_hunt_v6_human_open_10'),
                  onPressed:
                      () => _openLevel(
                        context,
                        levelIndex: 10,
                        targetSeconds: 120,
                      ),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text('B10 — hedef 120 saniye'),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Bu QA uygulaması kayıt/ilerleme ve Play sürümünden bağımsızdır.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xFF9AA8BE), fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HumanTimingLevel extends StatefulWidget {
  const _HumanTimingLevel({required this.levelIndex});

  final int levelIndex;

  @override
  State<_HumanTimingLevel> createState() => _HumanTimingLevelState();
}

class _HumanTimingLevelState extends State<_HumanTimingLevel> {
  @override
  void initState() {
    super.initState();
    final level =
        WordHuntStarterContent.baslangicLimani.levels[widget.levelIndex - 1];
    debugPrint(
      '[WORD_HUNT_V6_HUMAN_QA_CONFIG] '
      'level=${widget.levelIndex} rows=${level.rowCount} '
      'cols=${level.columnCount} targets=${level.targetWords.length} '
      'bonus=${level.bonusWords.length}',
    );
    _scheduleProductionCellGeometryProbe();
  }

  void _scheduleProductionCellGeometryProbe([int attempt = 1]) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final cellCount = _logProductionCellGeometry();
      if (cellCount == 64) {
        debugPrint(
          '[WORD_HUNT_V6_HUMAN_QA_READY] '
          'level=${widget.levelIndex} cells=64',
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

    void visit(Element element) {
      final key = element.widget.key;
      final match = RegExp(
        r'^word_hunt_production_cell_(\d+)_(\d+)$',
      ).firstMatch(key is ValueKey<String> ? key.value : '');
      final renderObject = element.renderObject;
      if (match != null && renderObject is RenderBox && renderObject.hasSize) {
        cellCount += 1;
      }
      element.visitChildren(visit);
    }

    WidgetsBinding.instance.rootElement?.visitChildren(visit);
    debugPrint(
      '[WORD_HUNT_V6_HUMAN_QA_GEOMETRY] '
      'level=${widget.levelIndex} cells=$cellCount',
    );
    return cellCount;
  }

  @override
  Widget build(BuildContext context) {
    final level =
        WordHuntStarterContent.baslangicLimani.levels[widget.levelIndex - 1];
    return WordHuntLevelProductionScreen(
      level: level,
      infoCards: WordHuntStarterContent.infoCards,
    );
  }
}
