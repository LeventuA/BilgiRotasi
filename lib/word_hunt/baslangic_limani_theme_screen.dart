import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'word_hunt_models.dart';
import 'word_hunt_screens.dart';

/// Başlangıç Limanı için kullanıcı tarafından seçilen gece-limanı temasını
/// doğrulanmış production oynanış ekranının üstüne uygular.
///
/// Path/scoring/gesture/8×8 geometri bu dosyada tekrar edilmez ve değiştirilmez.
class BaslangicLimaniThemedLevelScreen extends StatelessWidget {
  const BaslangicLimaniThemedLevelScreen({
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
      key: const Key('word_hunt_baslangic_limani_theme'),
      fit: StackFit.expand,
      children: [
        ColorFiltered(
          key: const Key('word_hunt_baslangic_limani_warm_filter'),
          colorFilter: const ColorFilter.mode(
            Color(0x24FFC85C),
            BlendMode.softLight,
          ),
          child: WordHuntLevelProductionScreen(
            level: level,
            infoCards: infoCards,
            now: now,
          ),
        ),
        const Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(
              key: Key('word_hunt_baslangic_limani_overlay'),
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

  static const Color _gold = Color(0xFFFFC85C);
  static const Color _deepNavy = Color(0xFF020A16);

  @override
  void paint(Canvas canvas, Size size) {
    final vignette = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: <Color>[
          Color(0x00020A16),
          Color(0x10020A16),
          Color(0x48020A16),
        ],
        stops: <double>[0, 0.58, 1],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, vignette);

    // Deniz feneri yalnız üst sağdaki başlık bölgesinde kalır; sayaç/grid üstüne
    // dekor taşırılmaz.
    final lighthouseX = size.width * 0.88;
    final lighthouseTop = size.height * 0.014;
    final lighthouseBottom = size.height * 0.066;
    final tower = Path()
      ..moveTo(lighthouseX - size.width * 0.016, lighthouseTop)
      ..lineTo(lighthouseX + size.width * 0.016, lighthouseTop)
      ..lineTo(lighthouseX + size.width * 0.027, lighthouseBottom)
      ..lineTo(lighthouseX - size.width * 0.027, lighthouseBottom)
      ..close();
    canvas.drawPath(
      tower,
      Paint()
        ..color = _deepNavy.withValues(alpha: 0.60)
        ..style = PaintingStyle.fill,
    );

    final lanternCenter = Offset(
      lighthouseX,
      lighthouseTop - size.height * 0.004,
    );
    canvas.drawCircle(
      lanternCenter,
      math.max(3.0, size.shortestSide * 0.011),
      Paint()
        ..color = _gold.withValues(alpha: 0.28)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7),
    );
    canvas.drawCircle(
      lanternCenter,
      math.max(1.4, size.shortestSide * 0.0045),
      Paint()..color = _gold.withValues(alpha: 0.74),
    );

    final beam = Path()
      ..moveTo(lanternCenter.dx, lanternCenter.dy)
      ..lineTo(0, math.max(0.0, lanternCenter.dy - size.height * 0.020))
      ..lineTo(0, lanternCenter.dy + size.height * 0.020)
      ..close();
    final beamBounds = Rect.fromLTWH(
      0,
      math.max(0.0, lanternCenter.dy - size.height * 0.020),
      lanternCenter.dx,
      size.height * 0.040,
    );
    canvas.drawPath(
      beam,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.centerRight,
          end: Alignment.centerLeft,
          colors: <Color>[
            Color(0x2EFFC85C),
            Color(0x0BFFC85C),
            Color(0x00FFC85C),
          ],
        ).createShader(beamBounds),
    );

    const dockLights = <Offset>[
      Offset(0.10, 0.105),
      Offset(0.29, 0.082),
      Offset(0.54, 0.112),
      Offset(0.72, 0.076),
      Offset(0.95, 0.118),
    ];
    final lightPaint = Paint()..color = _gold.withValues(alpha: 0.24);
    for (final light in dockLights) {
      canvas.drawCircle(
        Offset(size.width * light.dx, size.height * light.dy),
        1.1,
        lightPaint,
      );
    }

    final framePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = _gold.withValues(alpha: 0.08);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(1, 1, size.width - 2, size.height - 2),
        const Radius.circular(18),
      ),
      framePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _BaslangicLimaniHarborPainter oldDelegate) =>
      false;
}
