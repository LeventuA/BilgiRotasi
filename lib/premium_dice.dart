part of 'main.dart';

class PremiumDiceModel {
  PremiumDiceModel._();

  static int pipCount(int? value) {
    if (value == null) return 0;
    return value.clamp(1, 6).toInt();
  }

  static bool isLuckySix(int? value) => value == 6;
}

class PremiumDiceFace extends StatefulWidget {
  const PremiumDiceFace({
    required this.value,
    required this.rolling,
    this.size = 62,
    super.key,
  });

  final int? value;
  final bool rolling;
  final double size;

  @override
  State<PremiumDiceFace> createState() => _PremiumDiceFaceState();
}

class _PremiumDiceFaceState extends State<PremiumDiceFace>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  bool get _minimal =>
      AppPreferencesService.current.animationMode == 'minimal';

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: _minimal ? 230 : 620),
      value: widget.rolling ? 0 : 1,
    );
    _syncAnimation();
  }

  @override
  void didUpdateWidget(covariant PremiumDiceFace oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.rolling != widget.rolling) {
      _syncAnimation();
      return;
    }

    if (oldWidget.value != widget.value) {
      if (widget.rolling && !_minimal) {
        if (!_controller.isAnimating) {
          _controller.repeat();
        }
      } else {
        _controller.forward(from: 0);
      }
    }
  }

  void _syncAnimation() {
    if (widget.rolling) {
      if (_minimal) {
        _controller.forward(from: 0);
      } else {
        _controller.repeat();
      }
    } else {
      _controller.stop();
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = VisualCollectionService.theme;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value;
        final rollingTurn = widget.rolling ? t * pi * 2 : 0.0;
        final settle = widget.rolling ? 0.0 : sin(pi * t);
        final scale = widget.rolling
            ? 0.92 + sin(t * pi * 2).abs() * 0.10
            : 1 + settle * 0.13;

        return SizedBox.square(
          dimension: widget.size * 1.42,
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              if (PremiumDiceModel.isLuckySix(widget.value) &&
                  !widget.rolling)
                Positioned.fill(
                  child: IgnorePointer(
                    child: CustomPaint(
                      painter: PremiumDiceSixBurstPainter(
                        progress: t,
                        color: theme.gold,
                      ),
                    ),
                  ),
                ),
              Transform.rotate(
                angle: rollingTurn + settle * 0.10,
                child: Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.0015)
                    ..rotateX(
                      widget.rolling
                          ? sin(t * pi * 2) * 0.52
                          : settle * 0.08,
                    )
                    ..rotateY(
                      widget.rolling
                          ? cos(t * pi * 2) * 0.52
                          : -settle * 0.07,
                    )
                    ..scale(scale),
                  child: CustomPaint(
                    size: Size.square(widget.size),
                    painter: PremiumDicePainter(
                      value: widget.value,
                      rolling: widget.rolling,
                      primary: theme.backgroundColors.first,
                      secondary: theme.centerColors.first,
                      accent: theme.gold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class PremiumDicePainter extends CustomPainter {
  const PremiumDicePainter({
    required this.value,
    required this.rolling,
    required this.primary,
    required this.secondary,
    required this.accent,
  });

  final int? value;
  final bool rolling;
  final Color primary;
  final Color secondary;
  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final radius = Radius.circular(size.width * 0.23);
    final body = RRect.fromRectAndRadius(rect.deflate(size.width * 0.045), radius);

    canvas.drawRRect(
      body.shift(Offset(0, size.height * 0.075)),
      Paint()
        ..color = const Color(0x66000000)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );

    canvas.drawRRect(
      body,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            Color.lerp(primary, Colors.white, 0.52)!,
            Color.lerp(secondary, Colors.white, 0.18)!,
            Color.lerp(primary, Colors.black, 0.30)!,
          ],
          stops: const <double>[0, 0.54, 1],
        ).createShader(rect),
    );

    canvas.drawRRect(
      body,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.width * 0.055
        ..color = accent.withOpacity(rolling ? 0.72 : 0.95),
    );

    final highlight = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width * 0.13,
        size.height * 0.11,
        size.width * 0.62,
        size.height * 0.22,
      ),
      Radius.circular(size.width * 0.12),
    );
    canvas.drawRRect(
      highlight,
      Paint()
        ..shader = LinearGradient(
          colors: <Color>[
            Colors.white.withOpacity(0.68),
            Colors.white.withOpacity(0),
          ],
        ).createShader(highlight.outerRect),
    );

    final safeValue = value?.clamp(1, 6).toInt();
    if (safeValue == null) {
      _drawQuestionMark(canvas, size);
      return;
    }

    final points = _pipPoints(safeValue);
    final pipRadius = size.width * 0.078;
    final pipColor =
        safeValue == 6 ? const Color(0xFFFFF3B0) : Colors.white;

    for (final point in points) {
      final center = Offset(
        size.width * point.dx,
        size.height * point.dy,
      );

      canvas.drawCircle(
        center.translate(0, pipRadius * 0.23),
        pipRadius * 1.04,
        Paint()..color = const Color(0x55000000),
      );
      canvas.drawCircle(
        center,
        pipRadius,
        Paint()
          ..shader = RadialGradient(
            center: const Alignment(-0.3, -0.3),
            colors: <Color>[
              Colors.white,
              pipColor,
              Color.lerp(pipColor, Colors.black, 0.25)!,
            ],
          ).createShader(
            Rect.fromCircle(center: center, radius: pipRadius),
          ),
      );
    }
  }

  void _drawQuestionMark(Canvas canvas, Size size) {
    final painter = TextPainter(
      text: TextSpan(
        text: '?',
        style: TextStyle(
          color: Colors.white.withOpacity(0.94),
          fontSize: size.width * 0.54,
          height: 1,
          fontWeight: FontWeight.w900,
          shadows: const <Shadow>[
            Shadow(color: Color(0x88000000), blurRadius: 5, offset: Offset(0, 3)),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    painter.paint(
      canvas,
      Offset(
        (size.width - painter.width) / 2,
        (size.height - painter.height) / 2 - size.height * 0.025,
      ),
    );
  }

  List<Offset> _pipPoints(int number) {
    const left = 0.28;
    const center = 0.50;
    const right = 0.72;
    const top = 0.28;
    const middle = 0.50;
    const bottom = 0.72;

    return switch (number) {
      1 => const <Offset>[Offset(center, middle)],
      2 => const <Offset>[Offset(left, top), Offset(right, bottom)],
      3 => const <Offset>[
          Offset(left, top),
          Offset(center, middle),
          Offset(right, bottom),
        ],
      4 => const <Offset>[
          Offset(left, top),
          Offset(right, top),
          Offset(left, bottom),
          Offset(right, bottom),
        ],
      5 => const <Offset>[
          Offset(left, top),
          Offset(right, top),
          Offset(center, middle),
          Offset(left, bottom),
          Offset(right, bottom),
        ],
      _ => const <Offset>[
          Offset(left, top),
          Offset(right, top),
          Offset(left, middle),
          Offset(right, middle),
          Offset(left, bottom),
          Offset(right, bottom),
        ],
    };
  }

  @override
  bool shouldRepaint(covariant PremiumDicePainter oldDelegate) {
    return oldDelegate.value != value ||
        oldDelegate.rolling != rolling ||
        oldDelegate.primary != primary ||
        oldDelegate.secondary != secondary ||
        oldDelegate.accent != accent;
  }
}

class PremiumDiceSixBurstPainter extends CustomPainter {
  const PremiumDiceSixBurstPainter({
    required this.progress,
    required this.color,
  });

  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final pulse = sin(pi * progress).clamp(0.0, 1.0).toDouble();
    if (pulse <= 0.001) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * (0.28 + pulse * 0.22);

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = max(1.0, size.width * 0.025 * pulse)
        ..color = color.withOpacity(0.72 * pulse)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );

    for (var index = 0; index < 10; index++) {
      final angle = index * (2 * pi / 10) + progress * 0.45;
      final start = center +
          Offset(cos(angle), sin(angle)) * size.width * 0.34;
      final end = center +
          Offset(cos(angle), sin(angle)) * size.width * (0.43 + pulse * 0.10);

      canvas.drawLine(
        start,
        end,
        Paint()
          ..strokeCap = StrokeCap.round
          ..strokeWidth = max(1.0, size.width * 0.022 * pulse)
          ..color = (index.isEven ? color : Colors.white)
              .withOpacity(0.82 * pulse),
      );
    }
  }

  @override
  bool shouldRepaint(covariant PremiumDiceSixBurstPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
