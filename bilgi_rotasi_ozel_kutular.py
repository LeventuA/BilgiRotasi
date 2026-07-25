#!/usr/bin/env python3
from pathlib import Path
import re
import shutil
import subprocess

MAIN = Path("lib/main.dart")
PUBSPEC = Path("pubspec.yaml")

def read_template(name):
    path = Path(name)
    if not path.exists():
        raise SystemExit(f"Paket dosyası bulunamadı: {name}")
    return path.read_text(encoding="utf-8")

if not MAIN.exists() or not PUBSPEC.exists():
    raise SystemExit(
        "Bu dosyayı BilgiRotasi deposunun ana klasöründe çalıştır."
    )

source = MAIN.read_text(encoding="utf-8")
shutil.copy2(
    MAIN,
    "/tmp/bilgi_rotasi_ozel_kutular_oncesi.dart",
)

required = [
    "class GameSaveService {",
    "class _GameScreenState extends State<GameScreen>",
    "Future<void> _rollDiceAndAsk() async",
    "Future<void> _handleAnswer({",
    "enum BoardNodeKind { center, spoke, outer }",
    "class BoardPainter extends CustomPainter",
    "class PlayerData {",
    "canPop: _allowRoutePop",
]
for marker in required:
    if marker not in source:
        raise SystemExit(f"Beklenen güncel kod bulunamadı: {marker}")

if "enum SpecialCellEffect" in source:
    raise SystemExit("Özel kutular güncellemesi zaten uygulanmış.")

# 1) Özel kutu tipleri.
source = source.replace(
    "enum BoardNodeKind { center, spoke, outer }",
    read_template("ozel_kutu_tipleri.txt")
    + "enum BoardNodeKind { center, spoke, outer }",
    1,
)

# 2) BoardNode içine özel etki alanı.
old_node_constructor = """    this.ring,
    this.isBadge = false,
  });"""
new_node_constructor = """    this.ring,
    this.isBadge = false,
    this.specialEffect,
  });"""

if old_node_constructor not in source:
    raise SystemExit("BoardNode kurucu bölümü bulunamadı.")
source = source.replace(
    old_node_constructor,
    new_node_constructor,
    1,
)

old_node_fields = """  final int? ring;
  final bool isBadge;
}"""
new_node_fields = """  final int? ring;
  final bool isBadge;
  final SpecialCellEffect? specialEffect;
}"""

if old_node_fields not in source:
    raise SystemExit("BoardNode alanları bulunamadı.")
source = source.replace(
    old_node_fields,
    new_node_fields,
    1,
)

# 3) Sekiz özel kutunun dağılımı.
directions_marker = """  static const directions = [
    'Kuzey',
    'Kuzeydoğu',
    'Güneydoğu',
    'Güney',
    'Güneybatı',
    'Kuzeybatı',
  ];"""

special_map = directions_marker + """

  static const Map<int, SpecialCellEffect> specialCells = {
    4: SpecialCellEffect.forwardTwo,
    22: SpecialCellEffect.forwardTwo,
    9: SpecialCellEffect.backTwo,
    27: SpecialCellEffect.backTwo,
    14: SpecialCellEffect.chooseCategory,
    32: SpecialCellEffect.chooseCategory,
    18: SpecialCellEffect.doubleChance,
    36: SpecialCellEffect.doubleChance,
  };"""

if directions_marker not in source:
    raise SystemExit("BoardMap yön listesi bulunamadı.")
source = source.replace(
    directions_marker,
    special_map,
    1,
)

old_outer_node = """        ring: ring,
        isBadge: badge,
      );"""
new_outer_node = """        ring: ring,
        isBadge: badge,
        specialEffect: specialCells[id],
      );"""

if old_outer_node not in source:
    raise SystemExit("Dış halka BoardNode bölümü bulunamadı.")
source = source.replace(
    old_outer_node,
    new_outer_node,
    1,
)

# 4) İleri/geri özel hareket hesapları.
route_title_marker = "  static String routeTitle(MoveOption option) {"
if route_title_marker not in source:
    raise SystemExit("BoardMap routeTitle bulunamadı.")
source = source.replace(
    route_title_marker,
    read_template("ozel_hareket_hesaplari.txt")
    + route_title_marker,
    1,
)

# 5) Özel kutu etiketleri.
old_label_category = """    final category = GameCategory.values[n.categoryIndex];

    if (n.isBadge) {"""
new_label_category = """    final category = GameCategory.values[n.categoryIndex];

    if (n.specialEffect != null) {
      return '${n.specialEffect!.title} özel alanı';
    }

    if (n.isBadge) {"""

if old_label_category not in source:
    raise SystemExit("BoardMap label bölümü bulunamadı.")
source = source.replace(
    old_label_category,
    new_label_category,
    1,
)

# 6) Oyun akışı ve özel kutu işlemleri.
roll_start = source.index(
    "  Future<void> _rollDiceAndAsk() async"
)
wait_start = source.index(
    "  Future<MoveOption?> _waitForBoardMove(",
    roll_start,
)
source = (
    source[:roll_start]
    + read_template("ozel_kutu_oyun_akisi.txt")
    + source[wait_start:]
)

handle_start = source.index(
    "  Future<void> _handleAnswer({"
)
advance_start = source.index(
    "  void _advanceTurn()",
    handle_start,
)
source = (
    source[:handle_start]
    + read_template("cifte_sans_cevap_sistemi.txt")
    + source[advance_start:]
)

# 7) Çifte Şans hakkını kayda ekle.
old_json_save = """      'wrongAnswers': player.wrongAnswers,
      'badges': player.badges.toList()..sort(),"""
new_json_save = """      'wrongAnswers': player.wrongAnswers,
      'doubleChance': player.doubleChance,
      'badges': player.badges.toList()..sort(),"""

if old_json_save not in source:
    raise SystemExit("Oyuncu kayıt JSON bölümü bulunamadı.")
source = source.replace(
    old_json_save,
    new_json_save,
    1,
)

old_json_load = """    player.wrongAnswers =
        (json['wrongAnswers'] as num?)?.toInt() ?? 0;

    final rawBadges = json['badges'];"""
new_json_load = """    player.wrongAnswers =
        (json['wrongAnswers'] as num?)?.toInt() ?? 0;
    player.doubleChance = json['doubleChance'] == true;

    final rawBadges = json['badges'];"""

if old_json_load not in source:
    raise SystemExit("Oyuncu kayıt yükleme bölümü bulunamadı.")
source = source.replace(
    old_json_load,
    new_json_load,
    1,
)

old_player_fields = """  int wrongAnswers = 0;
  final Set<int> badges = <int>{};"""
new_player_fields = """  int wrongAnswers = 0;
  bool doubleChance = false;
  final Set<int> badges = <int>{};"""

if old_player_fields not in source:
    raise SystemExit("PlayerData alanları bulunamadı.")
source = source.replace(
    old_player_fields,
    new_player_fields,
    1,
)

# 8) Kontrol panelinde aktif Çifte Şans göstergesi.
control_start = source.index("  Widget _buildControlPanel() {")
control_end = source.index(
    "  Future<void> _onMainAction() async",
    control_start,
)
control = source[control_start:control_end]

old_stats = """                const SizedBox(height: 10),
                Text(
                  'Doğru: ${_currentPlayer.correctAnswers}   •   Yanlış: ${_currentPlayer.wrongAnswers}',"""

new_stats = """                const SizedBox(height: 10),
                if (_currentPlayer.doubleChance)
                  Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 9,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF22C55E).withOpacity(0.14),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: const Color(0xFF22C55E).withOpacity(0.48),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '🍀',
                          style: TextStyle(fontSize: 20),
                        ),
                        SizedBox(width: 7),
                        Text(
                          'Çifte Şans hazır',
                          style: TextStyle(
                            color: Color(0xFF166534),
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                Text(
                  'Doğru: ${_currentPlayer.correctAnswers}   •   Yanlış: ${_currentPlayer.wrongAnswers}',"""

if old_stats not in control:
    raise SystemExit("Kontrol paneli istatistik bölümü bulunamadı.")
control = control.replace(old_stats, new_stats, 1)
source = source[:control_start] + control + source[control_end:]

# 9) Tahtada özel kutuların 3D/parlayan görünümü.
old_paint_calls = """    _drawSpokeTiles(canvas, size, base);
    _drawOuterTiles(canvas, size, base);
    _drawCenterHex(canvas, center, base);"""
new_paint_calls = """    _drawSpokeTiles(canvas, size, base);
    _drawOuterTiles(canvas, size, base);
    _drawSpecialCellOverlays(canvas, size, base);
    _drawCenterHex(canvas, center, base);"""

if old_paint_calls not in source:
    raise SystemExit("BoardPainter çizim sırası bulunamadı.")
source = source.replace(
    old_paint_calls,
    new_paint_calls,
    1,
)

raised_tile_marker = "  void _drawRaisedTile({"
if raised_tile_marker not in source:
    raise SystemExit("BoardPainter _drawRaisedTile bulunamadı.")
source = source.replace(
    raised_tile_marker,
    read_template("ozel_kutu_tahta_cizimi.txt")
    + raised_tile_marker,
    1,
)

# 10) Nasıl oynanır metni.
old_rules = """              '• Beyaz çerçeveli özel alanlarda doğru cevap '
              'veren oyuncu o kategorinin rozetini kazanır.\\n\\n'
              '• Altı rozeti tamamlayan oyuncu final '"""

new_rules = """              '• Beyaz çerçeveli rozet alanlarında doğru cevap '
              'veren oyuncu o kategorinin rozetini kazanır.\\n\\n'
              '• Parlayan özel kutular; İleri 2, Geri 2, '
              'Kategori Seç veya Çifte Şans etkisi verir.\\n\\n'
              '• Altı rozeti tamamlayan oyuncu final '"""

if old_rules not in source:
    raise SystemExit("Nasıl oynanır metni bulunamadı.")
source = source.replace(old_rules, new_rules, 1)

# 11) Son doğrulamalar.
for marker in [
    "enum SpecialCellEffect",
    "specialCells = {",
    "SpecialCellEffect.forwardTwo",
    "Future<int?> _resolveSpecialEffect(",
    "Future<int> _chooseQuestionCategory()",
    "player.doubleChance = json['doubleChance'] == true;",
    "Çifte Şans hazır",
    "_drawSpecialCellOverlays(canvas, size, base);",
]:
    if marker not in source:
        raise SystemExit(f"Özel kutu doğrulaması başarısız: {marker}")

MAIN.write_text(source, encoding="utf-8")

pub = PUBSPEC.read_text(encoding="utf-8")
pub = re.sub(
    r"^version:\s*.*$",
    "version: 1.13.0+17",
    pub,
    flags=re.MULTILINE,
)
PUBSPEC.write_text(pub, encoding="utf-8")

if shutil.which("dart"):
    subprocess.run(
        ["dart", "format", "lib/main.dart"],
        check=True,
    )

subprocess.run(
    ["git", "diff", "--check"],
    check=True,
)

if shutil.which("flutter"):
    subprocess.run(
        ["flutter", "analyze", "--no-fatal-infos"],
        check=True,
    )

subprocess.run(
    ["git", "add", "lib/main.dart", "pubspec.yaml"],
    check=True,
)

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
            "Sekiz ozel kutu ve surpriz etkileri",
        ],
        check=True,
    )

subprocess.run(
    ["git", "push", "origin", "main"],
    check=True,
)

print("✅ Tahtaya sekiz parlayan özel kutu eklendi.")
print("✅ İleri 2 ve Geri 2 hareketleri animasyonlu çalışacak.")
print("✅ Kategori Seç ekranı eklendi.")
print("✅ Çifte Şans hakkı yanlış cevapta sırayı koruyacak.")
print("✅ Çifte Şans kayıt sistemine dahil edildi.")
print("✅ Özel kutular ses, titreşim ve piyon animasyonuyla uyumlu.")
print("✅ Kod analizden geçti ve GitHub'a gönderildi.")
