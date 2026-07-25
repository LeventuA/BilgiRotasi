#!/usr/bin/env python3
from pathlib import Path
import copy
import json
import re
import shutil
import subprocess

QUESTIONS = Path("assets/questions.json")
CORRECTIONS = Path("tum_soru_duzeltmeleri_v2.json")
MAIN = Path("lib/main.dart")
PUBSPEC = Path("pubspec.yaml")

for path in [QUESTIONS, CORRECTIONS, MAIN, PUBSPEC]:
    if not path.exists():
        raise SystemExit(
            f"Gerekli dosya bulunamadı: {path}\n"
            "Bu betiği BilgiRotasi deposunun ana klasöründe çalıştır."
        )

questions = json.loads(QUESTIONS.read_text(encoding="utf-8"))
corrections = json.loads(CORRECTIONS.read_text(encoding="utf-8"))

if not isinstance(questions, list):
    raise SystemExit("assets/questions.json bir JSON listesi olmalı.")
if not isinstance(corrections, list) or len(corrections) != 58:
    raise SystemExit("Paket içinde 58 soru düzeltmesi bulunmalı.")

question_ids = [str(item.get("id", "")) for item in questions]
if len(question_ids) != len(set(question_ids)):
    raise SystemExit("Soru bankasında yinelenen soru kimliği bulundu.")

correction_ids = [str(item.get("id", "")) for item in corrections]
if len(correction_ids) != len(set(correction_ids)):
    raise SystemExit("Düzeltme paketinde yinelenen soru kimliği bulundu.")

index_by_id = {
    str(item.get("id", "")): index
    for index, item in enumerate(questions)
}
missing = [qid for qid in correction_ids if qid not in index_by_id]
if missing:
    raise SystemExit(
        "Soru bankasında bulunamayan kimlikler: " + ", ".join(missing)
    )

updated_questions = copy.deepcopy(questions)
changed_ids = []
already_correct_ids = []
conflicts = []

for correction in corrections:
    qid = correction["id"]
    item = updated_questions[index_by_id[qid]]
    current_question = str(item.get("question", "")).strip()
    new_question = correction["question"]
    accepted_old = correction.get(
        "acceptedOldQuestions",
        [correction["expectedOldQuestion"]],
    )

    if item.get("categoryIndex") != correction["expectedCategoryIndex"]:
        conflicts.append(
            f"{qid}: kategori değişmiş ({item.get('categoryIndex')})"
        )
        continue

    if current_question == new_question:
        already_correct_ids.append(qid)
        continue

    if current_question not in accepted_old:
        conflicts.append(
            f"{qid}: soru başka bir çalışma tarafından değiştirilmiş.\n"
            f"  Mevcut: {current_question}"
        )
        continue

    options = correction["options"]
    answer_index = correction["answerIndex"]
    explanation = str(correction["explanation"]).strip()

    if not isinstance(options, list) or len(options) != 4:
        raise SystemExit(f"{qid}: tam dört seçenek bulunmalı.")
    if len({str(x).strip().casefold() for x in options}) != 4:
        raise SystemExit(f"{qid}: seçeneklerin tamamı farklı olmalı.")
    if answer_index not in (0, 1, 2, 3):
        raise SystemExit(f"{qid}: cevap indeksi geçersiz.")
    if not explanation:
        raise SystemExit(f"{qid}: açıklama boş.")

    item["question"] = new_question
    item["options"] = options
    item["answerIndex"] = answer_index
    item["explanation"] = explanation
    changed_ids.append(qid)

if conflicts:
    print("")
    print("❌ Çakışma bulundu; hiçbir dosya değiştirilmedi.")
    for conflict in conflicts:
        print(conflict)
    print("")
    print("Bu çıktıyı ChatGPT'ye gönder.")
    raise SystemExit(1)

if not changed_ids:
    raise SystemExit("Bu paketteki sorular zaten güncel.")

for correction in corrections:
    item = updated_questions[index_by_id[correction["id"]]]
    if item.get("question") != correction["question"]:
        raise SystemExit(
            f"{correction['id']}: yeni soru doğrulanamadı."
        )
    if item.get("options") != correction["options"]:
        raise SystemExit(
            f"{correction['id']}: yeni seçenekler doğrulanamadı."
        )
    if item.get("answerIndex") != correction["answerIndex"]:
        raise SystemExit(
            f"{correction['id']}: doğru cevap doğrulanamadı."
        )

backup = Path("/tmp/bilgi_rotasi_soru_duzeltmeleri_v2_oncesi.json")
shutil.copy2(QUESTIONS, backup)

QUESTIONS.write_text(
    json.dumps(updated_questions, ensure_ascii=False, indent=2) + "\n",
    encoding="utf-8",
)

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

json.loads(QUESTIONS.read_text(encoding="utf-8"))
subprocess.run(["git", "diff", "--check"], check=True)

if shutil.which("flutter"):
    subprocess.run(
        ["flutter", "analyze", "--no-fatal-infos"],
        check=True,
    )

subprocess.run(
    ["git", "add", "assets/questions.json", "lib/main.dart", "pubspec.yaml"],
    check=True,
)

has_changes = subprocess.run(
    ["git", "diff", "--cached", "--quiet"],
    check=False,
).returncode != 0

if has_changes:
    subprocess.run(
        ["git", "commit", "-m", "Soru duzeltmelerini V2 olarak yenile"],
        check=True,
    )

subprocess.run(["git", "push", "origin", "main"], check=True)

print("")
print("✅ Soru düzeltmeleri V2 uygulandı.")
print(f"✅ Güncellenen soru sayısı: {len(changed_ids)}")
print(f"✅ Zaten güncel soru sayısı: {len(already_correct_ids)}")
print(f"✅ Yeni sürüm: {new_version}")
print("✅ Değişiklikler GitHub'a gönderildi.")
print(f"ℹ️ Yedek: {backup}")
