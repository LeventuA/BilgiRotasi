import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'word_hunt_models.dart';
import 'word_hunt_progress.dart';
import 'word_hunt_starter_content.dart';

class WordHuntRouteMapV2Screen extends StatelessWidget {
  const WordHuntRouteMapV2Screen({
    super.key,
    this.route = WordHuntStarterContent.baslangicLimani,
    this.progress = const WordHuntProgressSnapshot(),
    this.onLevelTap,
    this.onBack,
    this.onInfo,
    this.onCompass,
    this.onJournal,
  });

  static const String backgroundAsset =
      'assets/word_hunt/baslangic_limani_bg.webp';

  final WordHuntRouteDefinition route;
  final WordHuntProgressSnapshot progress;
  final ValueChanged<int>? onLevelTap;
  final VoidCallback? onBack;
  final VoidCallback? onInfo;
  final VoidCallback? onCompass;
  final VoidCallback? onJournal;

  static const List<Offset> _stops = <Offset>[
    Offset(0.18, 0.07),
    Offset(0.48, 0.12),
    Offset(0.70, 0.20),
    Offset(0.82, 0.30),
    Offset(0.34, 0.38),
    Offset(0.16, 0.50),
    Offset(0.48, 0.54),
    Offset(0.76, 0.59),
    Offset(0.24, 0.72),
    Offset(0.53, 0.83),
  ];

  @override
  Widget build(BuildContext context) {
    final totalStars = WordHuntRouteProgressEngine.totalStars(route, progress);
    final lastUnlocked = _lastUnlockedIndex();

    return Scaffold(
      backgroundColor: const Color(0xFF020617),
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(onBack: onBack, onInfo: onInfo),
            _RouteBanner(
              title: route.title,
              stars: totalStars,
              maximumStars: route.maximumStars,
              gate: route.unlockStarsRequired,
            ),
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Image.asset(
                      backgroundAsset,
                      fit: BoxFit.cover,
                      alignment: Alignment.topCenter,
                      filterQuality: FilterQuality.high,
                      errorBuilder: (context, error, stackTrace) =>
                          const _HarborArtFallback(),
                    ),
                  ),
                  const Positioned.fill(child: _BackgroundReadabilityOverlay()),
                  Positioned.fill(
                    child: SingleChildScrollView(
                      key: const Key('word_hunt_v2_scroll'),
                      padding: const EdgeInsets.only(bottom: 104),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final mapHeight = math.max(
                            920.0,
                            MediaQuery.sizeOf(context).height * 1.20,
                          );
                          final size = Size(constraints.maxWidth, mapHeight);
                          final points = _stops
                              .map(
                                (stop) => Offset(
                                  stop.dx * size.width,
                                  stop.dy * size.height,
                                ),
                              )
                              .toList(growable: false);

                          return SizedBox(
                            height: mapHeight,
                            child: Stack(
                              children: [
                                Positioned.fill(
                                  child: CustomPaint(
                                    painter: _V2RoutePainter(
                                      points: points,
                                      route: route,
                                      lastUnlockedIndex: lastUnlocked,
                                    ),
                                  ),
                                ),
                                for (
                                  var index = 0;
                                  index < route.levels.length;
                                  index++
                                )
                                  _positionedStop(
                                    point: points[index],
                                    level: route.levels[index],
                                    stars: progress.starsFor(
                                      route.levels[index].id,
                                    ),
                                    unlocked:
                                        WordHuntRouteProgressEngine.isLevelUnlocked(
                                          route,
                                          progress,
                                          index + 1,
                                        ),
                                    mapSize: size,
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  Positioned(
                    left: 20,
                    bottom: 18,
                    child: _RoundControl(
                      icon: Icons.explore_rounded,
                      semanticLabel: 'Rota pusulası',
                      onTap: onCompass,
                    ),
                  ),
                  Positioned(
                    right: 20,
                    bottom: 18,
                    child: _RoundControl(
                      icon: Icons.menu_book_rounded,
                      semanticLabel: 'Kelime günlüğü',
                      onTap: onJournal,
                    ),
                  ),
                ],
              ),
            ),
          ],
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

  Widget _positionedStop({
    required Offset point,
    required WordHuntLevelDefinition level,
    required int stars,
    required bool unlocked,
    required Size mapSize,
  }) {
    final special = level.type != WordHuntLevelType.normal;
    final width = special ? 176.0 : 92.0;
    final height = special ? 112.0 : 88.0;
    final left = (point.dx - width / 2)
        .clamp(8.0, math.max(8.0, mapSize.width - width - 8))
        .toDouble();
    final top = (point.dy - height / 2)
        .clamp(8.0, math.max(8.0, mapSize.height - height - 8))
        .toDouble();

    return Positioned(
      left: left,
      top: top,
      width: width,
      height: height,
      child: _V2Stop(
        key: Key('word_hunt_v2_level_${level.index}'),
        level: level,
        stars: stars,
        unlocked: unlocked,
        onTap: unlocked && onLevelTap != null
            ? () => onLevelTap!(level.index)
            : null,
      ),
    );
  }
}

class _BackgroundReadabilityOverlay extends StatelessWidget {
  const _BackgroundReadabilityOverlay();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: const <double>[0, 0.18, 0.58, 1],
            colors: <Color>[
              const Color(0xFF020617).withValues(alpha: 0.28),
              const Color(0xFF020617).withValues(alpha: 0.05),
              Colors.transparent,
              const Color(0xFF020617).withValues(alpha: 0.32),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({this.onBack, this.onInfo});

  final VoidCallback? onBack;
  final VoidCallback? onInfo;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[Color(0xFF050A1D), Color(0xFF100A2A)],
        ),
      ),
      child: Row(
        children: [
          IconButton(
            key: const Key('word_hunt_v2_back'),
            tooltip: 'Geri',
            onPressed: onBack,
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: Color(0xFFFFD27A),
              size: 31,
            ),
          ),
          const Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                '✦  KELİME AVI  ✦',
                style: TextStyle(
                  color: Color(0xFFE9B8FF),
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.8,
                  shadows: <Shadow>[
                    Shadow(color: Color(0xFF7C3AED), blurRadius: 16),
                  ],
                ),
              ),
            ),
          ),
          IconButton(
            key: const Key('word_hunt_v2_info'),
            tooltip: 'Bilgi',
            onPressed: onInfo,
            icon: const Icon(
              Icons.info_outline_rounded,
              color: Color(0xFFE9B8FF),
              size: 30,
            ),
          ),
        ],
      ),
    );
  }
}

class _RouteBanner extends StatelessWidget {
  const _RouteBanner({
    required this.title,
    required this.stars,
    required this.maximumStars,
    required this.gate,
  });

  final String title;
  final int stars;
  final int maximumStars;
  final int gate;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 4, 12, 8),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 11),
      decoration: BoxDecoration(
        color: const Color(0xE90A1024),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFB58B4A), width: 1.4),
        boxShadow: const <BoxShadow>[
          BoxShadow(color: Color(0x66000000), blurRadius: 14, offset: Offset(0, 5)),
        ],
      ),
      child: Column(
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              title.replaceAll('i', 'İ').replaceAll('ı', 'I').toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 25,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.star_rounded, color: Color(0xFFFFD166), size: 25),
              const SizedBox(width: 5),
              Text(
                '$stars / $maximumStars',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const Spacer(),
              Text(
                'Kapı: $gate',
                style: const TextStyle(
                  color: Color(0xFFE5E7EB),
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.star_rounded, color: Color(0xFFFFD166), size: 22),
            ],
          ),
        ],
      ),
    );
  }
}

class _V2Stop extends StatelessWidget {
  const _V2Stop({
    super.key,
    required this.level,
    required this.stars,
    required this.unlocked,
    this.onTap,
  });

  final WordHuntLevelDefinition level;
  final int stars;
  final bool unlocked;
  final VoidCallback? onTap;

  Color get accent => switch (level.type) {
    WordHuntLevelType.normal => const Color(0xFF49E8F2),
    WordHuntLevelType.challenge => const Color(0xFFFF9D2E),
    WordHuntLevelType.bonus => const Color(0xFFC85CFF),
    WordHuntLevelType.routeFinal => const Color(0xFFFFD166),
  };

  String get specialLabel => switch (level.type) {
    WordHuntLevelType.normal => '',
    WordHuntLevelType.challenge => '⚔  MEYDAN OKUMA',
    WordHuntLevelType.bonus => '🎁  BONUS DURAK',
    WordHuntLevelType.routeFinal => '▣  ROTA FİNALİ',
  };

  @override
  Widget build(BuildContext context) {
    final activeAccent = unlocked ? accent : const Color(0xFF7C8495);
    final special = level.type != WordHuntLevelType.normal;
    final nodeSize = level.type == WordHuntLevelType.routeFinal ? 72.0 : 60.0;

    return Semantics(
      button: unlocked,
      label: unlocked
          ? 'Bölüm ${level.index}, ${specialLabel.isEmpty ? 'normal' : specialLabel}, $stars yıldız, açık'
          : 'Bölüm ${level.index}, kilitli',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: nodeSize,
                  height: nodeSize,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: unlocked
                          ? <Color>[
                              activeAccent.withValues(alpha: 0.65),
                              const Color(0xFF071427),
                            ]
                          : const <Color>[Color(0xFF3A3E48), Color(0xFF10131A)],
                    ),
                    border: Border.all(
                      color: activeAccent,
                      width: level.type == WordHuntLevelType.routeFinal ? 3.5 : 2.6,
                    ),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: activeAccent.withValues(alpha: unlocked ? 0.75 : 0.18),
                        blurRadius: unlocked ? 20 : 8,
                        spreadRadius: unlocked ? 3 : 0,
                      ),
                    ],
                  ),
                  child: unlocked
                      ? Text(
                          '${level.index}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: level.type == WordHuntLevelType.routeFinal ? 28 : 23,
                            fontWeight: FontWeight.w900,
                          ),
                        )
                      : const Icon(Icons.lock_rounded, color: Color(0xFFE5E7EB), size: 28),
                ),
                if (special) ...[
                  const SizedBox(width: 5),
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
                      decoration: BoxDecoration(
                        color: const Color(0xE60A0F1E),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: activeAccent.withValues(alpha: 0.9)),
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                            color: activeAccent.withValues(alpha: 0.22),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Text(
                        specialLabel,
                        maxLines: 2,
                        style: TextStyle(
                          color: activeAccent,
                          fontSize: 9.5,
                          height: 1.05,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: List<Widget>.generate(
                3,
                (index) => Icon(
                  Icons.star_rounded,
                  size: 17,
                  color: index < stars
                      ? const Color(0xFFFFD166)
                      : const Color(0xFF737989),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoundControl extends StatelessWidget {
  const _RoundControl({
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
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 62,
          height: 62,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xE70A1020),
            border: Border.all(color: const Color(0xFFB58B4A), width: 2),
            boxShadow: const <BoxShadow>[
              BoxShadow(color: Color(0x88000000), blurRadius: 12),
            ],
          ),
          child: Icon(icon, color: const Color(0xFFFFD27A), size: 32),
        ),
      ),
    );
  }
}

class _V2RoutePainter extends CustomPainter {
  const _V2RoutePainter({
    required this.points,
    required this.route,
    required this.lastUnlockedIndex,
  });

  final List<Offset> points;
  final WordHuntRouteDefinition route;
  final int lastUnlockedIndex;

  @override
  void paint(Canvas canvas, Size size) {
    for (var index = 0; index < points.length - 1; index++) {
      final start = points[index];
      final end = points[index + 1];
      final control = Offset(
        (start.dx + end.dx) / 2 + (index.isEven ? 36 : -36),
        (start.dy + end.dy) / 2,
      );
      final path = Path()
        ..moveTo(start.dx, start.dy)
        ..quadraticBezierTo(control.dx, control.dy, end.dx, end.dy);
      final active = index + 2 <= lastUnlockedIndex;
      final destination = route.levels[index + 1].type;
      final color = switch (destination) {
        WordHuntLevelType.challenge => const Color(0xFFFFA133),
        WordHuntLevelType.bonus => const Color(0xFFC85CFF),
        WordHuntLevelType.routeFinal => const Color(0xFFFFD166),
        WordHuntLevelType.normal => const Color(0xFF55E7EF),
      };

      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = active ? 11 : 7
          ..color = active
              ? color.withValues(alpha: 0.18)
              : const Color(0xFFCBD5E1).withValues(alpha: 0.08),
      );
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = active ? 4 : 2.5
          ..color = active
              ? color.withValues(alpha: 0.96)
              : const Color(0xFFB7C0CF).withValues(alpha: 0.62),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _V2RoutePainter oldDelegate) {
    return oldDelegate.lastUnlockedIndex != lastUnlockedIndex ||
        oldDelegate.points != points ||
        oldDelegate.route != route;
  }
}

class _HarborArtFallback extends StatelessWidget {
  const _HarborArtFallback();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _HarborArtPainter(),
      child: const SizedBox.expand(),
    );
  }
}

class _HarborArtPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            Color(0xFF020617),
            Color(0xFF082A43),
            Color(0xFF07506A),
            Color(0xFF031B2E),
          ],
        ).createShader(rect),
    );

    final moon = Offset(size.width * 0.72, size.height * 0.10);
    canvas.drawCircle(
      moon,
      34,
      Paint()
        ..shader = const RadialGradient(
          colors: <Color>[Color(0xFFFFF4D6), Color(0x55FFF4D6), Colors.transparent],
        ).createShader(Rect.fromCircle(center: moon, radius: 54)),
    );

    final reflection = Path()
      ..moveTo(size.width * 0.66, size.height * 0.15)
      ..lineTo(size.width * 0.84, size.height * 0.15)
      ..lineTo(size.width * 0.66, size.height * 0.80)
      ..lineTo(size.width * 0.48, size.height * 0.80)
      ..close();
    canvas.drawPath(
      reflection,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[Color(0x44FFF4D6), Colors.transparent],
        ).createShader(rect),
    );

    _drawIsland(canvas, size, Offset(size.width * -0.08, size.height * 0.12), 0.46, 0.16);
    _drawIsland(canvas, size, Offset(size.width * 0.66, size.height * 0.24), 0.46, 0.18);
    _drawIsland(canvas, size, Offset(size.width * -0.16, size.height * 0.44), 0.55, 0.17);
    _drawIsland(canvas, size, Offset(size.width * 0.68, size.height * 0.55), 0.45, 0.16);
    _drawIsland(canvas, size, Offset(size.width * -0.08, size.height * 0.74), 0.50, 0.18);
    _drawIsland(canvas, size, Offset(size.width * 0.62, size.height * 0.82), 0.50, 0.18);

    _drawLighthouse(canvas, size, Offset(size.width * 0.87, size.height * 0.20));
    _drawShip(canvas, size, Offset(size.width * 0.14, size.height * 0.32), 1.0);
    _drawShip(canvas, size, Offset(size.width * 0.78, size.height * 0.67), 0.72);
  }

  void _drawIsland(Canvas canvas, Size size, Offset origin, double w, double h) {
    final islandRect = Rect.fromLTWH(origin.dx, origin.dy, size.width * w, size.height * h);
    canvas.drawOval(
      islandRect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[Color(0xFF174B42), Color(0xFF092C2F), Color(0xFF071C29)],
        ).createShader(islandRect),
    );
    final glowPaint = Paint()..color = const Color(0xFFFFC766);
    final count = math.max(3, (w * 12).round());
    for (var i = 0; i < count; i++) {
      final x = islandRect.left + 18 + (i * 31) % math.max(24, islandRect.width - 30);
      final y = islandRect.top + islandRect.height * (0.48 + (i % 3) * 0.12);
      canvas.drawCircle(Offset(x, y), 2.3, glowPaint);
      canvas.drawCircle(
        Offset(x, y),
        7,
        Paint()..color = const Color(0x22FFD166),
      );
    }
  }

  void _drawLighthouse(Canvas canvas, Size size, Offset base) {
    final tower = Path()
      ..moveTo(base.dx - 12, base.dy + 64)
      ..lineTo(base.dx + 12, base.dy + 64)
      ..lineTo(base.dx + 8, base.dy)
      ..lineTo(base.dx - 8, base.dy)
      ..close();
    canvas.drawPath(tower, Paint()..color = const Color(0xFFD8D0B8));
    canvas.drawRect(
      Rect.fromCenter(center: Offset(base.dx, base.dy - 3), width: 24, height: 13),
      Paint()..color = const Color(0xFF2B2230),
    );
    canvas.drawCircle(
      Offset(base.dx, base.dy - 4),
      5,
      Paint()..color = const Color(0xFFFFD166),
    );
    canvas.drawCircle(
      Offset(base.dx, base.dy - 4),
      22,
      Paint()..color = const Color(0x22FFD166),
    );
  }

  void _drawShip(Canvas canvas, Size size, Offset base, double scale) {
    final hull = Path()
      ..moveTo(base.dx - 28 * scale, base.dy)
      ..quadraticBezierTo(
        base.dx,
        base.dy + 18 * scale,
        base.dx + 31 * scale,
        base.dy,
      )
      ..close();
    canvas.drawPath(hull, Paint()..color = const Color(0xFF3B2418));
    canvas.drawLine(
      Offset(base.dx, base.dy - 44 * scale),
      Offset(base.dx, base.dy + 3 * scale),
      Paint()
        ..color = const Color(0xFFBA8B5C)
        ..strokeWidth = 2,
    );
    final sail = Path()
      ..moveTo(base.dx + 2 * scale, base.dy - 40 * scale)
      ..lineTo(base.dx + 24 * scale, base.dy - 15 * scale)
      ..lineTo(base.dx + 2 * scale, base.dy - 10 * scale)
      ..close();
    canvas.drawPath(sail, Paint()..color = const Color(0xFFD6C9AA));
  }

  @override
  bool shouldRepaint(covariant _HarborArtPainter oldDelegate) => false;
}
