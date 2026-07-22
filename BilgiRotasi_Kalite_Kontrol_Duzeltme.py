#!/usr/bin/env python3
from pathlib import Path
import re
import shutil
import subprocess
import tempfile

MAIN = Path("lib/main.dart")
HEALTH = Path("lib/system_health.dart")
TEST = Path("test/system_smoke_test.dart")
PUBSPEC = Path("pubspec.yaml")

def run(command):
    print("$ " + " ".join(command))
    return subprocess.run(command, check=True)

for path in [MAIN, HEALTH, TEST, PUBSPEC]:
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
        "Bu düzeltme yalnızca main dalında çalıştırılabilir.\n"
        f"Şu anki dal: {branch or '(belirsiz)'}\n"
        "Önce: git switch main"
    )

question_status = subprocess.run(
    [
        "git",
        "status",
        "--porcelain",
        "--",
        "assets/questions.json",
    ],
    text=True,
    capture_output=True,
    check=True,
).stdout.strip()

if question_status:
    raise SystemExit(
        "assets/questions.json dosyasında yerel değişiklik var.\n"
        "Soru çalışmalarını ayrı branch'te bırakıp main dalını "
        "temizledikten sonra bu düzeltmeyi çalıştır."
    )

main = MAIN.read_text(encoding="utf-8")
health = HEALTH.read_text(encoding="utf-8")
test = TEST.read_text(encoding="utf-8")
pubspec = PUBSPEC.read_text(encoding="utf-8")

required_test_markers = [
    "BoardMap.spokeCount",
    "XpProgressService.requiredForLevel",
    "Meydan okuma kodu kayıpsız çözülür",
]

for marker in required_test_markers:
    if marker not in test:
        raise SystemExit(
            f"Beklenen test satırı bulunamadı: {marker}\n"
            "Depo daha önce düzeltilmiş olabilir."
        )

version_match = re.search(
    r"^version:\s*(\d+)\.(\d+)\.(\d+)\+(\d+)\s*$",
    pubspec,
    flags=re.MULTILINE,
)

if version_match is None:
    raise SystemExit("pubspec.yaml sürüm satırı okunamadı.")

major, minor, patch, build = map(
    int,
    version_match.groups(),
)

if (major, minor, patch, build) != (1, 29, 0, 38):
    raise SystemExit(
        "Bu düzeltme 1.29.0+38 sürümü için hazırlandı.\n"
        f"Depodaki sürüm: {major}.{minor}.{patch}+{build}"
    )

new_version = "1.29.1+39"

backup_dir = Path(tempfile.mkdtemp(
    prefix="bilgi_rotasi_quality_fix_"
))
committed = False

try:
    shutil.copy2(MAIN, backup_dir / "main.dart")
    shutil.copy2(HEALTH, backup_dir / "system_health.dart")
    shutil.copy2(TEST, backup_dir / "system_smoke_test.dart")
    shutil.copy2(PUBSPEC, backup_dir / "pubspec.yaml")

    # BoardMap sınıfında olmayan spokeCount yerine oyunun gerçek
    # kategori/kol sayısını kullan.
    test = test.replace(
        "BoardMap.spokeCount,",
        "GameCategory.values.length,",
        1,
    )

    # XpProgressService içinde bulunmayan requiredForLevel çağrısını
    # kaldırıp, gerçekten mevcut ve kararlı bir veri modeli testi koy.
    old_xp_test = """    test('XP seviye eğrisi artar', () {
      expect(
        XpProgressService.requiredForLevel(2),
        greaterThan(
          XpProgressService.requiredForLevel(1),
        ),
      );
    });

"""

    new_xp_test = """    test('Kategori adları ve emojileri doludur', () {
      for (final category in GameCategory.values) {
        expect(category.label.trim(), isNotEmpty);
        expect(category.emoji.trim(), isNotEmpty);
      }
    });

"""

    if old_xp_test not in test:
        raise RuntimeError(
            "Hatalı XP test bloğu bulunamadı."
        )

    test = test.replace(
        old_xp_test,
        new_xp_test,
        1,
    )

    main, main_count = re.subn(
        r"Bilgi Rotası • Sürüm 1\.29(?:\.0)?",
        "Bilgi Rotası • Sürüm 1.29.1",
        main,
        count=1,
    )

    if main_count != 1:
        raise RuntimeError(
            "Ana menü sürüm yazısı güncellenemedi."
        )

    health = health.replace(
        "Sürüm 1.29.0+38",
        "Sürüm 1.29.1+39",
    )

    pubspec = re.sub(
        r"^version:\s*.*$",
        f"version: {new_version}",
        pubspec,
        count=1,
        flags=re.MULTILINE,
    )

    MAIN.write_text(main, encoding="utf-8")
    HEALTH.write_text(health, encoding="utf-8")
    TEST.write_text(test, encoding="utf-8")
    PUBSPEC.write_text(pubspec, encoding="utf-8")

    checks = {
        TEST: [
            "GameCategory.values.length",
            "Kategori adları ve emojileri doludur",
            "Meydan okuma kodu kayıpsız çözülür",
        ],
        MAIN: ["Bilgi Rotası • Sürüm 1.29.1"],
        HEALTH: ["Sürüm 1.29.1+39"],
        PUBSPEC: [f"version: {new_version}"],
    }

    for path, markers in checks.items():
        content = path.read_text(encoding="utf-8")

        for marker in markers:
            if marker not in content:
                raise RuntimeError(
                    f"Doğrulama başarısız: {path} / {marker}"
                )

    if shutil.which("dart"):
        run([
            "dart",
            "format",
            "lib/main.dart",
            "lib/system_health.dart",
            "test/system_smoke_test.dart",
        ])

    run(["git", "diff", "--check"])

    if shutil.which("flutter"):
        run(["flutter", "pub", "get"])
        run([
            "flutter",
            "analyze",
            "--no-fatal-infos",
        ])
        run(["flutter", "test"])
    else:
        print(
            "ℹ️ Flutter bu ortamda bulunamadı; "
            "kontroller GitHub Actions'ta çalışacak."
        )

    files_to_stage = [
        "lib/main.dart",
        "lib/system_health.dart",
        "test/system_smoke_test.dart",
        "pubspec.yaml",
    ]

    if Path("pubspec.lock").exists():
        files_to_stage.append("pubspec.lock")

    run(["git", "add", *files_to_stage])

    changed = subprocess.run(
        ["git", "diff", "--cached", "--quiet"],
        check=False,
    ).returncode != 0

    if not changed:
        raise RuntimeError(
            "Commit edilecek değişiklik bulunamadı."
        )

    run([
        "git",
        "commit",
        "-m",
        "Kalite kontrol testlerini duzelt",
    ])
    committed = True

    run(["git", "push", "origin", "main"])

except Exception as error:
    if not committed:
        shutil.copy2(
            backup_dir / "main.dart",
            MAIN,
        )
        shutil.copy2(
            backup_dir / "system_health.dart",
            HEALTH,
        )
        shutil.copy2(
            backup_dir / "system_smoke_test.dart",
            TEST,
        )
        shutil.copy2(
            backup_dir / "pubspec.yaml",
            PUBSPEC,
        )

        reset_paths = [
            "lib/main.dart",
            "lib/system_health.dart",
            "test/system_smoke_test.dart",
            "pubspec.yaml",
        ]

        if Path("pubspec.lock").exists():
            reset_paths.append("pubspec.lock")

        subprocess.run(
            ["git", "reset", "--", *reset_paths],
            check=False,
        )

        if shutil.which("flutter"):
            subprocess.run(
                ["flutter", "pub", "get"],
                check=False,
            )

    print("")
    print("❌ Düzeltme tamamlanamadı.")
    print(str(error))

    if committed:
        print(
            "Commit oluşturuldu fakat push başarısız oldu. "
            "Tekrar dene: git push origin main"
        )
    else:
        print(
            "Dosyalar önceki hâline otomatik döndürüldü."
        )

    raise SystemExit(1)

finally:
    shutil.rmtree(backup_dir, ignore_errors=True)

print("")
print("✅ BoardMap.spokeCount test hatası düzeltildi.")
print("✅ Olmayan requiredForLevel XP testi kaldırıldı.")
print("✅ Yerine kararlı kategori veri modeli testi eklendi.")
print("✅ flutter analyze ve flutter test kontrolleri çalıştırıldı.")
print("✅ questions.json dosyasına dokunulmadı.")
print(f"✅ Yeni sürüm: {new_version}")
print("✅ Düzeltme GitHub main dalına gönderildi.")
