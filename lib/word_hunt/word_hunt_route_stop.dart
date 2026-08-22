import 'package:flutter/material.dart';

import 'word_hunt_models.dart';

/// Kelime Avı rota düğümlerinin tema bağımsız, deterministik geometrisi.
///
/// Bu değerler ilk modüler baseline'dır. Tema değişirken geometri değişmez;
/// nihai piksel kabulü Android görsel kanıtı + kullanıcı onayıyla yapılır.
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
    normalDiameter: 64,
    specialDiameter: 70,
    finalDiameter: 76,
    normalContainerWidth: 82,
    normalContainerHeight: 90,
    specialContainerWidth: 196,
    specialContainerHeight: 104,
    specialLabelGap: 8,
    starSize: 18,
    starGap: 3,
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
    normalAccent: Color(0xFF35DCE0),
    challengeAccent: Color(0xFFF2A44B),
    bonusAccent: Color(0xFFA96BF2),
    finalAccent: Color(0xFFE8C46B),
    lockedAccent: Color(0xFF7B8390),
    surfaceOuter: Color(0xFF07131D),
    surfaceInner: Color(0xFF10232D),
    textColor: Color(0xFFFFFBF2),
    lockColor: Color(0xFFE7E8EC),
    starFilled: Color(0xFFFFC94A),
    starEmpty: Color(0xFF5E6672),
    labelSurface: Color(0xE60A1018),
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
    WordHuntLevelType.routeFinal => Icons.flag_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final special = level.type != WordHuntLevelType.normal;
    final accent = unlocked
        ? theme.accentFor(level.type)
        : theme.lockedAccent;
    final clampedStars = stars.clamp(0, 3).toInt();

    return Semantics(
      button: unlocked,
      enabled: unlocked,
      label: unlocked
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
            borderRadius: BorderRadius.circular(44),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (special)
                  _SpecialRow(
                    level: level,
                    unlocked: unlocked,
                    accent: accent,
                    label: _typeLabel,
                    icon: _typeIcon,
                    labelOnLeft: labelOnLeft,
                    theme: theme,
                    metrics: metrics,
                  )
                else
                  _RouteStopOrb(
                    level: level,
                    unlocked: unlocked,
                    accent: accent,
                    theme: theme,
                    diameter: metrics.normalDiameter,
                  ),
                SizedBox(height: metrics.starGap),
                _RouteStopStars(
                  levelIndex: level.index,
                  stars: clampedStars,
                  unlocked: unlocked,
                  theme: theme,
                  starSize: metrics.starSize,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SpecialRow extends StatelessWidget {
  const _SpecialRow({
    required this.level,
    required this.unlocked,
    required this.accent,
    required this.label,
    required this.icon,
    required this.labelOnLeft,
    required this.theme,
    required this.metrics,
  });

  final WordHuntLevelDefinition level;
  final bool unlocked;
  final Color accent;
  final String label;
  final IconData icon;
  final bool labelOnLeft;
  final WordHuntRouteStopTheme theme;
  final WordHuntRouteStopMetrics metrics;

  @override
  Widget build(BuildContext context) {
    final diameter = metrics.diameterFor(level.type);
    final labelWidth =
        metrics.specialContainerWidth - diameter - metrics.specialLabelGap;
    final orb = _RouteStopOrb(
      level: level,
      unlocked: unlocked,
      accent: accent,
      theme: theme,
      diameter: diameter,
    );
    final stopLabel = SizedBox(
      width: labelWidth,
      child: _SpecialStopLabel(
        label: label,
        icon: icon,
        accent: accent,
        dimmed: !unlocked,
        theme: theme,
      ),
    );
    final gap = SizedBox(width: metrics.specialLabelGap);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: labelOnLeft
          ? <Widget>[stopLabel, gap, orb]
          : <Widget>[orb, gap, stopLabel],
    );
  }
}

class _RouteStopOrb extends StatelessWidget {
  const _RouteStopOrb({
    required this.level,
    required this.unlocked,
    required this.accent,
    required this.theme,
    required this.diameter,
  });

  final WordHuntLevelDefinition level;
  final bool unlocked;
  final Color accent;
  final WordHuntRouteStopTheme theme;
  final double diameter;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      key: Key('word_hunt_route_stop_orb_${level.index}'),
      dimension: diameter,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: accent.withValues(alpha: unlocked ? 0.96 : 0.72),
            width: level.type == WordHuntLevelType.routeFinal ? 3 : 2.4,
          ),
          gradient: RadialGradient(
            colors: <Color>[
              accent.withValues(alpha: unlocked ? 0.34 : 0.14),
              theme.surfaceInner,
              theme.surfaceOuter,
            ],
            stops: const <double>[0, 0.58, 1],
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: accent.withValues(alpha: unlocked ? 0.48 : 0.20),
              blurRadius: unlocked ? 14 : 7,
              spreadRadius: unlocked ? 2 : 0,
            ),
            const BoxShadow(
              color: Color(0x88000000),
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Center(
          child: unlocked
              ? Text(
                  '${level.index}',
                  key: Key('word_hunt_route_stop_number_${level.index}'),
                  style: TextStyle(
                    color: theme.textColor,
                    fontSize: level.type == WordHuntLevelType.routeFinal ? 27 : 24,
                    fontWeight: FontWeight.w900,
                    height: 1,
                    shadows: const <Shadow>[
                      Shadow(
                        color: Color(0xCC000000),
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                )
              : Icon(
                  Icons.lock_rounded,
                  key: Key('word_hunt_route_stop_lock_${level.index}'),
                  color: theme.lockColor,
                  size: 25,
                ),
        ),
      ),
    );
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
          color: earned
              ? theme.starFilled
              : theme.starEmpty.withValues(alpha: unlocked ? 1 : 0.72),
          shadows: earned
              ? <Shadow>[
                  Shadow(
                    color: theme.starFilled.withValues(alpha: 0.55),
                    blurRadius: 5,
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
  });

  final String label;
  final IconData icon;
  final Color accent;
  final bool dimmed;
  final WordHuntRouteStopTheme theme;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: dimmed ? 0.72 : 1,
      child: Container(
        constraints: const BoxConstraints(minHeight: 42),
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
        decoration: BoxDecoration(
          color: theme.labelSurface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: accent.withValues(alpha: 0.78),
            width: 1.1,
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: accent.withValues(alpha: 0.20),
              blurRadius: 8,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: accent, size: 18),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                maxLines: 2,
                overflow: TextOverflow.fade,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: accent,
                  fontSize: 10.5,
                  height: 1.08,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.35,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
