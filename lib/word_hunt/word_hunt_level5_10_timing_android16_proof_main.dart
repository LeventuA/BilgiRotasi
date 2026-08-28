import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'word_hunt_screens.dart';
import 'word_hunt_starter_content.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
    DeviceOrientation.portraitUp,
  ]);
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  runApp(const WordHuntLevel5And10TimingQaApp());
}

class WordHuntLevel5And10TimingQaApp extends StatefulWidget {
  const WordHuntLevel5And10TimingQaApp({super.key});

  @override
  State<WordHuntLevel5And10TimingQaApp> createState() =>
      _WordHuntLevel5And10TimingQaAppState();
}

class _WordHuntLevel5And10TimingQaAppState
    extends State<WordHuntLevel5And10TimingQaApp> {
  String? _activeLevelId;
  String _lastResult = 'Henüz oynanmadı';

  Future<void> _openLevel(int index) async {
    final level = WordHuntStarterContent.baslangicLimani.levels[index - 1];
    setState(() => _activeLevelId = level.id);
    debugPrint('[WORD_HUNT_TIMING_OPEN] level=${level.id}');

    final result = await Navigator.of(context).push<WordHuntLevelPlayResult>(
      MaterialPageRoute<WordHuntLevelPlayResult>(
        builder: (_) => WordHuntLevelProductionScreen(
          level: level,
          infoCards: WordHuntStarterContent.infoCards,
        ),
      ),
    );

    if (!mounted) return;
    if (result == null) {
      debugPrint('[WORD_HUNT_TIMING_RETURN] level=${level.id} result=none');
      setState(() {
        _lastResult = '${level.id}: sonuç yok';
        _activeLevelId = null;
      });
      return;
    }

    debugPrint(
      '[WORD_HUNT_TIMING_RETURN] level=${result.levelId} stars=${result.stars}',
    );
    setState(() {
      _lastResult = '${result.levelId}: ${result.stars} yıldız';
      _activeLevelId = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Kelime Avı B5/B10 Timing QA',
      builder: (context, child) => _TimingRuntimeProbe(
        activeLevelId: () => _activeLevelId,
        child: child ?? const SizedBox.shrink(),
      ),
      home: Scaffold(
        backgroundColor: const Color(0xFF06142E),
        appBar: AppBar(
          backgroundColor: const Color(0xFF06142E),
          foregroundColor: Colors.white,
          title: const Text('Kelime Avı Timing QA'),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Gerçek production ekranı ile Android 16 / insan süre testi',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Bu launcher yalnız QA içindir. Gameplay ekranı kopyalanmaz; '
                  'WordHuntLevelProductionScreen doğrudan açılır.',
                  style: TextStyle(color: Color(0xFFA7B0C9), height: 1.4),
                ),
                const SizedBox(height: 28),
                FilledButton(
                  key: const Key('word_hunt_timing_open_5'),
                  onPressed: () => _openLevel(5),
                  child: const Text('Bölüm 5'),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  key: const Key('word_hunt_timing_open_10'),
                  onPressed: () => _openLevel(10),
                  child: const Text('Bölüm 10'),
                ),
                const SizedBox(height: 28),
                Text(
                  'Son sonuç: $_lastResult',
                  key: const Key('word_hunt_timing_last_result'),
                  style: const TextStyle(color: Color(0xFFD6D9E8)),
                ),
                const Spacer(),
                const Text(
                  'Not: timeLimitSeconds enforcement ayrı product bug olarak '
                  'izlenir; bu QA branch product davranışını değiştirmez.',
                  style: TextStyle(color: Color(0xFFFFD166), fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TimingRuntimeProbe extends StatefulWidget {
  const _TimingRuntimeProbe({
    required this.activeLevelId,
    required this.child,
  });

  final String? Function() activeLevelId;
  final Widget child;

  @override
  State<_TimingRuntimeProbe> createState() => _TimingRuntimeProbeState();
}

class _TimingRuntimeProbeState extends State<_TimingRuntimeProbe> {
  Timer? _timer;
  final Set<String> _emitted = <String>{};
  String? _resultSignature;

  static const _geometryKeys = <String>[
    'word_hunt_timing_open_5',
    'word_hunt_timing_open_10',
    'word_hunt_production_grid',
    'word_hunt_production_back',
    'word_hunt_production_finish',
    'word_hunt_production_return_route',
  ];

  static const _trackedWords = <String>[
    'ANKARA',
    'ŞEHİR',
    'KALE',
    'PUSULA',
    'YOL',
    'BİLGİ',
    'YILDIZ',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scan());
    _timer = Timer.periodic(const Duration(milliseconds: 100), (_) => _scan());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _scan() {
    if (!mounted) return;
    final root = WidgetsBinding.instance.rootElement;
    if (root == null) return;

    final levelId = widget.activeLevelId();
    final productionVisible =
        _findByKey(root, const Key('word_hunt_production_screen')) != null;
    if (productionVisible && levelId != null) {
      _emitOnce(
        'visible:$levelId',
        '[WORD_HUNT_TIMING_VISIBLE] level=$levelId',
      );
      _emitTextUnderKey(root, 'word_hunt_production_elapsed_text', 'elapsed');
      _emitTextUnderKey(root, 'word_hunt_production_progress', 'progress');
      _emitTextUnderKey(root, 'word_hunt_production_mistakes', 'mistakes');

      for (final word in _trackedWords) {
        final targetFound = _findByKey(
          root,
          Key('word_hunt_production_target_${word}_found'),
        );
        if (targetFound != null) {
          _emitOnce(
            'found:$levelId:target:$word',
            '[WORD_HUNT_TIMING_FOUND] level=$levelId kind=target word=$word',
          );
        }
        final bonusFound = _findByKey(
          root,
          Key('word_hunt_production_bonus_${word}_found'),
        );
        if (bonusFound != null) {
          _emitOnce(
            'found:$levelId:bonus:$word',
            '[WORD_HUNT_TIMING_FOUND] level=$levelId kind=bonus word=$word',
          );
        }
      }
    }

    for (final keyName in _geometryKeys) {
      final element = _findByKey(root, Key(keyName));
      if (element == null) continue;
      final box = element.renderObject;
      if (box is! RenderBox || !box.hasSize) continue;
      final dpr = View.of(context).devicePixelRatio;
      final topLeft = box.localToGlobal(Offset.zero) * dpr;
      final size = box.size * dpr;
      final center = topLeft + Offset(size.width / 2, size.height / 2);
      final signature =
          '$keyName|${topLeft.dx.round()}|${topLeft.dy.round()}|'
          '${size.width.round()}|${size.height.round()}';
      if (!_emitted.add('geometry:$signature')) continue;
      debugPrint(
        '[WORD_HUNT_TIMING_GEOMETRY] key=$keyName '
        'left=${topLeft.dx.round()} top=${topLeft.dy.round()} '
        'width=${size.width.round()} height=${size.height.round()} '
        'center=${center.dx.round()},${center.dy.round()}',
      );
    }

    final dialog = _findByKey(
      root,
      const Key('word_hunt_production_result_dialog'),
    );
    if (dialog != null && levelId != null) {
      final elapsed = _textUnderKey(
        root,
        const Key('word_hunt_production_result_elapsed'),
      );
      final mistakes = _textUnderKey(
        root,
        const Key('word_hunt_production_result_mistakes'),
      );
      final bonus = _firstTextMatching(dialog, (value) => value.startsWith('Bonus:'));
      final stars = _resultStars(root);
      final signature = '$levelId|$elapsed|$mistakes|$stars|$bonus';
      if (_resultSignature != signature) {
        _resultSignature = signature;
        debugPrint(
          '[WORD_HUNT_TIMING_RESULT] level=$levelId elapsed=$elapsed '
          'mistakes=$mistakes stars=$stars bonus=${bonus ?? 'none'}',
        );
        _scheduleFreezeCheck(levelId, elapsed);
      }
    }
  }

  void _scheduleFreezeCheck(String levelId, String? before) {
    if (before == null) return;
    final key = 'freeze-scheduled:$levelId:$before';
    if (!_emitted.add(key)) return;
    Timer(const Duration(seconds: 2), () {
      if (!mounted) return;
      final root = WidgetsBinding.instance.rootElement;
      if (root == null) return;
      final after = _textUnderKey(
        root,
        const Key('word_hunt_production_result_elapsed'),
      );
      final pass = after == before;
      debugPrint(
        '[WORD_HUNT_TIMING_FREEZE] level=$levelId before=$before '
        'after=$after pass=$pass',
      );
    });
  }

  void _emitTextUnderKey(Element root, String keyName, String label) {
    final value = _textUnderKey(root, Key(keyName));
    final levelId = widget.activeLevelId();
    if (value == null || levelId == null) return;
    final signature = 'state:$levelId:$label:$value';
    if (!_emitted.add(signature)) return;
    debugPrint(
      '[WORD_HUNT_TIMING_STATE] level=$levelId $label=$value',
    );
  }

  int _resultStars(Element root) {
    var filled = 0;
    for (var index = 1; index <= 3; index++) {
      final element = _findByKey(
        root,
        Key('word_hunt_production_result_star_$index'),
      );
      final widget = element?.widget;
      if (widget is Icon && widget.icon == Icons.star_rounded) filled++;
    }
    return filled;
  }

  String? _textUnderKey(Element root, Key key) {
    final element = _findByKey(root, key);
    if (element == null) return null;
    if (element.widget is Text) {
      return (element.widget as Text).data;
    }
    return _firstTextMatching(element, (_) => true);
  }

  String? _firstTextMatching(Element root, bool Function(String value) accept) {
    String? result;
    void visitor(Element element) {
      if (result != null) return;
      final widget = element.widget;
      if (widget is Text && widget.data != null && accept(widget.data!)) {
        result = widget.data;
        return;
      }
      element.visitChildren(visitor);
    }

    visitor(root);
    return result;
  }

  void _emitOnce(String signature, String message) {
    if (_emitted.add(signature)) debugPrint(message);
  }

  Element? _findByKey(Element root, Key key) {
    Element? result;
    void visitor(Element element) {
      if (result != null) return;
      if (element.widget.key == key) {
        result = element;
        return;
      }
      element.visitChildren(visitor);
    }

    visitor(root);
    return result;
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
