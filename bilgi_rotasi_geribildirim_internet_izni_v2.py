#!/usr/bin/env python3
from pathlib import Path
import re
import shutil
import subprocess

WORKFLOW = Path(".github/workflows/android-apk.yml")
MAIN = Path("lib/main.dart")
PUBSPEC = Path("pubspec.yaml")

for path in [WORKFLOW, MAIN, PUBSPEC]:
    if not path.exists():
        raise SystemExit(
            f"Gerekli dosya bulunamadı: {path}\n"
            "Bu betiği BilgiRotasi deposunun ana klasöründe çalıştır."
        )

workflow = WORKFLOW.read_text(encoding="utf-8")
main = MAIN.read_text(encoding="utf-8")
pubspec = PUBSPEC.read_text(encoding="utf-8")

shutil.copy2(
    WORKFLOW,
    "/tmp/bilgi_rotasi_workflow_internet_v2_oncesi.yml",
)
shutil.copy2(
    MAIN,
    "/tmp/bilgi_rotasi_main_internet_v2_oncesi.dart",
)
shutil.copy2(
    PUBSPEC,
    "/tmp/bilgi_rotasi_pubspec_internet_v2_oncesi.yaml",
)

permission_name = "android.permission.INTERNET"

if permission_name not in workflow:
    build_match = re.search(
        r"(?m)^([ \t]*)flutter build apk --release[ \t]*$",
        workflow,
    )

    if build_match is None:
        raise SystemExit(
            "APK derleme satırı bulunamadı: flutter build apk --release"
        )

    indent = build_match.group(1)
    build_line = build_match.group(0)

    permission_block = "\n".join([
        f"{indent}if ! grep -q '{permission_name}' "
        "android/app/src/main/AndroidManifest.xml; then",
        f"{indent}  sed -i "
        "'/<application/i\\    <uses-permission "
        "android:name=\"android.permission.INTERNET\" />' "
        "android/app/src/main/AndroidManifest.xml",
        f"{indent}fi",
        f"{indent}grep -q '{permission_name}' "
        "android/app/src/main/AndroidManifest.xml",
        "",
    ])

    workflow = workflow.replace(
        build_line,
        permission_block + build_line,
        1,
    )

if permission_name not in workflow:
    raise SystemExit("INTERNET izni derleme akışına eklenemedi.")

WORKFLOW.write_text(workflow, encoding="utf-8")

if "Bilgi Rotası • Sürüm 1.20.1" not in main:
    main = main.replace(
        "Bilgi Rotası • Sürüm 1.20",
        "Bilgi Rotası • Sürüm 1.20.1",
        1,
    )
MAIN.write_text(main, encoding="utf-8")

version_match = re.search(
    r"^version:\s*(\d+)\.(\d+)\.(\d+)\+(\d+)\s*$",
    pubspec,
    flags=re.MULTILINE,
)

if version_match is None:
    raise SystemExit("pubspec.yaml sürüm satırı okunamadı.")

major, minor, patch, build = map(int, version_match.groups())

if (major, minor, patch) < (1, 20, 1):
    new_version = f"1.20.1+{max(build + 1, 27)}"
    pubspec = re.sub(
        r"^version:\s*.*$",
        f"version: {new_version}",
        pubspec,
        count=1,
        flags=re.MULTILINE,
    )
else:
    new_version = f"{major}.{minor}.{patch}+{build}"

PUBSPEC.write_text(pubspec, encoding="utf-8")

updated_workflow = WORKFLOW.read_text(encoding="utf-8")

required_markers = [
    "android.permission.INTERNET",
    "grep -q",
    "flutter build apk --release",
]

for marker in required_markers:
    if marker not in updated_workflow:
        raise SystemExit(
            f"Kurulum doğrulaması başarısız: {marker}"
        )

subprocess.run(
    ["git", "diff", "--check"],
    check=True,
)

subprocess.run(
    [
        "git",
        "add",
        ".github/workflows/android-apk.yml",
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
            "Release APK internet izni V2",
        ],
        check=True,
    )

subprocess.run(
    ["git", "push", "origin", "main"],
    check=True,
)

print("")
print("✅ Release APK için INTERNET izni eklendi.")
print("✅ GitHub Actions yeni APK derlemesini başlattı.")
print(f"✅ Uygulama sürümü: {new_version}")
print("✅ Eski uygulamayı silmeden yeni APK'yı üzerine kur.")
print("✅ Sonraki soru ekranında bekleyen geri bildirimler gönderilecek.")
