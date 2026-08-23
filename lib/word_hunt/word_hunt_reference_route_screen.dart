import 'dart:math' as math;

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
    Offset(0.189, 0.238), // 1 - üst sol
    Offset(0.443, 0.257), // 2 - üst orta
    Offset(0.642, 0.305), // 3 - üst sağ
    Offset(0.803, 0.373), // 4 - sağdaki deniz feneri dönüşü
    Offset(0.335, 0.453), // 5 - meydan okuma
    Offset(0.167, 0.552), // 6 - alt sol
    Offset(0.460, 0.583), // 7 - merkez-alt
    Offset(0.668, 0.616), // 8 - bonus, sağ
    Offset(0.236, 0.697), // 9 - kilitli sol kol
    Offset(0.489, 0.797), // 10 - rota finali
  ];

  static const double routeAreaTop = 0;
  static const double routeAreaBottom = 0;

  static const Rect topPanel = Rect.fromLTRB(0.081, 0.070, 0.924, 0.158);

  static const List<Offset> bottomControlCenters = <Offset>[
    Offset(0.126, 0.933),
    Offset(0.875, 0.933),
  ];

  /// Her segment için bağlayıcı referanstan ölçülen iki cubic Bézier kontrolü.
  static const List<(Offset, Offset)> routeControls = <(Offset, Offset)>[
    (Offset(0.270, 0.236), Offset(0.365, 0.242)),
    (Offset(0.515, 0.266), Offset(0.585, 0.286)),
    (Offset(0.704, 0.325), Offset(0.760, 0.348)),
    (Offset(0.778, 0.410), Offset(0.520, 0.423)),
    (Offset(0.250, 0.480), Offset(0.190, 0.515)),
    (Offset(0.245, 0.565), Offset(0.360, 0.575)),
    (Offset(0.535, 0.590), Offset(0.610, 0.603)),
    (Offset(0.600, 0.645), Offset(0.335, 0.660)),
    (Offset(0.225, 0.746), Offset(0.380, 0.775)),
  ];
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
    if (!unlocked && destinationType != WordHuntLevelType.routeFinal) {
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
      body: LayoutBuilder(
        builder: (context, constraints) {
          final size = Size(constraints.maxWidth, constraints.maxHeight);
          const routeTop = WordHuntReferenceRouteLayout.routeAreaTop;
          const routeBottom = WordHuntReferenceRouteLayout.routeAreaBottom;
          final routeHeight = size.height - routeTop - routeBottom;
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
              const Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(painter: _ReferenceFramePainter()),
                ),
              ),
              _ReferenceTopChrome(
                viewportSize: size,
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
                        unlocked: WordHuntRouteProgressEngine.isLevelUnlocked(
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
                left:
                    size.width *
                        WordHuntReferenceRouteLayout
                            .bottomControlCenters[0]
                            .dx -
                    35,
                top:
                    size.height *
                        WordHuntReferenceRouteLayout
                            .bottomControlCenters[0]
                            .dy -
                    35,
                child: _ReferenceBottomControl(
                  key: const Key('word_hunt_reference_compass'),
                  icon: Icons.explore_rounded,
                  semanticLabel: 'Pusula',
                  onTap: onCompass,
                ),
              ),
              Positioned(
                left:
                    size.width *
                        WordHuntReferenceRouteLayout
                            .bottomControlCenters[1]
                            .dx -
                    35,
                top:
                    size.height *
                        WordHuntReferenceRouteLayout
                            .bottomControlCenters[1]
                            .dy -
                    35,
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
    final desiredLeft =
        special ? point.dx - diameter / 2 : point.dx - width / 2;
    final desiredTop =
        point.dy - height / 2 + (_metrics.starGap + _metrics.starSize) / 2;
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
          onTap:
              unlocked && onLevelTap != null
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
        alignment: Alignment.topCenter,
        errorBuilder:
            (context, error, stackTrace) => const _FallbackBackground(),
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
            Color(0x6E050817),
            Color(0x26020916),
            Color(0x08000000),
            Color(0x32020611),
            Color(0x8001060E),
          ],
          stops: <double>[0, 0.16, 0.39, 0.80, 1],
        ),
      ),
    );
  }
}

class _ReferenceTopChrome extends StatelessWidget {
  const _ReferenceTopChrome({
    required this.viewportSize,
    required this.title,
    required this.stars,
    required this.maximumStars,
    required this.unlockStarsRequired,
    this.onBack,
    this.onInfo,
  });

  final Size viewportSize;
  final String title;
  final int stars;
  final int maximumStars;
  final int unlockStarsRequired;
  final VoidCallback? onBack;
  final VoidCallback? onInfo;

  @override
  Widget build(BuildContext context) {
    final panel = WordHuntReferenceRouteLayout.topPanel;
    return Positioned.fill(
      child: Stack(
        children: [
          Positioned(
            left: 12,
            right: 12,
            top: 8,
            child: SizedBox(
              height: 38,
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
                            'KELİME AVI',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFFF4E7FF),
                              fontFamily: 'serif',
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.7,
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
          ),
          Positioned(
            key: const Key('word_hunt_reference_top_panel'),
            left: panel.left * viewportSize.width,
            top: panel.top * viewportSize.height,
            width: panel.width * viewportSize.width,
            height: panel.height * viewportSize.height,
            child: CustomPaint(
              foregroundPainter: const _ReferencePanelOrnamentPainter(),
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 5, 16, 3),
                decoration: BoxDecoration(
                  color: const Color(0xE308101B),
                  borderRadius: BorderRadius.circular(3),
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
                      title.toUpperCase().replaceFirst('LIMANI', 'LİMANI'),
                      maxLines: 1,
                      overflow: TextOverflow.fade,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFFFFF7E7),
                        fontFamily: 'serif',
                        fontSize: 20,
                        height: 1,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.55,
                        shadows: <Shadow>[
                          Shadow(color: Color(0x99000000), blurRadius: 4),
                        ],
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          color: Color(0xFFFFC94A),
                          size: 17,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$stars / $maximumStars',
                          style: const TextStyle(
                            color: Color(0xFFFFE9B0),
                            fontFamily: 'serif',
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'Kapı: $unlockStarsRequired',
                          style: const TextStyle(
                            color: Color(0xFFF3E6C9),
                            fontFamily: 'serif',
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 3),
                        const Icon(
                          Icons.star_rounded,
                          color: Color(0xFFFFC94A),
                          size: 16,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReferencePanelOrnamentPainter extends CustomPainter {
  const _ReferencePanelOrnamentPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.8
          ..color = const Color(0xC6D1A45B);
    const inset = 4.0;
    const arm = 11.0;
    for (final corner in <(Offset, double, double)>[
      (const Offset(inset, inset), 1, 1),
      (Offset(size.width - inset, inset), -1, 1),
      (Offset(inset, size.height - inset), 1, -1),
      (Offset(size.width - inset, size.height - inset), -1, -1),
    ]) {
      final origin = corner.$1;
      canvas.drawLine(origin, origin + Offset(corner.$2 * arm, 0), paint);
      canvas.drawLine(origin, origin + Offset(0, corner.$3 * arm), paint);
      final diamond =
          Path()
            ..moveTo(origin.dx, origin.dy - 2)
            ..lineTo(origin.dx + 2, origin.dy)
            ..lineTo(origin.dx, origin.dy + 2)
            ..lineTo(origin.dx - 2, origin.dy)
            ..close();
      canvas.drawPath(diamond, paint);
    }
    final midpoint = Offset(size.width / 2, inset);
    final diamond =
        Path()
          ..moveTo(midpoint.dx, midpoint.dy - 2.5)
          ..lineTo(midpoint.dx + 3, midpoint.dy)
          ..lineTo(midpoint.dx, midpoint.dy + 2.5)
          ..lineTo(midpoint.dx - 3, midpoint.dy)
          ..close();
    canvas.drawPath(diamond, paint);
  }

  @override
  bool shouldRepaint(covariant _ReferencePanelOrnamentPainter oldDelegate) =>
      false;
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
                colors: const <Color>[Color(0x007B3BB5), Color(0xA88A4FC5)],
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
            width: 27,
            height: 27,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0x660A111D),
              border: Border.all(color: const Color(0xBBA57A3D)),
            ),
            child: Icon(icon, color: const Color(0xFFE8C678), size: 19),
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
          child: SizedBox.square(
            dimension: 70,
            child: CustomPaint(
              painter: const _ReferenceBottomControlPainter(),
              child: Icon(icon, color: const Color(0xFFF2CE71), size: 36),
            ),
          ),
        ),
      ),
    );
  }
}

class _ReferenceBottomControlPainter extends CustomPainter {
  const _ReferenceBottomControlPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    canvas.drawCircle(
      center,
      size.width * 0.49,
      Paint()
        ..shader = const RadialGradient(
          colors: <Color>[Color(0xFF1C303A), Color(0xFF071019)],
        ).createShader(Offset.zero & size),
    );
    for (final ring in <(double, double, Color)>[
      (0.46, 1.5, const Color(0xFFE2B760)),
      (0.39, 0.9, const Color(0xFF7F5B2D)),
      (0.32, 0.6, const Color(0xFFB38B4D)),
    ]) {
      canvas.drawCircle(
        center,
        size.width * ring.$1,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = ring.$2
          ..color = ring.$3,
      );
    }
    final ornament = Paint()..color = const Color(0xFFD8A951);
    for (var index = 0; index < 8; index++) {
      final angle = index * math.pi / 4;
      final direction = Offset(math.cos(angle), math.sin(angle));
      canvas.drawCircle(center + direction * size.width * 0.425, 1.2, ornament);
    }
  }

  @override
  bool shouldRepaint(covariant _ReferenceBottomControlPainter oldDelegate) =>
      false;
}

class _ReferenceFramePainter extends CustomPainter {
  const _ReferenceFramePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final outer = RRect.fromRectAndRadius(
      Rect.fromLTWH(3, 3, size.width - 6, size.height - 6),
      const Radius.circular(22),
    );
    final inner = RRect.fromRectAndRadius(
      Rect.fromLTWH(8, 8, size.width - 16, size.height - 16),
      const Radius.circular(18),
    );
    canvas.drawRRect(
      outer,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.1
        ..color = const Color(0x7AB78A3E),
    );
    canvas.drawRRect(
      inner,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.7
        ..color = const Color(0x554A3A25),
    );
  }

  @override
  bool shouldRepaint(covariant _ReferenceFramePainter oldDelegate) => false;
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

    final shadow =
        Paint()
          ..color = const Color(0xA8000000)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.4
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round;

    for (var index = 0; index < points.length - 1; index++) {
      final from = points[index];
      final to = points[index + 1];
      final controls = WordHuntReferenceRouteLayout.routeControls[index];
      final control1 = Offset(
        controls.$1.dx * size.width,
        controls.$1.dy * size.height,
      );
      final control2 = Offset(
        controls.$2.dx * size.width,
        controls.$2.dy * size.height,
      );
      final path =
          Path()
            ..moveTo(from.dx, from.dy)
            ..cubicTo(
              control1.dx,
              control1.dy,
              control2.dx,
              control2.dy,
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
        final dormantGlow =
            Paint()
              ..color = const Color(0x305B7589)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 3.2
              ..strokeCap = StrokeCap.round;
        final dormant =
            Paint()
              ..color = const Color(0xB59AA5B2)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1.8
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
        WordHuntReferenceRouteSegmentStyle.locked =>
          throw StateError(
            'Locked segment is handled before active palette selection.',
          ),
      };

      final glow =
          Paint()
            ..color = glowColor
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3.8
            ..strokeCap = StrokeCap.round
            ..strokeJoin = StrokeJoin.round
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.2);
      final core =
          Paint()
            ..color = coreColor
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.45
            ..strokeCap = StrokeCap.round
            ..strokeJoin = StrokeJoin.round;

      if (style == WordHuntReferenceRouteSegmentStyle.finalStop) {
        _drawFinalGradient(canvas, path, glow, core);
      } else {
        canvas.drawPath(path, glow);
        canvas.drawPath(path, core);
      }
    }
  }

  void _drawFinalGradient(Canvas canvas, Path path, Paint glow, Paint core) {
    for (final metric in path.computeMetrics()) {
      final split = metric.length * 0.52;
      final purple = metric.extractPath(0, split);
      final gold = metric.extractPath(split, metric.length);
      canvas.drawPath(purple, glow..color = const Color(0x70A94AF3));
      canvas.drawPath(purple, core..color = const Color(0xFFC06BFF));
      canvas.drawPath(gold, glow..color = const Color(0x70F6B83D));
      canvas.drawPath(gold, core..color = const Color(0xFFFFD76B));
    }
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint) {
    const dashLength = 8.0;
    const gapLength = 6.0;
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final end =
            (distance + dashLength).clamp(0.0, metric.length).toDouble();
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
