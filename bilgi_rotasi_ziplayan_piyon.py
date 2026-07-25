#!/usr/bin/env python3
from pathlib import Path
import re
import shutil
import subprocess

MAIN = Path("lib/main.dart")
PUBSPEC = Path("pubspec.yaml")
TEMPLATE = Path("piyon_animasyon_sistemi.txt")

if not MAIN.exists() or not PUBSPEC.exists() or not TEMPLATE.exists():
    raise SystemExit(
        "Dosyaları BilgiRotasi proje ana klasöründe çalıştır."
    )

source = MAIN.read_text(encoding="utf-8")
shutil.copy2(MAIN, "/tmp/bilgi_rotasi_ziplayan_piyon_oncesi.dart")

required = [
    "class _GameScreenState extends State<GameScreen>",
    "class PawnToken extends StatelessWidget",
    "class GameBoard extends StatelessWidget",
    "class BoardPainter extends CustomPainter",
    "class PlayerData {",
    "final pawnWidth = active ? base * 0.082 : base * 0.072;",
]
for marker in required:
    if marker not in source:
        raise SystemExit(f"Beklenen güncel kod bulunamadı: {marker}")

old_fields = """  List<MoveOption> _moveOptions = const <MoveOption>[];
  Completer<MoveOption>? _moveCompleter;"""

new_fields = """  List<MoveOption> _moveOptions = const <MoveOption>[];
  Completer<MoveOption>? _moveCompleter;
  MoveOption? _activeMove;
  double _routeOpacity = 0;
  int? _landingNodeId;
  int _landingPulse = 0;"""

if old_fields not in source:
    raise SystemExit("Oyun animasyon alanlarının ekleneceği bölüm bulunamadı.")
source = source.replace(old_fields, new_fields, 1)

old_board_call = """                      moveOptions: _moveOptions,
                      onMoveSelected: _selectMoveFromBoard,"""

new_board_call = """                      moveOptions: _moveOptions,
                      onMoveSelected: _selectMoveFromBoard,
                      activeMove: _activeMove,
                      routeOpacity: _routeOpacity,
                      landingNodeId: _landingNodeId,
                      landingPulse: _landingPulse,"""

if old_board_call not in source:
    raise SystemExit("GameBoard çağrısı bulunamadı.")
source = source.replace(old_board_call, new_board_call, 1)

old_movement = """    for (final id in selected.path.skip(1)) {
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
    });"""

new_movement = """    setState(() {
      _activeMove = selected;
      _routeOpacity = 1;
      _landingNodeId = null;
      _status = '${_currentPlayer.name} rotada ilerliyor…';
    });

    for (final id in selected.path.skip(1)) {
      setState(() {
        _currentPlayer.position = id;
        _currentPlayer.movePulse++;
      });
      HapticFeedback.selectionClick();
      await Future<void>.delayed(const Duration(milliseconds: 390));
      if (!mounted) return;
    }

    final target = BoardMap.node(_currentPlayer.position);
    final categoryIndex = target.categoryIndex < 0
        ? _random.nextInt(GameCategory.values.length)
        : target.categoryIndex;

    setState(() {
      _landingNodeId = _currentPlayer.position;
      _landingPulse++;
      _routeOpacity = 0;
      _status =
          '${_currentPlayer.name}, ${BoardMap.label(target.id)} alanına geldi.';
    });

    HapticFeedback.heavyImpact();
    await Future<void>.delayed(const Duration(milliseconds: 520));

    if (!mounted) return;

    setState(() {
      _activeMove = null;
      _landingNodeId = null;
    });"""

if old_movement not in source:
    raise SystemExit("Eski piyon hareket döngüsü bulunamadı.")
source = source.replace(old_movement, new_movement, 1)

insert_before = "class GameBoard extends StatelessWidget {"
if insert_before not in source:
    raise SystemExit("GameBoard başlangıcı bulunamadı.")

template = TEMPLATE.read_text(encoding="utf-8")
source = source.replace(insert_before, template + insert_before, 1)

old_constructor = """  const GameBoard({
    required this.players,
    required this.currentPlayerIndex,
    this.moveOptions = const <MoveOption>[],
    this.onMoveSelected,
    super.key,
  });

  final List<PlayerData> players;
  final int currentPlayerIndex;
  final List<MoveOption> moveOptions;
  final ValueChanged<MoveOption>? onMoveSelected;"""

new_constructor = """  const GameBoard({
    required this.players,
    required this.currentPlayerIndex,
    this.moveOptions = const <MoveOption>[],
    this.onMoveSelected,
    this.activeMove,
    this.routeOpacity = 0,
    this.landingNodeId,
    this.landingPulse = 0,
    super.key,
  });

  final List<PlayerData> players;
  final int currentPlayerIndex;
  final List<MoveOption> moveOptions;
  final ValueChanged<MoveOption>? onMoveSelected;
  final MoveOption? activeMove;
  final double routeOpacity;
  final int? landingNodeId;
  final int landingPulse;"""

if old_constructor not in source:
    raise SystemExit("GameBoard kurucu bölümü bulunamadı.")
source = source.replace(old_constructor, new_constructor, 1)

old_geometry = """          final base = BoardMap.base(size);
          final boardCenter = BoardMap.center(size);

          return Stack("""

new_geometry = """          final base = BoardMap.base(size);
          final boardCenter = BoardMap.center(size);
          final landingPoint = landingNodeId == null
              ? null
              : BoardMap.position(size, landingNodeId!);
          final landingNode = landingNodeId == null
              ? null
              : BoardMap.node(landingNodeId!);
          final landingColor =
              landingNode == null || landingNode.categoryIndex < 0
                  ? const Color(0xFF67E8F9)
                  : GameCategory.values[landingNode.categoryIndex].color;
          final landingSize = base * 0.17;

          return Stack("""

if old_geometry not in source:
    raise SystemExit("GameBoard geometri bölümü bulunamadı.")
source = source.replace(old_geometry, new_geometry, 1)

old_route_overlay = """              if (moveOptions.isNotEmpty)
                Positioned.fill(
                  child: IgnorePointer(
                    child: CustomPaint(
                      painter: RouteHighlightPainter(
                        options: moveOptions,
                      ),
                    ),
                  ),
                ),
              ...List.generate(players.length, (index) {"""

new_route_overlay = """              if (moveOptions.isNotEmpty)
                Positioned.fill(
                  child: IgnorePointer(
                    child: CustomPaint(
                      painter: RouteHighlightPainter(
                        options: moveOptions,
                      ),
                    ),
                  ),
                ),
              if (activeMove != null)
                Positioned.fill(
                  child: IgnorePointer(
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 520),
                      curve: Curves.easeOut,
                      opacity: routeOpacity,
                      child: CustomPaint(
                        painter: RouteHighlightPainter(
                          options: <MoveOption>[activeMove!],
                        ),
                      ),
                    ),
                  ),
                ),
              ...List.generate(players.length, (index) {"""

if old_route_overlay not in source:
    raise SystemExit("Rota çizim bölümü bulunamadı.")
source = source.replace(old_route_overlay, new_route_overlay, 1)

old_pawn_child = """                  child: PawnToken(
                    type: player.pawnType,
                    color: player.color,
                    active: active,
                    width: pawnWidth,
                    height: pawnHeight,
                  ),"""

new_pawn_child = """                  child: JumpingPawn(
                    key: ValueKey<String>('pawn-$index'),
                    type: player.pawnType,
                    color: player.color,
                    active: active,
                    width: pawnWidth,
                    height: pawnHeight,
                    movePulse: player.movePulse,
                  ),"""

if old_pawn_child not in source:
    raise SystemExit("Tahtadaki PawnToken çağrısı bulunamadı.")
source = source.replace(old_pawn_child, new_pawn_child, 1)

old_targets_start = """              }),
              ...moveOptions.map((option) {"""

new_targets_start = """              }),
              if (landingPoint != null)
                Positioned(
                  left: landingPoint.dx - landingSize / 2,
                  top: landingPoint.dy - landingSize / 2,
                  child: LandingBurst(
                    key: ValueKey<int>(landingPulse),
                    color: landingColor,
                    size: landingSize,
                  ),
                ),
              ...moveOptions.map((option) {"""

if old_targets_start not in source:
    raise SystemExit("İniş efektinin ekleneceği bölüm bulunamadı.")
source = source.replace(old_targets_start, new_targets_start, 1)

old_player_fields = """  final int pawnType;
  int position = 0;
  int correctAnswers = 0;"""

new_player_fields = """  final int pawnType;
  int position = 0;
  int movePulse = 0;
  int correctAnswers = 0;"""

if old_player_fields not in source:
    raise SystemExit("PlayerData alanları bulunamadı.")
source = source.replace(old_player_fields, new_player_fields, 1)

for marker in [
    "class JumpingPawn extends StatefulWidget",
    "class LandingBurst extends StatefulWidget",
    "MoveOption? _activeMove;",
    "int movePulse = 0;",
    "movePulse: player.movePulse",
    "scaleX: shadowScale",
    "duration: const Duration(milliseconds: 390)",
    "await Future<void>.delayed(const Duration(milliseconds: 520));",
]:
    if marker not in source:
        raise SystemExit(f"Güncelleme doğrulaması başarısız: {marker}")

MAIN.write_text(source, encoding="utf-8")

pub = PUBSPEC.read_text(encoding="utf-8")
pub = re.sub(
    r"^version:\s*.*$",
    "version: 1.10.0+11",
    pub,
    flags=re.MULTILINE,
)
PUBSPEC.write_text(pub, encoding="utf-8")

if shutil.which("dart"):
    subprocess.run(["dart", "format", "lib/main.dart"], check=True)

subprocess.run(["git", "diff", "--check"], check=True)
subprocess.run(["git", "add", "lib/main.dart", "pubspec.yaml"], check=True)

changed = subprocess.run(
    ["git", "diff", "--cached", "--quiet"],
    check=False,
).returncode != 0

if changed:
    subprocess.run(
        ["git", "commit", "-m", "Piyon ziplama ve inis animasyonu"],
        check=True,
    )

subprocess.run(["git", "push", "origin", "main"], check=True)

print("✅ Piyonlar her kareye zıplayarak ilerleyecek.")
print("✅ Havaya çıkarken zemin gölgesi küçülecek.")
print("✅ İnerken hafif esneme efekti uygulanacak.")
print("✅ Son karede ışık halkası ve parçacık patlaması çıkacak.")
print("✅ Seçilen rota hareket boyunca görünüp inişte yavaşça sönecek.")
print("✅ Soru ekranı bütün animasyonlar bittikten sonra açılacak.")
print("✅ Kod GitHub'a gönderildi; Actions derlemesi başlayacak.")
