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
shutil.copy2(MAIN, '/tmp/bilgi_rotasi_parlayan_rota_oncesi.dart')

required = [
    'class _GameScreenState extends State<GameScreen>',
    'Future<void> _rollDiceAndAsk() async',
    'Future<MoveOption?> _chooseMove(',
    'class GameBoard extends StatelessWidget',
    'class BoardPainter extends CustomPainter',
]
for marker in required:
    if marker not in source:
        raise SystemExit(f'Beklenen kod bulunamadı: {marker}')

# Completer için async kütüphanesi.
if "import 'dart:async';" not in source:
    source = source.replace(
        "import 'dart:convert';",
        "import 'dart:async';\nimport 'dart:convert';",
        1,
    )

# Oyun durumuna tahta üzerinden rota seçimi alanları ekle.
old_fields = r'''  int? _lastDice;
  bool _isBusy = false;
  String _status = 'Zarı at ve rotaya çık.';
  PlayerData? _winner;'''

new_fields = r'''  int? _lastDice;
  bool _isBusy = false;
  String _status = 'Zarı at ve rotaya çık.';
  PlayerData? _winner;
  List<MoveOption> _moveOptions = const <MoveOption>[];
  Completer<MoveOption>? _moveCompleter;'''

if old_fields not in source:
    raise SystemExit('Oyun durum alanları bulunamadı.')
source = source.replace(old_fields, new_fields, 1)

# GameBoard çağrısına parlayan rotaları ve dokunma olayını bağla.
old_board_call = r'''                    child: GameBoard(
                      players: widget.players,
                      currentPlayerIndex: _currentPlayerIndex,
                    ),'''

new_board_call = r'''                    child: GameBoard(
                      players: widget.players,
                      currentPlayerIndex: _currentPlayerIndex,
                      moveOptions: _moveOptions,
                      onMoveSelected: _selectMoveFromBoard,
                    ),'''

if old_board_call not in source:
    raise SystemExit('Tahta çağrısı bulunamadı.')
source = source.replace(old_board_call, new_board_call, 1)

# Açılır yön penceresi yerine tahtadan seçim bekle.
old_selection = r'''    final selected = options.length == 1
        ? options.first
        : await _chooseMove(options);

    if (!mounted) return;'''

new_selection = r'''    final MoveOption? selected;

    if (options.length == 1) {
      selected = options.first;
    } else {
      selected = await _waitForBoardMove(options);
    }

    if (!mounted) return;'''

if old_selection not in source:
    raise SystemExit('Eski yön seçme çağrısı bulunamadı.')
source = source.replace(old_selection, new_selection, 1)

# Eski SimpleDialog yöntemini tahta seçim yöntemleriyle değiştir.
choose_start = source.index('  Future<MoveOption?> _chooseMove(')
final_start = source.index('  Future<void> _askFinalQuestion() async', choose_start)

new_choose_methods = r'''  Future<MoveOption?> _waitForBoardMove(
    List<MoveOption> options,
  ) async {
    final completer = Completer<MoveOption>();

    setState(() {
      _moveOptions = List<MoveOption>.unmodifiable(options);
      _moveCompleter = completer;
      _status =
          '${_currentPlayer.name}, parlayan hedeflerden birine dokun.';
    });

    HapticFeedback.mediumImpact();

    final selected = await completer.future;

    if (!mounted) return null;

    setState(() {
      _moveOptions = const <MoveOption>[];
      _moveCompleter = null;
      _status = '${BoardMap.routeTitle(selected)} seçildi.';
    });

    return selected;
  }

  void _selectMoveFromBoard(MoveOption option) {
    final completer = _moveCompleter;

    if (completer == null || completer.isCompleted) return;

    HapticFeedback.heavyImpact();
    completer.complete(option);
  }

'''

source = source[:choose_start] + new_choose_methods + source[final_start:]

# Çıkışta bekleyen seçim varsa güvenli biçimde temizle.
old_exit = r'''    if (shouldExit && mounted) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }'''

new_exit = r'''    if (shouldExit && mounted) {
      final completer = _moveCompleter;
      if (completer != null && !completer.isCompleted && _moveOptions.isNotEmpty) {
        completer.complete(_moveOptions.first);
      }
      Navigator.of(context).popUntil((route) => route.isFirst);
    }'''

if old_exit in source:
    source = source.replace(old_exit, new_exit, 1)

# GameBoard sınıfını parlayan yollar ve dokunulabilir hedeflerle yenile.
board_start = source.index('class GameBoard extends StatelessWidget {')
board_painter_start = source.index(
    'class BoardPainter extends CustomPainter',
    board_start,
)

new_game_board = r'''class RouteHighlightPainter extends CustomPainter {
  const RouteHighlightPainter({required this.options});

  final List<MoveOption> options;

  @override
  void paint(Canvas canvas, Size size) {
    if (options.isEmpty) return;

    final glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = BoardMap.base(size) * 0.030
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = const Color(0x667DE3FF)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7);

    final routePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = BoardMap.base(size) * 0.012
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..shader = const LinearGradient(
        colors: [
          Color(0xFFFFE082),
          Color(0xFF67E8F9),
          Color(0xFFFFFFFF),
        ],
      ).createShader(Offset.zero & size);

    for (final option in options) {
      if (option.path.length < 2) continue;

      final route = Path();
      final first = BoardMap.position(size, option.path.first);
      route.moveTo(first.dx, first.dy);

      for (final nodeId in option.path.skip(1)) {
        final point = BoardMap.position(size, nodeId);
        route.lineTo(point.dx, point.dy);
      }

      canvas.drawPath(route, glowPaint);
      canvas.drawPath(route, routePaint);
    }
  }

  @override
  bool shouldRepaint(covariant RouteHighlightPainter oldDelegate) {
    return oldDelegate.options != options;
  }
}

class RouteTargetPulse extends StatefulWidget {
  const RouteTargetPulse({
    required this.color,
    required this.emoji,
    required this.onTap,
    required this.size,
    super.key,
  });

  final Color color;
  final String emoji;
  final VoidCallback onTap;
  final double size;

  @override
  State<RouteTargetPulse> createState() => _RouteTargetPulseState();
}

class _RouteTargetPulseState extends State<RouteTargetPulse>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 720),
    )..repeat(reverse: true);

    _scale = Tween<double>(begin: 0.88, end: 1.13).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onTap,
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          width: widget.size,
          height: widget.size,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                Colors.white,
                Color.lerp(widget.color, Colors.white, 0.20)!,
                widget.color,
              ],
              stops: const [0, 0.50, 1],
            ),
            border: Border.all(
              color: const Color(0xFFFFE082),
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.color.withOpacity(0.80),
                blurRadius: 14,
                spreadRadius: 4,
              ),
              const BoxShadow(
                color: Color(0xAAFFFFFF),
                blurRadius: 5,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Text(
            widget.emoji,
            style: TextStyle(
              fontSize: widget.size * 0.42,
              height: 1,
            ),
          ),
        ),
      ),
    );
  }
}

class GameBoard extends StatelessWidget {
  const GameBoard({
    required this.players,
    required this.currentPlayerIndex,
    this.moveOptions = const <MoveOption>[],
    this.onMoveSelected,
    super.key,
  });

  final List<PlayerData> players;
  final int currentPlayerIndex;
  final List<MoveOption> moveOptions;
  final ValueChanged<MoveOption>? onMoveSelected;

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
              if (moveOptions.isNotEmpty)
                Positioned.fill(
                  child: IgnorePointer(
                    child: CustomPaint(
                      painter: RouteHighlightPainter(
                        options: moveOptions,
                      ),
                    ),
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
                  final divisor = players.isEmpty ? 1 : players.length;
                  final angle = -pi / 2 +
                      index * (2 * pi / divisor.toDouble());
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
                  point += tangent *
                      stackedBefore.toDouble() *
                      base *
                      0.024;
                }

                final pawnWidth = active ? base * 0.046 : base * 0.040;
                final pawnHeight = active ? base * 0.060 : base * 0.053;

                return AnimatedPositioned(
                  duration: const Duration(milliseconds: 430),
                  curve: Curves.easeOutBack,
                  left: point.dx - pawnWidth / 2,
                  top: point.dy - pawnHeight * 0.76,
                  child: PawnToken(
                    type: player.pawnType,
                    color: player.color,
                    active: active,
                    width: pawnWidth,
                    height: pawnHeight,
                  ),
                );
              }),
              ...moveOptions.map((option) {
                final destination = BoardMap.node(option.destination);
                final point = BoardMap.position(size, option.destination);
                final category = destination.categoryIndex < 0
                    ? null
                    : GameCategory.values[destination.categoryIndex];
                final targetSize = destination.isBadge
                    ? base * 0.088
                    : base * 0.074;

                return Positioned(
                  left: point.dx - targetSize / 2,
                  top: point.dy - targetSize / 2,
                  child: Semantics(
                    button: true,
                    label: BoardMap.routeTitle(option),
                    child: RouteTargetPulse(
                      key: ValueKey<int>(option.destination),
                      color: category?.color ?? const Color(0xFF155E75),
                      emoji: category?.emoji ?? '🧭',
                      size: targetSize,
                      onTap: () => onMoveSelected?.call(option),
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

'''

source = source[:board_start] + new_game_board + source[board_painter_start:]

# Sürüm ve doğrulama.
for marker in [
    "import 'dart:async';",
    'Completer<MoveOption>? _moveCompleter',
    'Future<MoveOption?> _waitForBoardMove',
    'class RouteTargetPulse extends StatefulWidget',
    'class RouteHighlightPainter extends CustomPainter',
    'moveOptions: _moveOptions',
]:
    if marker not in source:
        raise SystemExit(f'Güncelleme doğrulaması başarısız: {marker}')

if 'Future<MoveOption?> _chooseMove(' in source:
    raise SystemExit('Eski açılır yön penceresi kaldırılamadı.')

MAIN.write_text(source, encoding='utf-8')

pub = PUBSPEC.read_text(encoding='utf-8')
pub = re.sub(
    r'^version:\s*.*$',
    'version: 1.6.0+7',
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
        ['git', 'commit', '-m', 'Tahtadan parlayan rota secimi'],
        check=True,
    )

subprocess.run(['git', 'push', 'origin', 'main'], check=True)

print('✅ Açılır yön penceresi kaldırıldı.')
print('✅ Gidilebilen rotalar tahtada ışıklı gösterilecek.')
print('✅ Oyuncu parlayan hedefe dokunarak yol seçecek.')
print('✅ Seçimden sonra piyon kare kare ilerleyecek.')
print('✅ Kod GitHub\'a gönderildi; Actions başlayacak.')
