#!/usr/bin/env python3
from pathlib import Path
import re
import shutil
import subprocess

MAIN = Path("lib/main.dart")
PUBSPEC = Path("pubspec.yaml")
TEMPLATE = Path("piyon_gorunurluk_sistemi.txt")

if not MAIN.exists() or not PUBSPEC.exists() or not TEMPLATE.exists():
    raise SystemExit(
        "Dosyaları BilgiRotasi proje ana klasöründe çalıştır."
    )

source = MAIN.read_text(encoding="utf-8")
shutil.copy2(MAIN, "/tmp/bilgi_rotasi_piyon_gorunurluk_oncesi.dart")

start_marker = "class PawnToken extends StatelessWidget {"
end_marker = "class RouteHighlightPainter extends CustomPainter"

if start_marker not in source or end_marker not in source:
    raise SystemExit("Güncel PawnToken kodu bulunamadı.")

start = source.index(start_marker)
end = source.index(end_marker, start)

template = TEMPLATE.read_text(encoding="utf-8")
source = source[:start] + template + source[end:]

old_sizes = """                final pawnWidth = active ? base * 0.064 : base * 0.056;
                final pawnHeight = active ? base * 0.086 : base * 0.075;"""
new_sizes = """                final pawnWidth = active ? base * 0.082 : base * 0.072;
                final pawnHeight = active ? base * 0.112 : base * 0.098;"""

if old_sizes not in source:
    raise SystemExit("Tahtadaki güncel piyon boyutları bulunamadı.")
source = source.replace(old_sizes, new_sizes, 1)

source = source.replace(
    "Offset(cos(angle), sin(angle)) * base * 0.064;",
    "Offset(cos(angle), sin(angle)) * base * 0.084;",
    1,
)
source = source.replace(
    "point += tangent * centeredSlot * base * 0.040;",
    "point += tangent * centeredSlot * base * 0.052;",
    1,
)
source = source.replace(
    "top: point.dy - pawnHeight * 0.84,",
    "top: point.dy - pawnHeight * 0.80,",
    1,
)

for marker in [
    "class RainbowRingPawnPainter extends CustomPainter",
    "final pawnWidth = active ? base * 0.082 : base * 0.072;",
    "final pawnHeight = active ? base * 0.112 : base * 0.098;",
    "Transform.scale(",
    "scale: active ? 1.34 : 1.24",
]:
    if marker not in source:
        raise SystemExit(f"Doğrulama başarısız: {marker}")

MAIN.write_text(source, encoding="utf-8")

pub = PUBSPEC.read_text(encoding="utf-8")
pub = re.sub(
    r"^version:\s*.*$",
    "version: 1.9.0+10",
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
        ["git", "commit", "-m", "Renkli halkayi duzelt ve piyonlari buyut"],
        check=True,
    )

subprocess.run(["git", "push", "origin", "main"], check=True)

print("✅ Renkli Halka görselden bağımsız, özel 3D çizimle düzeltildi.")
print("✅ Tahtadaki piyonlar yaklaşık yüzde 28 büyütüldü.")
print("✅ PNG piyonların kendi görüntüsü ayrıca büyütüldü.")
print("✅ Piyonların arkasına koyu altın çerçeveli zemin eklendi.")
print("✅ Oyuncu rengi ve aktif oyuncu parlaması güçlendirildi.")
print("✅ Aynı karedeki piyon aralığı artırıldı.")
print("✅ Kod GitHub'a gönderildi; Actions başlayacak.")
