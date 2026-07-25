#!/usr/bin/env python3
from pathlib import Path
import re
import shutil
import subprocess

MAIN = Path("lib/main.dart")
PUBSPEC = Path("pubspec.yaml")

if not MAIN.exists() or not PUBSPEC.exists():
    raise SystemExit("Bu dosyayı BilgiRotasi proje ana klasöründe çalıştır.")

source = MAIN.read_text(encoding="utf-8")
shutil.copy2(MAIN, "/tmp/bilgi_rotasi_piyon_olcegi_oncesi.dart")

required = [
    "class PawnToken extends StatelessWidget",
    "class RingPawnPainter extends CustomPainter",
    "class ClassicPawnPainter extends CustomPainter",
    "class GameBoard extends StatelessWidget",
    "final pawnWidth = active ? base * 0.046 : base * 0.040;",
]
for marker in required:
    if marker not in source:
        raise SystemExit(f"Beklenen güncel kod bulunamadı: {marker}")

old_stack = """                final stackedBefore = players
                    .take(index)
                    .where((other) => other.position == player.position)
                    .length;

                if (player.position == BoardMap.centerId) {
                  final divisor = players.isEmpty ? 1 : players.length;
                  final angle = -pi / 2 +
                      index * (2 * pi / divisor.toDouble());
                  point = boardCenter +
                      Offset(cos(angle), sin(angle)) * base * 0.052;
                } else if (stackedBefore > 0) {
                  final radialAngle = atan2(
                    point.dy - boardCenter.dy,
                    point.dx - boardCenter.dx,
                  );
                  final tangent = Offset(
                    -sin(radialAngle),
                    cos(radialAngle),
                  );
                  point += tangent *
                      stackedBefore.toDouble() *
                      base *
                      0.024;
                }

                final pawnWidth = active ? base * 0.046 : base * 0.040;
                final pawnHeight = active ? base * 0.060 : base * 0.053;"""

new_stack = """                final sameCellIndexes = <int>[
                  for (var otherIndex = 0;
                      otherIndex < players.length;
                      otherIndex++)
                    if (players[otherIndex].position == player.position)
                      otherIndex,
                ];
                final stackSlot = sameCellIndexes.indexOf(index);

                if (player.position == BoardMap.centerId) {
                  final divisor = players.isEmpty ? 1 : players.length;
                  final angle = -pi / 2 +
                      index * (2 * pi / divisor.toDouble());
                  point = boardCenter +
                      Offset(cos(angle), sin(angle)) * base * 0.064;
                } else if (sameCellIndexes.length > 1) {
                  final radialAngle = atan2(
                    point.dy - boardCenter.dy,
                    point.dx - boardCenter.dx,
                  );
                  final tangent = Offset(
                    -sin(radialAngle),
                    cos(radialAngle),
                  );
                  final centeredSlot =
                      stackSlot - (sameCellIndexes.length - 1) / 2;
                  point += tangent * centeredSlot * base * 0.040;
                }

                final pawnWidth = active ? base * 0.064 : base * 0.056;
                final pawnHeight = active ? base * 0.086 : base * 0.075;"""

if old_stack not in source:
    raise SystemExit("Tahtadaki eski piyon yerleşim kodu bulunamadı.")
source = source.replace(old_stack, new_stack, 1)

old_top = "                  top: point.dy - pawnHeight * 0.76,"
new_top = "                  top: point.dy - pawnHeight * 0.84,"
if old_top not in source:
    raise SystemExit("Piyon yükseklik konumu bulunamadı.")
source = source.replace(old_top, new_top, 1)

source = source.replace(
    "                width: width * 0.96,\n                height: width * 0.96,",
    "                width: width * 1.22,\n                height: width * 1.22,",
    1,
)
source = source.replace(
    "                      blurRadius: width * 0.32,\n                      spreadRadius: width * 0.05,",
    "                      blurRadius: width * 0.46,\n                      spreadRadius: width * 0.10,",
    1,
)
source = source.replace(
    "              width: width * 0.82,\n              height: height * 0.16,",
    "              width: width * 0.96,\n              height: height * 0.22,",
    1,
)
source = source.replace(
    """                  BoxShadow(
                    offset: Offset(0, 2),
                    blurRadius: 3,
                    color: Color(0x66000000),
                  ),""",
    """                  BoxShadow(
                    offset: Offset(0, 3),
                    blurRadius: 5,
                    spreadRadius: 0.5,
                    color: Color(0x88000000),
                  ),""",
    1,
)
source = source.replace(
    "                width: width * 0.82,\n                height: height * 0.67,",
    "                width: width * 0.90,\n                height: height * 0.70,",
    1,
)
source = source.replace(
    "                    width: active ? 2.2 : 1.5,",
    "                    width: active ? 3.0 : 2.0,",
    1,
)
source = source.replace(
    "                      fontSize: type == 10 ? width * 0.48 : width * 0.39,",
    "                      fontSize: type == 10 ? width * 0.56 : width * 0.48,",
    1,
)
source = source.replace(
    "              width: width * 0.10,\n              height: width * 0.10,",
    "              width: width * 0.13,\n              height: width * 0.13,",
    1,
)

source = source.replace(
    "    final radius = size.width * 0.34;",
    "    final radius = size.width * 0.38;",
    1,
)
source = source.replace(
    "        radius * 1.35,",
    "        radius * 1.52,",
    1,
)
source = source.replace(
    "        width: size.width * 0.82,\n        height: size.height * 0.15,",
    "        width: size.width * 0.96,\n        height: size.height * 0.21,",
    1,
)

source = source.replace(
    "        size.width * 0.52,",
    "        size.width * 0.64,",
    1,
)
source = source.replace(
    "        width: size.width * 0.84,\n        height: size.height * 0.16,",
    "        width: size.width * 0.98,\n        height: size.height * 0.21,",
    1,
)
source = source.replace(
    "    final headRadius = size.width * 0.24;",
    "    final headRadius = size.width * 0.28;",
    1,
)
source = source.replace(
    "      width: size.width * 0.72,\n      height: size.height * 0.16,",
    "      width: size.width * 0.88,\n      height: size.height * 0.20,",
    1,
)

source = source.replace(
    """                      width: 44,
                      height: 54,""",
    """                      width: 50,
                      height: 62,""",
    1,
)

for marker in [
    "final pawnWidth = active ? base * 0.064 : base * 0.056;",
    "final pawnHeight = active ? base * 0.086 : base * 0.075;",
    "final sameCellIndexes = <int>[",
    "centeredSlot * base * 0.040",
    "width: active ? 3.0 : 2.0",
]:
    if marker not in source:
        raise SystemExit(f"Güncelleme doğrulaması başarısız: {marker}")

MAIN.write_text(source, encoding="utf-8")

pub = PUBSPEC.read_text(encoding="utf-8")
pub = re.sub(
    r"^version:\s*.*$",
    "version: 1.7.0+8",
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
        ["git", "commit", "-m", "Piyonlari buyut ve okunabilirligi artir"],
        check=True,
    )

subprocess.run(["git", "push", "origin", "main"], check=True)

print("✅ Tahtadaki piyonlar büyütüldü.")
print("✅ Aktif piyon yaklaşık yüzde 14 daha büyük ve daha parlak.")
print("✅ Piyon tabanları ve sembolleri kalınlaştırıldı.")
print("✅ Aynı karedeki piyonlar simetrik olarak yan yana ayrıldı.")
print("✅ Piyonlar kareden biraz yukarı taşırılarak daha 3D gösterildi.")
print("✅ Kod GitHub'a gönderildi; Actions derlemesi başlayacak.")
