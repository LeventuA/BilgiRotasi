#!/usr/bin/env python3
from pathlib import Path
import re
import shutil
import subprocess
import tempfile

MAIN = Path("lib/main.dart")
PUBSPEC = Path("pubspec.yaml")
TEST = Path("test/system_smoke_test.dart")
TARGET = Path("lib/inspired_pawn_pack.dart")

PART_CONTENT = "part of 'main.dart';\n\nWidget buildMinikGalaksiBilgesiPawn({\n  required Color color,\n  required bool active,\n  required double width,\n  required double height,\n}) {\n  final glow = active ? 0.34 : 0.18;\n  return SizedBox(\n    width: width,\n    height: height,\n    child: Stack(\n      alignment: Alignment.center,\n      children: [\n        Positioned(\n          top: height * 0.12,\n          child: Container(\n            width: width * 0.72,\n            height: height * 0.18,\n            decoration: BoxDecoration(\n              color: const Color(0xFFC4B5FD).withValues(alpha: 0.45),\n              borderRadius: BorderRadius.circular(999),\n              boxShadow: [\n                BoxShadow(\n                  color: const Color(0xFF8B5CF6).withValues(alpha: glow),\n                  blurRadius: 12,\n                  spreadRadius: 1,\n                ),\n              ],\n            ),\n          ),\n        ),\n        Positioned(\n          top: height * 0.22,\n          child: Container(\n            width: width * 0.58,\n            height: height * 0.58,\n            decoration: BoxDecoration(\n              color: const Color(0xFF86EFAC),\n              borderRadius: BorderRadius.circular(width * 0.28),\n              border: Border.all(\n                color: const Color(0xFF14532D),\n                width: 2,\n              ),\n              boxShadow: [\n                BoxShadow(\n                  color: color.withValues(alpha: glow),\n                  blurRadius: 10,\n                  spreadRadius: 1,\n                ),\n              ],\n            ),\n          ),\n        ),\n        Positioned(\n          top: height * 0.26,\n          left: width * 0.03,\n          child: Transform.rotate(\n            angle: -0.45,\n            child: Container(\n              width: width * 0.22,\n              height: height * 0.16,\n              decoration: const BoxDecoration(\n                color: Color(0xFF86EFAC),\n                borderRadius: BorderRadius.only(\n                  topLeft: Radius.circular(4),\n                  topRight: Radius.circular(20),\n                  bottomLeft: Radius.circular(20),\n                  bottomRight: Radius.circular(4),\n                ),\n                border: Border.fromBorderSide(\n                  BorderSide(color: Color(0xFF14532D), width: 2),\n                ),\n              ),\n            ),\n          ),\n        ),\n        Positioned(\n          top: height * 0.26,\n          right: width * 0.03,\n          child: Transform.rotate(\n            angle: 0.45,\n            child: Container(\n              width: width * 0.22,\n              height: height * 0.16,\n              decoration: const BoxDecoration(\n                color: Color(0xFF86EFAC),\n                borderRadius: BorderRadius.only(\n                  topLeft: Radius.circular(20),\n                  topRight: Radius.circular(4),\n                  bottomLeft: Radius.circular(4),\n                  bottomRight: Radius.circular(20),\n                ),\n                border: Border.fromBorderSide(\n                  BorderSide(color: Color(0xFF14532D), width: 2),\n                ),\n              ),\n            ),\n          ),\n        ),\n        Positioned(\n          top: height * 0.37,\n          child: Row(\n            children: [\n              _pawnEye(const Color(0xFF111827)),\n              const SizedBox(width: 8),\n              _pawnEye(const Color(0xFF111827)),\n            ],\n          ),\n        ),\n        Positioned(\n          top: height * 0.50,\n          child: Container(\n            width: width * 0.34,\n            height: height * 0.05,\n            decoration: BoxDecoration(\n              color: const Color(0xFF166534),\n              borderRadius: BorderRadius.circular(999),\n            ),\n          ),\n        ),\n        Positioned(\n          bottom: height * 0.04,\n          child: Container(\n            width: width * 0.42,\n            height: height * 0.22,\n            decoration: BoxDecoration(\n              color: const Color(0xFFD4AF37),\n              borderRadius: BorderRadius.circular(width * 0.18),\n              border: Border.all(\n                color: const Color(0xFF7C2D12),\n                width: 2,\n              ),\n            ),\n            child: const Center(\n              child: Text('✨', style: TextStyle(fontSize: 12)),\n            ),\n          ),\n        ),\n      ],\n    ),\n  );\n}\n\nWidget buildFidanMuhafiziPawn({\n  required Color color,\n  required bool active,\n  required double width,\n  required double height,\n}) {\n  final glow = active ? 0.30 : 0.16;\n  return SizedBox(\n    width: width,\n    height: height,\n    child: Stack(\n      alignment: Alignment.center,\n      children: [\n        Positioned(\n          top: height * 0.15,\n          child: Container(\n            width: width * 0.50,\n            height: height * 0.46,\n            decoration: BoxDecoration(\n              color: const Color(0xFFBBF7D0),\n              borderRadius: BorderRadius.circular(width * 0.22),\n              border: Border.all(\n                color: const Color(0xFF166534),\n                width: 2,\n              ),\n              boxShadow: [\n                BoxShadow(\n                  color: const Color(0xFF22C55E).withValues(alpha: glow),\n                  blurRadius: 10,\n                  spreadRadius: 1,\n                ),\n              ],\n            ),\n          ),\n        ),\n        Positioned(\n          top: height * 0.02,\n          left: width * 0.10,\n          child: Transform.rotate(\n            angle: -0.4,\n            child: _leaf(width * 0.24, height * 0.20),\n          ),\n        ),\n        Positioned(\n          top: height * 0.02,\n          right: width * 0.10,\n          child: Transform.rotate(\n            angle: 0.4,\n            child: _leaf(width * 0.24, height * 0.20),\n          ),\n        ),\n        Positioned(\n          top: height * 0.32,\n          child: Row(\n            children: [\n              _pawnEye(const Color(0xFF14532D)),\n              const SizedBox(width: 7),\n              _pawnEye(const Color(0xFF14532D)),\n            ],\n          ),\n        ),\n        Positioned(\n          top: height * 0.43,\n          child: Container(\n            width: width * 0.22,\n            height: height * 0.04,\n            decoration: BoxDecoration(\n              color: const Color(0xFF166534),\n              borderRadius: BorderRadius.circular(999),\n            ),\n          ),\n        ),\n        Positioned(\n          bottom: height * 0.02,\n          child: Container(\n            width: width * 0.54,\n            height: height * 0.24,\n            decoration: BoxDecoration(\n              color: const Color(0xFF92400E),\n              borderRadius: BorderRadius.circular(999),\n              border: Border.all(\n                color: const Color(0xFF78350F),\n                width: 2,\n              ),\n            ),\n          ),\n        ),\n      ],\n    ),\n  );\n}\n\nWidget buildOzgurEvCiniPawn({\n  required Color color,\n  required bool active,\n  required double width,\n  required double height,\n}) {\n  final glow = active ? 0.26 : 0.14;\n  return SizedBox(\n    width: width,\n    height: height,\n    child: Stack(\n      alignment: Alignment.center,\n      children: [\n        Positioned(\n          top: height * 0.13,\n          child: Container(\n            width: width * 0.48,\n            height: height * 0.46,\n            decoration: BoxDecoration(\n              color: const Color(0xFFF5E0C8),\n              borderRadius: BorderRadius.circular(width * 0.20),\n              border: Border.all(\n                color: const Color(0xFF8B5E3C),\n                width: 2,\n              ),\n              boxShadow: [\n                BoxShadow(\n                  color: const Color(0xFFEAB308).withValues(alpha: glow),\n                  blurRadius: 10,\n                ),\n              ],\n            ),\n          ),\n        ),\n        Positioned(\n          top: height * 0.17,\n          left: width * 0.03,\n          child: Transform.rotate(\n            angle: -0.45,\n            child: _longEar(width * 0.18, height * 0.20),\n          ),\n        ),\n        Positioned(\n          top: height * 0.17,\n          right: width * 0.03,\n          child: Transform.rotate(\n            angle: 0.45,\n            child: _longEar(width * 0.18, height * 0.20),\n          ),\n        ),\n        Positioned(\n          top: height * 0.31,\n          child: Row(\n            children: [\n              _pawnEye(const Color(0xFF111827), size: 5),\n              const SizedBox(width: 8),\n              _pawnEye(const Color(0xFF111827), size: 5),\n            ],\n          ),\n        ),\n        Positioned(\n          top: height * 0.42,\n          child: Container(\n            width: width * 0.16,\n            height: height * 0.10,\n            decoration: BoxDecoration(\n              color: const Color(0xFFFDE68A),\n              borderRadius: BorderRadius.circular(5),\n              border: Border.all(\n                color: const Color(0xFFD97706),\n                width: 1.5,\n              ),\n            ),\n            child: const Center(\n              child: Text('🧦', style: TextStyle(fontSize: 10)),\n            ),\n          ),\n        ),\n        Positioned(\n          bottom: height * 0.02,\n          child: Container(\n            width: width * 0.46,\n            height: height * 0.23,\n            decoration: BoxDecoration(\n              color: const Color(0xFFE2E8F0),\n              borderRadius: BorderRadius.circular(999),\n              border: Border.all(\n                color: const Color(0xFF64748B),\n                width: 2,\n              ),\n            ),\n          ),\n        ),\n      ],\n    ),\n  );\n}\n\nWidget buildMagaraSinsigiPawn({\n  required Color color,\n  required bool active,\n  required double width,\n  required double height,\n}) {\n  final glow = active ? 0.28 : 0.15;\n  return SizedBox(\n    width: width,\n    height: height,\n    child: Stack(\n      alignment: Alignment.center,\n      children: [\n        Positioned(\n          top: height * 0.11,\n          child: Container(\n            width: width * 0.46,\n            height: height * 0.48,\n            decoration: BoxDecoration(\n              color: const Color(0xFFE7D7BF),\n              borderRadius: BorderRadius.circular(width * 0.20),\n              border: Border.all(\n                color: const Color(0xFF6B4F3A),\n                width: 2,\n              ),\n              boxShadow: [\n                BoxShadow(\n                  color: const Color(0xFFF59E0B).withValues(alpha: glow),\n                  blurRadius: 10,\n                ),\n              ],\n            ),\n          ),\n        ),\n        Positioned(\n          top: height * 0.27,\n          child: Row(\n            children: [\n              _pawnEye(const Color(0xFFF59E0B), size: 6),\n              const SizedBox(width: 7),\n              _pawnEye(const Color(0xFFF59E0B), size: 6),\n            ],\n          ),\n        ),\n        Positioned(\n          top: height * 0.38,\n          child: Container(\n            width: width * 0.12,\n            height: height * 0.16,\n            decoration: BoxDecoration(\n              color: const Color(0xFF8B5E3C),\n              borderRadius: BorderRadius.circular(999),\n            ),\n          ),\n        ),\n        Positioned(\n          bottom: height * 0.02,\n          child: Container(\n            width: width * 0.54,\n            height: height * 0.23,\n            decoration: BoxDecoration(\n              color: const Color(0xFFCBD5E1),\n              borderRadius: BorderRadius.circular(999),\n              border: Border.all(\n                color: const Color(0xFF475569),\n                width: 2,\n              ),\n            ),\n            child: const Center(\n              child: Text('💍', style: TextStyle(fontSize: 11)),\n            ),\n          ),\n        ),\n      ],\n    ),\n  );\n}\n\nWidget _pawnEye(Color color, {double size = 6}) {\n  return Container(\n    width: size,\n    height: size,\n    decoration: BoxDecoration(\n      color: color,\n      shape: BoxShape.circle,\n    ),\n  );\n}\n\nWidget _leaf(double width, double height) {\n  return Container(\n    width: width,\n    height: height,\n    decoration: BoxDecoration(\n      color: const Color(0xFF22C55E),\n      borderRadius: BorderRadius.only(\n        topLeft: Radius.circular(width),\n        topRight: Radius.circular(4),\n        bottomLeft: Radius.circular(4),\n        bottomRight: Radius.circular(height),\n      ),\n      border: Border.all(\n        color: const Color(0xFF166534),\n        width: 2,\n      ),\n    ),\n  );\n}\n\nWidget _longEar(double width, double height) {\n  return Container(\n    width: width,\n    height: height,\n    decoration: BoxDecoration(\n      color: const Color(0xFFF5E0C8),\n      borderRadius: BorderRadius.circular(width),\n      border: Border.all(\n        color: const Color(0xFF8B5E3C),\n        width: 2,\n      ),\n    ),\n  );\n}\n"
REPO_MESSAGE = "Ozgun ilhamli dort yeni piyon ekle"

def run(command):
    print("$ " + " ".join(command))
    return subprocess.run(command, check=True)

for path in [MAIN, PUBSPEC, TEST]:
    if not path.exists():
        raise SystemExit(
            f"Gerekli dosya bulunamadı: {path}\n"
            "Kurulumu BilgiRotasi deposunun ana klasöründe çalıştır."
        )

branch = subprocess.check_output(
    ["git", "branch", "--show-current"],
    text=True,
).strip()

if branch != "main":
    raise SystemExit(
        "Bu geliştirme yalnızca main dalına kurulabilir.\n"
        f"Şu anki dal: {branch or '(belirsiz)'}\n"
        "Önce: git switch main"
    )

question_status = subprocess.run(
    ["git", "status", "--porcelain", "--", "assets/questions.json"],
    text=True,
    capture_output=True,
    check=True,
).stdout.strip()

if question_status:
    raise SystemExit(
        "assets/questions.json dosyasında yerel değişiklik var.\n"
        "Soru çalışmalarını ayrı branch'te bırakıp main dalını "
        "temizledikten sonra bu paketi çalıştır."
    )

main = MAIN.read_text(encoding="utf-8")
pubspec = PUBSPEC.read_text(encoding="utf-8")
test = TEST.read_text(encoding="utf-8")

version_match = re.search(
    r"^version:\s*(\d+)\.(\d+)\.(\d+)\+(\d+)\s*$",
    pubspec,
    flags=re.MULTILINE,
)
if version_match is None:
    raise SystemExit("pubspec.yaml sürüm satırı okunamadı.")

version = tuple(map(int, version_match.groups()))
if version != (1, 36, 0, 46):
    raise SystemExit(
        "Bu paket 1.36.0+46 sürümü için hazırlandı.\n"
        f"Depodaki sürüm: {version[0]}.{version[1]}.{version[2]}+{version[3]}"
    )

new_enum_values = [
    "minikGalaksiBilgesi",
    "fidanMuhafizi",
    "ozgurEvCini",
    "magaraSinsigi",
]

if any(value in main for value in new_enum_values):
    raise SystemExit("İlhamlı piyon paketi zaten kurulmuş görünüyor.")

backup_dir = Path(tempfile.mkdtemp(prefix="bilgi_rotasi_inspired_pawns_"))
committed = False

try:
    shutil.copy2(MAIN, backup_dir / "main.dart")
    shutil.copy2(PUBSPEC, backup_dir / "pubspec.yaml")
    shutil.copy2(TEST, backup_dir / "system_smoke_test.dart")

    TARGET.write_text(PART_CONTENT, encoding="utf-8")

    if "part 'game_ui_polish.dart';" not in main:
        raise RuntimeError("Beklenen part satırı bulunamadı.")
    main = main.replace(
        "part 'game_ui_polish.dart';",
        "part 'game_ui_polish.dart';\npart 'inspired_pawn_pack.dart';",
        1,
    )

    enum_match = re.search(
        r"enum\s+PawnType\s*\{(?P<body>.*?)\n\}",
        main,
        flags=re.S,
    )
    if not enum_match:
        raise RuntimeError("PawnType enum bloğu bulunamadı.")

    enum_body = enum_match.group("body").rstrip()
    enum_insert = (
        "\n  minikGalaksiBilgesi,\n"
        "  fidanMuhafizi,\n"
        "  ozgurEvCini,\n"
        "  magaraSinsigi,\n"
    )
    new_enum = "enum PawnType {" + enum_body + enum_insert + "}"
    main = main[:enum_match.start()] + new_enum + main[enum_match.end():]

    definition_block_match = re.search(
        r"(List<PawnDefinition>[^=]*=\s*\[)(?P<body>.*?)(\n\s*\];)",
        main,
        flags=re.S,
    )
    if not definition_block_match:
        raise RuntimeError("Piyon tanım listesi bulunamadı.")

    definition_body = definition_block_match.group("body")
    if definition_body.count("PawnDefinition(") < 8:
        raise RuntimeError("Piyon tanım listesi beklenenden kısa görünüyor.")

    additions = '''
    PawnDefinition(
      type: PawnType.minikGalaksiBilgesi,
      name: 'Minik Galaksi Bilgesi',
      description: 'Bebeksi galaksi bilgeliği hissi veren özgün bir piyon.',
      previewColor: const Color(0xFF7C3AED),
    ),
    PawnDefinition(
      type: PawnType.fidanMuhafizi,
      name: 'Fidan Muhafızı',
      description: 'Küçük ama enerjik, ağaç ruhu esintili özgün bir piyon.',
      previewColor: const Color(0xFF16A34A),
    ),
    PawnDefinition(
      type: PawnType.ozgurEvCini,
      name: 'Özgür Ev Cini',
      description: 'Sevimli ve sadık, çorap temalı özgün ev cini piyon.',
      previewColor: const Color(0xFFD97706),
    ),
    PawnDefinition(
      type: PawnType.magaraSinsigi,
      name: 'Mağara Sinsiği',
      description: 'Halkalı ve gizemli, mağara yaratığı esintili piyon.',
      previewColor: const Color(0xFF64748B),
    ),
'''
    definition_body += additions
    main = (
        main[:definition_block_match.start()]
        + definition_block_match.group(1)
        + definition_body
        + definition_block_match.group(3)
        + main[definition_block_match.end():]
    )

    token_start = main.find("class PawnToken")
    if token_start < 0:
        raise RuntimeError("PawnToken sınıfı bulunamadı.")

    token_end = main.find("\nclass ", token_start + 10)
    if token_end < 0:
        token_end = len(main)

    token_block = main[token_start:token_end]
    switch_match = re.search(r"switch\s*\(\s*type\s*\)\s*\{", token_block)
    if not switch_match:
        switch_match = re.search(r"switch\s*\(\s*widget\.type\s*\)\s*\{", token_block)
    if not switch_match:
        raise RuntimeError("PawnToken switch bloğu bulunamadı.")

    injection = '''
      case PawnType.minikGalaksiBilgesi:
        return buildMinikGalaksiBilgesiPawn(
          color: color,
          active: active,
          width: width,
          height: height,
        );
      case PawnType.fidanMuhafizi:
        return buildFidanMuhafiziPawn(
          color: color,
          active: active,
          width: width,
          height: height,
        );
      case PawnType.ozgurEvCini:
        return buildOzgurEvCiniPawn(
          color: color,
          active: active,
          width: width,
          height: height,
        );
      case PawnType.magaraSinsigi:
        return buildMagaraSinsigiPawn(
          color: color,
          active: active,
          width: width,
          height: height,
        );
'''
    insert_pos = switch_match.end()
    token_block = token_block[:insert_pos] + injection + token_block[insert_pos:]
    main = main[:token_start] + token_block + main[token_end:]

    main, version_count = re.subn(
        r"Bilgi Rotası • Sürüm 1\.36\.0",
        "Bilgi Rotası • Sürüm 1.37.0",
        main,
        count=1,
    )
    if version_count != 1:
        raise RuntimeError("Ana menü sürüm yazısı güncellenemedi.")

    pubspec = re.sub(
        r"^version:\s*.*$",
        "version: 1.37.0+47",
        pubspec,
        count=1,
        flags=re.MULTILINE,
    )

    test_insert = '''
    test('İlhamlı piyon paketi dört yeni özgün piyon ekler', () {
      expect(PawnType.values, contains(PawnType.minikGalaksiBilgesi));
      expect(PawnType.values, contains(PawnType.fidanMuhafizi));
      expect(PawnType.values, contains(PawnType.ozgurEvCini));
      expect(PawnType.values, contains(PawnType.magaraSinsigi));
    });
'''
    group_end = test.rfind("  });\n}")
    if group_end < 0:
        raise RuntimeError("Test dosyası ekleme noktası bulunamadı.")
    test = test[:group_end] + test_insert + test[group_end:]

    MAIN.write_text(main, encoding="utf-8")
    PUBSPEC.write_text(pubspec, encoding="utf-8")
    TEST.write_text(test, encoding="utf-8")

    checks = {
        MAIN: [
            "part 'inspired_pawn_pack.dart';",
            "PawnType.minikGalaksiBilgesi",
            "PawnType.fidanMuhafizi",
            "PawnType.ozgurEvCini",
            "PawnType.magaraSinsigi",
            "Bilgi Rotası • Sürüm 1.37.0",
        ],
        TARGET: [
            "buildMinikGalaksiBilgesiPawn",
            "buildFidanMuhafiziPawn",
            "buildOzgurEvCiniPawn",
            "buildMagaraSinsigiPawn",
        ],
        TEST: [
            "İlhamlı piyon paketi dört yeni özgün piyon ekler",
        ],
        PUBSPEC: [
            "version: 1.37.0+47",
        ],
    }

    for path, markers in checks.items():
        content = path.read_text(encoding="utf-8")
        for marker in markers:
            if marker not in content:
                raise RuntimeError(f"Kurulum doğrulaması başarısız: {path} / {marker}")

    if shutil.which("dart"):
        run(["dart", "format", "lib/main.dart", "lib/inspired_pawn_pack.dart", "test/system_smoke_test.dart"])

    run(["git", "diff", "--check"])

    changed_paths = subprocess.check_output(["git", "diff", "--name-only"], text=True).splitlines()
    if "assets/questions.json" in changed_paths:
        raise RuntimeError("Güvenlik kontrolü: questions.json değişmiş görünüyor.")

    if shutil.which("flutter"):
        run(["flutter", "pub", "get"])
        run(["flutter", "analyze", "--no-fatal-warnings", "--no-fatal-infos"])
        run(["flutter", "test"])
    else:
        print("ℹ️ Flutter bu ortamda bulunamadı; analiz ve test GitHub Actions'ta çalışacak.")

    files_to_stage = [
        "lib/main.dart",
        "lib/inspired_pawn_pack.dart",
        "test/system_smoke_test.dart",
        "pubspec.yaml",
    ]
    if Path("pubspec.lock").exists():
        files_to_stage.append("pubspec.lock")

    run(["git", "add", *files_to_stage])

    changed = subprocess.run(["git", "diff", "--cached", "--quiet"], check=False).returncode != 0
    if not changed:
        raise RuntimeError("Commit edilecek değişiklik bulunamadı.")

    run(["git", "commit", "-m", REPO_MESSAGE])
    committed = True
    run(["git", "push", "origin", "main"])

except Exception as error:
    if not committed:
        shutil.copy2(backup_dir / "main.dart", MAIN)
        shutil.copy2(backup_dir / "pubspec.yaml", PUBSPEC)
        shutil.copy2(backup_dir / "system_smoke_test.dart", TEST)
        if TARGET.exists():
            TARGET.unlink()

        reset_paths = [
            "lib/main.dart",
            "lib/inspired_pawn_pack.dart",
            "test/system_smoke_test.dart",
            "pubspec.yaml",
        ]
        if Path("pubspec.lock").exists():
            reset_paths.append("pubspec.lock")
        subprocess.run(["git", "reset", "--", *reset_paths], check=False)

        if shutil.which("flutter"):
            subprocess.run(["flutter", "pub", "get"], check=False)

    print("")
    print("❌ Kurulum tamamlanamadı.")
    print(str(error))
    if committed:
        print("Commit oluşturuldu fakat push başarısız oldu. Tekrar dene: git push origin main")
    else:
        print("Dosyalar önceki hâline otomatik döndürüldü.")
    raise SystemExit(1)

finally:
    shutil.rmtree(backup_dir, ignore_errors=True)

print("")
print("✅ Minik Galaksi Bilgesi eklendi.")
print("✅ Fidan Muhafızı eklendi.")
print("✅ Özgür Ev Cini eklendi.")
print("✅ Mağara Sinsiği eklendi.")
print("✅ Piyon seçim ekranına dört yeni özgün piyon eklendi.")
print("✅ Yeni piyonlar tahtada da kullanılabilir oldu.")
print("✅ questions.json dosyasına dokunulmadı.")
print("✅ Yeni sürüm: 1.37.0+47")
print("✅ Değişiklikler GitHub main dalına gönderildi.")
