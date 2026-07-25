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
shutil.copy2(MAIN, '/tmp/bilgi_rotasi_piyon_secimi_oncesi.dart')

required = [
    'class _PlayerSetupScreenState extends State<PlayerSetupScreen>',
    'class GameScreen extends StatefulWidget',
    'class GameBoard extends StatelessWidget',
    'class BoardPainter extends CustomPainter',
    'class PlayerData {',
]
for marker in required:
    if marker not in source:
        raise SystemExit(f'Beklenen kod bulunamadı: {marker}')

setup_start = source.index(
    'class _PlayerSetupScreenState extends State<PlayerSetupScreen>'
)
game_screen_start = source.index(
    'class GameScreen extends StatefulWidget',
    setup_start,
)

new_setup = r'''class _PlayerSetupScreenState extends State<PlayerSetupScreen> {
  int _playerCount = 2;

  final List<TextEditingController> _controllers = List.generate(
    6,
    (index) => TextEditingController(text: 'Oyuncu ${index + 1}'),
  );

  final List<int> _selectedPawnTypes = List<int>.generate(
    6,
    (index) => index,
  );

  static const List<Color> _playerColors = [
    Color(0xFFE11D48),
    Color(0xFF2563EB),
    Color(0xFF16A34A),
    Color(0xFF9333EA),
    Color(0xFFF97316),
    Color(0xFF0891B2),
  ];

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Oyuncuları Hazırla')),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Oyuncu sayısı: $_playerCount',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Slider(
                            min: 2,
                            max: 6,
                            divisions: 4,
                            value: _playerCount.toDouble(),
                            label: '$_playerCount',
                            onChanged: (value) {
                              setState(() => _playerCount = value.round());
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  ...List.generate(_playerCount, (index) {
                    final pawn = PawnCatalog.at(_selectedPawnTypes[index]);

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            InkWell(
                              borderRadius: BorderRadius.circular(18),
                              onTap: () => _showPawnPicker(index),
                              child: Container(
                                width: 84,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: _playerColors[index].withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: _playerColors[index].withOpacity(0.35),
                                  ),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    PawnToken(
                                      type: _selectedPawnTypes[index],
                                      color: _playerColors[index],
                                      active: true,
                                      width: 42,
                                      height: 52,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      pawn.name,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 10,
                                        height: 1.05,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    const Text(
                                      'Değiştir',
                                      style: TextStyle(
                                        fontSize: 9,
                                        color: Color(0xFF64748B),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextField(
                                controller: _controllers[index],
                                maxLength: 16,
                                textCapitalization: TextCapitalization.words,
                                decoration: InputDecoration(
                                  counterText: '',
                                  labelText: '${index + 1}. oyuncu',
                                  helperText: 'Yanındaki piyona dokunarak seç',
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(18),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
              child: FilledButton.icon(
                onPressed: _startGame,
                icon: const Icon(Icons.casino_rounded),
                label: const Text(
                  'Tahtaya Geç',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showPawnPicker(int playerIndex) async {
    final selected = await showDialog<int>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('${playerIndex + 1}. oyuncunun piyonu'),
          contentPadding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
          content: SizedBox(
            width: double.maxFinite,
            height: 430,
            child: GridView.builder(
              itemCount: PawnCatalog.all.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 0.78,
              ),
              itemBuilder: (context, index) {
                final pawn = PawnCatalog.all[index];
                final isSelected = _selectedPawnTypes[playerIndex] == index;

                return Material(
                  color: isSelected
                      ? _playerColors[playerIndex].withOpacity(0.14)
                      : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => Navigator.pop(dialogContext, index),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? _playerColors[playerIndex]
                              : const Color(0xFFE2E8F0),
                          width: isSelected ? 2.5 : 1,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          PawnToken(
                            type: index,
                            color: _playerColors[playerIndex],
                            active: isSelected,
                            width: 46,
                            height: 58,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            pawn.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 10,
                              height: 1.05,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Vazgeç'),
            ),
          ],
        );
      },
    );

    if (selected == null || !mounted) return;

    setState(() {
      _selectedPawnTypes[playerIndex] = selected;
    });
  }

  void _startGame() {
    final players = <PlayerData>[];

    for (var index = 0; index < _playerCount; index++) {
      final name = _controllers[index].text.trim();

      players.add(
        PlayerData(
          name: name.isEmpty ? 'Oyuncu ${index + 1}' : name,
          color: _playerColors[index],
          pawnType: _selectedPawnTypes[index],
        ),
      );
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => GameScreen(
          questionBank: widget.questionBank,
          players: players,
        ),
      ),
    );
  }
}

'''

source = source[:setup_start] + new_setup + source[game_screen_start:]

old_avatar = r'''                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: _currentPlayer.color,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: const [
                          BoxShadow(blurRadius: 8, color: Color(0x33000000)),
                        ],
                      ),
                    ),'''
new_avatar = r'''                    PawnToken(
                      type: _currentPlayer.pawnType,
                      color: _currentPlayer.color,
                      active: true,
                      width: 44,
                      height: 54,
                    ),'''
if old_avatar not in source:
    raise SystemExit('Kontrol paneli oyuncu simgesi bulunamadı.')
source = source.replace(old_avatar, new_avatar, 1)

old_player_dot = r'''                        Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            color: player.color,
                            shape: BoxShape.circle,
                          ),
                        ),'''
new_player_dot = r'''                        PawnToken(
                          type: player.pawnType,
                          color: player.color,
                          active: active,
                          width: 24,
                          height: 30,
                        ),'''
if old_player_dot not in source:
    raise SystemExit('Oyuncu listesi simgesi bulunamadı.')
source = source.replace(old_player_dot, new_player_dot, 1)

board_start = source.index('class GameBoard extends StatelessWidget {')
board_painter_start = source.index(
    'class BoardPainter extends CustomPainter',
    board_start,
)

new_pawn_system = r'''class PawnDefinition {
  const PawnDefinition({
    required this.name,
    required this.symbol,
  });

  final String name;
  final String symbol;
}

class PawnCatalog {
  static const List<PawnDefinition> all = [
    PawnDefinition(name: 'Renkli Halka', symbol: '◉'),
    PawnDefinition(name: 'Bilgi Taşı', symbol: '🧠'),
    PawnDefinition(name: 'Beyin Maskotu', symbol: '🧠'),
    PawnDefinition(name: 'Klasik Piyon', symbol: '♟'),
    PawnDefinition(name: 'Bilge At Piyonu', symbol: '♞'),
    PawnDefinition(name: 'Kristal Zar Piyonu', symbol: '🎲'),
    PawnDefinition(name: 'Pusula Yıldızı', symbol: '🧭'),
    PawnDefinition(name: 'Açık Kitap', symbol: '📖'),
    PawnDefinition(name: 'Ampul Fikri', symbol: '💡'),
    PawnDefinition(name: 'Kum Saati', symbol: '⏳'),
    PawnDefinition(name: 'Soru İşareti', symbol: '?'),
    PawnDefinition(name: 'Kupa Rozet', symbol: '🏆'),
  ];

  static PawnDefinition at(int index) {
    final normalized = (index % all.length + all.length) % all.length;
    return all[normalized];
  }
}

class PawnToken extends StatelessWidget {
  const PawnToken({
    required this.type,
    required this.color,
    required this.active,
    required this.width,
    required this.height,
    super.key,
  });

  final int type;
  final Color color;
  final bool active;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    if (type == 0) {
      return SizedBox(
        width: width,
        height: height,
        child: CustomPaint(
          painter: RingPawnPainter(color: color, active: active),
        ),
      );
    }

    if (type == 3) {
      return SizedBox(
        width: width,
        height: height,
        child: CustomPaint(
          painter: ClassicPawnPainter(color: color, active: active),
        ),
      );
    }

    final pawn = PawnCatalog.at(type);
    final isGem = type == 1 || type == 5 || type == 11;
    final isRound = type == 2 || type == 6 || type == 8 || type == 10;

    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          if (active)
            Positioned(
              top: height * 0.05,
              child: Container(
                width: width * 0.96,
                height: width * 0.96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.42),
                      blurRadius: width * 0.32,
                      spreadRadius: width * 0.05,
                    ),
                  ],
                ),
              ),
            ),
          Positioned(
            bottom: 0,
            child: Container(
              width: width * 0.82,
              height: height * 0.16,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFFFE79A),
                    Color(0xFFD49A22),
                    Color(0xFF8A5914),
                  ],
                ),
                boxShadow: const [
                  BoxShadow(
                    offset: Offset(0, 2),
                    blurRadius: 3,
                    color: Color(0x66000000),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: height * 0.03,
            child: Transform.rotate(
              angle: isGem ? pi / 4 : 0,
              child: Container(
                width: width * 0.82,
                height: height * 0.67,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: isRound ? BoxShape.circle : BoxShape.rectangle,
                  borderRadius: isRound
                      ? null
                      : BorderRadius.circular(isGem ? 7 : 12),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color.lerp(color, Colors.white, 0.60)!,
                      color,
                      Color.lerp(color, Colors.black, 0.36)!,
                    ],
                    stops: const [0, 0.58, 1],
                  ),
                  border: Border.all(
                    color: const Color(0xFFFFE79A),
                    width: active ? 2.2 : 1.5,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      offset: Offset(0, 3),
                      blurRadius: 4,
                      color: Color(0x66000000),
                    ),
                  ],
                ),
                child: Transform.rotate(
                  angle: isGem ? -pi / 4 : 0,
                  child: Text(
                    pawn.symbol,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: type == 10 ? width * 0.48 : width * 0.39,
                      height: 1,
                      color: type == 10 ? Colors.white : null,
                      fontWeight: FontWeight.w900,
                      shadows: const [
                        Shadow(
                          offset: Offset(0, 1),
                          blurRadius: 2,
                          color: Color(0x77000000),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: height * 0.09,
            left: width * 0.28,
            child: Container(
              width: width * 0.10,
              height: width * 0.10,
              decoration: const BoxDecoration(
                color: Color(0xCCFFFFFF),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class RingPawnPainter extends CustomPainter {
  const RingPawnPainter({required this.color, required this.active});

  final Color color;
  final bool active;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.40);
    final radius = size.width * 0.34;

    if (active) {
      canvas.drawCircle(
        center,
        radius * 1.35,
        Paint()
          ..color = color.withOpacity(0.30)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
      );
    }

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height * 0.91),
        width: size.width * 0.82,
        height: size.height * 0.15,
      ),
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFFFE79A),
            Color(0xFFD49A22),
            Color(0xFF8A5914),
          ],
        ).createShader(Offset.zero & size),
    );

    canvas.drawCircle(
      center.translate(0, size.height * 0.035),
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.width * 0.23
        ..color = const Color(0xFF875817),
    );

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.width * 0.21
        ..shader = SweepGradient(
          colors: [
            color,
            Color.lerp(color, Colors.white, 0.65)!,
            Color.lerp(color, Colors.black, 0.25)!,
            color,
          ],
        ).createShader(Rect.fromCircle(center: center, radius: radius)),
    );

    canvas.drawCircle(
      center,
      radius * 1.12,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4
        ..color = const Color(0xFFFFE79A),
    );
  }

  @override
  bool shouldRepaint(covariant RingPawnPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.active != active;
  }
}

class ClassicPawnPainter extends CustomPainter {
  const ClassicPawnPainter({required this.color, required this.active});

  final Color color;
  final bool active;

  @override
  void paint(Canvas canvas, Size size) {
    if (active) {
      canvas.drawCircle(
        Offset(size.width / 2, size.height * 0.48),
        size.width * 0.52,
        Paint()
          ..color = color.withOpacity(0.28)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
      );
    }

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height * 0.92),
        width: size.width * 0.84,
        height: size.height * 0.16,
      ),
      Paint()
        ..color = const Color(0x66000000)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );

    final bounds = Offset.zero & size;
    final fill = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color.lerp(color, Colors.white, 0.65)!,
          color,
          Color.lerp(color, Colors.black, 0.42)!,
        ],
      ).createShader(bounds);

    final outline = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = active ? 2.1 : 1.4
      ..color = const Color(0xFFFFE79A);

    final head = Offset(size.width / 2, size.height * 0.22);
    final headRadius = size.width * 0.24;
    canvas.drawCircle(head, headRadius, fill);
    canvas.drawCircle(head, headRadius, outline);

    final body = Path()
      ..moveTo(size.width * 0.39, size.height * 0.42)
      ..quadraticBezierTo(
        size.width * 0.30,
        size.height * 0.61,
        size.width * 0.22,
        size.height * 0.79,
      )
      ..quadraticBezierTo(
        size.width * 0.16,
        size.height * 0.87,
        size.width * 0.28,
        size.height * 0.90,
      )
      ..lineTo(size.width * 0.72, size.height * 0.90)
      ..quadraticBezierTo(
        size.width * 0.84,
        size.height * 0.87,
        size.width * 0.78,
        size.height * 0.79,
      )
      ..quadraticBezierTo(
        size.width * 0.70,
        size.height * 0.61,
        size.width * 0.61,
        size.height * 0.42,
      )
      ..close();

    canvas.drawPath(body, fill);
    canvas.drawPath(body, outline);

    final baseRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height * 0.88),
      width: size.width * 0.72,
      height: size.height * 0.16,
    );
    canvas.drawOval(baseRect, fill);
    canvas.drawOval(baseRect, outline);
  }

  @override
  bool shouldRepaint(covariant ClassicPawnPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.active != active;
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
            ],
          );
        },
      ),
    );
  }
}

'''

source = source[:board_start] + new_pawn_system + source[board_painter_start:]

old_player_data = r'''class PlayerData {
  PlayerData({required this.name, required this.color});

  final String name;
  final Color color;
  int position = 0;
  int correctAnswers = 0;
  int wrongAnswers = 0;
  final Set<int> badges = <int>{};

  bool get hasAllBadges => badges.length == GameCategory.values.length;
}'''

new_player_data = r'''class PlayerData {
  PlayerData({
    required this.name,
    required this.color,
    required this.pawnType,
  });

  final String name;
  final Color color;
  final int pawnType;
  int position = 0;
  int correctAnswers = 0;
  int wrongAnswers = 0;
  final Set<int> badges = <int>{};

  bool get hasAllBadges => badges.length == GameCategory.values.length;
}'''

if old_player_data not in source:
    raise SystemExit('PlayerData modeli bulunamadı.')
source = source.replace(old_player_data, new_player_data, 1)

for marker in [
    'final List<int> _selectedPawnTypes',
    'class PawnCatalog',
    'class PawnToken',
    'required this.pawnType',
    'type: player.pawnType',
    'Renkli Halka',
    'Kupa Rozet',
]:
    if marker not in source:
        raise SystemExit(f'Güncelleme doğrulaması başarısız: {marker}')

MAIN.write_text(source, encoding='utf-8')

pub = PUBSPEC.read_text(encoding='utf-8')
pub = re.sub(
    r'^version:\s*.*$',
    'version: 1.5.0+6',
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
        ['git', 'commit', '-m', '12 piyon secimi ve oyuncu piyonlari'],
        check=True,
    )

subprocess.run(['git', 'push', 'origin', 'main'], check=True)

print('✅ Oyuncu adı yanında piyon seçme alanı eklendi.')
print('✅ 12 farklı piyon seçeneği eklendi.')
print('✅ Seçilen piyon tahtada ve oyuncu panelinde gösterilecek.')
print('✅ Kod GitHub\'a gönderildi; Actions derlemesi başlayacak.')
