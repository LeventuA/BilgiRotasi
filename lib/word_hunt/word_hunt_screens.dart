import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'word_hunt_models.dart';
import 'word_hunt_screens_core.dart' as core;

export 'word_hunt_screens_core.dart' hide WordHuntLevelProductionScreen;

/// Başlangıç Limanı production oynanışını seçilen gece-limanı temasıyla sarar.
///
/// Oynanış, path/scoring ve 8×8 geometri `word_hunt_screens_core.dart` içinde
/// birebir korunur. Bu katman yalnız görsel renklendirme ve dekor ekler.
class WordHuntLevelProductionScreen extends StatelessWidget {
  const WordHuntLevelProductionScreen({
    super.key,
    required this.level,
    required this.infoCards,
    this.now,
  });

  final WordHuntLevelDefinition level;
  final List<WordHuntInfoCard> infoCards;
  final DateTime Function()? now;

  @override
  Widget build(BuildContext context) {
    return Stack(
      key: const Key('word_hunt_production_harbor_theme'),
      fit: StackFit.expand,
      children: [
        ColorFiltered(
          key: const Key('word_hunt_production_harbor_warm_filter'),
          colorFilter: const ColorFilter.mode(
            Color(0x26FFC85C),
            BlendMode.softLight,
          ),
          child: core.WordHuntLevelProductionScreen(
            level: level,
            infoCards: infoCards,
            now: now,
          ),
        ),
        const Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(
              key: Key('word_hunt_production_harbor_overlay'),
              painter: _BaslangicLimaniHarborPainter(),
            ),
          ),
        ),
      ],
    );
  }
}

class _BaslangicLimaniHarborPainter extends CustomPainter {
  const _BaslangicLimaniHarborPainter();

  static const _gold = Color(0xFFFFC85C);
  static const _deepNavy = Color(0xFF020A16);

  @override
  void paint(Canvas canvas, Size size) {
    final vignette = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0x00020A16),
          Color(0x10020A16),
          Color(0x52020A16),
        ],
        stops: [0, 0.58, 1],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, vignette);

    final lighthouseX = size.width * 0.88;
    final lighthouseTop = size.height * 0.015;
    final lighthouseBottom = size.height * 0.073;
    final tower = Path()
      ..moveTo(lighthouseX - size.width * 0.018, lighthouseTop)
      ..lineTo(lighthouseX + size.width * 0.018, lighthouseTop)
      ..lineTo(lighthouseX + size.width * 0.032, lighthouseBottom)
      ..lineTo(lighthouseX - size.width * 0.032, lighthouseBottom)
      ..close();
    canvas.drawPath(
      tower,
      Paint()
        ..color = _deepNavy.withValues(alpha: 0.46)
        ..style = PaintingStyle.fill,
    );

    final lanternCenter = Offset(lighthouseX, lighthouseTop - size.height * 0.006);
    canvas.drawCircle(
      lanternCenter,
      math.max(3.0, size.shortestSide * 0.012),
      Paint()
        ..color = _gold.withValues(alpha: 0.30)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7),
    );
    canvas.drawCircle(
      lanternCenter,
      math.max(1.5, size.shortestSide * 0.005),
      Paint()..color = _gold.withValues(alpha: 0.72),
    );

    final beam = Path()
      ..moveTo(lanternCenter.dx, lanternCenter.dy)
      ..lineTo(0, math.max(0.0, lanternCenter.dy - size.height * 0.025))
      ..lineTo(0, lanternCenter.dy + size.height * 0.025)
      ..close();
    final beamBounds = Rect.fromLTWH(
      0,
      math.max(0.0, lanternCenter.dy - size.height * 0.025),
      lanternCenter.dx,
      size.height * 0.05,
    );
    canvas.drawPath(
      beam,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.centerRight,
          end: Alignment.centerLeft,
          colors: [
            Color(0x30FFC85C),
            Color(0x0CFFC85C),
            Color(0x00FFC85C),
          ],
        ).createShader(beamBounds),
    );

    const lights = [
      Offset(0.08, 0.18),
      Offset(0.23, 0.11),
      Offset(0.43, 0.17),
      Offset(0.68, 0.09),
      Offset(0.79, 0.20),
      Offset(0.94, 0.15),
    ];
    final lightPaint = Paint()..color = _gold.withValues(alpha: 0.34);
    for (final light in lights) {
      canvas.drawCircle(
        Offset(size.width * light.dx, size.height * light.dy),
        1.2,
        lightPaint,
      );
    }

    final edgePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = _gold.withValues(alpha: 0.10);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(1, 1, size.width - 2, size.height - 2),
        const Radius.circular(18),
      ),
      edgePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _BaslangicLimaniHarborPainter oldDelegate) =>
      false;
}
