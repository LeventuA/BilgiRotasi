#!/usr/bin/env python3
"""Bilgi Rotası — 1.000 özgün kaliteli soru kurucusu.

Tek işlem:
    python3 install_quality_1000.py --repo-root . --apply

Kurucu:
- mevcut questions.json dosyasını doğrular,
- yeni 1.000 soruyu şema ve tekrar açısından tarar,
- çakışma varsa ana dosyayı değiştirmeden rapor üretir,
- temizse tam yedek alır ve 1.000 soruyu ekler.

Çakışanları atlayarak temiz soruları tek seferde eklemek için:
    python3 install_quality_1000.py --repo-root . --apply --skip-conflicts
"""

from __future__ import annotations

import argparse
import json
import os
import re
import shutil
import tempfile
import unicodedata
from collections import Counter, defaultdict
from datetime import datetime, timezone
from difflib import SequenceMatcher
from pathlib import Path
from typing import Any

REQUIRED = {
    "id", "categoryIndex", "question", "options",
    "answerIndex", "difficulty", "explanation",
}
DIFFICULTIES = {"Kolay", "Orta", "Zor"}
STOPWORDS = {
    "hangi", "hangisi", "hangisidir", "nedir", "kimdir", "kac",
    "icin", "ile", "bir", "ve", "olarak", "bilinen", "adli",
    "olan", "olur", "neden", "nasil", "neye", "nerede", "neresidir",
    "daha", "en", "bu", "ne", "kimin", "kime",
}
CATEGORY_NAMES = {
    0: "Coğrafya",
    1: "Eğlence",
    2: "Tarih",
    3: "Sanat & Edebiyat",
    4: "Bilim & Doğa",
    5: "Spor",
}


def normalize(value: Any) -> str:
    text = str(value).replace("ı", "i").replace("İ", "I")
    text = unicodedata.normalize("NFKD", text)
    text = "".join(ch for ch in text if not unicodedata.combining(ch))
    text = text.casefold()
    text = re.sub(r"[^a-z0-9]+", " ", text)
    return " ".join(text.split())


def content_tokens(value: Any) -> set[str]:
    return {
        token
        for token in normalize(value).split()
        if token not in STOPWORDS and len(token) > 2
    }


def correct_answer(question: dict[str, Any]) -> str:
    options = question.get("options")
    index = question.get("answerIndex")
    if (
        isinstance(options, list)
        and isinstance(index, int)
        and 0 <= index < len(options)
    ):
        return str(options[index])
    return ""


def validate_question(question: dict[str, Any], label: str) -> list[str]:
    errors: list[str] = []

    if set(question) != REQUIRED:
        errors.append(f"{label}: alan şeması farklı")

    if not re.fullmatch(r"q\d+", str(question.get("id", ""))):
        errors.append(f"{label}: geçersiz ID")

    if question.get("categoryIndex") not in range(6):
        errors.append(f"{label}: geçersiz kategori")

    text = question.get("question")
    if not isinstance(text, str) or not text.strip():
        errors.append(f"{label}: soru metni yok")
    elif not text.endswith("?") or text.count("?") != 1:
        errors.append(f"{label}: soru tek bir '?' ile bitmeli")
    elif len(text) > 170:
        errors.append(f"{label}: soru gereğinden uzun")

    options = question.get("options")
    if (
        not isinstance(options, list)
        or len(options) != 4
        or not all(isinstance(option, str) and option.strip() for option in options)
    ):
        errors.append(f"{label}: dört dolu seçenek gerekli")
    elif len({normalize(option) for option in options}) != 4:
        errors.append(f"{label}: seçenekler benzersiz değil")

    answer_index = question.get("answerIndex")
    if not isinstance(answer_index, int) or not 0 <= answer_index <= 3:
        errors.append(f"{label}: answerIndex 0-3 aralığında olmalı")

    if question.get("difficulty") not in DIFFICULTIES:
        errors.append(f"{label}: geçersiz difficulty")

    explanation = question.get("explanation")
    if not isinstance(explanation, str) or len(explanation.strip()) < 35:
        errors.append(f"{label}: açıklama yetersiz")

    banned = (
        "icin dogru eslestirme",
        "dogru yayin yili",
        "olarak verilir",
        "birinci soru",
        "ikinci soru",
    )
    combined = normalize(f"{text} {explanation}")
    for phrase in banned:
        if phrase in combined:
            errors.append(f"{label}: seri üretim dili içeriyor")

    return errors


def load_list(path: Path) -> list[dict[str, Any]]:
    try:
        value = json.loads(path.read_text(encoding="utf-8"))
    except FileNotFoundError as error:
        raise SystemExit(f"Dosya bulunamadı: {path}") from error
    except json.JSONDecodeError as error:
        raise SystemExit(f"Geçersiz JSON: {path} — {error}") from error

    if not isinstance(value, list) or not all(isinstance(item, dict) for item in value):
        raise SystemExit(f"JSON kökü soru nesnelerinden oluşan liste olmalı: {path}")
    return value


def atomic_write(path: Path, value: Any) -> None:
    encoded = json.dumps(value, ensure_ascii=False, indent=2) + "\n"
    with tempfile.NamedTemporaryFile(
        "w",
        encoding="utf-8",
        dir=path.parent,
        delete=False,
    ) as handle:
        handle.write(encoded)
        temporary_path = Path(handle.name)
    os.replace(temporary_path, path)


def compare_questions(
    incoming: dict[str, Any],
    existing: dict[str, Any],
) -> tuple[bool, str, float, float]:
    new_text = normalize(incoming["question"])
    old_text = normalize(existing.get("question", ""))
    new_answer = normalize(correct_answer(incoming))
    old_answer = normalize(correct_answer(existing))

    if new_text == old_text:
        return True, "birebir aynı soru metni", 1.0, 1.0

    if new_text == old_text and new_answer == old_answer:
        return True, "aynı soru-cevap çifti", 1.0, 1.0

    # Aynı kategoride ve aynı doğru cevapta güçlü yeniden ifade edilmiş tekrar.
    if (
        incoming["categoryIndex"] == existing.get("categoryIndex")
        and new_answer
        and new_answer == old_answer
    ):
        new_tokens = content_tokens(incoming["question"])
        old_tokens = content_tokens(existing.get("question", ""))
        union = new_tokens | old_tokens
        jaccard = len(new_tokens & old_tokens) / len(union) if union else 0.0
        sequence = SequenceMatcher(None, new_text, old_text).ratio()
        if jaccard >= 0.78 or sequence >= 0.90:
            return True, "aynı bilgi güçlü biçimde yeniden sorulmuş", jaccard, sequence
        return False, "", jaccard, sequence

    return False, "", 0.0, 0.0


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--repo-root", default=".")
    mode = parser.add_mutually_exclusive_group(required=True)
    mode.add_argument("--check", action="store_true")
    mode.add_argument("--apply", action="store_true")
    parser.add_argument(
        "--skip-conflicts",
        action="store_true",
        help="Çakışan soruları atlayıp temiz olanları ekler.",
    )
    args = parser.parse_args()

    root = Path(args.repo_root).resolve()
    target = root / "assets" / "questions.json"
    script_root = Path(__file__).resolve().parent
    incoming_path = script_root / "quality_1000_q53121_q54120.json"

    existing = load_list(target)
    incoming = load_list(incoming_path)

    validation_errors: list[str] = []
    for index, question in enumerate(incoming, 1):
        validation_errors.extend(validate_question(question, f"yeni#{index}"))

    if len(incoming) != 1000:
        validation_errors.append(f"Yeni soru sayısı 1000 değil: {len(incoming)}")

    expected_ids = [f"q{i}" for i in range(53121, 54121)]
    if [question.get("id") for question in incoming] != expected_ids:
        validation_errors.append("Yeni soru ID aralığı q53121-q54120 değil")

    new_ids = [question["id"] for question in incoming]
    new_texts = [normalize(question["question"]) for question in incoming]
    new_pairs = [
        normalize(question["question"]) + "|" +
        normalize(correct_answer(question))
        for question in incoming
    ]
    if len(set(new_ids)) != 1000:
        validation_errors.append("Yeni pakette ID tekrarı var")
    if len(set(new_texts)) != 1000:
        validation_errors.append("Yeni pakette birebir soru tekrarı var")
    if len(set(new_pairs)) != 1000:
        validation_errors.append("Yeni pakette soru-cevap tekrarı var")

    if validation_errors:
        for error in validation_errors:
            print("HATA:", error)
        return 2

    existing_ids = {str(question.get("id")) for question in existing}
    existing_by_category: dict[int, list[dict[str, Any]]] = defaultdict(list)
    for question in existing:
        category = question.get("categoryIndex")
        if category in range(6):
            existing_by_category[category].append(question)

    accepted: list[dict[str, Any]] = []
    conflicts: list[dict[str, Any]] = []

    for question in incoming:
        reasons: list[str] = []
        if question["id"] in existing_ids:
            reasons.append("ID mevcut bankada zaten var")

        if not reasons:
            for old in existing_by_category[question["categoryIndex"]]:
                duplicate, reason, jaccard, sequence = compare_questions(question, old)
                if duplicate:
                    reasons.append(
                        f"{old.get('id')}: {reason} "
                        f"(Jaccard={jaccard:.2f}, benzerlik={sequence:.2f})"
                    )
                    break

        if reasons:
            conflicts.append({
                "id": question["id"],
                "category": CATEGORY_NAMES[question["categoryIndex"]],
                "question": question["question"],
                "correctAnswer": correct_answer(question),
                "reasons": reasons,
            })
        else:
            accepted.append(question)

    timestamp = datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%SZ")
    output_dir = root / "quality_1000_install_output"
    output_dir.mkdir(parents=True, exist_ok=True)

    report = {
        "timestampUtc": timestamp,
        "existingCount": len(existing),
        "incomingCount": len(incoming),
        "acceptedCount": len(accepted),
        "conflictCount": len(conflicts),
        "newTotalIfApplied": len(existing) + len(accepted),
        "categoryCountsAccepted": {
            CATEGORY_NAMES[index]: Counter(
                q["categoryIndex"] for q in accepted
            )[index]
            for index in range(6)
        },
        "difficultyCountsAccepted": dict(
            Counter(q["difficulty"] for q in accepted)
        ),
        "conflicts": conflicts,
    }

    report_path = output_dir / f"quality_1000_install_report_{timestamp}.json"
    report_path.write_text(
        json.dumps(report, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )

    print(f"Mevcut soru       : {len(existing)}")
    print(f"Yeni paket        : {len(incoming)}")
    print(f"Temiz kabul       : {len(accepted)}")
    print(f"Çakışma           : {len(conflicts)}")
    print(f"Rapor             : {report_path}")

    if conflicts and not args.skip_conflicts:
        print()
        print("Çakışma bulunduğu için questions.json değiştirilmedi.")
        print("Çakışanları atlayarak eklemek için --skip-conflicts kullanın.")
        return 3

    if args.check:
        print()
        print("Kontrol tamamlandı; assets/questions.json değiştirilmedi.")
        return 0

    if not accepted:
        print("Eklenecek temiz soru bulunamadı.")
        return 0

    backup_dir = root / ".question_backups"
    backup_dir.mkdir(parents=True, exist_ok=True)
    backup_path = (
        backup_dir
        / f"questions.json.{timestamp}.before_quality_1000.bak"
    )
    shutil.copy2(target, backup_path)

    final_data = existing + accepted
    atomic_write(target, final_data)

    reloaded = load_list(target)
    if len(reloaded) != len(final_data):
        shutil.copy2(backup_path, target)
        raise SystemExit(
            "Yazma sonrası soru sayısı kontrolü başarısız; yedek geri yüklendi."
        )

    final_ids = [str(question.get("id")) for question in reloaded]
    if len(final_ids) != len(set(final_ids)):
        shutil.copy2(backup_path, target)
        raise SystemExit(
            "Yazma sonrası ID tekrarı bulundu; yedek geri yüklendi."
        )

    print()
    print(f"Başarıyla eklendi : {len(accepted)}")
    print(f"Yeni toplam       : {len(reloaded)}")
    print(f"Tam yedek         : {backup_path}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
