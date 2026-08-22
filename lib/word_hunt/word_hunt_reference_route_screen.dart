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
    Offset(0.52, 0.58), // 7 - merkez/merkez-sağ
    Offset(0.58, 0.69), // 8 - bonus, sağ bölge
    Offset(0.18, 0.79), // 9 - kilitli sol bölge
    Offset(0.44, 0.90), // 10 - rota finali, alt-orta
  ];

  static const double routeAreaTop = 142;
  static const double routeAreaBottom = 68;
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

            return Stack(
              fit: StackFit.expand,
              children: [
                _ReferenceBackground(assetPath: sceneAssetPath),
                const _ReferenceLegibilityOverlay(),
                _ReferenceTopChrome(
                  title: route.title,
                  stars: totalStars,
                  maximumStars: route.maximumStars,
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
    this.onBack,
    this.onInfo,
  });

  final String title;
  final int stars;
  final int maximumStars;
  final VoidCallback? onBack;
  final VoidCallback? onInfo;

  String _upper(String value) =>
      value.replaceAll('i', 'İ').replaceAll('ı', 'I').toUpperCase();

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
                const Expanded(
                  child: Text(
                    'KELİME AVI',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFFF3E7FF),
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.7,
                      shadows: <Shadow>[
                        Shadow(color: Color(0xAA7C3AED), blurRadius: 14),
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
            decoration: BoxDecoration(
              color: const Color(0xD908111D),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: const Color(0xB9A57A3D), width: 1.2),
              boxShadow: const <BoxShadow>[
                BoxShadow(color: Color(0x77000000), blurRadius: 12, offset: Offset(0, 5)),
                BoxShadow(color: Color(0x337A5AF5), blurRadius: 14),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _upper(title),
                    maxLines: 1,
                    overflow: TextOverflow.fade,
                    style: const TextStyle(
                      color: Color(0xFFFFF7E7),
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.7,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                const Icon(Icons.star_rounded, color: Color(0xFFFFC94A), size: 22),
                const SizedBox(width: 3),
                Text(
                  '$stars/$maximumStars',
                  style: const TextStyle(
                    color: Color(0xFFFFF0C2),
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
                BoxShadow(color: Color(0x77000000), blurRadius: 8, offset: Offset(0, 4)),
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
    required this.lastUnlockedIndex,
  });

  final List<Offset> points;
  final int lastUnlockedIndex;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;

    final shadow = Paint()
      ..color = const Color(0xB8000000)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final dormant = Paint()
      ..color = const Color(0x807E8792)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final activeGlow = Paint()
      ..color = const Color(0x6639DEE1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 9
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final active = Paint()
      ..color = const Color(0xFFE2C46D)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.2
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
      if (unlockedSegment) {
        canvas.drawPath(path, activeGlow);
        canvas.drawPath(path, active);
      } else {
        canvas.drawPath(path, dormant);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ReferenceRoutePainter oldDelegate) {
    return oldDelegate.points != points ||
        oldDelegate.lastUnlockedIndex != lastUnlockedIndex;
  }
}
