#!/usr/bin/env python3
from pathlib import Path
import re
import shutil
import subprocess
import sys

SOURCE = Path("questions_3000.json")
TARGET = Path("assets/questions.json")
MAIN = Path("lib/main.dart")
PUBSPEC = Path("pubspec.yaml")
VALIDATOR = Path("soru_bankasi_dogrula.py")

required = [
    SOURCE,
    TARGET,
    MAIN,
    PUBSPEC,
    VALIDATOR,
]

for path in required:
    if not path.exists():
        raise SystemExit(
            f"Gerekli dosya bulunamadı: {path}\n"
            "Bu betiği BilgiRotasi deposunun ana "
            "klasöründe çalıştır."
        )

main_source = MAIN.read_text(encoding="utf-8")

if "part 'daily_challenge.dart';" not in main_source:
    raise SystemExit(
        "Önce Günlük Görev + Yeni Zar Sesi paketini "
        "kurup test et. Ardından bu paketi çalıştır."
    )

if (
    "Bilgi Rotası • Sürüm 1.18" not in main_source
    and "Bilgi Rotası • Sürüm 1.19" not in main_source
):
    raise SystemExit(
        "Beklenen 1.18 sürümü bulunamadı. "
        "Önce git pull yap ve Günlük Görev "
        "güncellemesini tamamla."
    )

# Kaynak dosyayı kopyalamadan önce bağımsız doğrula.
subprocess.run(
    [sys.executable, str(VALIDATOR), str(SOURCE)],
    check=True,
)

backup = Path(
    "/tmp/bilgi_rotasi_questions_before_3000.json"
)
shutil.copy2(TARGET, backup)
shutil.copy2(SOURCE, TARGET)

# Ana menü sürüm metni.
main_source = MAIN.read_text(encoding="utf-8")
main_source = main_source.replace(
    "Bilgi Rotası • Sürüm 1.18",
    "Bilgi Rotası • Sürüm 1.19",
    1,
)
MAIN.write_text(main_source, encoding="utf-8")

# Uygulama sürümü.
pubspec = PUBSPEC.read_text(encoding="utf-8")
pubspec = re.sub(
    r"^version:\s*.*$",
    "version: 1.19.0+24",
    pubspec,
    flags=re.MULTILINE,
)
PUBSPEC.write_text(pubspec, encoding="utf-8")

# Kurulan dosyayı tekrar doğrula.
subprocess.run(
    [sys.executable, str(VALIDATOR), str(TARGET)],
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

subprocess.run(
    [
        "git",
        "add",
        "assets/questions.json",
        "lib/main.dart",
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
            "Uc bin soruluk dengeli soru bankasi",
        ],
        check=True,
    )

subprocess.run(
    ["git", "push", "origin", "main"],
    check=True,
)

print("")
print("✅ Soru bankası 120 sorudan 3000 soruya çıkarıldı.")
print("✅ Eski q001–q120 soru kimlikleri korundu.")
print("✅ Her kategoride 500 soru bulunuyor.")
print("✅ Zorluk ve doğru şık konumları dengelendi.")
print("✅ Otomatik kalite kontrolü tamamlandı.")
print("✅ Sürüm 1.19.0+24 olarak güncellendi.")
print("✅ Değişiklikler GitHub'a gönderildi.")
print(f"ℹ️ Eski soru dosyası yedeği: {backup}")
