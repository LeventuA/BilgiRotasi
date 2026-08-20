import 'package:flutter/material.dart';

import 'word_hunt_progress.dart';
import 'word_hunt_route_map_screen.dart';

/// Yalnız görsel inceleme/kanıt için kullanılan izole giriş noktası.
/// Production `lib/main.dart` ve mevcut uygulama navigasyonuna bağlı değildir.
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const _WordHuntVisualProofApp());
}

class _WordHuntVisualProofApp extends StatelessWidget {
  const _WordHuntVisualProofApp();

  static const WordHuntProgressSnapshot _proofProgress =
      WordHuntProgressSnapshot(
        bestStarsByLevelId: <String, int>{
          'baslangic-1': 3,
          'baslangic-2': 3,
          'baslangic-3': 3,
          'baslangic-4': 3,
        },
      );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Kelime Avı Görsel Kanıtı',
      theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      home: const WordHuntRouteMapPrototypeScreen(progress: _proofProgress),
    );
  }
}
