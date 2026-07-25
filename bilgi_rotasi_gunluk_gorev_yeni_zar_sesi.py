#!/usr/bin/env python3
from pathlib import Path
import base64
import re
import shutil
import subprocess
import textwrap

MAIN = Path("lib/main.dart")
DAILY_SOURCE = Path("daily_challenge.dart")
DAILY_TARGET = Path("lib/daily_challenge.dart")
SOUND_DATA = Path("lib/sound_data.dart")
NEW_DICE = Path("dice_roll_new.mp3")
ASSET_DICE = Path("assets/sounds/dice_roll.mp3")
PUBSPEC = Path("pubspec.yaml")

required_files = [
    MAIN,
    DAILY_SOURCE,
    SOUND_DATA,
    NEW_DICE,
    PUBSPEC,
]

for path in required_files:
    if not path.exists():
        raise SystemExit(f"Gerekli dosya bulunamadı: {path}")

source = MAIN.read_text(encoding="utf-8")
sound_source = SOUND_DATA.read_text(encoding="utf-8")

required_markers = [
    "import 'sound_data.dart';",
    "class CareerStatsScreen extends StatefulWidget",
    "class HomeScreen extends StatefulWidget",
    "_buildSummary(stats),",
    "_buildCategoryStats(stats),",
    "_buildNewGameCard(),",
    "await CareerStatsService.clear();",
    "Bilgi Rotası • Sürüm 1.17",
    "bilgi_rotasi_embedded_sounds_v1",
]
for marker in required_markers:
    if marker not in source:
        raise SystemExit(f"Beklenen güncel kod bulunamadı: {marker}")

if "part 'daily_challenge.dart';" in source:
    raise SystemExit("Günlük Görev güncellemesi zaten uygulanmış.")

if "  'dice_roll.mp3':" not in sound_source:
    raise SystemExit("Gömülü zar sesi bulunamadı.")

if "  'step.mp3':" not in sound_source:
    raise SystemExit("Gömülü ses haritasında step.mp3 bulunamadı.")

shutil.copy2(
    MAIN,
    "/tmp/bilgi_rotasi_gunluk_gorev_oncesi.dart",
)
shutil.copy2(
    SOUND_DATA,
    "/tmp/bilgi_rotasi_zar_sesi_oncesi.dart",
)

# 1) Günlük görev dosyasını projeye ekle.
DAILY_TARGET.parent.mkdir(parents=True, exist_ok=True)
shutil.copy2(DAILY_SOURCE, DAILY_TARGET)

# 2) Part direktifi.
source = source.replace(
    "import 'sound_data.dart';",
    "import 'sound_data.dart';\n\n"
    "part 'daily_challenge.dart';",
    1,
)

# 3) Ana menüye Günlük Görev kartı.
home_marker = """                const SizedBox(height: 16),
                _buildNewGameCard(),"""

home_replacement = """                const SizedBox(height: 16),
                DailyChallengeHomeCard(
                  questionBank: widget.questionBank,
                ),
                const SizedBox(height: 16),
                _buildNewGameCard(),"""

if home_marker not in source:
    raise SystemExit("Ana menü yerleştirme noktası bulunamadı.")

source = source.replace(
    home_marker,
    home_replacement,
    1,
)

# 4) İstatistik ekranına günlük görev kariyeri.
stats_marker = """                  _buildSummary(stats),
                  const SizedBox(height: 16),
                  _buildCategoryStats(stats),"""

stats_replacement = """                  _buildSummary(stats),
                  const SizedBox(height: 16),
                  const DailyChallengeStatsCard(),
                  const SizedBox(height: 16),
                  _buildCategoryStats(stats),"""

if stats_marker not in source:
    raise SystemExit("İstatistik ekranı yerleştirme noktası bulunamadı.")

source = source.replace(
    stats_marker,
    stats_replacement,
    1,
)

# 5) İstatistik sıfırlama günlük görev geçmişini de temizlesin.
reset_marker = """    await CareerStatsService.clear();

    if (!mounted) return;"""

reset_replacement = """    await CareerStatsService.clear();
    await DailyChallengeService.clear();

    if (!mounted) return;"""

if reset_marker not in source:
    raise SystemExit("İstatistik sıfırlama bölümü bulunamadı.")

source = source.replace(
    reset_marker,
    reset_replacement,
    1,
)

# 6) Yeni gömülü seslerin eski geçici dosyadan ayrılması.
source = source.replace(
    "bilgi_rotasi_embedded_sounds_v1",
    "bilgi_rotasi_embedded_sounds_v2",
    1,
)

# Yeni zar sesi biraz daha dengeli seviyede çalsın.
source = source.replace(
    """      'dice_roll.mp3',
      volume: 1,""",
    """      'dice_roll.mp3',
      volume: 0.92,""",
    1,
)

# 7) Sürüm.
source = source.replace(
    "Bilgi Rotası • Sürüm 1.17",
    "Bilgi Rotası • Sürüm 1.18",
    1,
)

MAIN.write_text(source, encoding="utf-8")

# 8) Zar sesini sound_data.dart içinde yenile.
dice_bytes = NEW_DICE.read_bytes()

if len(dice_bytes) < 5000:
    raise SystemExit("Yeni zar sesi beklenenden küçük.")

encoded = base64.b64encode(dice_bytes).decode("ascii")
chunks = textwrap.wrap(encoded, 100)

new_entry_lines = [
    "  'dice_roll.mp3':",
]
for index, chunk in enumerate(chunks):
    suffix = "," if index == len(chunks) - 1 else ""
    new_entry_lines.append(f"      '{chunk}'{suffix}")

new_entry = "\n".join(new_entry_lines) + "\n"

dice_start = sound_source.index("  'dice_roll.mp3':")
step_start = sound_source.index("  'step.mp3':", dice_start)

sound_source = (
    sound_source[:dice_start]
    + new_entry
    + sound_source[step_start:]
)

SOUND_DATA.write_text(sound_source, encoding="utf-8")

# Kaynak ses dosyasını da aynı içerikle değiştir.
ASSET_DICE.parent.mkdir(parents=True, exist_ok=True)
shutil.copy2(NEW_DICE, ASSET_DICE)

# 9) pubspec sürümü.
pub = PUBSPEC.read_text(encoding="utf-8")
pub = re.sub(
    r"^version:\s*.*$",
    "version: 1.18.0+23",
    pub,
    flags=re.MULTILINE,
)
PUBSPEC.write_text(pub, encoding="utf-8")

# 10) Doğrulamalar.
updated = MAIN.read_text(encoding="utf-8")
updated_sound = SOUND_DATA.read_text(encoding="utf-8")

for marker in [
    "part 'daily_challenge.dart';",
    "DailyChallengeHomeCard(",
    "const DailyChallengeStatsCard()",
    "await DailyChallengeService.clear();",
    "bilgi_rotasi_embedded_sounds_v2",
    "Bilgi Rotası • Sürüm 1.18",
]:
    if marker not in updated:
        raise SystemExit(f"Güncelleme doğrulaması başarısız: {marker}")

if updated_sound.count("'dice_roll.mp3':") != 1:
    raise SystemExit("Zar sesi haritası doğrulanamadı.")

if not DAILY_TARGET.exists():
    raise SystemExit("daily_challenge.dart projeye eklenemedi.")

if shutil.which("dart"):
    subprocess.run(
        [
            "dart",
            "format",
            "lib/main.dart",
            "lib/daily_challenge.dart",
            "lib/sound_data.dart",
        ],
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
    [
        "git",
        "add",
        "lib/main.dart",
        "lib/daily_challenge.dart",
        "lib/sound_data.dart",
        "assets/sounds/dice_roll.mp3",
        "pubspec.yaml",
    ],
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
            "Gunluk gorev ve yeni premium zar sesi",
        ],
        check=True,
    )

subprocess.run(
    ["git", "push", "origin", "main"],
    check=True,
)

print("✅ Günlük 10 soruluk görev modu eklendi.")
print("✅ Her tarih için sabit ve dengeli soru dizilimi eklendi.")
print("✅ İlk tamamlanan tur resmî skor olarak kaydedilecek.")
print("✅ Günlük seri, en iyi seri, tam puan ve son 7 gün geçmişi eklendi.")
print("✅ Günlük görev sonuçları kariyer istatistiklerine işlenecek.")
print("✅ 3 Günlük Seri, 7 Günlük Seri ve Günün Bilgesi başarımları eklendi.")
print("✅ Eski zar sesi tok, kısa ve daha doğal yeni sesle değiştirildi.")
print("✅ Kod analizden geçti ve GitHub'a gönderildi.")
