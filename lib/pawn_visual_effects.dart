part of 'main.dart';

class PawnFxProfile {
  const PawnFxProfile({
    required this.label,
    required this.primary,
    required this.secondary,
    required this.glyph,
  });

  final String label;
  final Color primary;
  final Color secondary;
  final String glyph;
}

class PawnVisualEffects {
  PawnVisualEffects._();

  static const List<PawnFxProfile> profiles = <PawnFxProfile>[
    PawnFxProfile(label: 'Gökkuşağı halkaları', primary: Color(0xFFFF4D9D), secondary: Color(0xFF38BDF8), glyph: '◌'),
    PawnFxProfile(label: 'Kristal parçacıkları', primary: Color(0xFF38BDF8), secondary: Color(0xFFE0F2FE), glyph: '◆'),
    PawnFxProfile(label: 'Zihin kıvılcımları', primary: Color(0xFFF472B6), secondary: Color(0xFFC084FC), glyph: '●'),
    PawnFxProfile(label: 'Klasik oyun izleri', primary: Color(0xFFB45309), secondary: Color(0xFFFDE68A), glyph: '♟'),
    PawnFxProfile(label: 'Bilge nal izleri', primary: Color(0xFF7C3AED), secondary: Color(0xFFD8B4FE), glyph: '∩'),
    PawnFxProfile(label: 'Kristal zar küpleri', primary: Color(0xFF06B6D4), secondary: Color(0xFFA5F3FC), glyph: '□'),
    PawnFxProfile(label: 'Pusula yıldızları', primary: Color(0xFFF59E0B), secondary: Color(0xFFFFF3B0), glyph: '✦'),
    PawnFxProfile(label: 'Uçuşan sayfalar', primary: Color(0xFF3B82F6), secondary: Color(0xFFDBEAFE), glyph: '▱'),
    PawnFxProfile(label: 'Fikir parlamaları', primary: Color(0xFFFACC15), secondary: Color(0xFFFFF7AE), glyph: '✺'),
    PawnFxProfile(label: 'Kum taneleri', primary: Color(0xFFF97316), secondary: Color(0xFFFED7AA), glyph: '⋮'),
    PawnFxProfile(label: 'Merak işaretleri', primary: Color(0xFF8B5CF6), secondary: Color(0xFFEDE9FE), glyph: '?'),
    PawnFxProfile(label: 'Zafer madalyaları', primary: Color(0xFFEAB308), secondary: Color(0xFFFFE082), glyph: '♛'),
    PawnFxProfile(label: 'Kozmik yıldız tozu', primary: Color(0xFF9D7CFF), secondary: Color(0xFF67E8F9), glyph: '★'),
    PawnFxProfile(label: 'Canlı yaprak izleri', primary: Color(0xFF22C55E), secondary: Color(0xFFBBF7D0), glyph: '❧'),
    PawnFxProfile(label: 'Altın sihir kıvılcımları', primary: Color(0xFFFFC857), secondary: Color(0xFFFFF1B8), glyph: '✧'),
    PawnFxProfile(label: 'Taş tozu ve yüzük ışığı', primary: Color(0xFFB6A0FF), secondary: Color(0xFFE7E0FF), glyph: '◉'),
  ];

  static int normalize(int pawnType) {
    return (pawnType % profiles.length + profiles.length) % profiles.length;
  }

  static PawnFxProfile profileFor(int pawnType) {
    return profiles[normalize(pawnType)];
  }

  static bool get minimalAnimations =>
      AppPreferencesService.current.animationMode == 'minimal';
}

class PawnStepTrailPainter extends CustomPainter {
  const PawnStepTrailPainter({
    required this.progress,
    required this.pawnType,
    required this.playerColor,
    required this.pulse,
    required this.minimal,
  });

  final double progress;
  final int pawnType;
  final Color playerColor;
  final int pulse;
  final bool minimal;

  @override
  void paint(Canvas canvas, Size size) {
    final strength = sin(pi * progress).clamp(0.0, 1.0).toDouble();
    if (strength < 0.003) return;

    final profile = PawnVisualEffects.profileFor(pawnType);
    final count = minimal ? 2 : 6;
    final direction = pulse.isEven ? -1.0 : 1.0;
    final origin = Offset(size.width * 0.50, size.height * 0.78);

    for (var index = 0; index < count; index++) {
      final depth = (index + 1) / count;
      final center = origin + Offset(
        direction * size.width * (0.10 + depth * 0.44),
        size.height * (0.03 + depth * 0.12) +
            sin((progress * 5 + index) * pi) * size.height * 0.025,
      );
      final opacity = strength * (1 - depth * 0.68);
      final color = index.isEven
          ? Color.lerp(profile.primary, playerColor, 0.18)!
          : profile.secondary;

      canvas.drawCircle(
        center,
        size.width * 0.060,
        Paint()
          ..color = color.withOpacity(opacity * 0.20)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
      );

      _paintPawnFxGlyph(
        canvas,
        profile.glyph,
        center,
        size.width * (minimal ? 0.090 : 0.075),
        color.withOpacity(opacity),
        progress * pi + index * 0.42,
      );
    }
  }

  @override
  bool shouldRepaint(covariant PawnStepTrailPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.pawnType != pawnType ||
        oldDelegate.playerColor != playerColor ||
        oldDelegate.pulse != pulse ||
        oldDelegate.minimal != minimal;
  }
}

class PawnLandingSignaturePainter extends CustomPainter {
  const PawnLandingSignaturePainter({
    required this.progress,
    required this.pawnType,
    required this.playerColor,
    required this.minimal,
  });

  final double progress;
  final int pawnType;
  final Color playerColor;
  final bool minimal;

  @override
  void paint(Canvas canvas, Size size) {
    final profile = PawnVisualEffects.profileFor(pawnType);
    final center = Offset(size.width / 2, size.height / 2);
    final fade = (1 - progress).clamp(0.0, 1.0).toDouble();
    final opening = Curves.easeOutCubic.transform(progress);
    final radius = size.width * (0.15 + opening * 0.34);

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = max(1.0, size.width * 0.040 * fade)
        ..color = profile.primary.withOpacity(fade * 0.90)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );
    canvas.drawCircle(
      center,
      radius * 0.72,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = max(1.0, size.width * 0.020 * fade)
        ..color = profile.secondary.withOpacity(fade * 0.94),
    );

    final count = minimal ? 4 : 10;
    for (var index = 0; index < count; index++) {
      final angle = -pi / 2 + index * 2 * pi / count + progress * 0.50;
      final point = center + Offset(cos(angle), sin(angle)) * radius;
      final color = index.isEven ? profile.primary : profile.secondary;
      _paintPawnFxGlyph(
        canvas,
        profile.glyph,
        point,
        size.width * (minimal ? 0.090 : 0.075),
        color.withOpacity(fade * (index.isEven ? 0.95 : 0.75)),
        angle + progress * pi,
      );
    }

    final type = PawnVisualEffects.normalize(pawnType);
    if (type >= 12) {
      canvas.drawCircle(
        center,
        size.width * (0.07 + opening * 0.10),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = max(1.0, size.width * 0.028 * fade)
          ..color = Color.lerp(profile.primary, playerColor, 0.20)!
              .withOpacity(fade)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
      );
      _paintPawnFxGlyph(
        canvas,
        profile.glyph,
        center,
        size.width * (minimal ? 0.15 : 0.18),
        Colors.white.withOpacity(fade),
        type == 13 ? -0.40 : progress * pi,
      );
    }
  }

  @override
  bool shouldRepaint(covariant PawnLandingSignaturePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.pawnType != pawnType ||
        oldDelegate.playerColor != playerColor ||
        oldDelegate.minimal != minimal;
  }
}

void _paintPawnFxGlyph(
  Canvas canvas,
  String glyph,
  Offset center,
  double fontSize,
  Color color,
  double rotation,
) {
  canvas.save();
  canvas.translate(center.dx, center.dy);
  canvas.rotate(rotation);

  final painter = TextPainter(
    text: TextSpan(
      text: glyph,
      style: TextStyle(
        color: color,
        fontSize: fontSize,
        height: 1,
        fontWeight: FontWeight.w900,
        shadows: <Shadow>[
          Shadow(
            color: color.withOpacity(0.45),
            blurRadius: 5,
          ),
        ],
      ),
    ),
    textAlign: TextAlign.center,
    textDirection: TextDirection.ltr,
  )..layout();

  painter.paint(
    canvas,
    Offset(-painter.width / 2, -painter.height / 2),
  );
  canvas.restore();
}
