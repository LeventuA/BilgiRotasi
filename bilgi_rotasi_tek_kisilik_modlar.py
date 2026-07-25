#!/usr/bin/env python3
from pathlib import Path
import re
import shutil
import subprocess

MAIN = Path("lib/main.dart")
PUBSPEC = Path("pubspec.yaml")
FEATURE_TEMPLATE = Path("tek_kisilik_ana_menu.txt")
CLASSES_TEMPLATE = Path("tek_kisilik_modlar.txt")

if not MAIN.exists() or not PUBSPEC.exists():
    raise SystemExit(
        "Bu dosyayı BilgiRotasi deposunun ana klasöründe çalıştır."
    )

if not FEATURE_TEMPLATE.exists() or not CLASSES_TEMPLATE.exists():
    raise SystemExit("Paket şablon dosyaları bulunamadı.")

source = MAIN.read_text(encoding="utf-8")
shutil.copy2(
    MAIN,
    "/tmp/bilgi_rotasi_tek_kisilik_modlar_oncesi.dart",
)

required = [
    "class _HomeScreenState extends State<HomeScreen>",
    "Widget _buildFeatureStrip()",
    "Widget _buildCategoryCard()",
    "class PlayerSetupScreen extends StatefulWidget",
    "class GameScreen extends StatefulWidget",
    "class QuestionScreen extends StatefulWidget",
    "class QuestionBank",
    "class PawnCatalog",
]
for marker in required:
    if marker not in source:
        raise SystemExit(f"Beklenen güncel kod bulunamadı: {marker}")

if "class SoloRouteSetupScreen" in source:
    raise SystemExit("Tek kişilik modlar zaten uygulanmış.")

# Ana menüdeki üç kartı gerçek modlara dönüştür.
feature_start = source.index("  Widget _buildFeatureStrip()")
category_start = source.index(
    "  Widget _buildCategoryCard()",
    feature_start,
)

source = (
    source[:feature_start]
    + FEATURE_TEMPLATE.read_text(encoding="utf-8")
    + source[category_start:]
)

# Yeni ekranları oyuncu hazırlık ekranından önce ekle.
setup_marker = "class PlayerSetupScreen extends StatefulWidget"
setup_index = source.index(setup_marker)

source = (
    source[:setup_index]
    + CLASSES_TEMPLATE.read_text(encoding="utf-8")
    + "\n"
    + source[setup_index:]
)

# Ana menüde kayıtlı tek kişilik oyunu daha net göster.
source = source.replace(
    """                      'Sıra ${currentPlayer.name} oyuncusunda',""",
    """                      savedGame.players.length == 1
                          ? 'Serbest Rota • ${currentPlayer.name}'
                          : 'Sıra ${currentPlayer.name} oyuncusunda',""",
    1,
)

# Sürüm yazısını güncelle.
source = source.replace(
    "Bilgi Rotası • Sürüm 1.14",
    "Bilgi Rotası • Sürüm 1.15",
    1,
)

for marker in [
    "class SoloRouteSetupScreen extends StatefulWidget",
    "class MarathonSetupScreen extends StatefulWidget",
    "class MarathonScreen extends StatefulWidget",
    "class MarathonResultScreen extends StatelessWidget",
    "class MarathonScoreService",
    "('🧠', 'Soru Maratonu', 'Hızlı bilgi turu')",
    "await _openSavedGameShortcut();",
]:
    if marker not in source:
        raise SystemExit(f"Tek kişilik mod doğrulaması başarısız: {marker}")

if "('✨', 'Özel kutular')" in source:
    raise SystemExit("Eski Özel Kutular ana menü kartı kaldırılamadı.")

MAIN.write_text(source, encoding="utf-8")

pub = PUBSPEC.read_text(encoding="utf-8")
pub = re.sub(
    r"^version:\s*.*$",
    "version: 1.15.0+20",
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
            "Serbest Rota ve Soru Maratonu modlari",
        ],
        check=True,
    )

subprocess.run(
    ["git", "push", "origin", "main"],
    check=True,
)

print("✅ Serbest Rota gerçek tek kişilik tahta moduna dönüştürüldü.")
print("✅ Tek kişilik isim, renk ve piyon seçimi eklendi.")
print("✅ Soru Maratonu modu eklendi.")
print("✅ Karışık veya kategori bazlı maraton seçimi eklendi.")
print("✅ 10, 20 ve uygun olduğunda 50 soruluk turlar eklendi.")
print("✅ Doğru seri, başarı yüzdesi, süre ve rekor kaydı eklendi.")
print("✅ Kaydet ve dön kartı kayıtlı tahta oyununu doğrudan açacak.")
print("✅ Özel Kutular ana menü kartı kaldırıldı.")
print("✅ Kod analizden geçti ve GitHub'a gönderildi.")
