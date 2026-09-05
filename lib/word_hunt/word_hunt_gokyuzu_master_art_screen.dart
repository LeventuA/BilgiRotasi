import 'package:flutter/material.dart';

import 'word_hunt_models.dart';
import 'word_hunt_progress.dart';

/// Levent'in 3 Eylül 2026'da onayladığı Gökyüzü Adaları V2 rota
/// görselini tek görünür MASTER ART tabanı olarak kullanan production
/// rota ekranı. Ada, landmark, rota, başlık paneli, plaque ve alt köşe
/// kontrolleri Flutter ile ikinci kez çizilmez.
abstract final class WordHuntGokyuzuMasterArtAssets {
  static const String masterArt =
      'assets/word_hunt/gokyuzu_adalari_master_art_v2.webp';
}

abstract final class WordHuntGokyuzuMasterArtLayout {
  static const Size sourceSize = Size(1085, 1536);

  static const List<Offset> levelCenters = <Offset>[
    Offset(170, 350),
    Offset(500, 410),
    Offset(810, 545),
    Offset(215, 695),
    Offset(550, 800),
    Offset(835, 885),
    Offset(200, 980),
    Offset(515, 1090),
    Offset(230, 1275),
    Offset(810, 1300),
  ];

  static const List<double> levelHitboxDiameters = <double>[
    132,
    132,
    132,
    140,
    140,
    142,
    142,
    150,
    150,
    170,
  ];

  static const Offset compassCenter = Offset(100, 1405);
  static const Offset bookCenter = Offset(960, 1405);
  static const double bottomControlHitboxDiameter = 175;

  static const Offset backCenter = Offset(74, 48);
  static const Offset infoCenter = Offset(1010, 48);
  static const double topControlHitboxDiameter = 112;

  static const Rect progressCounterRect = Rect.fromLTWH(292, 100, 128, 48);
  static const Rect gateCounterRect = Rect.fromLTWH(650, 100, 158, 48);
}

class WordHuntGokyuzuMasterArtScreen extends StatelessWidget {
  const WordHuntGokyuzuMasterArtScreen({
    super.key,
    required this.route,
    this.progress = const WordHuntProgressSnapshot(),
    this.onBack,
    this.onInfo,
    this.onCompass,
    this.onBook,
    this.onLevelTap,
  });

  static const String routeId = 'gokyuzu-adalari';

  final WordHuntRouteDefinition route;
  final WordHuntProgressSnapshot progress;
  final VoidCallback? onBack;
  final VoidCallback? onInfo;
  final VoidCallback? onCompass;
  final VoidCallback? onBook;
  final ValueChanged<int>? onLevelTap;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const Key('word_hunt_gokyuzu_master_art_route'),
      backgroundColor: const Color(0xFF083A78),
      body: ClipRect(
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            // 9:16 cihazlarda onaylı 1085x1536 görsel kırpılmasın diye
            // aynı sanatın koyulaştırılmış cover kopyası yalnız dış dolgu
            // görevi görür. Asıl MASTER ART üstte contain olarak eksiksizdir.
            IgnorePointer(
              child: Opacity(
                opacity: .34,
                child: Image.asset(
                  WordHuntGokyuzuMasterArtAssets.masterArt,
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                  filterQuality: FilterQuality.low,
                  color: const Color(0x6611254B),
                  colorBlendMode: BlendMode.darken,
                ),
              ),
            ),
            Center(
              child: FittedBox(
                fit: BoxFit.contain,
                child: SizedBox.fromSize(
                  key: const Key('word_hunt_gokyuzu_master_art_source_scene'),
                  size: WordHuntGokyuzuMasterArtLayout.sourceSize,
                  child: Stack(
                    fit: StackFit.expand,
                    children: <Widget>[
                      IgnorePointer(
                        child: Image.asset(
                          WordHuntGokyuzuMasterArtAssets.masterArt,
                          key: const Key('word_hunt_gokyuzu_master_art_image'),
                          width:
                              WordHuntGokyuzuMasterArtLayout.sourceSize.width,
                          height:
                              WordHuntGokyuzuMasterArtLayout.sourceSize.height,
                          fit: BoxFit.fill,
                          filterQuality: FilterQuality.high,
                        ),
                      ),
                      _GokyuzuRuntimeOverlay(route: route, progress: progress),
                      for (
                        var index = 0;
                        index < route.levels.length &&
                            index <
                                WordHuntGokyuzuMasterArtLayout
                                    .levelCenters
                                    .length;
                        index++
                      )
                        _TransparentHitbox(
                          key: Key(
                            'word_hunt_gokyuzu_master_art_level_${index + 1}',
                          ),
                          center: WordHuntGokyuzuMasterArtLayout
                              .levelCenters[index],
                          diameter: WordHuntGokyuzuMasterArtLayout
                              .levelHitboxDiameters[index],
                          semanticLabel: 'Bölüm ${index + 1}',
                          onTap:
                              WordHuntRouteProgressEngine.isLevelUnlocked(
                                    route,
                                    progress,
                                    index + 1,
                                  ) &&
                                  onLevelTap != null
                              ? () => onLevelTap!(index + 1)
                              : null,
                        ),
                      _TransparentHitbox(
                        key: const Key('word_hunt_gokyuzu_master_art_compass'),
                        center: WordHuntGokyuzuMasterArtLayout.compassCenter,
                        diameter: WordHuntGokyuzuMasterArtLayout
                            .bottomControlHitboxDiameter,
                        semanticLabel: 'Pusula',
                        onTap: onCompass,
                      ),
                      _TransparentHitbox(
                        key: const Key('word_hunt_gokyuzu_master_art_book'),
                        center: WordHuntGokyuzuMasterArtLayout.bookCenter,
                        diameter: WordHuntGokyuzuMasterArtLayout
                            .bottomControlHitboxDiameter,
                        semanticLabel: 'Bilgi Kitabı',
                        onTap: onBook,
                      ),
                      _TransparentHitbox(
                        key: const Key('word_hunt_gokyuzu_master_art_back'),
                        center: WordHuntGokyuzuMasterArtLayout.backCenter,
                        diameter: WordHuntGokyuzuMasterArtLayout
                            .topControlHitboxDiameter,
                        semanticLabel: 'Geri',
                        onTap: onBack,
                      ),
                      _TransparentHitbox(
                        key: const Key('word_hunt_gokyuzu_master_art_info'),
                        center: WordHuntGokyuzuMasterArtLayout.infoCenter,
                        diameter: WordHuntGokyuzuMasterArtLayout
                            .topControlHitboxDiameter,
                        semanticLabel: 'Bilgi',
                        onTap: onInfo,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GokyuzuRuntimeOverlay extends StatelessWidget {
  const _GokyuzuRuntimeOverlay({required this.route, required this.progress});

  final WordHuntRouteDefinition route;
  final WordHuntProgressSnapshot progress;

  @override
  Widget build(BuildContext context) {
    final totalStars = WordHuntRouteProgressEngine.totalStars(route, progress);
    return IgnorePointer(
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          if (totalStars != 0)
            _CounterPatch(
              key: const Key('word_hunt_gokyuzu_master_art_progress'),
              rect: WordHuntGokyuzuMasterArtLayout.progressCounterRect,
              text: '$totalStars / ${route.maximumStars}',
            ),
          if (route.unlockStarsRequired != 18)
            _CounterPatch(
              key: const Key('word_hunt_gokyuzu_master_art_gate'),
              rect: WordHuntGokyuzuMasterArtLayout.gateCounterRect,
              text: 'Kapı: ${route.unlockStarsRequired}',
            ),
          for (
            var index = 0;
            index < route.levels.length &&
                index < WordHuntGokyuzuMasterArtLayout.levelCenters.length;
            index++
          )
            if (!WordHuntRouteProgressEngine.isLevelUnlocked(
              route,
              progress,
              index + 1,
            ))
              _LockBadge(
                key: Key(
                  'word_hunt_gokyuzu_master_art_level_${index + 1}_locked',
                ),
                center: WordHuntGokyuzuMasterArtLayout.levelCenters[index],
              ),
        ],
      ),
    );
  }
}

class _CounterPatch extends StatelessWidget {
  const _CounterPatch({super.key, required this.rect, required this.text});

  final Rect rect;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Positioned.fromRect(
      rect: rect,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xEC09284C),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFFFC52F), width: 2),
          boxShadow: const <BoxShadow>[
            BoxShadow(color: Color(0x88000000), blurRadius: 5),
          ],
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontFamily: 'serif',
              fontSize: 24,
              fontWeight: FontWeight.w700,
              shadows: <Shadow>[Shadow(color: Colors.black, blurRadius: 3)],
            ),
          ),
        ),
      ),
    );
  }
}

class _LockBadge extends StatelessWidget {
  const _LockBadge({super.key, required this.center});

  final Offset center;

  @override
  Widget build(BuildContext context) {
    const diameter = 72.0;
    return Positioned(
      left: center.dx - diameter / 2,
      top: center.dy - diameter / 2,
      width: diameter,
      height: diameter,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xE8092443),
          border: Border.all(color: const Color(0xFFFFC52F), width: 3),
          boxShadow: const <BoxShadow>[
            BoxShadow(color: Color(0x99000000), blurRadius: 8),
          ],
        ),
        child: const Icon(
          Icons.lock_rounded,
          color: Color(0xFFF7F4E9),
          size: 32,
        ),
      ),
    );
  }
}

class _TransparentHitbox extends StatelessWidget {
  const _TransparentHitbox({
    super.key,
    required this.center,
    required this.diameter,
    required this.semanticLabel,
    this.onTap,
  });

  final Offset center;
  final double diameter;
  final String semanticLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: center.dx - diameter / 2,
      top: center.dy - diameter / 2,
      width: diameter,
      height: diameter,
      child: Semantics(
        button: true,
        enabled: onTap != null,
        label: semanticLabel,
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: onTap,
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}
