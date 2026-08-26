import 'package:flutter/material.dart';

import 'word_hunt_models.dart';
import 'word_hunt_progress.dart';
import 'word_hunt_pixel_proof_screen.dart';

/// Flattened MASTER ART üzerinde yalnız oyun durumunu yansıtan görünür katman.
///
/// Arka plan, rota, plaque, node sanatları ve kontroller MASTER ART'tan gelir.
/// Bu katman yalnız değişken progression bilgisini düzeltir:
/// - toplam yıldız sayısı,
/// - kilitli durakların görünür lock state'i,
/// - her durağın gerçek 0-3 yıldızı.
///
/// Değişken alanlar MASTER ART'taki eski demo değerlerinin tam üstüne oturur;
/// ikinci sayaç veya ikinci yıldız satırı oluşturmaz.
class WordHuntMasterArtProgressOverlay extends StatelessWidget {
  const WordHuntMasterArtProgressOverlay({
    super.key,
    required this.route,
    required this.progress,
  });

  final WordHuntRouteDefinition route;
  final WordHuntProgressSnapshot progress;

  // 720x1280 MASTER ART kaynak uzayında eski `12 / 30` metin yuvası.
  // Soldaki dekoratif altın yıldız raster'da kalır; yalnız demo sayı maskelenir.
  static const Rect _progressCounterRect = Rect.fromLTWH(166, 158, 100, 34);

  @override
  Widget build(BuildContext context) {
    final totalStars = WordHuntRouteProgressEngine.totalStars(route, progress);
    final levelCount = route.levels.length.clamp(
      0,
      WordHuntPixelProofLayout.levelCenters.length,
    );

    return IgnorePointer(
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Positioned.fromRect(
            rect: _progressCounterRect,
            child: _ProgressCounter(
              stars: totalStars,
              maximumStars: route.maximumStars,
            ),
          ),
          for (var index = 0; index < levelCount; index++) ...<Widget>[
            _LevelStarsOverlay(
              levelIndex: index + 1,
              center: WordHuntPixelProofLayout.levelCenters[index],
              diameter: WordHuntPixelProofLayout.levelHitboxDiameters[index],
              stars: progress.starsFor(route.levels[index].id),
            ),
            if (!WordHuntRouteProgressEngine.isLevelUnlocked(
              route,
              progress,
              index + 1,
            ))
              _LockedLevelOverlay(
                levelIndex: index + 1,
                center: WordHuntPixelProofLayout.levelCenters[index],
                diameter:
                    WordHuntPixelProofLayout.levelHitboxDiameters[index],
              ),
          ],
        ],
      ),
    );
  }
}

class _ProgressCounter extends StatelessWidget {
  const _ProgressCounter({required this.stars, required this.maximumStars});

  final int stars;
  final int maximumStars;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      key: const Key('word_hunt_master_art_progress_counter'),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0D13),
        borderRadius: BorderRadius.circular(4),
        boxShadow: const <BoxShadow>[
          BoxShadow(color: Color(0x66000000), blurRadius: 2),
        ],
      ),
      child: Center(
        child: Text(
          '$stars / $maximumStars',
          key: const Key('word_hunt_master_art_progress_counter_text'),
          style: const TextStyle(
            color: Color(0xFFFFD56A),
            fontFamily: 'serif',
            fontSize: 20,
            fontWeight: FontWeight.w700,
            letterSpacing: .15,
            height: 1,
            shadows: <Shadow>[
              Shadow(color: Color(0xFF000000), blurRadius: 2),
            ],
          ),
        ),
      ),
    );
  }
}

class _LockedLevelOverlay extends StatelessWidget {
  const _LockedLevelOverlay({
    required this.levelIndex,
    required this.center,
    required this.diameter,
  });

  final int levelIndex;
  final Offset center;
  final double diameter;

  @override
  Widget build(BuildContext context) {
    final visualDiameter = diameter * .92;
    return Positioned(
      key: Key('word_hunt_master_art_level_${levelIndex}_locked'),
      left: center.dx - visualDiameter / 2,
      top: center.dy - visualDiameter / 2,
      width: visualDiameter,
      height: visualDiameter,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xB8070C13),
          border: Border.all(color: const Color(0xD0AEB8C5), width: 2),
          boxShadow: const <BoxShadow>[
            BoxShadow(color: Color(0xAA000000), blurRadius: 6),
          ],
        ),
        child: const Center(
          child: Icon(
            Icons.lock_rounded,
            color: Color(0xFFE7E8EC),
            size: 23,
            shadows: <Shadow>[
              Shadow(color: Color(0xFF000000), blurRadius: 3),
            ],
          ),
        ),
      ),
    );
  }
}

class _LevelStarsOverlay extends StatelessWidget {
  const _LevelStarsOverlay({
    required this.levelIndex,
    required this.center,
    required this.diameter,
    required this.stars,
  });

  final int levelIndex;
  final Offset center;
  final double diameter;
  final int stars;

  @override
  Widget build(BuildContext context) {
    final safeStars = stars.clamp(0, 3);
    const width = 48.0;
    const height = 17.0;
    // MASTER ART'taki yıldızların merkezine oturur; eski demo yıldızları
    // maskelenir ve yalnız gerçek state görünür kalır.
    final top = center.dy + diameter / 2 - 5;

    return Positioned(
      key: Key('word_hunt_master_art_level_${levelIndex}_stars'),
      left: center.dx - width / 2,
      top: top,
      width: width,
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xC9000000),
          borderRadius: BorderRadius.circular(8.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List<Widget>.generate(3, (index) {
            final filled = index < safeStars;
            return Icon(
              filled ? Icons.star_rounded : Icons.star_outline_rounded,
              key: Key(
                'word_hunt_master_art_level_${levelIndex}_star_${index + 1}',
              ),
              size: 14,
              color:
                  filled
                      ? const Color(0xFFFFC94A)
                      : const Color(0xFF68717C),
            );
          }),
        ),
      ),
    );
  }
}
