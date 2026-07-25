#!/usr/bin/env python3
from pathlib import Path
import re
import shutil
import subprocess

MAIN = Path("lib/main.dart")
PUBSPEC = Path("pubspec.yaml")
FEEDBACK_SOURCE = Path("question_feedback.dart")
FEEDBACK_TARGET = Path("lib/question_feedback.dart")
SCREEN_SOURCE = Path("question_screen_feedback.txt")

for path in [
    MAIN,
    PUBSPEC,
    FEEDBACK_SOURCE,
    SCREEN_SOURCE,
]:
    if not path.exists():
        raise SystemExit(f"Gerekli dosya bulunamadı: {path}")

main_source = MAIN.read_text(encoding="utf-8")

if "part 'question_feedback.dart';" in main_source:
    raise SystemExit(
        "Soru geri bildirim sistemi zaten kurulmuş."
    )

if "class QuestionScreen extends StatefulWidget" not in main_source:
    raise SystemExit("QuestionScreen bulunamadı.")

if "class PlayerData {" not in main_source:
    raise SystemExit("PlayerData sınırı bulunamadı.")

print("")
print("Google Apps Script dağıtımından aldığın Web uygulaması URL'sini yapıştır.")
print("URL /exec ile bitmelidir.")
endpoint = input("Web uygulaması URL'si: ").strip()

if not endpoint.startswith("https://") or "/exec" not in endpoint:
    raise SystemExit(
        "Geçerli bir Apps Script Web uygulaması URL'si girilmedi."
    )

feedback_source = FEEDBACK_SOURCE.read_text(
    encoding="utf-8",
).replace(
    "__FEEDBACK_WEB_APP_URL__",
    endpoint,
)

shutil.copy2(
    MAIN,
    "/tmp/bilgi_rotasi_feedback_oncesi_main.dart",
)
shutil.copy2(
    PUBSPEC,
    "/tmp/bilgi_rotasi_feedback_oncesi_pubspec.yaml",
)

FEEDBACK_TARGET.write_text(
    feedback_source,
    encoding="utf-8",
)

main_source = main_source.replace(
    "part 'daily_challenge.dart';",
    "part 'daily_challenge.dart';\n"
    "part 'question_feedback.dart';",
    1,
)

start = main_source.index(
    "class QuestionScreen extends StatefulWidget"
)
end = main_source.index("class PlayerData {", start)

new_screen = SCREEN_SOURCE.read_text(
    encoding="utf-8",
).rstrip() + "\n\n"

main_source = (
    main_source[:start]
    + new_screen
    + main_source[end:]
)

main_source = main_source.replace(
    "Bilgi Rotası • Sürüm 1.19",
    "Bilgi Rotası • Sürüm 1.20",
    1,
)

MAIN.write_text(main_source, encoding="utf-8")

pubspec = PUBSPEC.read_text(encoding="utf-8")
match = re.search(
    r"^version:\s*(\d+)\.(\d+)\.(\d+)\+(\d+)\s*$",
    pubspec,
    flags=re.MULTILINE,
)

if not match:
    raise SystemExit("Sürüm satırı okunamadı.")

major, minor, patch, build = map(int, match.groups())
new_version = f"{major}.{minor + 1}.0+{build + 1}"

pubspec = re.sub(
    r"^version:\s*.*$",
    f"version: {new_version}",
    pubspec,
    count=1,
    flags=re.MULTILINE,
)
PUBSPEC.write_text(pubspec, encoding="utf-8")

updated = MAIN.read_text(encoding="utf-8")

for marker in [
    "part 'question_feedback.dart';",
    "Bu soru nasıldı? • İsteğe bağlı",
    "Kolaydı",
    "Zordu",
    "Soru hatalı",
]:
    if marker not in (
        updated
        + FEEDBACK_TARGET.read_text(encoding="utf-8")
    ):
        raise SystemExit(
            f"Kurulum doğrulaması başarısız: {marker}"
        )

if shutil.which("dart"):
    subprocess.run(
        [
            "dart",
            "format",
            "lib/main.dart",
            "lib/question_feedback.dart",
        ],
        check=True,
    )

subprocess.run(["git", "diff", "--check"], check=True)

if shutil.which("flutter"):
    subprocess.run(
        ["flutter", "analyze", "--no-fatal-infos"],
        check=True,
    )

subprocess.run(
    [
        "git",
        "add",
        "lib/main.dart",
        "lib/question_feedback.dart",
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
            "Soru zorluk oylari ve hata bildirimleri",
        ],
        check=True,
    )

subprocess.run(
    ["git", "push", "origin", "main"],
    check=True,
)

print("")
print("✅ Kolaydı, Zordu ve Hatalı butonları eklendi.")
print("✅ Seçim yapmak isteğe bağlıdır.")
print("✅ Hata nedenleri ve açıklama kutusu eklendi.")
print("✅ İnternet yoksa geri bildirim cihazda kuyruğa alınır.")
print("✅ Sonraki soru açılışında kuyruk yeniden gönderilir.")
print("✅ Aynı cihaz aynı soruya iki zorluk oyu veremez.")
print("✅ Aynı cihaz aynı soruyu iki kez hatalı bildiremez.")
print(f"✅ Yeni sürüm: {new_version}")
print("✅ Değişiklikler GitHub'a gönderildi.")
