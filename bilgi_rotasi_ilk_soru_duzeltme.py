#!/usr/bin/env python3
from pathlib import Path
import json
import re
import shutil
import subprocess

QUESTIONS = Path("assets/questions.json")
CORRECTIONS = Path("soru_duzeltmeleri.json")
MAIN = Path("lib/main.dart")
PUBSPEC = Path("pubspec.yaml")

for path in [QUESTIONS, CORRECTIONS, MAIN, PUBSPEC]:
    if not path.exists():
        raise SystemExit(
            f"Gerekli dosya bulunamadı: {path}\n"
            "Bu betiği BilgiRotasi deposunun ana klasöründe çalıştır."
        )

try:
    questions = json.loads(QUESTIONS.read_text(encoding="utf-8"))
    corrections = json.loads(CORRECTIONS.read_text(encoding="utf-8"))
except Exception as error:
    raise SystemExit(f"JSON okunamadı: {error}")

if not isinstance(questions, list):
    raise SystemExit("assets/questions.json bir liste olmalı.")

if not isinstance(corrections, list) or len(corrections) != 4:
    raise SystemExit("Dört soru düzeltmesi bekleniyordu.")

ids = [str(item.get("id", "")) for item in questions]

if len(ids) != len(set(ids)):
    raise SystemExit("Soru bankasında yinelenen soru kimliği var.")

if len(questions) < 3000:
    raise SystemExit(
        f"En az 3000 soru bekleniyordu, {len(questions)} bulundu."
    )

index_by_id = {
    str(item.get("id", "")): index
    for index, item in enumerate(questions)
}

backup = Path("/tmp/bilgi_rotasi_ilk_duzeltme_oncesi_questions.json")
shutil.copy2(QUESTIONS, backup)
shutil.copy2(MAIN, "/tmp/bilgi_rotasi_ilk_duzeltme_oncesi_main.dart")
shutil.copy2(PUBSPEC, "/tmp/bilgi_rotasi_ilk_duzeltme_oncesi_pubspec.yaml")

changed_ids = []
already_correct_ids = []

for correction in corrections:
    question_id = correction["id"]

    if question_id not in index_by_id:
        raise SystemExit(f"Soru bulunamadı: {question_id}")

    item = questions[index_by_id[question_id]]

    if item.get("categoryIndex") != correction["expectedCategoryIndex"]:
        raise SystemExit(
            f"{question_id}: kategori beklenenden farklı. "
            "Güncel dosyayı kontrol et."
        )

    new_question = correction["question"]
    current_question = str(item.get("question", "")).strip()
    expected_old = correction["expectedOldQuestion"]

    if current_question == new_question:
        already_correct_ids.append(question_id)
        continue

    if current_question != expected_old:
        raise SystemExit(
            f"{question_id}: soru metni başka bir paket tarafından "
            "değiştirilmiş.\n"
            f"Mevcut: {current_question}\n"
            "Güncel dosyanın üzerine körlemesine yazılmadı."
        )

    options = correction["options"]
    answer_index = correction["answerIndex"]

    if not isinstance(options, list) or len(options) != 4:
        raise SystemExit(f"{question_id}: dört seçenek bulunmalı.")

    if len({str(option).casefold() for option in options}) != 4:
        raise SystemExit(f"{question_id}: seçenekler benzersiz değil.")

    if answer_index not in (0, 1, 2, 3):
        raise SystemExit(f"{question_id}: cevap indeksi geçersiz.")

    item["question"] = new_question
    item["options"] = options
    item["answerIndex"] = answer_index
    item["explanation"] = correction["explanation"]
    changed_ids.append(question_id)

# Tüm soru bankasının temel yapısını doğrula.
normalized_questions = set()

for position, item in enumerate(questions, start=1):
    question_id = str(item.get("id", "")).strip()
    question_text = str(item.get("question", "")).strip()
    options = item.get("options")
    answer_index = item.get("answerIndex")
    explanation = str(item.get("explanation", "")).strip()

    if not question_id:
        raise SystemExit(f"{position}. kayıtta soru kimliği yok.")

    if not question_text:
        raise SystemExit(f"{question_id}: soru metni boş.")

    normalized = " ".join(question_text.casefold().split())
    if normalized in normalized_questions:
        raise SystemExit(f"{question_id}: yinelenen tam soru metni.")

    normalized_questions.add(normalized)

    if not isinstance(options, list) or len(options) != 4:
        raise SystemExit(f"{question_id}: dört seçenek bulunmalı.")

    if len({str(option).strip().casefold() for option in options}) != 4:
        raise SystemExit(f"{question_id}: seçenekler farklı değil.")

    if answer_index not in (0, 1, 2, 3):
        raise SystemExit(f"{question_id}: cevap indeksi geçersiz.")

    if not explanation:
        raise SystemExit(f"{question_id}: açıklama boş.")

QUESTIONS.write_text(
    json.dumps(questions, ensure_ascii=False, indent=2) + "\n",
    encoding="utf-8",
)

# Sürümü otomatik bir hotfix artır.
pubspec = PUBSPEC.read_text(encoding="utf-8")
match = re.search(
    r"^version:\s*(\d+)\.(\d+)\.(\d+)\+(\d+)\s*$",
    pubspec,
    flags=re.MULTILINE,
)

if not match:
    raise SystemExit("pubspec.yaml sürüm satırı okunamadı.")

major, minor, patch, build = map(int, match.groups())
new_version = f"{major}.{minor}.{patch + 1}+{build + 1}"
display_version = f"{major}.{minor}.{patch + 1}"

pubspec = re.sub(
    r"^version:\s*.*$",
    f"version: {new_version}",
    pubspec,
    count=1,
    flags=re.MULTILINE,
)
PUBSPEC.write_text(pubspec, encoding="utf-8")

main = MAIN.read_text(encoding="utf-8")
main, replacements = re.subn(
    r"Bilgi Rotası • Sürüm \d+\.\d+(?:\.\d+)?",
    f"Bilgi Rotası • Sürüm {display_version}",
    main,
    count=1,
)

if replacements != 1:
    raise SystemExit("Ana menü sürüm metni güncellenemedi.")

MAIN.write_text(main, encoding="utf-8")

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
        "assets/questions.json",
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
            "Ilk hatali soru duzeltmeleri",
        ],
        check=True,
    )

subprocess.run(
    ["git", "push", "origin", "main"],
    check=True,
)

print("")
print("✅ İlk soru düzeltme paketi uygulandı.")
print(f"✅ Güncellenen sorular: {', '.join(changed_ids) or 'Yok'}")
if already_correct_ids:
    print(
        "ℹ️ Zaten düzeltilmiş sorular: "
        + ", ".join(already_correct_ids)
    )
print(f"✅ Toplam soru sayısı korundu: {len(questions)}")
print(f"✅ Yeni sürüm: {new_version}")
print("✅ Değişiklikler GitHub'a gönderildi.")
print(f"ℹ️ Eski soru bankası yedeği: {backup}")
