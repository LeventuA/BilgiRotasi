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
      title: 'Kelime Avı V6 B5 60s QA',
      home: const _B5BalanceQaScreen(),
    ),
  );
}

class _B5BalanceQaScreen extends StatefulWidget {
  const _B5BalanceQaScreen();

  @override
  State<_B5BalanceQaScreen> createState() => _B5BalanceQaScreenState();
}

class _B5BalanceQaScreenState extends State<_B5BalanceQaScreen> {
  @override
  void initState() {
    super.initState();
    final level = WordHuntStarterContent.baslangicLimani.levels[4];
    debugPrint(
      '[WORD_HUNT_V6_B5_BALANCE_QA_CONFIG] '
      'rows=${level.rowCount} cols=${level.columnCount} '
      'targets=${level.targetWords.length} bonus=${level.bonusWords.length} '
      'targetSeconds=${level.timeLimitSeconds}',
    );
    _probeCells();
  }

  void _probeCells([int attempt = 1]) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      var cells = 0;
      void visit(Element element) {
        final key = element.widget.key;
        final value = key is ValueKey<String> ? key.value : '';
        if (RegExp(r'^word_hunt_production_cell_\d+_\d+$').hasMatch(value)) {
          final renderObject = element.renderObject;
          if (renderObject is RenderBox && renderObject.hasSize) cells += 1;
        }
        element.visitChildren(visit);
      }
      WidgetsBinding.instance.rootElement?.visitChildren(visit);
      debugPrint('[WORD_HUNT_V6_B5_BALANCE_QA_GEOMETRY] cells=$cells');
      if (cells == 64) {
        debugPrint('[WORD_HUNT_V6_B5_BALANCE_QA_READY] cells=64');
      } else if (attempt < 20) {
        Future<void>.delayed(const Duration(milliseconds: 250), () {
          if (mounted) _probeCells(attempt + 1);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final level = WordHuntStarterContent.baslangicLimani.levels[4];
    return WordHuntLevelProductionScreen(
      level: level,
      infoCards: WordHuntStarterContent.infoCards,
    );
  }
}
