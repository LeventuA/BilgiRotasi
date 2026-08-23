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
    required this.specialDiameter,
    required this.finalDiameter,
    required this.normalContainerWidth,
    required this.normalContainerHeight,
    required this.specialContainerWidth,
    required this.specialContainerHeight,
    required this.specialLabelGap,
    required this.starSize,
    required this.starGap,
  });

  static const referenceBaseline = WordHuntRouteStopMetrics(
    normalDiameter: 32,
    specialDiameter: 42,
    finalDiameter: 58,
    normalContainerWidth: 48,
    normalContainerHeight: 54,
    specialContainerWidth: 146,
    specialContainerHeight: 70,
    specialLabelGap: 5,
    starSize: 11,
    starGap: 1,
  );

  final double normalDiameter;
  final double specialDiameter;
  final double finalDiameter;
  final double normalContainerWidth;
  final double normalContainerHeight;
  final double specialContainerWidth;
  final double specialContainerHeight;
  final double specialLabelGap;
  final double starSize;
  final double starGap;

  double diameterFor(WordHuntLevelType type) => switch (type) {
    WordHuntLevelType.normal => normalDiameter,
    WordHuntLevelType.challenge => specialDiameter,
    WordHuntLevelType.bonus => specialDiameter,
    WordHuntLevelType.routeFinal => finalDiameter,
  };

  double containerWidthFor(WordHuntLevelType type) =>
      type == WordHuntLevelType.normal
          ? normalContainerWidth
          : specialContainerWidth;

  double containerHeightFor(WordHuntLevelType type) =>
      type == WordHuntLevelType.normal
          ? normalContainerHeight
          : specialContainerHeight;
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
          diameter: metrics.diameterFor(level.type),
        ),
        SizedBox(height: metrics.starGap),
        _RouteStopStars(
          levelIndex: level.index,
          stars: stars,
          unlocked: unlocked,
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
        metrics.specialContainerWidth - diameter - metrics.specialLabelGap;
    final stopLabel = SizedBox(
      width: labelWidth,
      child: _SpecialStopLabel(
        label: label,
        icon: icon,
        accent: accent,
        dimmed: !unlocked && !lockedFinal,
        theme: theme,
        emphasized: level.type == WordHuntLevelType.routeFinal,
      ),
    );
    final gap = SizedBox(width: metrics.specialLabelGap);

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
      WordHuntLevelType.normal => 14.0,
      WordHuntLevelType.challenge => 17.0,
      WordHuntLevelType.bonus => 17.0,
      WordHuntLevelType.routeFinal => 23.0,
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
                        size: 15,
                        shadows: const <Shadow>[
                          Shadow(color: Color(0xCC000000), blurRadius: 3),
                        ],
                      ),
            ),
            if (lockedFinal)
              Positioned(
                right: 2,
                bottom: 2,
                child: Container(
                  key: Key('word_hunt_route_stop_lock_badge_${level.index}'),
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xE6131820),
                    border: Border.all(
                      color: theme.finalAccent.withValues(alpha: 0.92),
                      width: 1.2,
                    ),
                    boxShadow: const <BoxShadow>[
                      BoxShadow(color: Color(0x99000000), blurRadius: 3),
                    ],
                  ),
                  child: Icon(
                    Icons.lock_rounded,
                    color: theme.lockColor,
                    size: 9,
                  ),
                ),
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
          ..strokeWidth = finalStop ? 5.5 : (special ? 4.5 : 3.5)
          ..color = accent.withValues(alpha: unlocked ? 0.22 : 0.10)
          ..maskFilter = MaskFilter.blur(
            BlurStyle.normal,
            unlocked ? (finalStop ? 7 : 5) : 2,
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
          ..strokeWidth = finalStop ? 2.6 : 2.0
          ..color = accent.withValues(alpha: 0.94 * alpha);
    final innerRing =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0
          ..color = accent.withValues(alpha: 0.48 * alpha);
    final fineRing =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.8
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
    final ornamentLength = finalStop ? 7.0 : (special ? 5.5 : 4.5);
    final ornamentWidth = finalStop ? 4.0 : 3.0;
    final ornamentRadius = radius - 4.5;

    for (var index = 0; index < ornamentCount; index++) {
      final angle = -math.pi / 2 + (2 * math.pi * index / ornamentCount);
      final radial = Offset(math.cos(angle), math.sin(angle));
      final tangent = Offset(-radial.dy, radial.dx);
      final base = center + radial * (ornamentRadius - ornamentLength * 0.5);
      final tip = center + radial * (ornamentRadius + ornamentLength * 0.45);
      final left = base + tangent * ornamentWidth;
      final right = base - tangent * ornamentWidth;
      final inner = center + radial * (ornamentRadius - ornamentLength * 1.15);

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

    if (finalStop) {
      final crownPaint =
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.4
            ..strokeCap = StrokeCap.round
            ..color = accent.withValues(alpha: 0.95 * alpha);
      final top = center.dy - radius + 2;
      final crown =
          Path()
            ..moveTo(center.dx - 10, top + 9)
            ..lineTo(center.dx - 6, top + 2)
            ..lineTo(center.dx, top + 7)
            ..lineTo(center.dx + 6, top + 2)
            ..lineTo(center.dx + 10, top + 9);
      canvas.drawPath(crown, crownPaint);
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

class _RouteStopStars extends StatelessWidget {
  const _RouteStopStars({
    required this.levelIndex,
    required this.stars,
    required this.unlocked,
    required this.theme,
    required this.starSize,
  });

  final int levelIndex;
  final int stars;
  final bool unlocked;
  final WordHuntRouteStopTheme theme;
  final double starSize;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List<Widget>.generate(3, (index) {
        final earned = index < stars;
        return Icon(
          Icons.star_rounded,
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
    required this.label,
    required this.icon,
    required this.accent,
    required this.dimmed,
    required this.theme,
    required this.emphasized,
  });

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
      child: Container(
        constraints: BoxConstraints(minHeight: emphasized ? 38 : 34),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: BoxDecoration(
          color: theme.labelSurface,
          borderRadius: BorderRadius.circular(2),
          border: Border.all(
            color: accent.withValues(alpha: 0.84),
            width: emphasized ? 1.6 : 1.2,
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(color: accent.withValues(alpha: 0.20), blurRadius: 7),
          ],
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(
              color: accent.withValues(alpha: 0.22),
              width: 0.8,
            ),
            borderRadius: BorderRadius.circular(1),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: accent, size: emphasized ? 15 : 14),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 2,
                    overflow: TextOverflow.fade,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: accent,
                      fontSize: emphasized ? 10 : 9.5,
                      height: 1.05,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.3,
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
