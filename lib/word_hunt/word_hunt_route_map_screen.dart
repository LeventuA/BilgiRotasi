import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'word_hunt_models.dart';
import 'word_hunt_progress.dart';
import 'word_hunt_starter_content.dart';

/// Kullanıcı tarafından 20 Ağustos 2026'da onaylanan görsel yönü izole olarak
/// uygular. Mevcut Bilgi Rotası ana navigasyonuna veya eski rota ekranına bağlı
/// değildir.
class WordHuntRouteMapPrototypeScreen extends StatelessWidget {
  const WordHuntRouteMapPrototypeScreen({
    super.key,
    this.route = WordHuntStarterContent.baslangicLimani,
    this.progress = const WordHuntProgressSnapshot(),
    this.onLevelTap,
  });

  final WordHuntRouteDefinition route;
  final WordHuntProgressSnapshot progress;
  final ValueChanged<int>? onLevelTap;

  static const List<Offset> _normalizedStops = <Offset>[
    Offset(0.15, 0.09),
    Offset(0.48, 0.16),
    Offset(0.71, 0.26),
    Offset(0.82, 0.39),
    Offset(0.57, 0.49),
    Offset(0.20, 0.59),
    Offset(0.46, 0.68),
    Offset(0.77, 0.73),
    Offset(0.31, 0.81),
    Offset(0.58, 0.90),
  ];

  @override
  Widget build(BuildContext context) {
    final routeStars = WordHuntRouteProgressEngine.totalStars(route, progress);
    final routeComplete = WordHuntRouteProgressEngine.isRouteComplete(
      route,
      progress,
    );
    final lastUnlocked = _lastUnlockedIndex();

    return Scaffold(
      backgroundColor: const Color(0xFF041027),
      appBar: AppBar(
        backgroundColor: const Color(0xFF041027),
        foregroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          'KELİME AVI',
          style: TextStyle(
            color: Color(0xFFD8B4FE),
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(14, 8, 14, 28),
          children: [
            _ApprovedRouteHeader(
              title: route.title,
              stars: routeStars,
              maximumStars: route.maximumStars,
              unlockStarsRequired: route.unlockStarsRequired,
              complete: routeComplete,
            ),
            const SizedBox(height: 12),
            AspectRatio(
              aspectRatio: 0.58,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final size = Size(
                    constraints.maxWidth,
                    constraints.maxHeight,
                  );
                  final points = _pointsFor(size)
                      .take(math.min(route.levels.length, _normalizedStops.length))
                      .toList(growable: false);

                  return ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: DecoratedBox(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: <Color>[
                            Color(0xFF071A3A),
                            Color(0xFF072A42),
                            Color(0xFF081A37),
                            Color(0xFF120C2B),
                          ],
                        ),
                      ),
                      child: Stack(
                        children: [
                          const Positioned.fill(child: _HarborBackdrop()),
                          Positioned.fill(
                            child: CustomPaint(
                              painter: _RoutePathPainter(
                                points: points,
                                lastUnlockedIndex: lastUnlocked,
                                route: route,
                              ),
                            ),
                          ),
                          for (var index = 0; index < points.length; index++)
                            _positionedNode(
                              point: points[index],
                              level: route.levels[index],
                              stars: progress.starsFor(route.levels[index].id),
                              unlocked:
                                  WordHuntRouteProgressEngine.isLevelUnlocked(
                                    route,
                                    progress,
                                    index + 1,
                                  ),
                              size: size,
                            ),
                          const Positioned(
                            right: 18,
                            top: 112,
                            child: _Landmark(
                              icon: Icons.light_mode_rounded,
                              label: 'Fener',
                            ),
                          ),
                          const Positioned(
                            left: 14,
                            top: 242,
                            child: _Landmark(
                              icon: Icons.directions_boat_filled_rounded,
                              label: 'Liman',
                            ),
                          ),
                          const Positioned(
                            right: 18,
                            bottom: 26,
                            child: _Landmark(
                              icon: Icons.inventory_2_rounded,
                              label: 'Hazine',
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
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

  List<Offset> _pointsFor(Size size) {
    return _normalizedStops
        .map((stop) => Offset(stop.dx * size.width, stop.dy * size.height))
        .toList(growable: false);
  }

  Widget _positionedNode({
    required Offset point,
    required WordHuntLevelDefinition level,
    required int stars,
    required bool unlocked,
    required Size size,
  }) {
    final nodeSize = switch (level.type) {
      WordHuntLevelType.normal => 58.0,
      WordHuntLevelType.challenge => 66.0,
      WordHuntLevelType.bonus => 66.0,
      WordHuntLevelType.routeFinal => 72.0,
    };
    final labelWidth = level.type == WordHuntLevelType.normal ? 92.0 : 132.0;
    final boxWidth = math.max(nodeSize, labelWidth).toDouble();
    final extraHeight = level.type == WordHuntLevelType.normal ? 24.0 : 44.0;
    final left = (point.dx - nodeSize / 2)
        .clamp(0.0, math.max(0.0, size.width - boxWidth))
        .toDouble();
    final top = (point.dy - nodeSize / 2)
        .clamp(0.0, math.max(0.0, size.height - nodeSize - extraHeight))
        .toDouble();

    return Positioned(
      left: left,
      top: top,
      width: boxWidth,
      child: Align(
        alignment: Alignment.topLeft,
        child: _RouteMapNode(
          key: Key('word_hunt_map_level_${level.index}'),
          level: level,
          stars: stars,
          unlocked: unlocked,
          nodeSize: nodeSize,
          onTap: unlocked && onLevelTap != null
              ? () => onLevelTap!(level.index)
              : null,
        ),
      ),
    );
  }
}

class _ApprovedRouteHeader extends StatelessWidget {
  const _ApprovedRouteHeader({
    required this.title,
    required this.stars,
    required this.maximumStars,
    required this.unlockStarsRequired,
    required this.complete,
  });

  final String title;
  final int stars;
  final int maximumStars;
  final int unlockStarsRequired;
  final bool complete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: <Color>[Color(0xFF1B123B), Color(0xFF0A1E43)],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFB68432), width: 1.3),
        boxShadow: const <BoxShadow>[
          BoxShadow(color: Color(0x338B5CF6), blurRadius: 16),
        ],
      ),
      child: Column(
        children: [
          const Text(
            '1. ROTA',
            style: TextStyle(
              color: Color(0xFFD8B4FE),
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.4,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title.replaceAll('i', 'İ').replaceAll('ı', 'I').toUpperCase(),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 9),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.star_rounded, color: Color(0xFFFFD166), size: 22),
              const SizedBox(width: 5),
              Text(
                '$stars / $maximumStars',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(width: 18),
              Text(
                complete ? 'ROTA TAMAMLANDI' : 'Kapı: $unlockStarsRequired ⭐',
                style: TextStyle(
                  color: complete
                      ? const Color(0xFF5EEAD4)
                      : const Color(0xFFFFD166),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HarborBackdrop extends StatelessWidget {
  const _HarborBackdrop();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: CustomPaint(painter: _WaterTexturePainter()),
        ),
        const Positioned(
          left: -54,
          top: 38,
          child: _IslandBlob(width: 160, height: 118, rotation: -0.18),
        ),
        const Positioned(
          right: -64,
          top: 155,
          child: _IslandBlob(width: 190, height: 132, rotation: 0.12),
        ),
        const Positioned(
          left: -72,
          top: 320,
          child: _IslandBlob(width: 210, height: 142, rotation: 0.08),
        ),
        const Positioned(
          right: -60,
          bottom: 118,
          child: _IslandBlob(width: 190, height: 132, rotation: -0.12),
        ),
        const Positioned(
          left: 22,
          bottom: 12,
          child: Icon(
            Icons.anchor_rounded,
            size: 42,
            color: Color(0x5587A9C8),
          ),
        ),
      ],
    );
  }
}

class _IslandBlob extends StatelessWidget {
  const _IslandBlob({
    required this.width,
    required this.height,
    required this.rotation,
  });

  final double width;
  final double height;
  final double rotation;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: rotation,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(70),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[Color(0xFF163A3C), Color(0xFF10233B)],
          ),
          border: Border.all(color: const Color(0x5534D399)),
          boxShadow: const <BoxShadow>[
            BoxShadow(color: Color(0x55000000), blurRadius: 18, spreadRadius: 4),
          ],
        ),
      ),
    );
  }
}

class _Landmark extends StatelessWidget {
  const _Landmark({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0x99101B37),
            border: Border.all(color: const Color(0x66FFD166)),
          ),
          child: Icon(icon, color: const Color(0xFFFFD166), size: 23),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFFA7B0C9),
            fontSize: 9,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _RouteMapNode extends StatelessWidget {
  const _RouteMapNode({
    super.key,
    required this.level,
    required this.stars,
    required this.unlocked,
    required this.nodeSize,
    this.onTap,
  });

  final WordHuntLevelDefinition level;
  final int stars;
  final bool unlocked;
  final double nodeSize;
  final VoidCallback? onTap;

  Color get _accent => switch (level.type) {
    WordHuntLevelType.normal => const Color(0xFF22D3EE),
    WordHuntLevelType.challenge => const Color(0xFFF59E0B),
    WordHuntLevelType.bonus => const Color(0xFFA855F7),
    WordHuntLevelType.routeFinal => const Color(0xFFFFD166),
  };

  String get _typeLabel => switch (level.type) {
    WordHuntLevelType.normal => '',
    WordHuntLevelType.challenge => 'MEYDAN OKUMA',
    WordHuntLevelType.bonus => 'BONUS DURAK',
    WordHuntLevelType.routeFinal => 'ROTA FİNALİ',
  };

  @override
  Widget build(BuildContext context) {
    final accent = unlocked ? _accent : const Color(0xFF5D6678);
    final semanticLabel = unlocked
        ? 'Bölüm ${level.index}, ${_typeLabel.isEmpty ? 'Normal' : _typeLabel}, $stars yıldız, açık'
        : 'Bölüm ${level.index}, kilitli';

    return Semantics(
      button: unlocked,
      label: semanticLabel,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Column(
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
                          accent.withValues(alpha: 0.55),
                          const Color(0xFF0B1833),
                        ]
                      : const <Color>[Color(0xFF263044), Color(0xFF111827)],
                ),
                border: Border.all(
                  color: accent,
                  width: level.type == WordHuntLevelType.routeFinal ? 3 : 2,
                ),
                boxShadow: unlocked
                    ? <BoxShadow>[
                        BoxShadow(
                          color: accent.withValues(alpha: 0.42),
                          blurRadius: 15,
                          spreadRadius: 2,
                        ),
                      ]
                    : const <BoxShadow>[],
              ),
              child: unlocked
                  ? Text(
                      '${level.index}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: level.type == WordHuntLevelType.routeFinal ? 25 : 21,
                        fontWeight: FontWeight.w900,
                      ),
                    )
                  : const Icon(Icons.lock_rounded, color: Color(0xFFA1A8B5)),
            ),
            const SizedBox(height: 3),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: List<Widget>.generate(
                3,
                (index) => Icon(
                  Icons.star_rounded,
                  size: 13,
                  color: index < stars
                      ? const Color(0xFFFFD166)
                      : const Color(0xFF586174),
                ),
              ),
            ),
            if (_typeLabel.isNotEmpty) ...[
              const SizedBox(height: 3),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xCC0A1226),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: accent.withValues(alpha: 0.75)),
                ),
                child: Text(
                  _typeLabel,
                  maxLines: 1,
                  style: TextStyle(
                    color: accent,
                    fontSize: 8.5,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _RoutePathPainter extends CustomPainter {
  const _RoutePathPainter({
    required this.points,
    required this.lastUnlockedIndex,
    required this.route,
  });

  final List<Offset> points;
  final int lastUnlockedIndex;
  final WordHuntRouteDefinition route;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;

    for (var index = 0; index < points.length - 1; index++) {
      final start = points[index];
      final end = points[index + 1];
      final midpoint = Offset(
        (start.dx + end.dx) / 2 + (index.isEven ? 24 : -24),
        (start.dy + end.dy) / 2,
      );
      final path = Path()
        ..moveTo(start.dx, start.dy)
        ..quadraticBezierTo(midpoint.dx, midpoint.dy, end.dx, end.dy);

      final unlockedSegment = index + 2 <= lastUnlockedIndex;
      final destinationType = index + 1 < route.levels.length
          ? route.levels[index + 1].type
          : WordHuntLevelType.normal;
      final activeColor = switch (destinationType) {
        WordHuntLevelType.challenge => const Color(0xFFF59E0B),
        WordHuntLevelType.bonus => const Color(0xFFA855F7),
        WordHuntLevelType.routeFinal => const Color(0xFFFFD166),
        WordHuntLevelType.normal => const Color(0xFF22D3EE),
      };

      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 9
          ..strokeCap = StrokeCap.round
          ..color = const Color(0x33000000),
      );
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = unlockedSegment ? 4.5 : 2.5
          ..strokeCap = StrokeCap.round
          ..color = unlockedSegment
              ? activeColor.withValues(alpha: 0.92)
              : const Color(0xFF475569).withValues(alpha: 0.58),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RoutePathPainter oldDelegate) {
    return oldDelegate.lastUnlockedIndex != lastUnlockedIndex ||
        oldDelegate.points != points ||
        oldDelegate.route != route;
  }
}

class _WaterTexturePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = const Color(0x2245E6F2);

    for (var y = 18.0; y < size.height; y += 34) {
      final path = Path()..moveTo(0, y);
      for (var x = 0.0; x <= size.width; x += 30) {
        path.quadraticBezierTo(
          x + 8,
          y + ((x ~/ 30).isEven ? 3 : -3),
          x + 15,
          y,
        );
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _WaterTexturePainter oldDelegate) => false;
}
