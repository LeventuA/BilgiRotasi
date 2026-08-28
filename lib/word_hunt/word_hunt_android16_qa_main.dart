import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'word_hunt_screens.dart';
import 'word_hunt_starter_content.dart';

const int _qaLevel = int.fromEnvironment('WORD_HUNT_QA_LEVEL', defaultValue: 1);
const int _qaTimeOffsetSeconds = int.fromEnvironment(
  'WORD_HUNT_QA_TIME_OFFSET_SECONDS',
  defaultValue: 0,
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
    DeviceOrientation.portraitUp,
  ]);
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  if (!const <int>{1, 5, 8, 10}.contains(_qaLevel)) {
    throw StateError('Unsupported WORD_HUNT_QA_LEVEL=$_qaLevel');
  }

  final level = WordHuntStarterContent.baslangicLimani.levels[_qaLevel - 1];
  final realStart = DateTime.now();
  final scoringStart = realStart;
  var firstClockRead = true;

  DateTime qaNow() {
    if (firstClockRead) {
      firstClockRead = false;
      return scoringStart;
    }
    return scoringStart
        .add(Duration(seconds: _qaTimeOffsetSeconds))
        .add(DateTime.now().difference(realStart));
  }

  debugPrint(
    '[WORD_HUNT_ANDROID16_QA_CONFIG] '
    'level=$_qaLevel rows=${level.rowCount} cols=${level.columnCount} '
    'targets=${level.targetWords.length} bonus=${level.bonusWords.length} '
    'timeOffset=$_qaTimeOffsetSeconds',
  );

  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Kelime Avı Android 16 QA',
      home: WordHuntLevelProductionScreen(
        level: level,
        infoCards: WordHuntStarterContent.infoCards,
        now: qaNow,
      ),
    ),
  );

  WidgetsBinding.instance.addPostFrameCallback((_) {
    debugPrint('[WORD_HUNT_ANDROID16_QA_READY] level=$_qaLevel');
  });
}
