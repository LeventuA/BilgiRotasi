import 'dart:async';

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
      home: _CompletionQaSelector(),
    ),
  );
}

class _CompletionQaSelector extends StatelessWidget {
  const _CompletionQaSelector();

  void _logGeometry() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ratio = WidgetsBinding
          .instance.platformDispatcher.views.first.devicePixelRatio;
      var count = 0;
      void visit(Element element) {
        final key = element.widget.key;
        final value = key is ValueKey<String> ? key.value : '';
        final match = RegExp(r'^completion_qa_open_(5|10)$').firstMatch(value);
        final renderObject = element.renderObject;
        if (match != null && renderObject is RenderBox && renderObject.hasSize) {
          final center = renderObject.localToGlobal(
            renderObject.size.center(Offset.zero),
          );
          debugPrint(
            '[COMP_QA_BUTTON] level=${match.group(1)} '
            'x=${(center.dx * ratio).round()} y=${(center.dy * ratio).round()}',
          );
          count += 1;
        }
        element.visitChildren(visit);
      }
      WidgetsBinding.instance.rootElement?.visitChildren(visit);
      debugPrint('[COMP_QA_SELECTOR_READY] buttons=$count');
    });
  }

  Future<void> _open(BuildContext context, int levelIndex) async {
    debugPrint('[COMP_QA_OPEN] level=$levelIndex');
    await Navigator.of(context).push<WordHuntLevelResult>(
      MaterialPageRoute<WordHuntLevelResult>(
        builder: (_) => _CompletionQaLevel(levelIndex: levelIndex),
      ),
    );
    _logGeometry();
  }

  @override
  Widget build(BuildContext context) {
    _logGeometry();
    return Scaffold(
      backgroundColor: const Color(0xFF061425),
      body: SafeArea(
        child: Center(
          child: SizedBox(
            width: 330,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const Text(
                  'Kelime Avı V6 Completion QA',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 22),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  key: const Key('completion_qa_open_5'),
                  onPressed: () => _open(context, 5),
                  child: const Text('Bölüm 5'),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  key: const Key('completion_qa_open_10'),
                  onPressed: () => _open(context, 10),
                  child: const Text('Bölüm 10'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CompletionQaLevel extends StatefulWidget {
  const _CompletionQaLevel({required this.levelIndex});

  final int levelIndex;

  @override
  State<_CompletionQaLevel> createState() => _CompletionQaLevelState();
}

class _CompletionQaLevelState extends State<_CompletionQaLevel> {
  Timer? _probeTimer;
  String? _lastSignature;
  bool _geometryLogged = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _probe(force: true));
    _probeTimer = Timer.periodic(
      const Duration(milliseconds: 250),
      (_) => _probe(),
    );
  }

  @override
  void dispose() {
    _probeTimer?.cancel();
    super.dispose();
  }

  void _probe({bool force = false}) {
    if (!mounted) return;
    final ratio = WidgetsBinding
        .instance.platformDispatcher.views.first.devicePixelRatio;
    var cells = 0;
    var targets = 0;
    var bonus = 0;
    var dialog = 0;
    Offset? returnCenter;
    final cellCenters = <String, Offset>{};

    void visit(Element element) {
      final key = element.widget.key;
      final value = key is ValueKey<String> ? key.value : '';
      final renderObject = element.renderObject;
      final cellMatch = RegExp(
        r'^word_hunt_production_cell_(\d+)_(\d+)$',
      ).firstMatch(value);
      if (cellMatch != null &&
          renderObject is RenderBox &&
          renderObject.hasSize) {
        cells += 1;
        cellCenters['${cellMatch.group(1)}_${cellMatch.group(2)}'] =
            renderObject.localToGlobal(
          renderObject.size.center(Offset.zero),
        );
      }
      if (RegExp(r'^word_hunt_production_target_.+_found$').hasMatch(value)) {
        targets += 1;
      }
      if (RegExp(r'^word_hunt_production_bonus_.+_found$').hasMatch(value)) {
        bonus += 1;
      }
      if (value == 'word_hunt_production_result_dialog') {
        dialog = 1;
      }
      if (value == 'word_hunt_production_return_route' &&
          renderObject is RenderBox &&
          renderObject.hasSize) {
        returnCenter = renderObject.localToGlobal(
          renderObject.size.center(Offset.zero),
        );
      }
      element.visitChildren(visit);
    }

    WidgetsBinding.instance.rootElement?.visitChildren(visit);
    final signature = '$cells/$targets/$bonus/$dialog';
    if (force || signature != _lastSignature) {
      debugPrint(
        '[COMP_QA_STATE] level=${widget.levelIndex} cells=$cells '
        'targets=$targets bonus=$bonus dialog=$dialog',
      );
      _lastSignature = signature;
    }

    if (!_geometryLogged && cells == 64) {
      for (var row = 0; row < 8; row++) {
        for (var col = 0; col < 8; col++) {
          final center = cellCenters['${row}_$col'];
          if (center == null) continue;
          debugPrint(
            '[COMP_QA_CELL] level=${widget.levelIndex} row=$row col=$col '
            'x=${(center.dx * ratio).round()} y=${(center.dy * ratio).round()}',
          );
        }
      }
      _geometryLogged = true;
    }

    if (dialog == 1 && returnCenter != null) {
      final center = returnCenter!;
      debugPrint(
        '[COMP_QA_RETURN] level=${widget.levelIndex} '
        'x=${(center.dx * ratio).round()} y=${(center.dy * ratio).round()}',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final level = WordHuntStarterContent
        .baslangicLimani.levels[widget.levelIndex - 1];
    return WordHuntLevelProductionScreen(
      level: level,
      infoCards: WordHuntStarterContent.infoCards,
    );
  }
}
