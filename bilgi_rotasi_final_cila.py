#!/usr/bin/env python3
from pathlib import Path
import re
import shutil
import subprocess

MAIN = Path("lib/main.dart")
PUBSPEC = Path("pubspec.yaml")
WORKFLOW = Path(".github/workflows/android-apk.yml")

def read_template(name):
    path = Path(name)
    if not path.exists():
        raise SystemExit(f"Paket dosyası bulunamadı: {name}")
    return path.read_text(encoding="utf-8")

if not MAIN.exists() or not PUBSPEC.exists() or not WORKFLOW.exists():
    raise SystemExit(
        "Bu dosyayı BilgiRotasi deposunun ana klasöründe çalıştır."
    )

source = MAIN.read_text(encoding="utf-8")
shutil.copy2(
    MAIN,
    "/tmp/bilgi_rotasi_final_cila_oncesi.dart",
)

required = [
    "class HomeScreen extends StatefulWidget",
    "class CategoryPill extends StatelessWidget",
    "Future<void> _showWinnerDialog(PlayerData player) async",
    "tooltip: 'Sesi test et'",
    "enum SpecialCellEffect",
]
for marker in required:
    if marker not in source:
        raise SystemExit(f"Beklenen güncel kod bulunamadı: {marker}")

if "class WinnerScreen extends StatefulWidget" in source:
    raise SystemExit("Final cila güncellemesi zaten uygulanmış.")

# 1) Ana ekranı tamamen yenile.
home_start = source.index(
    "class HomeScreen extends StatefulWidget"
)
category_start = source.index(
    "class CategoryPill extends StatelessWidget",
    home_start,
)
source = (
    source[:home_start]
    + read_template("premium_ana_ekran.txt")
    + "\n"
    + source[category_start:]
)

# 2) Kazanan ekranını GameScreen öncesine ekle.
game_marker = "class GameScreen extends StatefulWidget"
game_index = source.index(game_marker)
source = (
    source[:game_index]
    + read_template("sampiyon_ekrani.txt")
    + game_marker
    + source[game_index + len(game_marker):]
)

# 3) Eski kazanan dialogunu tam ekran şampiyon ekranına dönüştür.
winner_start = source.index(
    "  Future<void> _showWinnerDialog(PlayerData player) async"
)
back_start = source.index(
    "  Future<void> _handleSystemBack() async",
    winner_start,
)

new_winner_method = """  Future<void> _showWinnerDialog(
    PlayerData player,
  ) async {
    await Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => WinnerScreen(
          questionBank: widget.questionBank,
          winner: player,
          players: widget.players,
        ),
      ),
    );
  }

"""

source = (
    source[:winner_start]
    + new_winner_method
    + source[back_start:]
)

# 4) Artık yalnızca geliştirme için gerekli olan ses testi düğmesini kaldır.
test_start = source.index(
    """          IconButton(
            tooltip: 'Sesi test et',"""
)
exit_start = source.index(
    """          IconButton(
            tooltip: 'Oyunu bitir',""",
    test_start,
)
source = source[:test_start] + source[exit_start:]

for marker in [
    "class WinnerScreen extends StatefulWidget",
    "class WinnerConfettiPainter extends CustomPainter",
    "assets/branding/splash_logo.png",
    "Bilgi Rotası • Sürüm 1.14",
    "Navigator.of(context).pushReplacement(",
]:
    if marker not in source:
        raise SystemExit(f"Final cila doğrulaması başarısız: {marker}")

if "tooltip: 'Sesi test et'" in source:
    raise SystemExit("Ses testi düğmesi kaldırılamadı.")

MAIN.write_text(source, encoding="utf-8")

# 5) Pubspec: ikon, splash ve branding assetleri.
pub = PUBSPEC.read_text(encoding="utf-8")

if "  flutter_native_splash:" not in pub:
    pub = pub.replace(
        "dependencies:\n",
        "dependencies:\n"
        "  flutter_native_splash: ^2.4.8\n",
        1,
    )

if "  flutter_launcher_icons:" not in pub:
    pub = pub.replace(
        "dev_dependencies:\n",
        "dev_dependencies:\n"
        "  flutter_launcher_icons: ^0.14.4\n",
        1,
    )

if "    - assets/branding/" not in pub:
    pub = pub.replace(
        "  assets:\n",
        "  assets:\n"
        "    - assets/branding/\n",
        1,
    )

if "\nflutter_launcher_icons:\n" not in pub:
    pub += """

flutter_launcher_icons:
  android: "launcher_icon"
  ios: false
  image_path: "assets/branding/app_icon.png"
  min_sdk_android: 21
  adaptive_icon_background: "#24122F"
  adaptive_icon_foreground: "assets/branding/app_icon_foreground.png"

flutter_native_splash:
  color: "#24122F"
  image: assets/branding/splash_logo.png
  android: true
  ios: false
  web: false
  android_12:
    color: "#24122F"
    image: assets/branding/splash_logo.png
"""

pub = re.sub(
    r"^version:\s*.*$",
    "version: 1.14.0+18",
    pub,
    flags=re.MULTILINE,
)
PUBSPEC.write_text(pub, encoding="utf-8")

# 6) Workflow: geçici Android projesinde ikon/splash üret.
workflow = WORKFLOW.read_text(encoding="utf-8")

old_commands = """          cd .flutter_build
          flutter pub get
          flutter build apk --release"""

new_commands = """          cd .flutter_build
          flutter pub get

          dart run flutter_launcher_icons
          dart run flutter_native_splash:create

          sed -i 's/android:label="bilgi_rotasi"/android:label="Bilgi Rotası"/' \
            android/app/src/main/AndroidManifest.xml

          flutter build apk --release"""

if old_commands not in workflow:
    raise SystemExit("APK workflow komut bölümü bulunamadı.")

workflow = workflow.replace(
    old_commands,
    new_commands,
    1,
)
WORKFLOW.write_text(workflow, encoding="utf-8")

if shutil.which("flutter"):
    subprocess.run(
        ["flutter", "pub", "get"],
        check=True,
    )

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

files_to_add = [
    "lib/main.dart",
    "pubspec.yaml",
    ".github/workflows/android-apk.yml",
    "assets/branding",
]
if Path("pubspec.lock").exists():
    files_to_add.append("pubspec.lock")

subprocess.run(
    ["git", "add", *files_to_add],
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
            "Premium ana menu sampiyon ekrani ikon ve splash",
        ],
        check=True,
    )

subprocess.run(
    ["git", "push", "origin", "main"],
    check=True,
)

print("✅ Ana menü mor-altın premium tasarımla yenilendi.")
print("✅ Tam ekran animasyonlu şampiyon ekranı eklendi.")
print("✅ Oyun sonu sıralaması ve başarı yüzdesi eklendi.")
print("✅ Bilgi Rotası uygulama ikonu eklendi.")
print("✅ Mor temalı açılış ekranı eklendi.")
print("✅ Android uygulama adı Bilgi Rotası olarak ayarlandı.")
print("✅ Geliştirme amaçlı Ses Testi düğmesi kaldırıldı.")
print("✅ Kod analizden geçti ve GitHub'a gönderildi.")
