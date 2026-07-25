#!/usr/bin/env python3
from pathlib import Path
import re
import shutil
import subprocess

MAIN = Path("lib/main.dart")
PUBSPEC = Path("pubspec.yaml")
DATA_SOURCE = Path("sound_data.dart")
TEMPLATE = Path("gomulu_ses_sistemi.txt")
TARGET_DATA = Path("lib/sound_data.dart")

if not MAIN.exists() or not PUBSPEC.exists():
    raise SystemExit(
        "Bu dosyayı BilgiRotasi proje ana klasöründe çalıştır."
    )

if not DATA_SOURCE.exists() or not TEMPLATE.exists():
    raise SystemExit("Paketin ses kodu dosyaları bulunamadı.")

source = MAIN.read_text(encoding="utf-8")
shutil.copy2(
    MAIN,
    "/tmp/bilgi_rotasi_gomulu_ses_oncesi.dart",
)

required = [
    "class SoundFx {",
    "Future<void> main() async",
    "Sesi test et",
    "SoundFx.lastError",
]
for marker in required:
    if marker not in source:
        raise SystemExit(f"Beklenen güncel ses kodu bulunamadı: {marker}")

if "import 'dart:io';" not in source:
    source = source.replace(
        "import 'dart:convert';",
        "import 'dart:convert';\nimport 'dart:io';",
        1,
    )

if "import 'sound_data.dart';" not in source:
    import_marker = "import 'package:flutter/services.dart';"
    if import_marker not in source:
        raise SystemExit("Flutter import bölümü bulunamadı.")
    source = source.replace(
        import_marker,
        import_marker + "\n\nimport 'sound_data.dart';",
        1,
    )

sound_start = source.index("class SoundFx {")
main_start = source.index("Future<void> main() async", sound_start)

source = (
    source[:sound_start]
    + TEMPLATE.read_text(encoding="utf-8")
    + source[main_start:]
)

for marker in [
    "embeddedSoundBase64.entries",
    "Directory.systemTemp.path",
    "DeviceFileSource(path)",
    "Gömülü ses hazırlanamadı",
]:
    if marker not in source:
        raise SystemExit(f"Gömülü ses doğrulaması başarısız: {marker}")

sound_section = source[
    source.index("class SoundFx {"):
    source.index("Future<void> main() async")
]
if "AssetSource(" in sound_section:
    raise SystemExit("Eski AssetSource ses kodu kaldırılamadı.")

MAIN.write_text(source, encoding="utf-8")
shutil.copy2(DATA_SOURCE, TARGET_DATA)

pub = PUBSPEC.read_text(encoding="utf-8")
pub = re.sub(
    r"^version:\s*.*$",
    "version: 1.11.2+14",
    pub,
    flags=re.MULTILINE,
)
PUBSPEC.write_text(pub, encoding="utf-8")

if shutil.which("flutter"):
    subprocess.run(["flutter", "pub", "get"], check=True)

if shutil.which("dart"):
    subprocess.run(["dart", "format", "lib/main.dart"], check=True)

subprocess.run(["git", "diff", "--check"], check=True)

files_to_add = [
    "lib/main.dart",
    "lib/sound_data.dart",
    "pubspec.yaml",
]
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
            "Sesleri APK icine gom ve oynatmayi duzelt",
        ],
        check=True,
    )

subprocess.run(["git", "push", "origin", "main"], check=True)

print("✅ Yedi ses dosyası doğrudan APK koduna gömüldü.")
print("✅ Ses sistemi artık Flutter asset klasörüne bağlı değil.")
print("✅ Gömülü MP3 dosyaları uygulama önbelleğine çıkarılacak.")
print("✅ Sesler DeviceFileSource ile yerel dosyadan oynatılacak.")
print("✅ Mevcut Ses Testi düğmesi korunuyor.")
print("✅ Kod GitHub'a gönderildi; Actions derlemesi başlayacak.")
