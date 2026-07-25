#!/usr/bin/env python3
from pathlib import Path
import re
import shutil
import subprocess

main = Path("lib/main.dart")
pubspec = Path("pubspec.yaml")

if not main.exists() or not pubspec.exists():
    raise SystemExit("Bu dosyayı BilgiRotasi proje ana klasöründe çalıştır.")

s = main.read_text(encoding="utf-8")
shutil.copy2(main, "/tmp/bilgi_rotasi_main_backup.dart")

for marker in [
    "class _GameScreenState extends State<GameScreen>",
    "Future<void> _rollDiceAndAsk() async",
    "class GameBoard extends StatelessWidget",
    "class DiceFace extends StatelessWidget",
    "⭐ ${category.label} Rozet Sorusu",
]:
    if marker not in s:
        raise SystemExit(f"Beklenen kod bulunamadı: {marker}")

s = s.replace("  static const int boardCellCount = 36;\n\n", "", 1)

a = s.index("  Future<void> _rollDiceAndAsk() async {")
b = s.index("  Future<void> _askFinalQuestion() async {", a)

movement = r'''  Future<void> _rollDiceAndAsk() async {
    if (_isBusy || _winner != null) return;

    setState(() {
      _isBusy = true;
      _lastDice = _random.nextInt(6) + 1;
      _status = '${_currentPlayer.name} $_lastDice attı. Yolunu seç.';
    });

    HapticFeedback.mediumImpact();
    await Future<void>.delayed(const Duration(milliseconds: 450));

    final options = BoardMap.options(
      _currentPlayer.position,
      _lastDice!,
    );

    if (!mounted) return;

    final selected = options.length == 1
        ? options.first
        : await _chooseMove(options);

    if (!mounted) return;

    if (selected == null) {
      setState(() {
        _isBusy = false;
        _status = 'Yol seçimi iptal edildi.';
      });
      return;
    }

    for (final id in selected.path.skip(1)) {
      setState(() => _currentPlayer.position = id);
      HapticFeedback.selectionClick();
      await Future<void>.delayed(const Duration(milliseconds: 220));
      if (!mounted) return;
    }

    final target = BoardMap.node(_currentPlayer.position);
    final categoryIndex = target.categoryIndex < 0
        ? _random.nextInt(GameCategory.values.length)
        : target.categoryIndex;

    setState(() {
      _status =
          '${_currentPlayer.name}, ${BoardMap.label(target.id)} alanına geldi.';
    });

    final question = widget.questionBank.randomQuestion(
      categoryIndex,
      _random,
    );

    final correct = await Navigator.of(context).push<bool>(
          MaterialPageRoute(
            fullscreenDialog: true,
            builder: (_) => QuestionScreen(
              question: question,
              isBadgeQuestion: target.isBadge,
            ),
          ),
        ) ??
        false;

    if (!mounted) return;

    _handleAnswer(
      correct: correct,
      categoryIndex: categoryIndex,
      wasBadgeCell: target.isBadge,
    );
  }

  Future<MoveOption?> _chooseMove(
    List<MoveOption> options,
  ) {
    return showDialog<MoveOption>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return SimpleDialog(
          title: Text('$_lastDice adım için yolunu seç'),
          children: options.map((option) {
            final target = BoardMap.node(option.destination);
            final category = target.categoryIndex < 0
                ? null
                : GameCategory.values[target.categoryIndex];

            return SimpleDialogOption(
              onPressed: () {
                Navigator.pop(dialogContext, option);
              },
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor:
                      category?.color ?? const Color(0xFF26364A),
                  child: Text(category?.emoji ?? '🧭'),
                ),
                title: Text(
                  BoardMap.routeTitle(option),
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                subtitle: Text(
                  BoardMap.label(option.destination),
                ),
                trailing: const Icon(Icons.arrow_forward_rounded),
              ),
            );
          }).toList(),
        );
      },
    );
  }

'''

s = s[:a] + movement + s[b:]

old_helpers = r'''  static bool isSpecialCell(int position) => position % 6 == 0;

  static int categoryForCell(int position) {
    if (isSpecialCell(position)) {
      return (position ~/ 6) % GameCategory.values.length;
    }
    return position % GameCategory.values.length;
  }
'''
s = s.replace(old_helpers, "", 1)

a = s.index("class GameBoard extends StatelessWidget {")
b = s.index("class DiceFace extends StatelessWidget {", a)

board = r'''enum BoardNodeKind { center, spoke, outer }

class BoardNode {
  const BoardNode({
    required this.id,
    required this.kind,
    required this.categoryIndex,
    this.arm,
    this.step,
    this.ring,
    this.isBadge = false,
  });

  final int id;
  final BoardNodeKind kind;
  final int categoryIndex;
  final int? arm;
  final int? step;
  final int? ring;
  final bool isBadge;
}

class MoveOption {
  const MoveOption(this.path);

  final List<int> path;
  int get destination => path.last;
}

class BoardMap {
  static const centerId = 0;
  static const outerCount = 36;
  static const spokeCount = 6;
  static const spokeLength = 5;
  static const outerStart = 1;
  static const spokeStart = 37;

  static const directions = [
    'Kuzey',
    'Kuzeydoğu',
    'Güneydoğu',
    'Güney',
    'Güneybatı',
    'Kuzeybatı',
  ];

  static int outerId(int ring) {
    final value = (ring % outerCount + outerCount) % outerCount;
    return outerStart + value;
  }

  static int spokeId(int arm, int step) {
    return spokeStart + arm * spokeLength + step;
  }

  static BoardNode node(int id) {
    if (id == centerId) {
      return const BoardNode(
        id: centerId,
        kind: BoardNodeKind.center,
        categoryIndex: -1,
      );
    }

    if (id >= outerStart && id < outerStart + outerCount) {
      final ring = id - outerStart;
      final badge = ring % 6 == 0;

      return BoardNode(
        id: id,
        kind: BoardNodeKind.outer,
        categoryIndex: badge ? ring ~/ 6 : ring % 6,
        ring: ring,
        isBadge: badge,
      );
    }

    final offset = id - spokeStart;
    if (offset >= 0 && offset < spokeCount * spokeLength) {
      final arm = offset ~/ spokeLength;
      final step = offset % spokeLength;

      return BoardNode(
        id: id,
        kind: BoardNodeKind.spoke,
        categoryIndex: (arm + step + 1) % 6,
        arm: arm,
        step: step,
      );
    }

    throw RangeError('Geçersiz tahta alanı: $id');
  }

  static List<int> neighbors(int id) {
    final n = node(id);

    switch (n.kind) {
      case BoardNodeKind.center:
        return List.generate(
          spokeCount,
          (arm) => spokeId(arm, 0),
        );

      case BoardNodeKind.spoke:
        final result = <int>[];
        result.add(
          n.step == 0
              ? centerId
              : spokeId(n.arm!, n.step! - 1),
        );
        result.add(
          n.step == spokeLength - 1
              ? outerId(n.arm! * 6)
              : spokeId(n.arm!, n.step! + 1),
        );
        return result;

      case BoardNodeKind.outer:
        final result = <int>[
          outerId(n.ring! - 1),
          outerId(n.ring! + 1),
        ];

        if (n.ring! % 6 == 0) {
          result.add(
            spokeId(n.ring! ~/ 6, spokeLength - 1),
          );
        }

        return result;
    }
  }

  static List<MoveOption> options(int start, int steps) {
    final found = <List<int>>[];

    void walk(int current, int left, List<int> path) {
      if (left == 0) {
        found.add(path);
        return;
      }

      for (final next in neighbors(current)) {
        if (path.contains(next)) continue;
        walk(next, left - 1, [...path, next]);
      }
    }

    walk(start, steps, [start]);

    final unique = <int, MoveOption>{};
    for (final path in found) {
      unique.putIfAbsent(path.last, () => MoveOption(path));
    }

    return unique.values.toList();
  }

  static String routeTitle(MoveOption option) {
    final start = node(option.path.first);
    final first = node(option.path[1]);

    if (start.kind == BoardNodeKind.center) {
      return '${directions[first.arm!]} yolunu seç';
    }

    if (start.kind == BoardNodeKind.outer &&
        first.kind == BoardNodeKind.outer) {
      final clockwise =
          (first.ring! - start.ring! + outerCount) % outerCount == 1;
      return clockwise
          ? 'Saat yönünde ilerle'
          : 'Saat yönünün tersine ilerle';
    }

    if (first.kind == BoardNodeKind.center) {
      return 'Merkeze gir';
    }

    if (start.kind == BoardNodeKind.outer &&
        first.kind == BoardNodeKind.spoke) {
      return 'Merkeze doğru ilerle';
    }

    if (start.kind == BoardNodeKind.spoke &&
        first.kind == BoardNodeKind.spoke) {
      return first.step! < start.step!
          ? 'Merkeze doğru ilerle'
          : 'Dış halkaya doğru ilerle';
    }

    return 'Dış halkaya çık';
  }

  static String label(int id) {
    final n = node(id);

    if (n.kind == BoardNodeKind.center) {
      return 'Merkez altıgen';
    }

    final category = GameCategory.values[n.categoryIndex];

    if (n.isBadge) {
      return '${category.label} rozet alanı';
    }

    if (n.kind == BoardNodeKind.spoke) {
      return '${directions[n.arm!]} bağlantısı • ${category.label}';
    }

    return 'Dış halka • ${category.label}';
  }

  static double base(Size size) {
    return min(size.width, size.height);
  }

  static Offset center(Size size) {
    return Offset(size.width / 2, size.height / 2);
  }

  static double armAngle(int arm) {
    return -pi / 2 + arm * (2 * pi / spokeCount);
  }

  static Offset position(Size size, int id) {
    final n = node(id);
    final c = center(size);
    final b = base(size);

    if (n.kind == BoardNodeKind.center) return c;

    if (n.kind == BoardNodeKind.outer) {
      final angle = -pi / 2 + n.ring! * (2 * pi / outerCount);
      return c + Offset(cos(angle), sin(angle)) * b * 0.42;
    }

    final angle = armAngle(n.arm!);
    final radius = b * (0.155 + n.step! * 0.049);
    return c + Offset(cos(angle), sin(angle)) * radius;
  }
}

class GameBoard extends StatelessWidget {
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

          return Stack(
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

                if (player.position == BoardMap.centerId) {
                  final angle =
                      -pi / 2 + index * (2 * pi / players.length);
                  point +=
                      Offset(cos(angle), sin(angle)) * base * 0.052;
                }

                final token = active ? base * 0.052 : base * 0.044;

                return AnimatedPositioned(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOutBack,
                  left: point.dx - token / 2,
                  top: point.dy - token / 2,
                  child: Container(
                    width: token,
                    height: token,
                    decoration: BoxDecoration(
                      color: player.color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: active ? 3 : 2,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          blurRadius: 5,
                          color: Color(0x77000000),
                        ),
                      ],
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

class BoardPainter extends CustomPainter {
  const BoardPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final b = BoardMap.base(size);
    final c = BoardMap.center(size);
    final rect = Rect.fromCenter(
      center: c,
      width: b * 0.98,
      height: b * 0.98,
    );
    final board = RRect.fromRectAndRadius(
      rect,
      Radius.circular(b * 0.035),
    );

    canvas.drawRRect(
      board,
      Paint()..color = const Color(0xFF3A2051),
    );
    canvas.drawRRect(
      board.deflate(b * 0.012),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..color = const Color(0xFFE4BE67),
    );

    for (var arm = 0; arm < 6; arm++) {
      final angle = BoardMap.armAngle(arm);

      for (var step = 0; step < 5; step++) {
        final id = BoardMap.spokeId(arm, step);
        final n = BoardMap.node(id);
        _cell(
          canvas,
          BoardMap.position(size, id),
          angle,
          b * 0.105,
          b * 0.042,
          GameCategory.values[n.categoryIndex],
          false,
          b,
        );
      }
    }

    for (var ring = 0; ring < 36; ring++) {
      final id = BoardMap.outerId(ring);
      final n = BoardMap.node(id);
      final angle = -pi / 2 + ring * (2 * pi / 36);

      _cell(
        canvas,
        BoardMap.position(size, id),
        angle,
        n.isBadge ? b * 0.078 : b * 0.064,
        n.isBadge ? b * 0.065 : b * 0.050,
        GameCategory.values[n.categoryIndex],
        n.isBadge,
        b,
      );
    }

    final hex = Path();
    final radius = b * 0.12;

    for (var i = 0; i < 6; i++) {
      final angle = -pi / 2 + i * (2 * pi / 6);
      final p = c + Offset(cos(angle), sin(angle)) * radius;
      if (i == 0) {
        hex.moveTo(p.dx, p.dy);
      } else {
        hex.lineTo(p.dx, p.dy);
      }
    }

    hex.close();

    canvas.drawPath(
      hex,
      Paint()..color = const Color(0xFF143F50),
    );
    canvas.drawPath(
      hex,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..color = const Color(0xFFFFD978),
    );

    _text(
      canvas,
      '🧭\nBİLGİ ROTASI',
      c,
      b * 0.021,
    );
  }

  void _cell(
    Canvas canvas,
    Offset center,
    double angle,
    double width,
    double height,
    GameCategory category,
    bool badge,
    double base,
  ) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle + pi / 2);

    final rect = Rect.fromCenter(
      center: Offset.zero,
      width: width,
      height: height,
    );
    final shape = RRect.fromRectAndRadius(
      rect,
      Radius.circular(base * 0.005),
    );

    canvas.drawRRect(
      shape,
      Paint()..color = category.color,
    );
    canvas.drawRRect(
      shape,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = badge ? 2.2 : 1
        ..color = badge
            ? const Color(0xFFFFE69B)
            : Colors.white,
    );

    if (badge) {
      _text(
        canvas,
        category.emoji,
        Offset.zero,
        base * 0.025,
      );
    }

    canvas.restore();
  }

  void _text(
    Canvas canvas,
    String text,
    Offset center,
    double size,
  ) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: Colors.white,
          fontSize: size,
          fontWeight: FontWeight.w900,
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout();

    painter.paint(
      canvas,
      center - Offset(painter.width / 2, painter.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

'''

s = s[:a] + board + s[b:]

s = s.replace(
    "• Sırası gelen oyuncu zarı atar ve renkli halkada ilerler.\\n\\n",
    "• Bütün oyuncular oyuna ortadaki altıgenden başlar.\\n\\n",
)
s = s.replace(
    "• Gelinen rengin kategorisinden dört şıklı soru açılır.\\n\\n",
    "• Zar atıldıktan sonra gidilecek yol seçilir. Kavşaklarda dış halkada sağa, sola veya merkeze doğru ilerlenebilir.\\n\\n"
    "• Gelinen rengin kategorisinden dört şıklı soru açılır.\\n\\n",
)

if "class BoardMap" not in s or "Future<MoveOption?> _chooseMove" not in s:
    raise SystemExit("Güncelleme doğrulaması başarısız.")

main.write_text(s, encoding="utf-8")

p = pubspec.read_text(encoding="utf-8")
p = re.sub(
    r"^version:\s*.*$",
    "version: 1.2.0+3",
    p,
    flags=re.MULTILINE,
)
pubspec.write_text(p, encoding="utf-8")

subprocess.run(["git", "diff", "--check"], check=True)
subprocess.run(["git", "add", "lib/main.dart", "pubspec.yaml"], check=True)

changed = subprocess.run(
    ["git", "diff", "--cached", "--quiet"],
    check=False,
).returncode != 0

if changed:
    subprocess.run(
        [
            "git",
            "commit",
            "-m",
            "Merkez baslangicli yol secimli oyun tahtasi",
        ],
        check=True,
    )

subprocess.run(["git", "push", "origin", "main"], check=True)

print("✅ Kod güncellendi ve GitHub'a gönderildi.")
print("✅ Actions derlemesi başlayacak.")
