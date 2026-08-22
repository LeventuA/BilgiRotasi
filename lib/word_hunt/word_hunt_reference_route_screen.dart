import 'package:flutter/material.dart';

import 'word_hunt_models.dart';
import 'word_hunt_progress.dart';
import 'word_hunt_route_stop.dart';
import 'word_hunt_starter_content.dart';

/// Kullanıcının onayladığı Başlangıç Limanı referansının kod tarafındaki
/// bağlayıcı kompozisyon sözleşmesi.
///
/// Bu koordinatlar PR #98'de reddedilen geometriyi taşımaz. 1-10 hiyerarşisi,
/// proje hafızasında kayıtlı resmi referans kurallarından yeniden kurulmuştur.
class WordHuntReferenceRouteLayout {
  WordHuntReferenceRouteLayout._();

  static const List<Offset> stops = <Offset>[
    Offset(0.19, 0.08), // 1 - üst sol
    Offset(0.47, 0.13), // 2 - üst orta
    Offset(0.74, 0.20), // 3 - üst sağ
    Offset(0.77, 0.35), // 4 - üst sağda ferah dönüş
    Offset(0.26, 0.41), // 5 - meydan okuma, merkez-sol
    Offset(0.12, 0.53), // 6 - sol geçiş
    Offset(0.41, 0.64), // 7 - merkez; 9'dan uzak, 8'in yıldız alanından açık
    Offset(0.60, 0.69), // 8 - bonus, sağ bölge
    Offset(0.18, 0.79), // 9 - kilitli sol bölge
    Offset(0.44, 0.90), // 10 - rota finali, alt-orta
  ];

  static const double routeAreaTop = 142;
  static const double routeAreaBottom = 68;
}

enum WordHuntReferenceRouteSegmentStyle {
  normal,
  challenge,
  bonus,
  finalStop,
  locked,
}

/// Onaylı referanstaki rota ışık dilini oyun mantığından ayırır.
/// Kilit/progression yine [WordHuntRouteProgressEngine] tarafından belirlenir.
class WordHuntReferenceRouteVisualContract {
  WordHuntReferenceRouteVisualContract._();

  static WordHuntReferenceRouteSegmentStyle segmentStyleFor({
    required WordHuntLevelType destinationType,
    required bool unlocked,
  }) {
    if (!unlocked) {
      return WordHuntReferenceRouteSegmentStyle.locked;
    }
    return switch (destinationType) {
      WordHuntLevelType.normal => WordHuntReferenceRouteSegmentStyle.normal,
      WordHuntLevelType.challenge =>
        WordHuntReferenceRouteSegmentStyle.challenge,
      WordHuntLevelType.bonus => WordHuntReferenceRouteSegmentStyle.bonus,
      WordHuntLevelType.routeFinal =>
        WordHuntReferenceRouteSegmentStyle.finalStop,
    };
  }
}

/// Başlangıç Limanı'nın resmi referans hiyerarşisini doğrulamak için izole
/// Flutter ekranı. Production `lib/main.dart` navigasyonuna bağlı değildir.
class WordHuntReferenceRouteScreen extends StatelessWidget {
  const WordHuntReferenceRouteScreen({
    super.key,
    this.route = WordHuntStarterContent.baslangicLimani,
    this.progress = const WordHuntProgressSnapshot(),
    this.sceneAssetPath,
    this.onBack,
    this.onInfo,
    this.onCompass,
    this.onBook,
    this.onLevelTap,
  });

  final WordHuntRouteDefinition route;
  final WordHuntProgressSnapshot progress;
  final String? sceneAssetPath;
  final VoidCallback? onBack;
  final VoidCallback? onInfo;
  final VoidCallback? onCompass;
  final VoidCallback? onBook;
  final ValueChanged<int>? onLevelTap;

  static const WordHuntRouteStopMetrics _metrics =
      WordHuntRouteStopMetrics.referenceBaseline;

  @override
  Widget build(BuildContext context) {
    final totalStars = WordHuntRouteProgressEngine.totalStars(route, progress);
    final lastUnlocked = _lastUnlockedIndex();

    return Scaffold(
      backgroundColor: const Color(0xFF020611),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final size = Size(constraints.maxWidth, constraints.maxHeight);
            final routeTop = WordHuntReferenceRouteLayout.routeAreaTop
                .clamp(126.0, size.height * 0.19)
                .toDouble();
            final routeBottom = WordHuntReferenceRouteLayout.routeAreaBottom
                .clamp(58.0, size.height * 0.10)
                .toDouble();
            final routeHeight = (size.height - routeTop - routeBottom)
                .clamp(500.0, size.height)
                .toDouble();
            final routeSize = Size(size.width, routeHeight);
            final points = WordHuntReferenceRouteLayout.stops
                .take(route.levels.length)
                .map(
                  (stop) => Offset(
                    stop.dx * routeSize.width,
                    stop.dy * routeSize.height,
                  ),
                )
                .toList(growable: false);
            final levelTypes = route.levels
                .take(points.length)
                .map((level) => level.type)
                .toList(growable: false);

            return Stack(
              fit: StackFit.expand,
              children: [
                _ReferenceBackground(assetPath: sceneAssetPath),
                const _ReferenceLegibilityOverlay(),
                _ReferenceTopChrome(
                  title: route.title,
                  stars: totalStars,
                  maximumStars: route.maximumStars,
                  unlockStarsRequired: route.unlockStarsRequired,
                  onBack: onBack,
                  onInfo: onInfo,
                ),
                Positioned(
                  key: const Key('word_hunt_reference_route_area'),
                  left: 0,
                  right: 0,
                  top: routeTop,
                  height: routeHeight,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned.fill(
                        child: CustomPaint(
                          painter: _ReferenceRoutePainter(
                            points: points,
                            levelTypes: levelTypes,
                            lastUnlockedIndex: lastUnlocked,
                          ),
                        ),
                      ),
                      for (var index = 0; index < points.length; index++)
                        _positionStop(
                          point: points[index],
                          level: route.levels[index],
                          stars: progress.starsFor(route.levels[index].id),
                          unlocked:
                              WordHuntRouteProgressEngine.isLevelUnlocked(
                            route,
                            progress,
                            index + 1,
                          ),
                          routeSize: routeSize,
                        ),
                    ],
                  ),
                ),
                Positioned(
                  left: 16,
                  bottom: 10,
                  child: _ReferenceBottomControl(
                    key: const Key('word_hunt_reference_compass'),
                    icon: Icons.explore_rounded,
                    semanticLabel: 'Pusula',
                    onTap: onCompass,
                  ),
                ),
                Positioned(
                  right: 16,
                  bottom: 10,
                  child: _ReferenceBottomControl(
                    key: const Key('word_hunt_reference_book'),
                    icon: Icons.menu_book_rounded,
                    semanticLabel: 'Bilgi Kitabı',
                    onTap: onBook,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  int _lastUnlockedIndex() {
    var last = 0;
    for (var index = 1; index <= route.levels.length; index++) {
      if (WordHuntRouteProgressEngine.isLevelUnlocked(route, progress, index)) {
        last = index;
      }
    }
    return last;
  }

  Widget _positionStop({
    required Offset point,
    required WordHuntLevelDefinition level,
    required int stars,
    required bool unlocked,
    required Size routeSize,
  }) {
    final special = level.type != WordHuntLevelType.normal;
    final width = _metrics.containerWidthFor(level.type);
    final height = _metrics.containerHeightFor(level.type);
    final diameter = _metrics.diameterFor(level.type);

    // Normal duraklarda bütün bileşen merkezi rota noktasına oturur. Özel
    // duraklarda rota noktası dairenin merkezidir; kart her zaman sağa açılır.
    final desiredLeft = special
        ? point.dx - diameter / 2
        : point.dx - width / 2;
    final desiredTop = point.dy - height / 2;
    final left = desiredLeft.clamp(4.0, routeSize.width - width - 4).toDouble();
    final top = desiredTop.clamp(2.0, routeSize.height - height - 2).toDouble();

    return Positioned(
      left: left,
      top: top,
      width: width,
      height: height,
      child: SizedBox(
        key: Key('word_hunt_reference_level_${level.index}'),
        width: width,
        height: height,
        child: WordHuntRouteStop(
          level: level,
          stars: stars,
          unlocked: unlocked,
          theme: WordHuntRouteStopTheme.harbor,
          metrics: _metrics,
          labelOnLeft: false,
          onTap: unlocked && onLevelTap != null
              ? () => onLevelTap!(level.index)
              : null,
        ),
      ),
    );
  }
}

class _ReferenceBackground extends StatelessWidget {
  const _ReferenceBackground({required this.assetPath});

  final String? assetPath;

  @override
  Widget build(BuildContext context) {
    final path = assetPath;
    if (path != null && path.isNotEmpty) {
      return Image.asset(
        path,
        key: const Key('word_hunt_reference_background_asset'),
        fit: BoxFit.cover,
        alignment: Alignment.center,
        errorBuilder: (context, error, stackTrace) => const _FallbackBackground(),
      );
    }
    return const _FallbackBackground();
  }
}

class _FallbackBackground extends StatelessWidget {
  const _FallbackBackground();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      key: Key('word_hunt_reference_background_fallback'),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            Color(0xFF08172B),
            Color(0xFF0D2737),
            Color(0xFF06121F),
          ],
        ),
      ),
    );
  }
}

class _ReferenceLegibilityOverlay extends StatelessWidget {
  const _ReferenceLegibilityOverlay();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            Color(0xC90A0B18),
            Color(0x4A020916),
            Color(0x16000000),
            Color(0x5C020611),
            Color(0xB8020611),
          ],
          stops: <double>[0, 0.16, 0.39, 0.80, 1],
        ),
      ),
    );
  }
}

class _ReferenceTopChrome extends StatelessWidget {
  const _ReferenceTopChrome({
    required this.title,
    required this.stars,
    required this.maximumStars,
    required this.unlockStarsRequired,
    this.onBack,
    this.onInfo,
  });

  final String title;
  final int stars;
  final int maximumStars;
  final int unlockStarsRequired;
  final VoidCallback? onBack;
  final VoidCallback? onInfo;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 12,
      right: 12,
      top: 6,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 44,
            child: Row(
              children: [
                _ReferenceRoundButton(
                  key: const Key('word_hunt_reference_back'),
                  icon: Icons.arrow_back_rounded,
                  semanticLabel: 'Geri',
                  onTap: onBack,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      children: [
                        const Expanded(
                          child: _ReferenceTitleFlourish(reverse: false),
                        ),
                        const SizedBox(width: 7),
                        const Text(
                          'Kelime Avı',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFFF4E7FF),
                            fontSize: 19,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                            shadows: <Shadow>[
                              Shadow(
                                color: Color(0xD99C4DFF),
                                blurRadius: 12,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 7),
                        const Expanded(
                          child: _ReferenceTitleFlourish(reverse: true),
                        ),
                      ],
                    ),
                  ),
                ),
                _ReferenceRoundButton(
                  key: const Key('word_hunt_reference_info'),
                  icon: Icons.info_outline_rounded,
                  semanticLabel: 'Bilgi',
                  onTap: onInfo,
                ),
              ],
            ),
          ),
          const SizedBox(height: 5),
          Container(
            constraints: const BoxConstraints(maxWidth: 330),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xE308101B),
              borderRadius: BorderRadius.circular(13),
              border: Border.all(
                color: const Color(0xD0B68B45),
                width: 1.3,
              ),
              boxShadow: const <BoxShadow>[
                BoxShadow(
                  color: Color(0x88000000),
                  blurRadius: 12,
                  offset: Offset(0, 5),
                ),
                BoxShadow(color: Color(0x2D8B5CF6), blurRadius: 13),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.fade,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFFFFF7E7),
                    fontSize: 23,
                    height: 1,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.25,
                    shadows: <Shadow>[
                      Shadow(color: Color(0x99000000), blurRadius: 4),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      color: Color(0xFFFFC94A),
                      size: 19,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$stars / $maximumStars',
                      style: const TextStyle(
                        color: Color(0xFFFFE9B0),
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Kapı: $unlockStarsRequired',
                      style: const TextStyle(
                        color: Color(0xFFF3E6C9),
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 3),
                    const Icon(
                      Icons.star_rounded,
                      color: Color(0xFFFFC94A),
                      size: 17,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReferenceTitleFlourish extends StatelessWidget {
  const _ReferenceTitleFlourish({required this.reverse});

  final bool reverse;

  @override
  Widget build(BuildContext context) {
    return Row(
      textDirection: reverse ? TextDirection.rtl : TextDirection.ltr,
      children: [
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: reverse ? Alignment.centerRight : Alignment.centerLeft,
                end: reverse ? Alignment.centerLeft : Alignment.centerRight,
                colors: const <Color>[
                  Color(0x007B3BB5),
                  Color(0xA88A4FC5),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 4),
        Transform.rotate(
          angle: 0.785398,
          child: Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xB9A764DD), width: 0.8),
            ),
          ),
        ),
      ],
    );
  }
}

class _ReferenceRoundButton extends StatelessWidget {
  const _ReferenceRoundButton({
    super.key,
    required this.icon,
    required this.semanticLabel,
    this.onTap,
  });

  final IconData icon;
  final String semanticLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xD70A111D),
              border: Border.all(color: const Color(0xBBA57A3D)),
            ),
            child: Icon(icon, color: const Color(0xFFE8C678), size: 23),
          ),
        ),
      ),
    );
  }
}

class _ReferenceBottomControl extends StatelessWidget {
  const _ReferenceBottomControl({
    super.key,
    required this.icon,
    required this.semanticLabel,
    this.onTap,
  });

  final IconData icon;
  final String semanticLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const RadialGradient(
                colors: <Color>[Color(0xFF18313B), Color(0xFF07131D)],
              ),
              border: Border.all(color: const Color(0xB8C29650), width: 1.3),
              boxShadow: const <BoxShadow>[
                BoxShadow(
                  color: Color(0x77000000),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: const Color(0xFFE9C86E), size: 28),
          ),
        ),
      ),
    );
  }
}

class _ReferenceRoutePainter extends CustomPainter {
  const _ReferenceRoutePainter({
    required this.points,
    required this.levelTypes,
    required this.lastUnlockedIndex,
  });

  final List<Offset> points;
  final List<WordHuntLevelType> levelTypes;
  final int lastUnlockedIndex;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2 || levelTypes.length < points.length) return;

    final shadow = Paint()
      ..color = const Color(0xA8000000)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    for (var index = 0; index < points.length - 1; index++) {
      final from = points[index];
      final to = points[index + 1];
      final path = Path()..moveTo(from.dx, from.dy);
      final middleY = (from.dy + to.dy) / 2;
      path.cubicTo(
        from.dx,
        middleY,
        to.dx,
        middleY,
        to.dx,
        to.dy,
      );

      canvas.drawPath(path, shadow);

      final unlockedSegment = index + 2 <= lastUnlockedIndex;
      final style = WordHuntReferenceRouteVisualContract.segmentStyleFor(
        destinationType: levelTypes[index + 1],
        unlocked: unlockedSegment,
      );

      if (style == WordHuntReferenceRouteSegmentStyle.locked) {
        final dormantGlow = Paint()
          ..color = const Color(0x305B7589)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 5.5
          ..strokeCap = StrokeCap.round;
        final dormant = Paint()
          ..color = const Color(0xB59AA5B2)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.2
          ..strokeCap = StrokeCap.round;
        canvas.drawPath(path, dormantGlow);
        _drawDashedPath(canvas, path, dormant);
        continue;
      }

      final (coreColor, glowColor) = switch (style) {
        WordHuntReferenceRouteSegmentStyle.normal => (
            const Color(0xFF76F7FF),
            const Color(0x7047EAF1),
          ),
        WordHuntReferenceRouteSegmentStyle.challenge => (
            const Color(0xFFFFC45F),
            const Color(0x70F39B38),
          ),
        WordHuntReferenceRouteSegmentStyle.bonus => (
            const Color(0xFFC06BFF),
            const Color(0x70A94AF3),
          ),
        WordHuntReferenceRouteSegmentStyle.finalStop => (
            const Color(0xFFFFD76B),
            const Color(0x70F6B83D),
          ),
        WordHuntReferenceRouteSegmentStyle.locked => throw StateError(
            'Locked segment is handled before active palette selection.',
          ),
      };

      final glow = Paint()
        ..color = glowColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 7.5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;
      final core = Paint()
        ..color = coreColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      canvas.drawPath(path, glow);
      canvas.drawPath(path, core);
    }
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint) {
    const dashLength = 8.0;
    const gapLength = 6.0;
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final end = (distance + dashLength).clamp(0.0, metric.length).toDouble();
        canvas.drawPath(metric.extractPath(distance, end), paint);
        distance += dashLength + gapLength;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ReferenceRoutePainter oldDelegate) {
    return oldDelegate.points != points ||
        oldDelegate.levelTypes != levelTypes ||
        oldDelegate.lastUnlockedIndex != lastUnlockedIndex;
  }
}
