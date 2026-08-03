part of 'main.dart';

class PerspectiveBoardProjection {
  const PerspectiveBoardProjection._();

  static double base(Size size) => min(size.width, size.height);

  static Offset flatCenter(Size size) =>
      Offset(size.width / 2, size.height / 2);

  static Offset center(Size size) => project(size, flatCenter(size));

  static Offset flatPosition(Size size, int nodeId) {
    return BoardMap.position(size, nodeId);
  }

  static Offset project(Size size, Offset flatPoint) {
    final b = base(size);
    final c = flatCenter(size);
    final nx = (flatPoint.dx - c.dx) / b;
    final ny = (flatPoint.dy - c.dy) / b;
    final depth = ((ny + 0.52) / 1.04).clamp(0.0, 1.0);
    final horizontalScale = 0.74 + depth * 0.34;

    return Offset(c.dx + nx * b * horizontalScale, b * 0.455 + ny * b * 0.64);
  }

  static Offset position(Size size, int nodeId) {
    return project(size, flatPosition(size, nodeId));
  }

  static double scaleForFlat(Size size, Offset flatPoint) {
    final b = base(size);
    final c = flatCenter(size);
    final ny = (flatPoint.dy - c.dy) / b;
    final depth = ((ny + 0.52) / 1.04).clamp(0.0, 1.0);
    return 0.76 + depth * 0.34;
  }

  static double scaleForNode(Size size, int nodeId) {
    return scaleForFlat(size, flatPosition(size, nodeId));
  }

  static List<Offset> projectPolygon(Size size, Iterable<Offset> points) {
    return points.map((point) => project(size, point)).toList(growable: false);
  }
}

class PerspectiveBoardLayer extends StatefulWidget {
  const PerspectiveBoardLayer({super.key});

  @override
  State<PerspectiveBoardLayer> createState() => _PerspectiveBoardLayerState();
}

class _PerspectiveBoardLayerState extends State<PerspectiveBoardLayer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final live = VisualCollectionService.current.liveBoard;

    if (!live) {
      return const CustomPaint(painter: PerspectiveBoardPainter());
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return CustomPaint(
          painter: PerspectiveBoardPainter(pulse: _controller.value),
        );
      },
    );
  }
}

class PerspectiveRouteHighlightPainter extends CustomPainter {
  const PerspectiveRouteHighlightPainter({required this.options});

  final List<MoveOption> options;

  @override
  void paint(Canvas canvas, Size size) {
    if (options.isEmpty) return;

    final b = PerspectiveBoardProjection.base(size);
    final glowPaint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = b * 0.028
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..color = const Color(0x667DE3FF)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7);

    final routePaint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = b * 0.010
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..shader = const LinearGradient(
            colors: [Color(0xFFFFE082), Color(0xFF67E8F9), Color(0xFFFFFFFF)],
          ).createShader(Offset.zero & size);

    for (final option in options) {
      if (option.path.length < 2) continue;

      final route = Path();
      final first = PerspectiveBoardProjection.position(
        size,
        option.path.first,
      );
      route.moveTo(first.dx, first.dy);

      for (final nodeId in option.path.skip(1)) {
        final point = PerspectiveBoardProjection.position(size, nodeId);
        route.lineTo(point.dx, point.dy);
      }

      canvas.drawPath(route, glowPaint);
      canvas.drawPath(route, routePaint);
    }
  }

  @override
  bool shouldRepaint(covariant PerspectiveRouteHighlightPainter oldDelegate) {
    return oldDelegate.options != options;
  }
}

class PerspectiveBoardPainter extends CustomPainter {
  const PerspectiveBoardPainter({this.pulse = 0});

  final double pulse;

  BoardThemeDefinition get _theme => VisualCollectionService.theme;
  Color get _gold => _theme.gold;
  Color get _darkGold => _theme.darkGold;
  Color get _foundation => _theme.foundation;

  @override
  void paint(Canvas canvas, Size size) {
    final b = PerspectiveBoardProjection.base(size);

    _drawBackground(canvas, size, b);
    _drawBoardBody(canvas, size, b);
    _drawOuterFoundation(canvas, size, b);
    _drawSpokeFoundations(canvas, size, b);
    _drawTiles(canvas, size, b);
    _drawCenterHex(canvas, size, b);
    _drawAtmosphere(canvas, size, b);
  }

  void _drawBackground(Canvas canvas, Size size, double b) {
    final rect = Offset.zero & size;

    canvas.drawRect(
      rect,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(0, -0.45),
          radius: 1.25,
          colors: [
            _theme.backgroundColors.first,
            _theme.backgroundColors[1],
            _theme.backgroundColors.last,
          ],
        ).createShader(rect),
    );

    final starPaint = Paint()..color = const Color(0x55FFFFFF);
    for (var index = 0; index < 62; index++) {
      final x = ((index * 71) % 997) / 997 * size.width;
      final y = ((index * 131) % 991) / 991 * size.height;
      final radius = b * (index % 7 == 0 ? 0.0030 : 0.0015);
      canvas.drawCircle(Offset(x, y), radius, starPaint);
    }

    final beamPath =
        Path()
          ..moveTo(-b * 0.02, 0)
          ..lineTo(b * 0.28, 0)
          ..lineTo(b * 0.52, b * 0.48)
          ..lineTo(b * 0.25, b * 0.42)
          ..close();

    canvas.drawPath(
      beamPath,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0x55FFF2C4), Color(0x00FFF2C4)],
        ).createShader(Offset.zero & size),
    );
  }

  void _drawBoardBody(Canvas canvas, Size size, double b) {
    final flatCenter = PerspectiveBoardProjection.flatCenter(size);
    final top = <Offset>[];

    for (var index = 0; index < 72; index++) {
      final angle = -pi / 2 + index * (2 * pi / 72);
      top.add(
        PerspectiveBoardProjection.project(
          size,
          flatCenter + Offset(cos(angle), sin(angle)) * b * 0.486,
        ),
      );
    }

    final depth = b * 0.050;
    final lower = top.map((point) => point.translate(0, depth)).toList();

    final lowerPath = _polygon(lower);
    canvas.drawShadow(lowerPath, const Color(0xCC000000), b * 0.030, true);
    canvas.drawPath(
      lowerPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.lerp(_foundation, Colors.black, 0.22)!,
            Color.lerp(_foundation, Colors.black, 0.72)!,
          ],
        ).createShader(lowerPath.getBounds()),
    );

    final side = Path();
    side.moveTo(top.first.dx, top.first.dy);
    for (final point in top) {
      side.lineTo(point.dx, point.dy);
    }
    for (final point in lower.reversed) {
      side.lineTo(point.dx, point.dy);
    }
    side.close();

    canvas.drawPath(
      side,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.lerp(_foundation, Colors.black, 0.28)!,
            Color.lerp(_foundation, Colors.black, 0.78)!,
          ],
        ).createShader(side.getBounds()),
    );

    final topPath = _polygon(top);
    canvas.drawPath(
      topPath,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.2, -0.28),
          radius: 1.0,
          colors: [
            Color.lerp(_theme.backgroundColors.first, Colors.white, 0.08)!,
            _theme.backgroundColors[1],
            _theme.backgroundColors.last,
          ],
        ).createShader(topPath.getBounds()),
    );

    canvas.drawPath(
      topPath,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = b * 0.008
        ..color = _darkGold,
    );

    canvas.drawPath(
      topPath,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = b * 0.0025
        ..color = _gold,
    );

    if (pulse > 0) {
      canvas.drawPath(
        topPath,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = b * (0.004 + pulse * 0.002)
          ..color = _gold.withOpacity(0.08 + pulse * 0.14)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
      );
    }
  }

  void _drawOuterFoundation(Canvas canvas, Size size, double b) {
    final c = PerspectiveBoardProjection.flatCenter(size);

    for (var ring = 0; ring < BoardMap.outerCount; ring++) {
      final a0 = -pi / 2 + (ring - 0.50) * (2 * pi / BoardMap.outerCount);
      final a1 = -pi / 2 + (ring + 0.50) * (2 * pi / BoardMap.outerCount);

      final flat = <Offset>[
        c + Offset(cos(a0), sin(a0)) * b * 0.463,
        c + Offset(cos(a1), sin(a1)) * b * 0.463,
        c + Offset(cos(a1), sin(a1)) * b * 0.372,
        c + Offset(cos(a0), sin(a0)) * b * 0.372,
      ];

      final top = PerspectiveBoardProjection.projectPolygon(size, flat);
      _drawFoundationQuad(canvas, top, b);
    }
  }

  void _drawSpokeFoundations(Canvas canvas, Size size, double b) {
    final c = PerspectiveBoardProjection.flatCenter(size);

    for (var arm = 0; arm < BoardMap.spokeCount; arm++) {
      final angle = BoardMap.armAngle(arm);
      final radial = Offset(cos(angle), sin(angle));
      final tangent = Offset(-sin(angle), cos(angle));
      final inner = c + radial * b * 0.118;
      final outer = c + radial * b * 0.379;
      final half = b * 0.062;

      final flat = <Offset>[
        inner - tangent * half,
        inner + tangent * half,
        outer + tangent * half,
        outer - tangent * half,
      ];

      final top = PerspectiveBoardProjection.projectPolygon(size, flat);
      _drawFoundationQuad(canvas, top, b);
    }
  }

  void _drawFoundationQuad(Canvas canvas, List<Offset> top, double b) {
    final depth = b * 0.018;
    final lower = top.map((point) => point.translate(0, depth)).toList();

    canvas.drawPath(
      _polygon(lower),
      Paint()..color = Color.lerp(_foundation, Colors.black, 0.65)!,
    );

    canvas.drawPath(
      _polygon(top),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.lerp(_foundation, Colors.white, 0.10)!,
            _foundation,
            Color.lerp(_foundation, Colors.black, 0.28)!,
          ],
        ).createShader(_polygon(top).getBounds()),
    );

    canvas.drawPath(
      _polygon(top),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = b * 0.0024
        ..color = _darkGold,
    );
  }

  void _drawTiles(Canvas canvas, Size size, double b) {
    final tiles = <_PerspectiveTileData>[];

    for (var ring = 0; ring < BoardMap.outerCount; ring++) {
      final id = BoardMap.outerId(ring);
      final node = BoardMap.node(id);
      final angle = -pi / 2 + ring * (2 * pi / BoardMap.outerCount);
      tiles.add(
        _PerspectiveTileData(
          id: id,
          node: node,
          flatCenter: BoardMap.position(size, id),
          radialAngle: angle,
          width: node.isBadge ? b * 0.088 : b * 0.073,
          height: node.isBadge ? b * 0.068 : b * 0.056,
        ),
      );
    }

    for (var arm = 0; arm < BoardMap.spokeCount; arm++) {
      for (var step = 0; step < BoardMap.spokeLength; step++) {
        final id = BoardMap.spokeId(arm, step);
        tiles.add(
          _PerspectiveTileData(
            id: id,
            node: BoardMap.node(id),
            flatCenter: BoardMap.position(size, id),
            radialAngle: BoardMap.armAngle(arm),
            width: b * 0.106,
            height: b * 0.047,
          ),
        );
      }
    }

    tiles.sort((a, bTile) {
      final ay = PerspectiveBoardProjection.project(size, a.flatCenter).dy;
      final by = PerspectiveBoardProjection.project(size, bTile.flatCenter).dy;
      return ay.compareTo(by);
    });

    for (final tile in tiles) {
      if (tile.node.isBadge) {
        _drawBadgeTile(canvas, size, b, tile);
      } else {
        _drawRaisedTile(canvas, size, b, tile);
      }
    }
  }

  void _drawRaisedTile(
    Canvas canvas,
    Size size,
    double b,
    _PerspectiveTileData tile,
  ) {
    final radial = Offset(cos(tile.radialAngle), sin(tile.radialAngle));
    final tangent = Offset(-sin(tile.radialAngle), cos(tile.radialAngle));
    final halfW = tile.width / 2;
    final halfH = tile.height / 2;

    final flatCorners = <Offset>[
      tile.flatCenter - tangent * halfW - radial * halfH,
      tile.flatCenter + tangent * halfW - radial * halfH,
      tile.flatCenter + tangent * halfW + radial * halfH,
      tile.flatCenter - tangent * halfW + radial * halfH,
    ];

    final top = PerspectiveBoardProjection.projectPolygon(size, flatCorners);
    final scale = PerspectiveBoardProjection.scaleForFlat(
      size,
      tile.flatCenter,
    );
    final depth = b * 0.012 * scale;
    final lower = top.map((point) => point.translate(0, depth)).toList();
    final category = GameCategory.values[tile.node.categoryIndex];
    final effect = tile.node.specialEffect;
    final tileColor = effect?.color ?? category.color;

    canvas.drawPath(
      _polygon(lower),
      Paint()..color = Color.lerp(tileColor, Colors.black, 0.58)!,
    );

    final frontIndexes = _frontEdgeIndexes(top);
    final frontSide = <Offset>[
      top[frontIndexes.$1],
      top[frontIndexes.$2],
      lower[frontIndexes.$2],
      lower[frontIndexes.$1],
    ];

    canvas.drawPath(
      _polygon(frontSide),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.lerp(tileColor, Colors.black, 0.34)!,
            Color.lerp(tileColor, Colors.black, 0.68)!,
          ],
        ).createShader(_polygon(frontSide).getBounds()),
    );

    final topPath = _polygon(top);
    canvas.drawPath(
      topPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.lerp(tileColor, Colors.white, 0.52)!,
            tileColor,
            Color.lerp(tileColor, Colors.black, 0.26)!,
          ],
          stops: const [0, 0.60, 1],
        ).createShader(topPath.getBounds()),
    );

    canvas.drawPath(
      topPath,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = max(1.0, b * 0.0032 * scale)
        ..color = effect == null ? _gold : const Color(0xFFFFF2A8),
    );

    final ordered = List<Offset>.from(top)
      ..sort((a, b) => a.dy.compareTo(b.dy));
    canvas.drawLine(
      ordered[0],
      ordered[1],
      Paint()
        ..strokeWidth = max(1.0, b * 0.0022 * scale)
        ..strokeCap = StrokeCap.round
        ..color = const Color(0xCCFFFFFF),
    );

    final center = PerspectiveBoardProjection.project(size, tile.flatCenter);
    final emoji = effect?.emoji ?? category.emoji;
    _drawText(
      canvas,
      emoji,
      center.translate(0, -b * 0.002 * scale),
      b * 0.020 * scale,
      Colors.white,
    );
  }

  void _drawBadgeTile(
    Canvas canvas,
    Size size,
    double b,
    _PerspectiveTileData tile,
  ) {
    final center = PerspectiveBoardProjection.project(size, tile.flatCenter);
    final scale = PerspectiveBoardProjection.scaleForFlat(
      size,
      tile.flatCenter,
    );
    final category = GameCategory.values[tile.node.categoryIndex];
    final width = tile.width * scale;
    final height = tile.height * (0.62 + scale * 0.10);
    final depth = b * 0.014 * scale;

    final lowerRect = Rect.fromCenter(
      center: center.translate(0, depth),
      width: width,
      height: height,
    );
    final topRect = Rect.fromCenter(
      center: center,
      width: width,
      height: height,
    );

    canvas.drawOval(
      lowerRect.inflate(b * 0.005 * scale),
      Paint()..color = Color.lerp(_darkGold, Colors.black, 0.45)!,
    );
    canvas.drawOval(topRect.inflate(b * 0.007 * scale), Paint()..color = _gold);
    canvas.drawOval(
      topRect,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.35, -0.42),
          colors: [
            Color.lerp(category.color, Colors.white, 0.55)!,
            category.color,
            Color.lerp(category.color, Colors.black, 0.36)!,
          ],
        ).createShader(topRect),
    );
    canvas.drawOval(
      topRect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = max(1.0, b * 0.0028 * scale)
        ..color = const Color(0xEEFFFFFF),
    );

    _drawText(
      canvas,
      category.emoji,
      center.translate(0, -b * 0.002 * scale),
      b * 0.028 * scale,
      Colors.white,
    );
  }

  void _drawCenterHex(Canvas canvas, Size size, double b) {
    final c = PerspectiveBoardProjection.flatCenter(size);
    final flat = <Offset>[];

    for (var index = 0; index < 6; index++) {
      final angle = -pi / 2 + index * (2 * pi / 6);
      flat.add(c + Offset(cos(angle), sin(angle)) * b * 0.124);
    }

    final top = PerspectiveBoardProjection.projectPolygon(size, flat);
    final depth = b * 0.024;
    final lower = top.map((point) => point.translate(0, depth)).toList();

    canvas.drawShadow(
      _polygon(lower),
      const Color(0xCC000000),
      b * 0.022,
      true,
    );
    canvas.drawPath(
      _polygon(lower),
      Paint()..color = Color.lerp(_darkGold, Colors.black, 0.35)!,
    );

    final topPath = _polygon(top);
    canvas.drawPath(
      topPath,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.35, -0.38),
          colors: _theme.centerColors,
        ).createShader(topPath.getBounds()),
    );
    canvas.drawPath(
      topPath,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = b * 0.006
        ..color = _gold,
    );
    canvas.drawPath(
      topPath,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = b * 0.0018
        ..color = const Color(0xAAFFFFFF),
    );

    final center = PerspectiveBoardProjection.center(size);
    _drawText(
      canvas,
      BoardThemeArt.centerEmoji(_theme.id),
      center.translate(0, -b * 0.027),
      b * 0.032,
      Colors.white,
    );
    _drawText(
      canvas,
      'BİLGİ\nROTASI',
      center.translate(0, b * 0.027),
      b * 0.022,
      const Color(0xFFFFF2B4),
      bold: true,
    );
  }

  void _drawAtmosphere(Canvas canvas, Size size, double b) {
    final glowCenter = Offset(size.width / 2, b * 0.82);
    canvas.drawOval(
      Rect.fromCenter(center: glowCenter, width: b * 0.78, height: b * 0.13),
      Paint()
        ..color = _gold.withOpacity(0.08 + pulse * 0.05)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18),
    );

    final propPaint = Paint()..color = const Color(0x6623112D);
    for (var index = 0; index < 7; index++) {
      final x = b * (0.12 + index * 0.125);
      final y = b * (0.12 + (index.isEven ? 0.00 : 0.018));
      final h = b * (0.030 + (index % 3) * 0.010);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, y, b * 0.055, h),
          Radius.circular(b * 0.006),
        ),
        propPaint,
      );
    }
  }

  Path _polygon(List<Offset> points) {
    final path = Path();
    if (points.isEmpty) return path;
    path.moveTo(points.first.dx, points.first.dy);
    for (final point in points.skip(1)) {
      path.lineTo(point.dx, point.dy);
    }
    return path..close();
  }

  (int, int) _frontEdgeIndexes(List<Offset> points) {
    final indexed = <(int, Offset)>[
      for (var index = 0; index < points.length; index++)
        (index, points[index]),
    ]..sort((a, b) => b.$2.dy.compareTo(a.$2.dy));

    return (indexed[0].$1, indexed[1].$1);
  }

  void _drawText(
    Canvas canvas,
    String text,
    Offset center,
    double fontSize,
    Color color, {
    bool bold = false,
  }) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: fontSize,
          height: 1,
          color: color,
          fontWeight: bold ? FontWeight.w900 : FontWeight.w700,
          shadows: const [
            Shadow(
              offset: Offset(0, 1.5),
              blurRadius: 2.5,
              color: Color(0xAA000000),
            ),
          ],
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout();

    painter.paint(
      canvas,
      Offset(center.dx - painter.width / 2, center.dy - painter.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant PerspectiveBoardPainter oldDelegate) {
    return oldDelegate.pulse != pulse ||
        VisualCollectionService.theme.id != _theme.id;
  }
}

class _PerspectiveTileData {
  const _PerspectiveTileData({
    required this.id,
    required this.node,
    required this.flatCenter,
    required this.radialAngle,
    required this.width,
    required this.height,
  });

  final int id;
  final BoardNode node;
  final Offset flatCenter;
  final double radialAngle;
  final double width;
  final double height;
}
