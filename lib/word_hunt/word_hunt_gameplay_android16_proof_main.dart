import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'word_hunt_gameplay_flow.dart';
import 'word_hunt_progress.dart';
import 'word_hunt_starter_content.dart';

/// Android 16 QA kanıtı için izole giriş noktası.
///
/// Görünür ürün akışı doğrudan [WordHuntGameplayFlow] kullanır. Bu dosyadaki
/// probe yalnız gerçek widget durumunu ve fiziksel ekran geometrisini loglar;
/// gameplay sonucu üretmez ve product davranışını taklit etmez.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
    DeviceOrientation.portraitUp,
  ]);
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  runApp(const _WordHuntGameplayAndroid16ProofApp());
}

class _WordHuntGameplayAndroid16ProofApp extends StatefulWidget {
  const _WordHuntGameplayAndroid16ProofApp();

  @override
  State<_WordHuntGameplayAndroid16ProofApp> createState() =>
      _WordHuntGameplayAndroid16ProofAppState();
}

class _WordHuntGameplayAndroid16ProofAppState
    extends State<_WordHuntGameplayAndroid16ProofApp> {
  WordHuntProgressSnapshot _latestProgress = const WordHuntProgressSnapshot();

  void _recordProgress(WordHuntProgressSnapshot progress) {
    _latestProgress = progress;
    final route = WordHuntStarterContent.baslangicLimani;
    final total = WordHuntRouteProgressEngine.totalStars(route, progress);
    final nodeTwoUnlocked = WordHuntRouteProgressEngine.isLevelUnlocked(
      route,
      progress,
      2,
    );
    debugPrint(
      '[WORD_HUNT_PROOF_PROGRESS_RECORDED] '
      'level1=${progress.starsFor('baslangic-1')} '
      'total=$total node2Unlocked=$nodeTwoUnlocked',
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Kelime Avı Bölüm 1 Android 16 Proof',
      home: _GameplayRuntimeProbe(
        progress: () => _latestProgress,
        child: WordHuntGameplayFlow(onProgressChanged: _recordProgress),
      ),
    );
  }
}

class _GameplayRuntimeProbe extends StatefulWidget {
  const _GameplayRuntimeProbe({required this.progress, required this.child});

  final WordHuntProgressSnapshot Function() progress;
  final Widget child;

  @override
  State<_GameplayRuntimeProbe> createState() => _GameplayRuntimeProbeState();
}

class _GameplayRuntimeProbeState extends State<_GameplayRuntimeProbe> {
  Timer? _probeTimer;
  bool _routeVisible = false;
  bool _gameplayVisible = false;
  int _routeVisit = 0;
  int _attempt = 0;
  final Set<String> _emitted = <String>{};

  static const List<String> _geometryKeys = <String>[
    'word_hunt_reference_level_1',
    'word_hunt_reference_level_2',
    'word_hunt_production_grid',
    'word_hunt_production_back',
    'word_hunt_production_finish',
    'word_hunt_production_return_route',
    'word_hunt_production_exit_confirm',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scan());
    _probeTimer = Timer.periodic(
      const Duration(milliseconds: 60),
      (_) => _scan(),
    );
  }

  @override
  void dispose() {
    _probeTimer?.cancel();
    super.dispose();
  }

  void _scan() {
    if (!mounted) return;
    final root = WidgetsBinding.instance.rootElement;
    if (root == null) return;

    final routeNow =
        _findByKey(root, const Key('word_hunt_production_master_art_route')) !=
        null;
    final gameplayNow =
        _findByKey(root, const Key('word_hunt_production_screen')) != null;

    if (routeNow && !_routeVisible) {
      _routeVisit++;
      final progress = widget.progress();
      final route = WordHuntStarterContent.baslangicLimani;
      final total = WordHuntRouteProgressEngine.totalStars(route, progress);
      final levelOneStars = progress.starsFor('baslangic-1');
      final nodeTwoUnlocked = WordHuntRouteProgressEngine.isLevelUnlocked(
        route,
        progress,
        2,
      );
      debugPrint(
        '[WORD_HUNT_PROOF_ROUTE_VISIBLE] visit=$_routeVisit '
        'total=$total level1=$levelOneStars '
        'node2Unlocked=$nodeTwoUnlocked',
      );
    }
    if (gameplayNow && !_gameplayVisible) {
      _attempt++;
      debugPrint('[WORD_HUNT_PROOF_GAMEPLAY_VISIBLE] attempt=$_attempt');
    }
    _routeVisible = routeNow;
    _gameplayVisible = gameplayNow;

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
          'geometry|$_routeVisit|$_attempt|$keyName|'
          '${topLeft.dx.round()}|${topLeft.dy.round()}|'
          '${size.width.round()}|${size.height.round()}';
      if (!_emitted.add(signature)) continue;
      debugPrint(
        '[WORD_HUNT_PROOF_GEOMETRY] key=$keyName '
        'left=${topLeft.dx.round()} top=${topLeft.dy.round()} '
        'width=${size.width.round()} height=${size.height.round()} '
        'center=${center.dx.round()},${center.dy.round()}',
      );
    }

    if (!gameplayNow) return;
    _emitPresence(
      root,
      'word_hunt_production_target_KALEM_found',
      '[WORD_HUNT_PROOF_TARGET_FOUND] attempt=$_attempt word=KALEM',
    );
    _emitPresence(
      root,
      'word_hunt_production_target_MASA_found',
      '[WORD_HUNT_PROOF_TARGET_FOUND] attempt=$_attempt word=MASA',
    );
    _emitPresence(
      root,
      'word_hunt_production_bonus_ELMA_found',
      '[WORD_HUNT_PROOF_BONUS_FOUND] attempt=$_attempt word=ELMA',
    );
    _emitPresence(
      root,
      'word_hunt_production_error_cell_3_0',
      '[WORD_HUNT_PROOF_ERROR_VISIBLE] attempt=$_attempt anchor=3,0',
      allowRepeats: true,
    );
    _emitTextUnderKey(root, 'word_hunt_production_mistakes', 'mistakes');
    _emitTextUnderKey(root, 'word_hunt_production_progress', 'progress');
    _emitPresence(
      root,
      'word_hunt_production_exit_dialog',
      '[WORD_HUNT_PROOF_EXIT_CONFIRMATION] attempt=$_attempt',
    );
    _emitPresence(
      root,
      'word_hunt_production_result_dialog',
      '[WORD_HUNT_PROOF_RESULT_DIALOG] attempt=$_attempt',
    );
    _emitResultStars(root);
  }

  void _emitPresence(
    Element root,
    String keyName,
    String message, {
    bool allowRepeats = false,
  }) {
    if (_findByKey(root, Key(keyName)) == null) return;
    final signature = '$message|$keyName';
    if (!allowRepeats && !_emitted.add(signature)) return;
    if (allowRepeats) {
      final activeSignature = '$signature|active';
      if (!_emitted.add(activeSignature)) return;
      Timer(const Duration(milliseconds: 400), () {
        _emitted.remove(activeSignature);
      });
    }
    debugPrint(message);
  }

  void _emitTextUnderKey(Element root, String keyName, String label) {
    final element = _findByKey(root, Key(keyName));
    if (element == null) return;
    String? value;
    void visitor(Element child) {
      final widget = child.widget;
      if (widget is Text && widget.data != null) value ??= widget.data;
      child.visitChildren(visitor);
    }

    element.visitChildren(visitor);
    if (value == null) return;
    final signature = '$label|$_attempt|$value';
    if (!_emitted.add(signature)) return;
    debugPrint('[WORD_HUNT_PROOF_STATE] attempt=$_attempt $label=${value!}');
  }

  void _emitResultStars(Element root) {
    if (_findByKey(root, const Key('word_hunt_production_result_dialog')) ==
        null) {
      return;
    }
    var filled = 0;
    for (var index = 1; index <= 3; index++) {
      final element = _findByKey(
        root,
        Key('word_hunt_production_result_star_$index'),
      );
      final widget = element?.widget;
      if (widget is Icon && widget.icon == Icons.star_rounded) filled++;
    }
    final signature = 'result-stars|$_attempt|$filled';
    if (!_emitted.add(signature)) return;
    debugPrint(
      '[WORD_HUNT_PROOF_RESULT_STARS] attempt=$_attempt value=$filled',
    );
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
