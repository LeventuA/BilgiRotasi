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
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: WordHuntLevelProductionScreen(
        level: WordHuntStarterContent.baslangicLimani.levels[4],
        infoCards: WordHuntStarterContent.infoCards,
      ),
    ),
  );
  _probeRuntime();
}

void _probeRuntime([int attempt = 1]) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    final root = WidgetsBinding.instance.rootElement;
    if (root == null) return;

    var cells = 0;
    Offset? start;
    Offset? overshoot;
    var foundAnkara = false;
    var zeroMistakes = false;
    var oneOfSeven = false;

    void visit(Element element) {
      final key = element.widget.key;
      final keyValue = key is ValueKey<String> ? key.value : '';
      if (RegExp(r'^word_hunt_production_cell_\d+_\d+$').hasMatch(keyValue)) {
        cells += 1;
      }
      if (keyValue == 'word_hunt_production_target_ANKARA_found') {
        foundAnkara = true;
      }
      if (keyValue == 'word_hunt_production_cell_0_0' ||
          keyValue == 'word_hunt_production_cell_0_6') {
        final renderObject = element.renderObject;
        if (renderObject is RenderBox && renderObject.hasSize) {
          final center = renderObject.localToGlobal(
            Offset(renderObject.size.width / 2, renderObject.size.height / 2),
          );
          if (keyValue.endsWith('_0_0')) start = center;
          if (keyValue.endsWith('_0_6')) overshoot = center;
        }
      }
      final widget = element.widget;
      if (widget is Text) {
        zeroMistakes = zeroMistakes || widget.data == '0 hata';
        oneOfSeven = oneOfSeven || widget.data == '1/7';
      }
      element.visitChildren(visit);
    }

    root.visitChildren(visit);
    if (cells == 64 && start != null && overshoot != null) {
      debugPrint(
        '[WORD_HUNT_SWIPE_QA_READY] cells=64 '
        'startX=${start!.dx.round()} startY=${start!.dy.round()} '
        'endX=${overshoot!.dx.round()} endY=${overshoot!.dy.round()}',
      );
    }
    if (foundAnkara && zeroMistakes && oneOfSeven) {
      debugPrint(
        '[WORD_HUNT_SWIPE_QA_PASS] target=ANKARA progress=1/7 mistakes=0',
      );
      return;
    }
    if (attempt < 120) {
      Future<void>.delayed(const Duration(milliseconds: 250), () {
        _probeRuntime(attempt + 1);
      });
    }
  });
}
