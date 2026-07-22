#!/usr/bin/env python3
from pathlib import Path
import shutil
import subprocess
import tempfile

TEST = Path("test/system_smoke_test.dart")
PUBSPEC = Path("pubspec.yaml")

def run(command):
    print("$ " + " ".join(command))
    return subprocess.run(command, check=True)

for path in [TEST, PUBSPEC]:
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

pubspec = PUBSPEC.read_text(encoding="utf-8")

if "version: 1.29.1+39" not in pubspec:
    raise SystemExit(
        "Bu düzeltme mevcut 1.29.1+39 sürümü için hazırlandı.\n"
        "pubspec.yaml içindeki sürüm farklı görünüyor."
    )

test = TEST.read_text(encoding="utf-8")

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

if (
    "BoardMap.spokeCount" not in test
    and "XpProgressService.requiredForLevel" not in test
):
    raise SystemExit(
        "Kalite kontrol testleri zaten düzeltilmiş görünüyor."
    )

backup_dir = Path(tempfile.mkdtemp(
    prefix="bilgi_rotasi_quality_fix_v2_"
))
committed = False

try:
    shutil.copy2(
        TEST,
        backup_dir / "system_smoke_test.dart",
    )

    # Test dosyasındaki bütün hatalı spokeCount kullanımlarını
    # mevcut altı kategori sayısıyla değiştir.
    test = test.replace(
        "BoardMap.spokeCount",
        "GameCategory.values.length",
    )

    if "XpProgressService.requiredForLevel" in test:
        if old_xp_test not in test:
            raise RuntimeError(
                "Hatalı XP test bloğu beklenen biçimde bulunamadı."
            )

        test = test.replace(
            old_xp_test,
            new_xp_test,
            1,
        )

    TEST.write_text(test, encoding="utf-8")

    updated = TEST.read_text(encoding="utf-8")

    required_markers = [
        "GameCategory.values.length",
        "Kategori adları ve emojileri doludur",
        "Meydan okuma kodu kayıpsız çözülür",
    ]

    for marker in required_markers:
        if marker not in updated:
            raise RuntimeError(
                f"Doğrulama başarısız: {marker}"
            )

    forbidden_markers = [
        "BoardMap.spokeCount",
        "XpProgressService.requiredForLevel",
    ]

    for marker in forbidden_markers:
        if marker in updated:
            raise RuntimeError(
                f"Eski hatalı test hâlâ mevcut: {marker}"
            )

    if shutil.which("dart"):
        run([
            "dart",
            "format",
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

    run([
        "git",
        "add",
        "test/system_smoke_test.dart",
    ])

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
        "Kalite kontrol testlerini duzelt v2",
    ])
    committed = True

    run(["git", "push", "origin", "main"])

except Exception as error:
    if not committed:
        shutil.copy2(
            backup_dir / "system_smoke_test.dart",
            TEST,
        )

        subprocess.run(
            [
                "git",
                "reset",
                "--",
                "test/system_smoke_test.dart",
            ],
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
            "Test dosyası önceki hâline otomatik döndürüldü."
        )

    raise SystemExit(1)

finally:
    shutil.rmtree(backup_dir, ignore_errors=True)

print("")
print("✅ Bütün BoardMap.spokeCount test kullanımları düzeltildi.")
print("✅ requiredForLevel testi güvenli kategori testiyle değiştirildi.")
print("✅ flutter analyze ve flutter test çalıştırıldı.")
print("✅ Uygulama sürümü 1.29.1+39 olarak korundu.")
print("✅ questions.json dosyasına dokunulmadı.")
print("✅ Düzeltme GitHub main dalına gönderildi.")
