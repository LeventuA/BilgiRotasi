#!/usr/bin/env python3
from pathlib import Path
import subprocess

WORKFLOW_DIR = Path(".github/workflows")

if not Path("pubspec.yaml").exists() or not Path("lib/main.dart").exists():
    raise SystemExit(
        "Bu dosyayı BilgiRotasi deposunun ana klasöründe çalıştır."
    )

WORKFLOW_DIR.mkdir(parents=True, exist_ok=True)

workflow_text = """name: APK oluştur

on:
  push:
    branches:
      - main
  workflow_dispatch:

permissions:
  contents: read

jobs:
  build:
    name: APK
    runs-on: ubuntu-latest

    steps:
      - name: Depoyu indir
        uses: actions/checkout@v4

      - name: Flutter kur
        uses: subosito/flutter-action@v2
        with:
          flutter-version: "3.44.7"
          channel: stable
          cache: true

      - name: Temiz Flutter projesi oluştur ve bütün dosyaları kopyala
        shell: bash
        run: |
          set -euxo pipefail

          rm -rf .flutter_build

          flutter create \
            --platforms=android \
            --org com.levent \
            --project-name bilgi_rotasi \
            .flutter_build

          rm -rf .flutter_build/lib
          cp -R lib .flutter_build/lib

          if [ -d assets ]; then
            rm -rf .flutter_build/assets
            cp -R assets .flutter_build/assets
          fi

          cp pubspec.yaml .flutter_build/pubspec.yaml

          if [ -f pubspec.lock ]; then
            cp pubspec.lock .flutter_build/pubspec.lock
          fi

          if [ -f analysis_options.yaml ]; then
            cp analysis_options.yaml .flutter_build/analysis_options.yaml
          fi

          test -f .flutter_build/lib/main.dart
          test -f .flutter_build/lib/sound_data.dart
          test -f .flutter_build/assets/sounds/correct.mp3

          cd .flutter_build
          flutter pub get
          flutter build apk --release

      - name: APK dosyasını yükle
        uses: actions/upload-artifact@v4
        with:
          name: BilgiRotasi-APK
          path: .flutter_build/build/app/outputs/flutter-apk/app-release.apk
          if-no-files-found: error
          retention-days: 14
"""

candidates = []

for pattern in ("*.yml", "*.yaml"):
    for path in WORKFLOW_DIR.glob(pattern):
        text = path.read_text(encoding="utf-8", errors="ignore")
        lowered = text.lower()

        if (
            "flutter build apk" in lowered
            or "assemblerelease" in lowered
            or "apk oluştur" in lowered
            or "apk olustur" in lowered
        ):
            candidates.append(path)

if candidates:
    target = sorted(candidates)[0]
else:
    target = WORKFLOW_DIR / "apk.yml"

target.write_text(workflow_text, encoding="utf-8")

# Aynı APK derlemesini başlatabilecek eski dosyaları devre dışı bırak.
for path in candidates:
    if path == target:
        continue

    disabled = path.with_suffix(path.suffix + ".disabled")
    if disabled.exists():
        disabled.unlink()
    path.rename(disabled)

subprocess.run(["git", "add", ".github/workflows"], check=True)
subprocess.run(["git", "diff", "--check"], check=True)

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
            "APK workflow tum lib ve asset dosyalarini kopyala",
        ],
        check=True,
    )

subprocess.run(["git", "push", "origin", "main"], check=True)

print("✅ APK workflow dosyası düzeltildi.")
print("✅ Artık yalnızca main.dart değil, lib klasörünün tamamı kopyalanacak.")
print("✅ lib/sound_data.dart derleme projesine dahil edilecek.")
print("✅ assets klasörünün tamamı APK projesine dahil edilecek.")
print("✅ Eski çakışan APK workflow dosyaları devre dışı bırakıldı.")
print("✅ GitHub Actions yeni APK derlemesini başlatacak.")
