#!/usr/bin/env python3
from pathlib import Path
import re
import shutil
import subprocess

MAIN = Path("lib/main.dart")
PUBSPEC = Path("pubspec.yaml")
MANIFEST = Path("assets/pawns/manifest.json")
TEMPLATE = Path("png_piyon_sistemi.txt")

if not MAIN.exists() or not PUBSPEC.exists():
    raise SystemExit("Bu dosyayı BilgiRotasi proje ana klasöründe çalıştır.")

if not MANIFEST.exists():
    raise SystemExit(
        "assets/pawns/manifest.json bulunamadı. Önce 12 piyon asset paketini kur."
    )

if not TEMPLATE.exists():
    raise SystemExit("png_piyon_sistemi.txt bulunamadı.")

source = MAIN.read_text(encoding="utf-8")
shutil.copy2(MAIN, "/tmp/bilgi_rotasi_png_piyon_oncesi.dart")

start_marker = "class PawnDefinition {"
end_marker = "class RouteHighlightPainter extends CustomPainter"

if start_marker not in source or end_marker not in source:
    raise SystemExit("Piyon sınıfları güncel kodda bulunamadı.")

start = source.index(start_marker)
end = source.index(end_marker, start)

new_pawn_code = TEMPLATE.read_text(encoding="utf-8")
source = source[:start] + new_pawn_code + source[end:]

replacements = [
    (r"width:\s*42,\s*\n\s*height:\s*52,", "width: 54,\n                                      height: 66,"),
    (r"width:\s*46,\s*\n\s*height:\s*58,", "width: 58,\n                            height: 72,"),
    (r"childAspectRatio:\s*0\.78,", "childAspectRatio: 0.72,"),
    (r"width:\s*50,\s*\n\s*height:\s*62,", "width: 58,\n                      height: 72,"),
    (r"width:\s*24,\s*\n\s*height:\s*30,", "width: 32,\n                          height: 40,"),
]

for pattern, replacement in replacements:
    source, _ = re.subn(pattern, replacement, source, count=1)

for marker in [
    "assetPath: 'assets/pawns/01_renkli_halka.png'",
    "assetPath: 'assets/pawns/12_kupa_rozet.png'",
    "Image.asset(",
    "filterQuality: FilterQuality.high",
    "class RouteHighlightPainter extends CustomPainter",
]:
    if marker not in source:
        raise SystemExit(f"Güncelleme doğrulaması başarısız: {marker}")

if "class RingPawnPainter extends CustomPainter" in source:
    raise SystemExit("Eski çizim tabanlı piyon sınıfları kaldırılamadı.")

MAIN.write_text(source, encoding="utf-8")

pub = PUBSPEC.read_text(encoding="utf-8")
if "    - assets/pawns/" not in pub:
    raise SystemExit("pubspec.yaml içinde assets/pawns/ kaydı bulunamadı.")

pub = re.sub(
    r"^version:\s*.*$",
    "version: 1.8.0+9",
    pub,
    flags=re.MULTILINE,
)
PUBSPEC.write_text(pub, encoding="utf-8")

if shutil.which("dart"):
    subprocess.run(["dart", "format", "lib/main.dart"], check=True)

subprocess.run(["git", "diff", "--check"], check=True)
subprocess.run(["git", "add", "lib/main.dart", "pubspec.yaml"], check=True)

changed = subprocess.run(
    ["git", "diff", "--cached", "--quiet"],
    check=False,
).returncode != 0

if changed:
    subprocess.run(
        ["git", "commit", "-m", "3D piyon PNG gorsellerini oyuna bagla"],
        check=True,
    )

subprocess.run(["git", "push", "origin", "main"], check=True)

print("✅ 12 PNG piyon seçim ekranına bağlandı.")
print("✅ Seçilen PNG piyon tahtada gösterilecek.")
print("✅ Oyuncu rengi ışık ve alt şeritle gösterilecek.")
print("✅ Aktif oyuncuya parlama ve renk noktası eklendi.")
print("✅ Eski emoji/çizim tabanlı piyon görünümü kaldırıldı.")
print("✅ Kod GitHub'a gönderildi; Actions derlemesi başlayacak.")
