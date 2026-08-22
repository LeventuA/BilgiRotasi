import 'package:flutter/material.dart';

import 'word_hunt_progress.dart';
import 'word_hunt_reference_route_screen.dart';

const _sceneAssetPath = 'assets/word_hunt/baslangic_limani_bg.jpg';

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
          'baslangic-5': 3,
          'baslangic-6': 3,
          'baslangic-7': 3,
        },
      );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Kelime Avı Referans Görsel Kanıtı',
      theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      home: const _AssetRuntimeProbe(
        child: WordHuntReferenceRouteScreen(
          progress: _proofProgress,
          sceneAssetPath: _sceneAssetPath,
        ),
      ),
    );
  }
}

class _AssetRuntimeProbe extends StatefulWidget {
  const _AssetRuntimeProbe({required this.child});

  final Widget child;

  @override
  State<_AssetRuntimeProbe> createState() => _AssetRuntimeProbeState();
}

class _AssetRuntimeProbeState extends State<_AssetRuntimeProbe> {
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      try {
        await precacheImage(const AssetImage(_sceneAssetPath), context);
        debugPrint('[WORD_HUNT_ASSET_LOADED] path=$_sceneAssetPath');
      } catch (error, stackTrace) {
        debugPrint(
          '[WORD_HUNT_ASSET_ERROR] path=$_sceneAssetPath error=$error',
        );
        debugPrintStack(
          label: '[WORD_HUNT_ASSET_ERROR_STACK]',
          stackTrace: stackTrace,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
