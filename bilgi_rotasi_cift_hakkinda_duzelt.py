#!/usr/bin/env python3
from pathlib import Path
import re
import shutil
import subprocess

NAV = Path("lib/main_navigation.dart")
MAIN = Path("lib/main.dart")
ABOUT = Path("lib/about_privacy.dart")
PUBSPEC = Path("pubspec.yaml")

for path in [NAV, MAIN, ABOUT, PUBSPEC]:
    if not path.exists():
        raise SystemExit(
            f"Gerekli dosya bulunamadı: {path}\n"
            "Bu dosyayı BilgiRotasi deposunun ana klasöründe çalıştır."
        )

nav = NAV.read_text(encoding="utf-8")
main = MAIN.read_text(encoding="utf-8")
about = ABOUT.read_text(encoding="utf-8")
pub = PUBSPEC.read_text(encoding="utf-8")

shutil.copy2(
    NAV,
    "/tmp/bilgi_rotasi_cift_hakkinda_oncesi.dart",
)

card = """        _HubActionCard(
          emoji: 'ℹ️',
          title: 'Hakkında & Gizlilik',
          description:
              'Sürüm bilgisi, çevrimdışı kullanım, '
              'yerel kayıtlar ve gizlilik açıklaması.',
          accent: const Color(0xFF475569),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => AboutPrivacyScreen(
                questionBank: questionBank,
              ),
            ),
          ),
        ),
"""

count = nav.count(card)

if count < 2:
    raise SystemExit(
        "İki adet Hakkında & Gizlilik kartı bulunamadı. "
        "Önce git pull yap."
    )

# İlk kartı koru, sonraki bütün aynı kartları kaldır.
first = nav.find(card)
before = nav[: first + len(card)]
after = nav[first + len(card):].replace(card, "")
nav = before + after

if nav.count(card) != 1:
    raise SystemExit(
        "Hakkında & Gizlilik kartı tekilleştirilemedi."
    )

NAV.write_text(nav, encoding="utf-8")

main = main.replace(
    "Bilgi Rotası • Sürüm 1.41.1",
    "Bilgi Rotası • Sürüm 1.41.2",
    1,
)
MAIN.write_text(main, encoding="utf-8")

about = about.replace(
    "Sürüm 1.41.1+52",
    "Sürüm 1.41.2+53",
    1,
)
ABOUT.write_text(about, encoding="utf-8")

pub = re.sub(
    r"^version:\s*.*$",
    "version: 1.41.2+53",
    pub,
    flags=re.MULTILINE,
)
PUBSPEC.write_text(pub, encoding="utf-8")

if shutil.which("dart"):
    subprocess.run(
        [
            "dart",
            "format",
            "lib/main_navigation.dart",
            "lib/main.dart",
            "lib/about_privacy.dart",
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
        "lib/main_navigation.dart",
        "lib/main.dart",
        "lib/about_privacy.dart",
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
            "Cift Hakkinda ve Gizlilik kartini kaldir",
        ],
        check=True,
    )

subprocess.run(
    ["git", "push", "origin", "main"],
    check=True,
)

print("✅ Ayarlar ekranındaki ikinci Hakkında & Gizlilik kartı kaldırıldı.")
print("✅ Tek kart ve tek ekran korunuyor.")
print("✅ Sürüm 1.41.2+53 olarak güncellendi.")
print("✅ Flutter analizi tamamlandı.")
print("✅ Düzeltme GitHub main dalına gönderildi.")
