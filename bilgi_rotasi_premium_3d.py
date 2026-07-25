#!/usr/bin/env python3
from pathlib import Path
import re
import shutil
import subprocess

MAIN = Path('lib/main.dart')
PUBSPEC = Path('pubspec.yaml')

if not MAIN.exists() or not PUBSPEC.exists():
    raise SystemExit('Bu dosyayı BilgiRotasi proje ana klasöründe çalıştır.')

source = MAIN.read_text(encoding='utf-8')
shutil.copy2(MAIN, '/tmp/bilgi_rotasi_3d_oncesi.dart')

for marker in [
    'class BoardMap {',
    'class GameBoard extends StatelessWidget {',
    'class DiceFace extends StatelessWidget {',
    '⭐ ${category.label} Rozet Sorusu',
]:
    if marker not in source:
        raise SystemExit(f'Beklenen kod bulunamadı: {marker}')

if 'static const spokeMix' not in source:
    directions_block = r'''  static const directions = [
    'Kuzey',
    'Kuzeydoğu',
    'Güneydoğu',
    'Güney',
    'Güneybatı',
    'Kuzeybatı',
  ];
'''

    mix_block = directions_block + r'''

  static const spokeMix = <List<int>>[
    [3, 1, 5, 2, 4],
    [4, 2, 0, 5, 3],
    [5, 3, 1, 0, 4],
    [0, 4, 2, 1, 5],
    [1, 5, 3, 2, 0],
    [2, 0, 4, 3, 1],
  ];

  static const outerMix = <List<int>>[
    [2, 5, 1, 4, 3],
    [3, 0, 4, 2, 5],
    [4, 1, 5, 3, 0],
    [5, 2, 0, 4, 1],
    [0, 3, 1, 5, 2],
    [1, 4, 2, 0, 3],
  ];
'''

    if directions_block not in source:
        raise SystemExit('Yön listesi bulunamadı.')
    source = source.replace(directions_block, mix_block, 1)

old_outer = 'categoryIndex: badge ? ring ~/ 6 : ring % 6,'
new_outer = r'''categoryIndex: badge
            ? ring ~/ 6
            : outerMix[ring ~/ 6][(ring % 6) - 1],'''
if old_outer in source:
    source = source.replace(old_outer, new_outer, 1)
elif 'outerMix[ring ~/ 6]' not in source:
    raise SystemExit('Dış halka kategori satırı bulunamadı.')

old_spoke = 'categoryIndex: (arm + step + 1) % 6,'
new_spoke = 'categoryIndex: spokeMix[arm][step],'
if old_spoke in source:
    source = source.replace(old_spoke, new_spoke, 1)
elif new_spoke not in source:
    raise SystemExit('İç kol kategori satırı bulunamadı.')

board_start = source.index('class GameBoard extends StatelessWidget {')
dice_start = source.index('class DiceFace extends StatelessWidget {', board_start)

new_board = r'''class GameBoard extends StatelessWidget {
  const GameBoard({
    required this.players,
    required this.currentPlayerIndex,
    super.key,
  });

  final List<PlayerData> players;
  final int currentPlayerIndex;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = Size(
            constraints.maxWidth,
            constraints.maxHeight,
          );
          final base = BoardMap.base(size);
          final boardCenter = BoardMap.center(size);

          return Stack(
            clipBehavior: Clip.none,
            children: [
              const Positioned.fill(
                child: CustomPaint(
                  painter: BoardPainter(),
                ),
              ),
              ...List.generate(players.length, (index) {
                final player = players[index];
                var point = BoardMap.position(size, player.position);
                final active = index == currentPlayerIndex;

                final stackedBefore = players
                    .take(index)
                    .where((other) => other.position == player.position)
                    .length;

                if (player.position == BoardMap.centerId) {
                  final angle = -pi / 2 +
                      index * (2 * pi / max(players.length, 1));
                  point = boardCenter +
                      Offset(cos(angle), sin(angle)) * base * 0.052;
                } else if (stackedBefore > 0) {
                  final radialAngle = atan2(
                    point.dy - boardCenter.dy,
                    point.dx - boardCenter.dx,
                  );
                  final tangent = Offset(
                    -sin(radialAngle),
                    cos(radialAngle),
                  );
                  point += tangent * stackedBefore * base * 0.024;
                }

                final pawnWidth = active ? base * 0.052 : base * 0.045;
                final pawnHeight = active ? base * 0.074 : base * 0.064;

                return AnimatedPositioned(
                  duration: const Duration(milliseconds: 430),
                  curve: Curves.easeOutBack,
                  left: point.dx - pawnWidth / 2,
                  top: point.dy - pawnHeight * 0.78,
                  child: SizedBox(
                    width: pawnWidth,
                    height: pawnHeight,
                    child: CustomPaint(
                      painter: PremiumPawnPainter(
                        color: player.color,
                        active: active,
                      ),
                    ),
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }
}

class PremiumPawnPainter extends CustomPainter {
  const PremiumPawnPainter({required this.color, required this.active});

  final Color color;
  final bool active;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height * 0.92),
        width: size.width * 0.86,
        height: size.height * 0.17,
      ),
      Paint()
        ..color = const Color(0x66000000)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.5),
    );

    if (active) {
      canvas.drawCircle(
        Offset(size.width / 2, size.height * 0.50),
        size.width * 0.56,
        Paint()
          ..color = color.withOpacity(0.28)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
      );
    }

    final bounds = Rect.fromLTWH(0, 0, size.width, size.height);
    final fill = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color.lerp(color, Colors.white, 0.65)!,
          color,
          Color.lerp(color, Colors.black, 0.42)!,
        ],
        stops: const [0, 0.52, 1],
      ).createShader(bounds);

    final outline = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = active ? 2.2 : 1.5
      ..color = const Color(0xFFFFF5D2);

    final headCenter = Offset(size.width / 2, size.height * 0.24);
    final headRadius = size.width * 0.245;
    canvas.drawCircle(headCenter, headRadius, fill);
    canvas.drawCircle(headCenter, headRadius, outline);

    final body = Path()
      ..moveTo(size.width * 0.40, size.height * 0.43)
      ..quadraticBezierTo(
        size.width * 0.31,
        size.height * 0.60,
        size.width * 0.23,
        size.height * 0.78,
      )
      ..quadraticBezierTo(
        size.width * 0.17,
        size.height * 0.88,
        size.width * 0.28,
        size.height * 0.90,
      )
      ..lineTo(size.width * 0.72, size.height * 0.90)
      ..quadraticBezierTo(
        size.width * 0.83,
        size.height * 0.88,
        size.width * 0.77,
        size.height * 0.78,
      )
      ..quadraticBezierTo(
        size.width * 0.69,
        size.height * 0.60,
        size.width * 0.60,
        size.height * 0.43,
      )
      ..close();

    canvas.drawPath(body, fill);
    canvas.drawPath(body, outline);

    final baseRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height * 0.88),
      width: size.width * 0.72,
      height: size.height * 0.17,
    );
    canvas.drawOval(baseRect, fill);
    canvas.drawOval(baseRect, outline);

    canvas.drawCircle(
      Offset(size.width * 0.42, size.height * 0.16),
      size.width * 0.055,
      Paint()..color = const Color(0xDDFFFFFF),
    );
  }

  @override
  bool shouldRepaint(covariant PremiumPawnPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.active != active;
  }
}

class BoardPainter extends CustomPainter {
  const BoardPainter();

  static const _gold = Color(0xFFE8C76A);
  static const _darkGold = Color(0xFF7B5721);
  static const _deepPurple = Color(0xFF24122F);

  @override
  void paint(Canvas canvas, Size size) {
    final base = BoardMap.base(size);
    final center = BoardMap.center(size);

    final boardRect = Rect.fromCenter(
      center: center,
      width: base * 0.98,
      height: base * 0.98,
    );
    final boardShape = RRect.fromRectAndRadius(
      boardRect,
      Radius.circular(base * 0.042),
    );

    canvas.drawShadow(
      Path()..addRRect(boardShape),
      const Color(0xAA000000),
      15,
      true,
    );

    canvas.drawRRect(
      boardShape,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF56336B),
            Color(0xFF382047),
            Color(0xFF1D1027),
          ],
        ).createShader(boardRect),
    );

    canvas.drawRRect(
      boardShape.deflate(base * 0.012),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.2
        ..color = _gold,
    );
    canvas.drawRRect(
      boardShape.deflate(base * 0.024),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.1
        ..color = const Color(0x99FBE7A2),
    );

    _drawDecorativeWedges(canvas, center, base);
    _drawFoundations(canvas, center, base);
    _drawSpokeTiles(canvas, size, base);
    _drawOuterTiles(canvas, size, base);
    _drawCenterHex(canvas, center, base);
  }

  void _drawDecorativeWedges(Canvas canvas, Offset center, double base) {
    for (var arm = 0; arm < 6; arm++) {
      final angle = BoardMap.armAngle(arm);
      final left = angle - pi / 6;
      final right = angle + pi / 6;
      final path = Path()
        ..moveTo(
          center.dx + cos(left) * base * 0.14,
          center.dy + sin(left) * base * 0.14,
        )
        ..lineTo(
          center.dx + cos(left) * base * 0.375,
          center.dy + sin(left) * base * 0.375,
        )
        ..arcTo(
          Rect.fromCircle(center: center, radius: base * 0.375),
          left,
          pi / 3,
          false,
        )
        ..lineTo(
          center.dx + cos(right) * base * 0.14,
          center.dy + sin(right) * base * 0.14,
        )
        ..close();

      canvas.drawPath(
        path,
        Paint()
          ..color = arm.isEven
              ? const Color(0x18000000)
              : const Color(0x0EFFFFFF),
      );
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.8
          ..color = const Color(0x33E8C76A),
      );
    }
  }

  void _drawFoundations(Canvas canvas, Offset center, double base) {
    canvas.drawCircle(
      center.translate(0, base * 0.013),
      base * 0.420,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = base * 0.086
        ..color = const Color(0x99000000),
    );
    canvas.drawCircle(
      center,
      base * 0.420,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = base * 0.084
        ..color = _darkGold,
    );
    canvas.drawCircle(
      center,
      base * 0.420,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = base * 0.071
        ..color = const Color(0xFF2B1837),
    );

    for (var arm = 0; arm < 6; arm++) {
      final direction = Offset(
        cos(BoardMap.armAngle(arm)),
        sin(BoardMap.armAngle(arm)),
      );
      final start = center + direction * base * 0.125;
      final end = center + direction * base * 0.368;

      canvas.drawLine(
        start.translate(0, base * 0.012),
        end.translate(0, base * 0.012),
        Paint()
          ..strokeWidth = base * 0.123
          ..strokeCap = StrokeCap.butt
          ..color = const Color(0x88000000),
      );
      canvas.drawLine(
        start,
        end,
        Paint()
          ..strokeWidth = base * 0.121
          ..strokeCap = StrokeCap.butt
          ..color = _darkGold,
      );
      canvas.drawLine(
        start,
        end,
        Paint()
          ..strokeWidth = base * 0.106
          ..strokeCap = StrokeCap.butt
          ..color = _deepPurple,
      );
    }
  }

  void _drawSpokeTiles(Canvas canvas, Size size, double base) {
    for (var arm = 0; arm < 6; arm++) {
      final angle = BoardMap.armAngle(arm);
      for (var step = 0; step < 5; step++) {
        final id = BoardMap.spokeId(arm, step);
        final node = BoardMap.node(id);
        _drawRaisedTile(
          canvas: canvas,
          center: BoardMap.position(size, id),
          angle: angle,
          width: base * 0.102,
          height: base * 0.045,
          category: GameCategory.values[node.categoryIndex],
          base: base,
          iconSize: base * 0.018,
        );
      }
    }
  }

  void _drawOuterTiles(Canvas canvas, Size size, double base) {
    for (var ring = 0; ring < 36; ring++) {
      final id = BoardMap.outerId(ring);
      final node = BoardMap.node(id);
      final angle = -pi / 2 + ring * (2 * pi / 36);
      final category = GameCategory.values[node.categoryIndex];

      if (node.isBadge) {
        _drawBadgeMedallion(
          canvas,
          BoardMap.position(size, id),
          category,
          base,
        );
      } else {
        _drawRaisedTile(
          canvas: canvas,
          center: BoardMap.position(size, id),
          angle: angle,
          width: base * 0.071,
          height: base * 0.052,
          category: category,
          base: base,
          iconSize: base * 0.015,
        );
      }
    }
  }

  void _drawRaisedTile({
    required Canvas canvas,
    required Offset center,
    required double angle,
    required double width,
    required double height,
    required GameCategory category,
    required double base,
    required double iconSize,
  }) {
    final depth = base * 0.010;

    void drawAt(Offset tileCenter, bool top) {
      canvas.save();
      canvas.translate(tileCenter.dx, tileCenter.dy);
      canvas.rotate(angle + pi / 2);

      final rect = Rect.fromCenter(
        center: Offset.zero,
        width: width,
        height: height,
      );
      final shape = RRect.fromRectAndRadius(
        rect,
        Radius.circular(base * 0.006),
      );

      if (!top) {
        canvas.drawRRect(
          shape.inflate(base * 0.004),
          Paint()..color = _darkGold,
        );
        canvas.drawRRect(
          shape,
          Paint()
            ..color = Color.lerp(category.color, Colors.black, 0.52)!,
        );
      } else {
        canvas.drawRRect(
          shape.inflate(base * 0.003),
          Paint()..color = _gold,
        );
        canvas.drawRRect(
          shape,
          Paint()
            ..shader = LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.lerp(category.color, Colors.white, 0.48)!,
                category.color,
                Color.lerp(category.color, Colors.black, 0.25)!,
              ],
              stops: const [0, 0.58, 1],
            ).createShader(rect),
        );
        canvas.drawLine(
          Offset(rect.left + base * 0.007, rect.top + base * 0.005),
          Offset(rect.right - base * 0.007, rect.top + base * 0.005),
          Paint()
            ..strokeWidth = 1.2
            ..strokeCap = StrokeCap.round
            ..color = const Color(0xAAFFFFFF),
        );
        _drawText(
          canvas,
          category.emoji,
          Offset.zero,
          iconSize,
          Colors.white,
        );
      }

      canvas.restore();
    }

    drawAt(center.translate(0, depth), false);
    drawAt(center, true);
  }

  void _drawBadgeMedallion(
    Canvas canvas,
    Offset center,
    GameCategory category,
    double base,
  ) {
    final radius = base * 0.043;
    final depth = base * 0.012;

    canvas.drawCircle(
      center.translate(0, depth + base * 0.004),
      radius * 1.12,
      Paint()
        ..color = const Color(0x77000000)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );
    canvas.drawCircle(
      center.translate(0, depth),
      radius * 1.07,
      Paint()..color = _darkGold,
    );
    canvas.drawCircle(
      center,
      radius * 1.08,
      Paint()..color = _gold,
    );
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.38, -0.42),
          colors: [
            Color.lerp(category.color, Colors.white, 0.50)!,
            category.color,
            Color.lerp(category.color, Colors.black, 0.30)!,
          ],
        ).createShader(Rect.fromCircle(center: center, radius: radius)),
    );
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = const Color(0xCCFFFFFF),
    );
    _drawText(
      canvas,
      category.emoji,
      center,
      base * 0.027,
      Colors.white,
    );
  }

  void _drawCenterHex(Canvas canvas, Offset center, double base) {
    final radius = base * 0.124;
    final depth = base * 0.015;

    Path makeHex(Offset c) {
      final path = Path();
      for (var i = 0; i < 6; i++) {
        final angle = -pi / 2 + i * (2 * pi / 6);
        final point = c + Offset(cos(angle), sin(angle)) * radius;
        if (i == 0) {
          path.moveTo(point.dx, point.dy);
        } else {
          path.lineTo(point.dx, point.dy);
        }
      }
      return path..close();
    }

    final lower = makeHex(center.translate(0, depth));
    final upper = makeHex(center);

    canvas.drawShadow(lower, const Color(0xAA000000), 9, true);
    canvas.drawPath(lower, Paint()..color = _darkGold);
    canvas.drawPath(
      upper,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(-0.35, -0.38),
          colors: [
            Color(0xFF2B7184),
            Color(0xFF153E50),
            Color(0xFF071E2A),
          ],
        ).createShader(Rect.fromCircle(center: center, radius: radius)),
    );
    canvas.drawPath(
      upper,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.2
        ..color = const Color(0xFFFFD978),
    );

    _drawText(
      canvas,
      '🧭',
      center.translate(0, -base * 0.025),
      base * 0.030,
      Colors.white,
    );
    _drawText(
      canvas,
      'BİLGİ\nROTASI',
      center.translate(0, base * 0.030),
      base * 0.020,
      Colors.white,
      bold: true,
    );
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
              blurRadius: 2,
              color: Color(0x88000000),
            ),
          ],
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout();

    painter.paint(
      canvas,
      Offset(
        center.dx - painter.width / 2,
        center.dy - painter.height / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

'''

source = source[:board_start] + new_board + source[dice_start:]

for marker in [
    'static const spokeMix',
    'class PremiumPawnPainter',
    '⭐ ${category.label} Rozet Sorusu',
]:
    if marker not in source:
        raise SystemExit(f'Doğrulama başarısız: {marker}')

MAIN.write_text(source, encoding='utf-8')

pub = PUBSPEC.read_text(encoding='utf-8')
pub = re.sub(
    r'^version:\s*.*$',
    'version: 1.3.0+4',
    pub,
    flags=re.MULTILINE,
)
PUBSPEC.write_text(pub, encoding='utf-8')

if shutil.which('dart'):
    subprocess.run(['dart', 'format', 'lib/main.dart'], check=True)

subprocess.run(['git', 'diff', '--check'], check=True)
subprocess.run(['git', 'add', 'lib/main.dart', 'pubspec.yaml'], check=True)

changed = subprocess.run(
    ['git', 'diff', '--cached', '--quiet'],
    check=False,
).returncode != 0

if changed:
    subprocess.run(
        ['git', 'commit', '-m', 'Karisik kategorili premium 3D tahta'],
        check=True,
    )

subprocess.run(['git', 'push', 'origin', 'main'], check=True)

print('✅ İç kollar karışık kategorili oldu.')
print('✅ Dış halka renkli ve kabartmalı oldu.')
print('✅ Rozet alanları 3D madalyonlara dönüştü.')
print('✅ Piyonlar 3D görünüme geçti.')
print('✅ Kod GitHub\'a gönderildi; Actions başlayacak.')
