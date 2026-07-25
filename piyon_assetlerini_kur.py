#!/usr/bin/env python3
from pathlib import Path
import subprocess

pubspec = Path("pubspec.yaml")
if not pubspec.exists():
    raise SystemExit("Bu dosyayı BilgiRotasi proje ana klasöründe çalıştır.")

text = pubspec.read_text(encoding="utf-8")

if "    - assets/pawns/" not in text:
    marker = "  assets:\n"
    if marker not in text:
        raise SystemExit("pubspec.yaml içinde flutter/assets bölümü bulunamadı.")
    text = text.replace(marker, marker + "    - assets/pawns/\n", 1)
    pubspec.write_text(text, encoding="utf-8")

subprocess.run(["git", "add", "assets/pawns", "pubspec.yaml"], check=True)

changed = subprocess.run(
    ["git", "diff", "--cached", "--quiet"],
    check=False,
).returncode != 0

if changed:
    subprocess.run(
        ["git", "commit", "-m", "12 piyon gorsel assetlerini ekle"],
        check=True,
    )

subprocess.run(["git", "push", "origin", "main"], check=True)

print("✅ 12 şeffaf piyon PNG dosyası eklendi.")
print("✅ pubspec.yaml içine assets/pawns/ tanımlandı.")
print("✅ Dosyalar GitHub'a gönderildi.")
