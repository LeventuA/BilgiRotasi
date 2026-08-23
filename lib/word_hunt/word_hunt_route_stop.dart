import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'word_hunt_models.dart';

/// Kelime Avı rota düğümlerinin tema bağımsız, deterministik geometrisi.
///
/// Başlangıç Limanı için kullanıcı tarafından onaylanan referans küçük rota
/// medalyonlarını kullanır. Tema değişirken geometri değişmez; yeni temalar aynı
/// ölçüleri kendi renk/doku karakterleriyle yeniden kullanır.
@immutable
class WordHuntRouteStopMetrics {
  const WordHuntRouteStopMetrics({
    required this.normalDiameter,
    required this.lockedNormalDiameter,
    required this.challengeDiameter,
    required this.bonusDiameter,
    required this.finalDiameter,
    required this.normalContainerWidth,
    required this.normalContainerHeight,
    required this.challengeContainerWidth,
    required this.bonusContainerWidth,
    required this.finalContainerWidth,
    required this.specialContainerHeight,
    required this.challengeLabelGap,
    required this.bonusLabelGap,
    required this.finalLabelGap,
    required this.challengePlaqueHeight,
    required this.bonusPlaqueHeight,
    required this.finalPlaqueHeight,
    required this.starSize,
    required this.starGap,
  });

  static const referenceBaseline = WordHuntRouteStopMetrics(
    normalDiameter: 78,
    lockedNormalDiameter: 100,
    challengeDiameter: 104,
    bonusDiameter: 104,
    finalDiameter: 142,
    normalContainerWidth: 110,
    normalContainerHeight: 128,
    challengeContainerWidth: 440,
    bonusContainerWidth: 321,
    finalContainerWidth: 406,
    specialContainerHeight: 210,
    challengeLabelGap: 12,
    bonusLabelGap: 11,
    finalLabelGap: 14,
    challengePlaqueHeight: 88,
    bonusPlaqueHeight: 82,
    finalPlaqueHeight: 110,
    starSize: 24,
    starGap: 3,
  );

  final double normalDiameter;
  final double lockedNormalDiameter;
  final double challengeDiameter;
  final double bonusDiameter;
  final double finalDiameter;
  final double normalContainerWidth;
  final double normalContainerHeight;
  final double challengeContainerWidth;
  final double bonusContainerWidth;
  final double finalContainerWidth;
  final double specialContainerHeight;
  final double challengeLabelGap;
  final double bonusLabelGap;
  final double finalLabelGap;
  final double challengePlaqueHeight;
  final double bonusPlaqueHeight;
  final double finalPlaqueHeight;
  final double starSize;
  final double starGap;

  double diameterFor(WordHuntLevelType type) => switch (type) {
    WordHuntLevelType.normal => normalDiameter,
    WordHuntLevelType.challenge => challengeDiameter,
    WordHuntLevelType.bonus => bonusDiameter,
    WordHuntLevelType.routeFinal => finalDiameter,
  };

  double containerWidthFor(WordHuntLevelType type) => switch (type) {
    WordHuntLevelType.normal => normalContainerWidth,
    WordHuntLevelType.routeFinal => finalContainerWidth,
    WordHuntLevelType.challenge => challengeContainerWidth,
    WordHuntLevelType.bonus => bonusContainerWidth,
  };

  double containerHeightFor(WordHuntLevelType type) =>
      type == WordHuntLevelType.normal
          ? normalContainerHeight
          : specialContainerHeight;

  double labelGapFor(WordHuntLevelType type) => switch (type) {
    WordHuntLevelType.challenge => challengeLabelGap,
    WordHuntLevelType.bonus => bonusLabelGap,
    WordHuntLevelType.routeFinal => finalLabelGap,
    WordHuntLevelType.normal => 0,
  };

  double plaqueHeightFor(WordHuntLevelType type) => switch (type) {
    WordHuntLevelType.challenge => challengePlaqueHeight,
    WordHuntLevelType.bonus => bonusPlaqueHeight,
    WordHuntLevelType.routeFinal => finalPlaqueHeight,
    WordHuntLevelType.normal => 0,
  };
}

/// Rota düğümünün yalnız görsel tokenlarını taşır.
///
/// Oyun durumu, kilit mantığı veya yıldız hesabı bu sınıfa girmez. Böylece
/// Liman/Orman gibi temalar aynı geometriyi farklı renk ve yüzeylerle kullanır.
@immutable
class WordHuntRouteStopTheme {
  const WordHuntRouteStopTheme({
    required this.normalAccent,
    required this.challengeAccent,
    required this.bonusAccent,
    required this.finalAccent,
    required this.lockedAccent,
    required this.surfaceOuter,
    required this.surfaceInner,
    required this.textColor,
    required this.lockColor,
    required this.starFilled,
    required this.starEmpty,
    required this.labelSurface,
  });

  static const harbor = WordHuntRouteStopTheme(
    normalAccent: Color(0xFF4CE7ED),
    challengeAccent: Color(0xFFF3A744),
    bonusAccent: Color(0xFFB765FF),
    finalAccent: Color(0xFFFFC95D),
    lockedAccent: Color(0xFF8C939E),
    surfaceOuter: Color(0xFF050D14),
    surfaceInner: Color(0xFF0C2632),
    textColor: Color(0xFFFFFBF2),
    lockColor: Color(0xFFE7E8EC),
    starFilled: Color(0xFFFFC94A),
    starEmpty: Color(0xFF59616D),
    labelSurface: Color(0xEE090E16),
  );

  final Color normalAccent;
  final Color challengeAccent;
  final Color bonusAccent;
  final Color finalAccent;
  final Color lockedAccent;
  final Color surfaceOuter;
  final Color surfaceInner;
  final Color textColor;
  final Color lockColor;
  final Color starFilled;
  final Color starEmpty;
  final Color labelSurface;

  Color accentFor(WordHuntLevelType type) => switch (type) {
    WordHuntLevelType.normal => normalAccent,
    WordHuntLevelType.challenge => challengeAccent,
    WordHuntLevelType.bonus => bonusAccent,
    WordHuntLevelType.routeFinal => finalAccent,
  };

  WordHuntRouteStopTheme copyWith({
    Color? normalAccent,
    Color? challengeAccent,
    Color? bonusAccent,
    Color? finalAccent,
    Color? lockedAccent,
    Color? surfaceOuter,
    Color? surfaceInner,
    Color? textColor,
    Color? lockColor,
    Color? starFilled,
    Color? starEmpty,
    Color? labelSurface,
  }) {
    return WordHuntRouteStopTheme(
      normalAccent: normalAccent ?? this.normalAccent,
      challengeAccent: challengeAccent ?? this.challengeAccent,
      bonusAccent: bonusAccent ?? this.bonusAccent,
      finalAccent: finalAccent ?? this.finalAccent,
      lockedAccent: lockedAccent ?? this.lockedAccent,
      surfaceOuter: surfaceOuter ?? this.surfaceOuter,
      surfaceInner: surfaceInner ?? this.surfaceInner,
      textColor: textColor ?? this.textColor,
      lockColor: lockColor ?? this.lockColor,
      starFilled: starFilled ?? this.starFilled,
      starEmpty: starEmpty ?? this.starEmpty,
      labelSurface: labelSurface ?? this.labelSurface,
    );
  }
}

/// 1-10 rota duraklarının ortak görsel/etkileşim bileşeni.
///
/// - Açık/kilitli durum aynı geometriyi korur.
/// - Her durakta her zaman üç yıldız yuvası bulunur.
/// - Kilitli durak callback üretmez.
/// - Tema yalnız token değiştirir; ölçüler [metrics] tarafından sabitlenir.
class WordHuntRouteStop extends StatelessWidget {
  const WordHuntRouteStop({
    super.key,
    required this.level,
    required this.stars,
    required this.unlocked,
    this.theme = WordHuntRouteStopTheme.harbor,
    this.metrics = WordHuntRouteStopMetrics.referenceBaseline,
    this.labelOnLeft = false,
    this.onTap,
  });

  final WordHuntLevelDefinition level;
  final int stars;
  final bool unlocked;
  final WordHuntRouteStopTheme theme;
  final WordHuntRouteStopMetrics metrics;
  final bool labelOnLeft;
  final VoidCallback? onTap;

  String get _typeLabel => switch (level.type) {
    WordHuntLevelType.normal => '',
    WordHuntLevelType.challenge => 'MEYDAN OKUMA',
    WordHuntLevelType.bonus => 'BONUS DURAK',
    WordHuntLevelType.routeFinal => 'ROTA FİNALİ',
  };

  IconData get _typeIcon => switch (level.type) {
    WordHuntLevelType.normal => Icons.circle,
    WordHuntLevelType.challenge => Icons.sports_martial_arts_rounded,
    WordHuntLevelType.bonus => Icons.card_giftcard_rounded,
    WordHuntLevelType.routeFinal => Icons.inventory_2_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final special = level.type != WordHuntLevelType.normal;
    final lockedFinal = level.type == WordHuntLevelType.routeFinal && !unlocked;
    final accent =
        lockedFinal
            ? theme.finalAccent
            : unlocked
            ? theme.accentFor(level.type)
            : theme.lockedAccent;
    final clampedStars = stars.clamp(0, 3).toInt();

    final stopWithStars = _StopMedallionAndStars(
      level: level,
      stars: clampedStars,
      unlocked: unlocked,
      lockedFinal: lockedFinal,
      accent: accent,
      theme: theme,
      metrics: metrics,
    );

    return Semantics(
      button: unlocked,
      enabled: unlocked,
      label:
          unlocked
              ? 'Bölüm ${level.index}, ${_typeLabel.isEmpty ? 'normal' : _typeLabel}, $clampedStars yıldız, açık'
              : 'Bölüm ${level.index}, kilitli',
      child: SizedBox(
        key: Key('word_hunt_route_stop_${level.index}'),
        width: metrics.containerWidthFor(level.type),
        height: metrics.containerHeightFor(level.type),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: unlocked ? onTap : null,
            borderRadius: BorderRadius.circular(42),
            child:
                special
                    ? _SpecialRow(
                      level: level,
                      unlocked: unlocked,
                      lockedFinal: lockedFinal,
                      accent: accent,
                      label: _typeLabel,
                      icon: _typeIcon,
                      labelOnLeft: labelOnLeft,
                      theme: theme,
                      metrics: metrics,
                      stopWithStars: stopWithStars,
                    )
                    : Center(child: stopWithStars),
          ),
        ),
      ),
    );
  }
}

class _StopMedallionAndStars extends StatelessWidget {
  const _StopMedallionAndStars({
    required this.level,
    required this.stars,
    required this.unlocked,
    required this.lockedFinal,
    required this.accent,
    required this.theme,
    required this.metrics,
  });

  final WordHuntLevelDefinition level;
  final int stars;
  final bool unlocked;
  final bool lockedFinal;
  final Color accent;
  final WordHuntRouteStopTheme theme;
  final WordHuntRouteStopMetrics metrics;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _RouteStopOrb(
          level: level,
          unlocked: unlocked,
          lockedFinal: lockedFinal,
          accent: accent,
          theme: theme,
          diameter:
              level.type == WordHuntLevelType.normal && !unlocked
                  ? metrics.lockedNormalDiameter
                  : metrics.diameterFor(level.type),
        ),
        SizedBox(height: metrics.starGap),
        _RouteStopStars(
          levelIndex: level.index,
          stars: stars,
          unlocked: unlocked,
          goldTarget: level.type == WordHuntLevelType.routeFinal,
          theme: theme,
          starSize: metrics.starSize,
        ),
      ],
    );
  }
}

class _SpecialRow extends StatelessWidget {
  const _SpecialRow({
    required this.level,
    required this.unlocked,
    required this.lockedFinal,
    required this.accent,
    required this.label,
    required this.icon,
    required this.labelOnLeft,
    required this.theme,
    required this.metrics,
    required this.stopWithStars,
  });

  final WordHuntLevelDefinition level;
  final bool unlocked;
  final bool lockedFinal;
  final Color accent;
  final String label;
  final IconData icon;
  final bool labelOnLeft;
  final WordHuntRouteStopTheme theme;
  final WordHuntRouteStopMetrics metrics;
  final Widget stopWithStars;

  @override
  Widget build(BuildContext context) {
    final diameter = metrics.diameterFor(level.type);
    final labelWidth =
        metrics.containerWidthFor(level.type) -
        diameter -
        metrics.labelGapFor(level.type);
    final stopLabel = Transform.translate(
      offset: Offset(
        0,
        level.type == WordHuntLevelType.routeFinal
            ? 0
            : -(metrics.starGap + metrics.starSize) / 2,
      ),
      child: SizedBox(
        width: labelWidth,
        height: metrics.plaqueHeightFor(level.type),
        child: _SpecialStopLabel(
          levelIndex: level.index,
          label: label,
          icon: icon,
          accent: accent,
          dimmed: !unlocked && !lockedFinal,
          theme: theme,
          emphasized: level.type == WordHuntLevelType.routeFinal,
        ),
      ),
    );
    final gap = SizedBox(width: metrics.labelGapFor(level.type));

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children:
          labelOnLeft
              ? <Widget>[stopLabel, gap, stopWithStars]
              : <Widget>[stopWithStars, gap, stopLabel],
    );
  }
}

class _RouteStopOrb extends StatelessWidget {
  const _RouteStopOrb({
    required this.level,
    required this.unlocked,
    required this.lockedFinal,
    required this.accent,
    required this.theme,
    required this.diameter,
  });

  final WordHuntLevelDefinition level;
  final bool unlocked;
  final bool lockedFinal;
  final Color accent;
  final WordHuntRouteStopTheme theme;
  final double diameter;

  @override
  Widget build(BuildContext context) {
    final numberSize = switch (level.type) {
      WordHuntLevelType.normal => 30.0,
      WordHuntLevelType.challenge => 39.0,
      WordHuntLevelType.bonus => 40.0,
      WordHuntLevelType.routeFinal => 58.0,
    };
    final visuallyHighlighted = unlocked || lockedFinal;

    return SizedBox.square(
      key: Key('word_hunt_route_stop_orb_${level.index}'),
      dimension: diameter,
      child: CustomPaint(
        key: Key('word_hunt_route_stop_frame_${level.index}'),
        painter: _MedallionFramePainter(
          accent: accent,
          surfaceOuter: theme.surfaceOuter,
          surfaceInner: theme.surfaceInner,
          unlocked: visuallyHighlighted,
          type: level.type,
        ),
        child: Stack(
          fit: StackFit.expand,
          clipBehavior: Clip.none,
          children: [
            Center(
              child:
                  visuallyHighlighted
                      ? Text(
                        '${level.index}',
                        key: Key('word_hunt_route_stop_number_${level.index}'),
                        style: TextStyle(
                          color: theme.textColor,
                          fontSize: numberSize,
                          fontWeight: FontWeight.w800,
                          height: 1,
                          shadows: const <Shadow>[
                            Shadow(
                              color: Color(0xDD000000),
                              blurRadius: 3,
                              offset: Offset(0, 1.5),
                            ),
                          ],
                        ),
                      )
                      : Icon(
                        Icons.lock_rounded,
                        key: Key('word_hunt_route_stop_lock_${level.index}'),
                        color: theme.lockColor,
                        size: 34,
                        shadows: const <Shadow>[
                          Shadow(color: Color(0xCC000000), blurRadius: 3),
                        ],
                      ),
            ),
            if (level.type == WordHuntLevelType.routeFinal)
              Positioned(
                key: Key('word_hunt_route_stop_crown_${level.index}'),
                top: -42,
                left: -6,
                width: 154,
                height: 94,
                child: CustomPaint(painter: _FinalCrownPainter(accent: accent)),
              ),
          ],
        ),
      ),
    );
  }
}

class _MedallionFramePainter extends CustomPainter {
  const _MedallionFramePainter({
    required this.accent,
    required this.surfaceOuter,
    required this.surfaceInner,
    required this.unlocked,
    required this.type,
  });

  final Color accent;
  final Color surfaceOuter;
  final Color surfaceInner;
  final bool unlocked;
  final WordHuntLevelType type;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide / 2;
    final special = type != WordHuntLevelType.normal;
    final finalStop = type == WordHuntLevelType.routeFinal;
    final alpha = unlocked ? 1.0 : 0.72;

    final glowPaint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = finalStop ? 9.0 : (special ? 7.0 : 5.0)
          ..color = accent.withValues(alpha: unlocked ? 0.22 : 0.10)
          ..maskFilter = MaskFilter.blur(
            BlurStyle.normal,
            unlocked ? (finalStop ? 12 : 8) : 4,
          );
    canvas.drawCircle(center, radius - 5, glowPaint);

    final shellPaint =
        Paint()
          ..style = PaintingStyle.fill
          ..shader = RadialGradient(
            colors: <Color>[
              accent.withValues(alpha: unlocked ? 0.32 : 0.12),
              surfaceInner,
              surfaceOuter,
            ],
            stops: const <double>[0, 0.58, 1],
          ).createShader(Rect.fromCircle(center: center, radius: radius - 4));
    canvas.drawCircle(center, radius - 5, shellPaint);

    final outerRing =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = finalStop ? 5.2 : 3.6
          ..color = accent.withValues(alpha: 0.94 * alpha);
    final innerRing =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0
          ..color = accent.withValues(alpha: 0.48 * alpha);
    final fineRing =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4
          ..color = const Color(0xFFFFF2C6).withValues(alpha: 0.42 * alpha);

    canvas.drawCircle(center, radius - 5.5, outerRing);
    canvas.drawCircle(center, radius - 9.0, innerRing);
    canvas.drawCircle(center, radius - 12.5, fineRing);

    final ornamentPaint =
        Paint()
          ..style = PaintingStyle.fill
          ..color = accent.withValues(alpha: 0.90 * alpha);
    final ornamentOutline =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.8
          ..color = const Color(0xFFFFF2C6).withValues(alpha: 0.65 * alpha);

    final ornamentCount = finalStop ? 8 : (special ? 6 : 4);
    final ornamentLength = finalStop ? 8.0 : (special ? 5.0 : 2.2);
    final ornamentWidth = finalStop ? 5.0 : (special ? 3.2 : 1.8);
    final ornamentRadius = radius - 6.5;

    for (var index = 0; index < ornamentCount; index++) {
      final angle = -math.pi / 2 + (2 * math.pi * index / ornamentCount);
      final radial = Offset(math.cos(angle), math.sin(angle));
      final tangent = Offset(-radial.dy, radial.dx);
      final base = center + radial * (ornamentRadius - ornamentLength * 0.5);
      final tip =
          center +
          radial * (ornamentRadius + (special ? ornamentLength * 0.34 : 0.8));
      final left = base + tangent * ornamentWidth;
      final right = base - tangent * ornamentWidth;
      final inner =
          center +
          radial * (ornamentRadius - (special ? ornamentLength * 0.9 : 2.0));

      final path =
          Path()
            ..moveTo(tip.dx, tip.dy)
            ..lineTo(left.dx, left.dy)
            ..lineTo(inner.dx, inner.dy)
            ..lineTo(right.dx, right.dy)
            ..close();
      canvas.drawPath(path, ornamentPaint);
      canvas.drawPath(path, ornamentOutline);
    }
  }

  @override
  bool shouldRepaint(covariant _MedallionFramePainter oldDelegate) {
    return oldDelegate.accent != accent ||
        oldDelegate.surfaceOuter != surfaceOuter ||
        oldDelegate.surfaceInner != surfaceInner ||
        oldDelegate.unlocked != unlocked ||
        oldDelegate.type != type;
  }
}

class _FinalCrownPainter extends CustomPainter {
  const _FinalCrownPainter({required this.accent});

  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final crown =
        Path()
          ..moveTo(w * 0.08, h * 0.82)
          ..quadraticBezierTo(w * 0.10, h * 0.54, w * 0.16, h * 0.23)
          ..quadraticBezierTo(w * 0.20, h * 0.12, w * 0.24, h * 0.25)
          ..lineTo(w * 0.39, h * 0.57)
          ..quadraticBezierTo(w * 0.42, h * 0.63, w * 0.44, h * 0.52)
          ..lineTo(w * 0.49, h * 0.08)
          ..quadraticBezierTo(w * 0.50, 0, w * 0.51, h * 0.08)
          ..lineTo(w * 0.56, h * 0.52)
          ..quadraticBezierTo(w * 0.58, h * 0.63, w * 0.61, h * 0.57)
          ..lineTo(w * 0.76, h * 0.25)
          ..quadraticBezierTo(w * 0.80, h * 0.12, w * 0.84, h * 0.23)
          ..quadraticBezierTo(w * 0.90, h * 0.54, w * 0.92, h * 0.82)
          ..quadraticBezierTo(w * 0.50, h * 0.94, w * 0.08, h * 0.82)
          ..close();
    final cutouts =
        Path()
          ..addPath(
            Path()
              ..moveTo(w * 0.18, h * 0.38)
              ..lineTo(w * 0.34, h * 0.61)
              ..lineTo(w * 0.27, h * 0.70)
              ..lineTo(w * 0.14, h * 0.55)
              ..close(),
            Offset.zero,
          )
          ..addPath(
            Path()
              ..moveTo(w * 0.36, h * 0.58)
              ..lineTo(w * 0.47, h * 0.20)
              ..lineTo(w * 0.46, h * 0.68)
              ..close(),
            Offset.zero,
          )
          ..addPath(
            Path()
              ..moveTo(w * 0.64, h * 0.58)
              ..lineTo(w * 0.53, h * 0.20)
              ..lineTo(w * 0.54, h * 0.68)
              ..close(),
            Offset.zero,
          )
          ..addPath(
            Path()
              ..moveTo(w * 0.82, h * 0.38)
              ..lineTo(w * 0.66, h * 0.61)
              ..lineTo(w * 0.73, h * 0.70)
              ..lineTo(w * 0.86, h * 0.55)
              ..close(),
            Offset.zero,
          );
    final ornateCrown = Path.combine(PathOperation.difference, crown, cutouts);
    canvas.drawShadow(ornateCrown, accent, 12, true);
    canvas.drawPath(
      ornateCrown,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            const Color(0xFFFFF1A0),
            accent,
            const Color(0xFFE49A20),
            const Color(0xFF6D3506),
          ],
          stops: <double>[0, 0.42, 0.74, 1],
        ).createShader(Offset.zero & size),
    );
    canvas.drawPath(
      ornateCrown,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4
        ..color = const Color(0xFFFFE99B),
    );
    final band = RRect.fromRectAndRadius(
      Rect.fromLTRB(w * 0.11, h * 0.72, w * 0.89, h * 0.90),
      Radius.circular(h * 0.07),
    );
    canvas.drawRRect(
      band,
      Paint()
        ..shader = const LinearGradient(
          colors: <Color>[Color(0xFFFFE58B), Color(0xFF9B560E)],
        ).createShader(band.outerRect),
    );
    canvas.drawRRect(
      band,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = const Color(0xFFFFF0A7),
    );
    final jewel = Paint()..color = const Color(0xFFFFF1B2);
    final ruby = Paint()..color = const Color(0xFF8D2D42);
    for (final point in <Offset>[
      Offset(w * 0.16, h * 0.23),
      Offset(w * 0.50, h * 0.08),
      Offset(w * 0.84, h * 0.23),
    ]) {
      canvas.drawCircle(point, h * 0.045, jewel);
    }
    canvas.drawCircle(Offset(w * 0.50, h * 0.81), h * 0.055, ruby);
    canvas.drawCircle(
      Offset(w * 0.50, h * 0.81),
      h * 0.055,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = const Color(0xFFFFEAA2),
    );
  }

  @override
  bool shouldRepaint(covariant _FinalCrownPainter oldDelegate) =>
      oldDelegate.accent != accent;
}

class _RouteStopStars extends StatelessWidget {
  const _RouteStopStars({
    required this.levelIndex,
    required this.stars,
    required this.unlocked,
    required this.goldTarget,
    required this.theme,
    required this.starSize,
  });

  final int levelIndex;
  final int stars;
  final bool unlocked;
  final bool goldTarget;
  final WordHuntRouteStopTheme theme;
  final double starSize;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List<Widget>.generate(3, (index) {
        final earned = index < stars || goldTarget;
        return Icon(
          earned ? Icons.star_rounded : Icons.star_border_rounded,
          key: Key('word_hunt_route_stop_star_${levelIndex}_$index'),
          size: starSize,
          color:
              earned
                  ? theme.starFilled
                  : theme.starEmpty.withValues(alpha: unlocked ? 1 : 0.72),
          shadows:
              earned
                  ? <Shadow>[
                    Shadow(
                      color: theme.starFilled.withValues(alpha: 0.55),
                      blurRadius: 4,
                    ),
                  ]
                  : const <Shadow>[],
        );
      }),
    );
  }
}

class _SpecialStopLabel extends StatelessWidget {
  const _SpecialStopLabel({
    required this.levelIndex,
    required this.label,
    required this.icon,
    required this.accent,
    required this.dimmed,
    required this.theme,
    required this.emphasized,
  });

  final int levelIndex;
  final String label;
  final IconData icon;
  final Color accent;
  final bool dimmed;
  final WordHuntRouteStopTheme theme;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: dimmed ? 0.72 : 1,
      child: SizedBox.expand(
        key: Key('word_hunt_route_stop_plaque_$levelIndex'),
        child: CustomPaint(
          painter: _FantasyPlaquePainter(
            accent: accent,
            surface: theme.labelSurface,
            emphasized: emphasized,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                _SpecialStopIcon(
                  label: label,
                  fallback: icon,
                  color: accent,
                  size: emphasized ? 40 : 36,
                ),
                const SizedBox(width: 12),
                Flexible(
                  child: Text(
                    label,
                    maxLines: label == 'MEYDAN OKUMA' ? 1 : 2,
                    overflow: TextOverflow.fade,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: accent,
                      fontFamily: 'serif',
                      fontSize:
                          label == 'MEYDAN OKUMA'
                              ? 24.0
                              : emphasized
                              ? 29.0
                              : 24.0,
                      height: 1.05,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.7,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SpecialStopIcon extends StatelessWidget {
  const _SpecialStopIcon({
    required this.label,
    required this.fallback,
    required this.color,
    required this.size,
  });

  final String label;
  final IconData fallback;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    if (label == 'MEYDAN OKUMA') {
      return SizedBox.square(
        key: const Key('word_hunt_route_stop_crossed_swords_5'),
        dimension: size,
        child: CustomPaint(painter: _CrossedSwordsPainter(color: color)),
      );
    }
    if (label == 'ROTA FİNALİ') {
      return SizedBox.square(
        key: const Key('word_hunt_route_stop_treasure_chest_10'),
        dimension: size,
        child: CustomPaint(painter: _TreasureChestPainter(color: color)),
      );
    }
    return Icon(fallback, color: color, size: size);
  }
}

class _CrossedSwordsPainter extends CustomPainter {
  const _CrossedSwordsPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final blade =
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = size.width * 0.09;
    final hilt =
        Paint()
          ..color = const Color(0xFFFFE3A0)
          ..strokeCap = StrokeCap.round
          ..strokeWidth = size.width * 0.075;
    canvas.drawLine(
      Offset(size.width * 0.22, size.height * 0.18),
      Offset(size.width * 0.78, size.height * 0.82),
      blade,
    );
    canvas.drawLine(
      Offset(size.width * 0.78, size.height * 0.18),
      Offset(size.width * 0.22, size.height * 0.82),
      blade,
    );
    canvas.drawLine(
      Offset(size.width * 0.18, size.height * 0.30),
      Offset(size.width * 0.32, size.height * 0.16),
      hilt,
    );
    canvas.drawLine(
      Offset(size.width * 0.68, size.height * 0.16),
      Offset(size.width * 0.82, size.height * 0.30),
      hilt,
    );
  }

  @override
  bool shouldRepaint(covariant _CrossedSwordsPainter oldDelegate) =>
      oldDelegate.color != color;
}

class _TreasureChestPainter extends CustomPainter {
  const _TreasureChestPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final outline =
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = size.width * 0.085
          ..strokeJoin = StrokeJoin.round;
    final body = Rect.fromLTRB(
      size.width * 0.12,
      size.height * 0.42,
      size.width * 0.88,
      size.height * 0.86,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(body, Radius.circular(size.width * 0.07)),
      outline,
    );
    final lid =
        Path()
          ..moveTo(size.width * 0.15, size.height * 0.43)
          ..quadraticBezierTo(
            size.width * 0.50,
            size.height * 0.08,
            size.width * 0.85,
            size.height * 0.43,
          );
    canvas.drawPath(lid, outline);
    canvas.drawLine(
      Offset(size.width * 0.12, size.height * 0.58),
      Offset(size.width * 0.88, size.height * 0.58),
      outline,
    );
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(size.width * 0.50, size.height * 0.60),
        width: size.width * 0.16,
        height: size.height * 0.22,
      ),
      Paint()..color = const Color(0xFFFFE3A0),
    );
  }

  @override
  bool shouldRepaint(covariant _TreasureChestPainter oldDelegate) =>
      oldDelegate.color != color;
}

class _FantasyPlaquePainter extends CustomPainter {
  const _FantasyPlaquePainter({
    required this.accent,
    required this.surface,
    required this.emphasized,
  });

  final Color accent;
  final Color surface;
  final bool emphasized;

  @override
  void paint(Canvas canvas, Size size) {
    final notch = emphasized ? 18.0 : 14.0;
    final path =
        Path()
          ..moveTo(notch, 1)
          ..lineTo(size.width - notch, 1)
          ..lineTo(size.width - 1, size.height * 0.24)
          ..lineTo(size.width - notch, size.height * 0.50)
          ..lineTo(size.width - 1, size.height * 0.76)
          ..lineTo(size.width - notch, size.height - 1)
          ..lineTo(notch, size.height - 1)
          ..lineTo(1, size.height * 0.76)
          ..lineTo(notch, size.height * 0.50)
          ..lineTo(1, size.height * 0.24)
          ..close();
    canvas.drawShadow(path, accent.withValues(alpha: 0.85), 7, true);
    canvas.drawPath(path, Paint()..color = surface);
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = emphasized ? 3.2 : 2.6
        ..color = accent.withValues(alpha: 0.95),
    );
    canvas.drawRect(
      Rect.fromLTRB(14, 11, size.width - 14, size.height - 11),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = accent.withValues(alpha: 0.40),
    );
    final dot = Paint()..color = accent.withValues(alpha: 0.85);
    canvas.drawCircle(Offset(notch, size.height / 2), 3.4, dot);
    canvas.drawCircle(Offset(size.width - notch, size.height / 2), 3.4, dot);
  }

  @override
  bool shouldRepaint(covariant _FantasyPlaquePainter oldDelegate) =>
      oldDelegate.accent != accent ||
      oldDelegate.surface != surface ||
      oldDelegate.emphasized != emphasized;
}
