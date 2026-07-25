#!/usr/bin/env python3
from pathlib import Path
import base64
import hashlib
import re
import shutil
import subprocess
import textwrap

MAIN = Path("lib/main.dart")
SOUND_DATA = Path("lib/sound_data.dart")
PUBSPEC = Path("pubspec.yaml")
SOURCE_SOUND = Path("dice_roll_user_selected.mp3")
ASSET_SOUND = Path("assets/sounds/dice_roll.mp3")

EXPECTED_SHA256 = "39e4098fcf5871dbb0ded196d6f0f2dfd5b195c1742bcbff830830037eaa1819"

for path in [MAIN, SOUND_DATA, PUBSPEC, SOURCE_SOUND]:
    if not path.exists():
        raise SystemExit(
            f"Gerekli dosya bulunamadı: {path}\n"
            "Bu betiği BilgiRotasi deposunun ana klasöründe çalıştır."
        )

sound_bytes = SOURCE_SOUND.read_bytes()
actual_sha = hashlib.sha256(sound_bytes).hexdigest()

if actual_sha != EXPECTED_SHA256:
    raise SystemExit(
        "Zar sesi dosyası değişmiş veya bozulmuş. "
        "Paketi yeniden yükle."
    )

main_source = MAIN.read_text(encoding="utf-8")
sound_source = SOUND_DATA.read_text(encoding="utf-8")
pubspec_source = PUBSPEC.read_text(encoding="utf-8")

if "  'dice_roll.mp3':" not in sound_source:
    raise SystemExit("Gömülü dice_roll.mp3 kaydı bulunamadı.")

if "  'step.mp3':" not in sound_source:
    raise SystemExit("Ses haritasında step.mp3 sınırı bulunamadı.")

# Güvenli yedekler
shutil.copy2(
    MAIN,
    "/tmp/bilgi_rotasi_main_kullanici_zar_sesi_oncesi.dart",
)
shutil.copy2(
    SOUND_DATA,
    "/tmp/bilgi_rotasi_sound_data_kullanici_zar_sesi_oncesi.dart",
)
if ASSET_SOUND.exists():
    shutil.copy2(
        ASSET_SOUND,
        "/tmp/bilgi_rotasi_dice_roll_kullanici_sesi_oncesi.mp3",
    )

# Eski gömülü ses önbelleğini kesin olarak aş.
cache_pattern = re.compile(
    r"bilgi_rotasi_embedded_sounds_[A-Za-z0-9_]+"
)

if not cache_pattern.search(main_source):
    raise SystemExit("Gömülü ses önbelleği yolu main.dart içinde bulunamadı.")

main_source = cache_pattern.sub(
    "bilgi_rotasi_embedded_sounds_user_dice_95077",
    main_source,
    count=1,
)

# Zar sesini tam ses seviyesinde çal.
main_source = re.sub(
    r"('dice_roll\.mp3',\s*\n\s*volume:\s*)[0-9.]+",
    r"\g<1>1.0",
    main_source,
    count=1,
)

MAIN.write_text(main_source, encoding="utf-8")

# Kullanıcının seçtiği MP3'ü değiştirmeden Base64 haritasına göm.
encoded = base64.b64encode(sound_bytes).decode("ascii")
chunks = textwrap.wrap(encoded, 100)

entry_lines = ["  'dice_roll.mp3':"]
for index, chunk in enumerate(chunks):
    suffix = "," if index == len(chunks) - 1 else ""
    entry_lines.append(f"      '{chunk}'{suffix}")

new_entry = "\n".join(entry_lines) + "\n"

dice_start = sound_source.index("  'dice_roll.mp3':")
step_start = sound_source.index("  'step.mp3':", dice_start)

sound_source = (
    sound_source[:dice_start]
    + new_entry
    + sound_source[step_start:]
)

SOUND_DATA.write_text(sound_source, encoding="utf-8")

# Asset dosyasını da aynı baytlarla değiştir.
ASSET_SOUND.parent.mkdir(parents=True, exist_ok=True)
ASSET_SOUND.write_bytes(sound_bytes)

# Sürümün patch ve build bölümünü bir artır.
match = re.search(
    r"^version:\s*(\d+)\.(\d+)\.(\d+)\+(\d+)\s*$",
    pubspec_source,
    flags=re.MULTILINE,
)

if not match:
    raise SystemExit("pubspec.yaml sürüm satırı okunamadı.")

major, minor, patch, build = map(int, match.groups())
new_version = f"{major}.{minor}.{patch + 1}+{build + 1}"

pubspec_source = re.sub(
    r"^version:\s*.*$",
    f"version: {new_version}",
    pubspec_source,
    count=1,
    flags=re.MULTILINE,
)
PUBSPEC.write_text(pubspec_source, encoding="utf-8")

# Bayt düzeyinde kesin doğrulama.
if ASSET_SOUND.read_bytes() != sound_bytes:
    raise SystemExit("Asset zar sesi birebir kopyalanamadı.")

updated_sound = SOUND_DATA.read_text(encoding="utf-8")
if updated_sound.count("'dice_roll.mp3':") != 1:
    raise SystemExit("Gömülü zar sesi kaydı doğrulanamadı.")

if shutil.which("dart"):
    subprocess.run(
        ["dart", "format", "lib/main.dart", "lib/sound_data.dart"],
        check=True,
    )

subprocess.run(["git", "diff", "--check"], check=True)

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
            "Kullanicinin sectigi zar sesi",
        ],
        check=True,
    )

subprocess.run(
    ["git", "push", "origin", "main"],
    check=True,
)

print("")
print("✅ Yüklediğin MP3 hiçbir efekt uygulanmadan aynen kullanıldı.")
print("✅ Dosya bayt düzeyinde doğrulandı.")
print("✅ Gömülü ses ve asset dosyası birlikte değiştirildi.")
print("✅ Ses seviyesi 1.0 olarak ayarlandı.")
print("✅ Eski ses önbelleği kesin olarak aşıldı.")
print(f"✅ Yeni uygulama sürümü: {new_version}")
print("✅ Değişiklikler GitHub'a gönderildi.")
