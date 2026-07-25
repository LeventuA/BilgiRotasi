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
        raise SystemExit(f"Gerekli dosya bulunamadı: {path}")

workflow = WORKFLOW.read_text(encoding="utf-8")
main = MAIN.read_text(encoding="utf-8")
pubspec = PUBSPEC.read_text(encoding="utf-8")

if "android.permission.INTERNET" in workflow:
    raise SystemExit("İnternet izni düzeltmesi zaten kurulmuş.")

if "flutter build apk --release" not in workflow:
    raise SystemExit("APK derleme satırı bulunamadı.")

shutil.copy2(
    WORKFLOW,
    "/tmp/bilgi_rotasi_workflow_internet_izni_oncesi.yml",
)
shutil.copy2(
    MAIN,
    "/tmp/bilgi_rotasi_main_internet_izni_oncesi.dart",
)
shutil.copy2(
    PUBSPEC,
    "/tmp/bilgi_rotasi_pubspec_internet_izni_oncesi.yaml",
)

marker = "           flutter build apk --release"

permission_lines = [
    "           python3 - <<'PY'",
    "           from pathlib import Path",
    "",
    '           manifest = Path("android/app/src/main/AndroidManifest.xml")',
    '           source = manifest.read_text(encoding="utf-8")',
    "           permission = (",
    "               '<uses-permission '",
    "               'android:name=\"android.permission.INTERNET\" />'",
    "           )",
    "",
    "           if permission not in source:",
    "               source = source.replace(",
    '                   "<application",',
    '                   f"    {permission}\\n    <application",',
    "                   1,",
    "               )",
    "",
    '           manifest.write_text(source, encoding="utf-8")',
    "           PY",
    "",
    "           grep -q 'android.permission.INTERNET' \\",
    "             android/app/src/main/AndroidManifest.xml",
    "",
]

permission_block = "\n".join(permission_lines)

workflow = workflow.replace(
    marker,
    permission_block + marker,
    1,
)

if "android.permission.INTERNET" not in workflow:
    raise SystemExit("İnternet izni adımı eklenemedi.")

WORKFLOW.write_text(workflow, encoding="utf-8")

main = main.replace(
    "Bilgi Rotası • Sürüm 1.20",
    "Bilgi Rotası • Sürüm 1.20.1",
    1,
)
MAIN.write_text(main, encoding="utf-8")

match = re.search(
    r"^version:\s*(\d+)\.(\d+)\.(\d+)\+(\d+)\s*$",
    pubspec,
    flags=re.MULTILINE,
)

if not match:
    raise SystemExit("pubspec.yaml sürüm satırı okunamadı.")

major, minor, patch, build = map(int, match.groups())
new_version = f"{major}.{minor}.{patch + 1}+{build + 1}"

pubspec = re.sub(
    r"^version:\s*.*$",
    f"version: {new_version}",
    pubspec,
    count=1,
    flags=re.MULTILINE,
)
PUBSPEC.write_text(pubspec, encoding="utf-8")

subprocess.run(["git", "diff", "--check"], check=True)

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
            "Release APK internet izni",
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
print(f"✅ Yeni sürüm: {new_version}")
print("✅ Mevcut uygulamayı silmeden yeni APK'yı üzerine kur.")
print("✅ Sonraki soru ekranında bekleyen geri bildirimler gönderilecek.")
