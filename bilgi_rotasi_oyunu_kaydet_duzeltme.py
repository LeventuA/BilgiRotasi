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
        "Bu dosyayı BilgiRotasi proje ana klasöründe çalıştır."
    )

source = MAIN.read_text(encoding="utf-8")
shutil.copy2(
    MAIN,
    "/tmp/bilgi_rotasi_kayit_sistemi_oncesi.dart",
)

required = [
    "class HomeScreen extends StatelessWidget",
    "class PlayerSetupScreen extends StatefulWidget",
    "class GameScreen extends StatefulWidget",
    "class _GameScreenState extends State<GameScreen>",
    "void _handleAnswer({",
    "Future<void> _confirmExit() async",
    "class PlayerData {",
]
for marker in required:
    if marker not in source:
        raise SystemExit(f"Beklenen güncel kod bulunamadı: {marker}")

if "package:shared_preferences/shared_preferences.dart" not in source:
    source = source.replace(
        "import 'package:flutter/services.dart';",
        "import 'package:flutter/services.dart';\n"
        "import 'package:shared_preferences/shared_preferences.dart';",
        1,
    )

if "class GameSaveService {" not in source:
    save_code = read_template("oyun_kayit_sistemi.txt") + "\n"

    main_markers = [
        "Future<void> main() async {",
        "void main() {",
    ]
    main_marker = next(
        (marker for marker in main_markers if marker in source),
        None,
    )

    if main_marker is None:
        raise SystemExit("Uygulamanın main() başlangıcı bulunamadı.")

    source = source.replace(
        main_marker,
        save_code + main_marker,
        1,
    )

home_start = source.index("class HomeScreen extends StatelessWidget")
category_start = source.index(
    "class CategoryPill extends StatelessWidget",
    home_start,
)
source = (
    source[:home_start]
    + read_template("kayitli_oyun_ana_ekrani.txt")
    + "\n"
    + source[category_start:]
)

start_method = source.index("  void _startGame() {")
start_method_end_marker = "\n  }\n}\n\nclass GameScreen"
start_method_end = source.index(
    start_method_end_marker,
    start_method,
) + len("\n  }")
source = (
    source[:start_method]
    + read_template("yeni_oyun_baslatma.txt")
    + source[start_method_end:]
)

game_widget_start = source.index("class GameScreen extends StatefulWidget")
game_widget_end = source.index(
    "  @override\n  State<GameScreen>",
    game_widget_start,
)
source = (
    source[:game_widget_start]
    + read_template("game_screen_widget.txt")
    + source[game_widget_end:]
)

getter_start = source.index("  PlayerData get _currentPlayer")
build_start = source.index(
    "  @override\n  Widget build(BuildContext context)",
    getter_start,
)
source = (
    source[:getter_start]
    + read_template("game_screen_init.txt")
    + source[build_start:]
)

old_answer_call = (
    "    _handleAnswer(\n"
    "      correct: correct,\n"
    "      categoryIndex: categoryIndex,\n"
    "      wasBadgeCell: target.isBadge,\n"
    "    );"
)
new_answer_call = (
    "    await _handleAnswer(\n"
    "      correct: correct,\n"
    "      categoryIndex: categoryIndex,\n"
    "      wasBadgeCell: target.isBadge,\n"
    "    );"
)
if old_answer_call not in source:
    raise SystemExit("Cevap işleme çağrısı bulunamadı.")
source = source.replace(old_answer_call, new_answer_call, 1)

ask_start = source.index("  Future<void> _askFinalQuestion() async")
handle_start = source.index("  void _handleAnswer({", ask_start)
source = (
    source[:ask_start]
    + read_template("final_kayit_metodu.txt")
    + source[handle_start:]
)

handle_start = source.index("  void _handleAnswer({")
advance_start = source.index("  void _advanceTurn()", handle_start)
source = (
    source[:handle_start]
    + read_template("cevap_kayit_metodu.txt")
    + source[advance_start:]
)

confirm_start = source.index("  Future<void> _confirmExit() async")
class_end_marker = "\n\n}\n\nenum BoardNodeKind"
confirm_end = source.index(class_end_marker, confirm_start)
source = (
    source[:confirm_start]
    + read_template("kaydet_ve_cik_metodu.txt")
    + source[confirm_end:]
)

for marker in [
    "class GameSaveService {",
    "class HomeScreen extends StatefulWidget",
    "Oyuna Devam Et",
    "initialPlayerIndex",
    "Future<void> _saveGame()",
    "await _saveGame();",
    "Kaydet ve Çık",
    "await GameSaveService.clear();",
]:
    if marker not in source:
        raise SystemExit(f"Kayıt sistemi doğrulaması başarısız: {marker}")

MAIN.write_text(source, encoding="utf-8")

pub = PUBSPEC.read_text(encoding="utf-8")

if "  shared_preferences:" not in pub:
    pub = pub.replace(
        "dependencies:\n",
        "dependencies:\n  shared_preferences: ^2.5.5\n",
        1,
    )

pub = re.sub(
    r"^version:\s*.*$",
    "version: 1.12.0+15",
    pub,
    flags=re.MULTILINE,
)
PUBSPEC.write_text(pub, encoding="utf-8")

if shutil.which("flutter"):
    subprocess.run(["flutter", "pub", "get"], check=True)
elif shutil.which("dart"):
    subprocess.run(["dart", "pub", "get"], check=True)

if shutil.which("dart"):
    subprocess.run(["dart", "format", "lib/main.dart"], check=True)

subprocess.run(["git", "diff", "--check"], check=True)

files_to_add = ["lib/main.dart", "pubspec.yaml"]
if Path("pubspec.lock").exists():
    files_to_add.append("pubspec.lock")

subprocess.run(["git", "add", *files_to_add], check=True)

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
            "Oyunu kaydet ve devam et sistemi",
        ],
        check=True,
    )

subprocess.run(["git", "push", "origin", "main"], check=True)

print("✅ Asenkron main() uyumluluğu düzeltildi.")
print("✅ Oyun otomatik kayıt sistemi eklendi.")
print("✅ Ana menüye Oyuna Devam Et kartı eklendi.")
print("✅ Oyuncular, piyonlar, konumlar ve rozetler kaydedilecek.")
print("✅ Doğru/yanlış istatistikleri ve sıra bilgisi korunacak.")
print("✅ Çıkış ekranına Kaydet ve Çık / Oyunu Sil seçenekleri eklendi.")
print("✅ Şampiyon tamamlanınca eski kayıt otomatik silinecek.")
print("✅ Kod GitHub'a gönderildi; Actions derlemesi başlayacak.")
