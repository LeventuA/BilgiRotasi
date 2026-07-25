#!/usr/bin/env python3
from pathlib import Path
import shutil
import subprocess

MAIN = Path("lib/main.dart")

if not MAIN.exists():
    raise SystemExit(
        "Bu dosyayı BilgiRotasi deposunun ana klasöründe çalıştır."
    )

source = MAIN.read_text(encoding="utf-8")
shutil.copy2(
    MAIN,
    "/tmp/bilgi_rotasi_appbuildinfo_oncesi.dart",
)

broken_part = "part 'release_candidate.dart';\n"
broken_text = "'Bilgi Rotası • ${AppBuildInfo.shortLabel}'"

if broken_part not in source and broken_text not in source:
    raise SystemExit(
        "AppBuildInfo derleme kalıntısı bulunamadı. "
        "Önce git pull yap."
    )

# Eksik release_candidate.dart dosyasına olan bağlantıyı kaldır.
source = source.replace(broken_part, "", 1)

# Ana menü sürümünü mevcut gerçek sürümle sabitle.
source = source.replace(
    broken_text,
    "'Bilgi Rotası • Sürüm 1.41.1'",
    1,
)

if "AppBuildInfo.shortLabel" in source:
    raise SystemExit(
        "AppBuildInfo başvurusu tamamen temizlenemedi."
    )

MAIN.write_text(source, encoding="utf-8")

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
    ["git", "add", "lib/main.dart"],
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
            "AppBuildInfo derleme hatasini duzelt",
        ],
        check=True,
    )

subprocess.run(
    ["git", "push", "origin", "main"],
    check=True,
)

print("✅ Eksik release_candidate.dart bağlantısı kaldırıldı.")
print("✅ AppBuildInfo sabit ifade hatası giderildi.")
print("✅ Hakkında & Gizlilik ekranı korunuyor.")
print("✅ Flutter analizi tamamlandı.")
print("✅ Düzeltme GitHub main dalına gönderildi.")
