#!/usr/bin/env python3
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

REQUIRED_KEYS = {
    "id", "categoryIndex", "question", "options",
    "answerIndex", "difficulty", "explanation"
}
DIFFICULTIES = {"Kolay", "Orta", "Zor"}
STOPWORDS = {
    "hangi", "hangisi", "nedir", "kimdir", "icin", "ile", "bir", "ve",
    "olarak", "bilinen", "olan", "ne", "neden", "nasil", "kac", "daha",
    "en", "nerede", "neye", "ad", "adi", "denir"
}

def normalize(value: Any) -> str:
    text = str(value).replace("ı", "i").replace("İ", "I")
    text = unicodedata.normalize("NFKD", text)
    text = "".join(ch for ch in text if not unicodedata.combining(ch))
    return " ".join(re.sub(r"[^a-z0-9]+", " ", text.casefold()).split())

def content_tokens(value: Any) -> set[str]:
    return {
        token for token in normalize(value).split()
        if token not in STOPWORDS and len(token) > 2
    }

def correct_answer(question: dict[str, Any]) -> str:
    options = question.get("options")
    index = question.get("answerIndex")
    if isinstance(options, list) and isinstance(index, int) and index in range(len(options)):
        return str(options[index])
    return ""

def load_json_list(path: Path) -> list[dict[str, Any]]:
    try:
        value = json.loads(path.read_text(encoding="utf-8"))
    except Exception as exc:
        raise SystemExit(f"JSON okunamadı: {path} — {exc}")
    if not isinstance(value, list) or not all(isinstance(item, dict) for item in value):
        raise SystemExit(f"JSON kökünde nesne listesi gerekli: {path}")
    return value

def atomic_write(path: Path, value: list[dict[str, Any]]) -> None:
    payload = json.dumps(value, ensure_ascii=False, indent=2) + "\n"
    with tempfile.NamedTemporaryFile(
        "w", encoding="utf-8", dir=path.parent, delete=False
    ) as handle:
        handle.write(payload)
        temporary = Path(handle.name)
    os.replace(temporary, path)

def validate_question(question: dict[str, Any], label: str) -> list[str]:
    errors: list[str] = []
    if set(question) != REQUIRED_KEYS:
        errors.append(f"{label}: şema anahtarları hatalı")
    if not re.fullmatch(r"q\d+", str(question.get("id", ""))):
        errors.append(f"{label}: ID biçimi hatalı")
    if question.get("categoryIndex") not in range(6):
        errors.append(f"{label}: kategori 0–5 arasında değil")
    text = question.get("question")
    if not isinstance(text, str) or not text.endswith("?") or text.count("?") != 1:
        errors.append(f"{label}: soru tek soru işaretiyle bitmeli")
    options = question.get("options")
    if (
        not isinstance(options, list)
        or len(options) != 4
        or len({normalize(option) for option in options}) != 4
    ):
        errors.append(f"{label}: dört farklı seçenek gerekli")
    answer_index = question.get("answerIndex")
    if not isinstance(answer_index, int) or answer_index not in range(4):
        errors.append(f"{label}: answerIndex 0–3 arasında değil")
    if question.get("difficulty") not in DIFFICULTIES:
        errors.append(f"{label}: zorluk değeri hatalı")
    explanation = question.get("explanation")
    if not isinstance(explanation, str) or len(explanation.strip()) < 38:
        errors.append(f"{label}: açıklama çok kısa")
    return errors

def similarity(left: dict[str, Any], right: dict[str, Any]) -> tuple[float, float, bool]:
    left_text = normalize(left.get("question", ""))
    right_text = normalize(right.get("question", ""))
    sequence = SequenceMatcher(None, left_text, right_text).ratio()
    left_tokens = content_tokens(left.get("question", ""))
    right_tokens = content_tokens(right.get("question", ""))
    union = left_tokens | right_tokens
    jaccard = len(left_tokens & right_tokens) / len(union) if union else 0.0
    same_answer = normalize(correct_answer(left)) == normalize(correct_answer(right))
    return sequence, jaccard, same_answer

def is_probable_duplicate(left: dict[str, Any], right: dict[str, Any]) -> tuple[bool, float, float]:
    sequence, jaccard, same_answer = similarity(left, right)
    duplicate = (
        sequence >= 0.88
        or (same_answer and (sequence >= 0.70 or jaccard >= 0.52))
    )
    return duplicate, sequence, jaccard

def main() -> int:
    parser = argparse.ArgumentParser(
        description="Bilgi Rotası V3 — 1.000 soruyu güvenli biçimde ekler."
    )
    parser.add_argument("--repo-root", default=".")
    mode = parser.add_mutually_exclusive_group(required=True)
    mode.add_argument("--check", action="store_true")
    mode.add_argument("--apply", action="store_true")
    parser.add_argument(
        "--skip-conflicts",
        action="store_true",
        help="Çakışanları atlayıp yalnız temiz soruları ekler."
    )
    args = parser.parse_args()

    root = Path(args.repo_root).resolve()
    target = root / "assets" / "questions.json"
    incoming_path = (
        Path(__file__).resolve().parent
        / "v3_quality_1000_q55121_q56120.json"
    )
    if not target.exists():
        raise SystemExit(f"Ana soru dosyası bulunamadı: {target}")

    existing = load_json_list(target)
    incoming = load_json_list(incoming_path)

    errors: list[str] = []
    for position, question in enumerate(incoming, start=1):
        errors.extend(validate_question(question, f"yeni#{position}"))

    expected_ids = [f"q{number}" for number in range(55121, 56121)]
    if len(incoming) != 1000:
        errors.append("Yeni soru sayısı 1.000 değil")
    if [question.get("id") for question in incoming] != expected_ids:
        errors.append("ID aralığı/sırası q55121–q56120 değil")
    if len({normalize(q["question"]) for q in incoming}) != len(incoming):
        errors.append("V3 paketinin kendi içinde aynı soru metni var")
    if len({q["id"] for q in incoming}) != len(incoming):
        errors.append("V3 paketinin kendi içinde aynı ID var")

    # Paket içi güçlü yakın tekrar kontrolü.
    incoming_by_category: dict[int, list[dict[str, Any]]] = defaultdict(list)
    for question in incoming:
        incoming_by_category[question["categoryIndex"]].append(question)
    for category_questions in incoming_by_category.values():
        for index, question in enumerate(category_questions):
            for previous in category_questions[:index]:
                duplicate, sequence, jaccard = is_probable_duplicate(question, previous)
                if duplicate:
                    errors.append(
                        f"{question['id']} ile {previous['id']} paket içinde yakın tekrar "
                        f"(J={jaccard:.2f}, S={sequence:.2f})"
                    )
                    break

    if errors:
        for error in errors:
            print("HATA:", error)
        return 2

    existing_ids = {str(question.get("id")) for question in existing}
    existing_text = {
        normalize(question.get("question", "")): question
        for question in existing
    }
    existing_by_category_answer: dict[tuple[int, str], list[dict[str, Any]]] = defaultdict(list)
    existing_token_index: dict[tuple[int, str], list[int]] = defaultdict(list)
    for old_index, old_question in enumerate(existing):
        category = old_question.get("categoryIndex")
        if category not in range(6):
            continue
        existing_by_category_answer[
            (category, normalize(correct_answer(old_question)))
        ].append(old_question)
        for token in content_tokens(old_question.get("question", "")):
            existing_token_index[(category, token)].append(old_index)

    accepted: list[dict[str, Any]] = []
    conflicts: list[dict[str, Any]] = []

    for question in incoming:
        reasons: list[str] = []
        normalized_question = normalize(question["question"])
        category = question["categoryIndex"]

        if question["id"] in existing_ids:
            reasons.append("ID mevcut")
        if normalized_question in existing_text:
            other = existing_text[normalized_question]
            reasons.append(f"Soru metni {other.get('id')} ile aynı")

        if not reasons:
            compared: set[int] = set()

            # Aynı doğru cevaba sahip sorular, daha düşük eşiklerle karşılaştırılır.
            same_answer_candidates = existing_by_category_answer.get(
                (category, normalize(correct_answer(question))), []
            )
            for old_question in same_answer_candidates:
                old_index = id(old_question)
                compared.add(old_index)
                duplicate, sequence, jaccard = is_probable_duplicate(question, old_question)
                if duplicate:
                    reasons.append(
                        f"{old_question.get('id')} ile olası aynı bilgi "
                        f"(J={jaccard:.2f}, S={sequence:.2f})"
                    )
                    break

            # Farklı cevaplı ama neredeyse aynı metinleri yakalamak için yalnız
            # en az iki anlamlı kelime paylaşan adaylar taranır.
            if not reasons:
                token_hits: Counter[int] = Counter()
                for token in content_tokens(question["question"]):
                    token_hits.update(existing_token_index.get((category, token), []))
                candidate_indices = [
                    old_index for old_index, hit_count in token_hits.items()
                    if hit_count >= 2
                ]
                for old_index in candidate_indices:
                    old_question = existing[old_index]
                    if id(old_question) in compared:
                        continue
                    sequence = SequenceMatcher(
                        None,
                        normalized_question,
                        normalize(old_question.get("question", ""))
                    ).ratio()
                    if sequence >= 0.88:
                        left_tokens = content_tokens(question["question"])
                        right_tokens = content_tokens(old_question.get("question", ""))
                        union = left_tokens | right_tokens
                        jaccard = len(left_tokens & right_tokens) / len(union) if union else 0.0
                        reasons.append(
                            f"{old_question.get('id')} ile çok benzer soru metni "
                            f"(J={jaccard:.2f}, S={sequence:.2f})"
                        )
                        break

        if reasons:
            conflicts.append({
                "id": question["id"],
                "question": question["question"],
                "reasons": reasons,
            })
        else:
            accepted.append(question)

    timestamp = datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%SZ")
    output_dir = root / "quality_v3_1000_install_output"
    output_dir.mkdir(exist_ok=True)
    report_path = output_dir / f"v3_install_report_{timestamp}.json"
    report = {
        "existingCount": len(existing),
        "incomingCount": len(incoming),
        "acceptedCount": len(accepted),
        "conflictCount": len(conflicts),
        "newTotalIfApplied": len(existing) + len(accepted),
        "incomingCategoryCounts": dict(Counter(q["categoryIndex"] for q in incoming)),
        "acceptedCategoryCounts": dict(Counter(q["categoryIndex"] for q in accepted)),
        "conflicts": conflicts,
    }
    report_path.write_text(
        json.dumps(report, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )

    print("Mevcut soru       :", len(existing))
    print("V3 paketi         :", len(incoming))
    print("Temiz kabul       :", len(accepted))
    print("Çakışma           :", len(conflicts))
    print("Yeni olası toplam :", len(existing) + len(accepted))
    print("Rapor             :", report_path)

    if conflicts and not args.skip_conflicts:
        print(
            "\nÇakışma bulundu; questions.json değiştirilmedi. "
            "Temizleri eklemek için --skip-conflicts kullanın."
        )
        return 3

    if args.check:
        print("\nKontrol tamamlandı; ana dosya değiştirilmedi.")
        return 0

    if not accepted:
        print("Eklenecek temiz soru yok.")
        return 0

    backup_dir = root / ".question_backups"
    backup_dir.mkdir(exist_ok=True)
    backup_path = (
        backup_dir
        / f"questions.json.{timestamp}.before_v3_1000.bak"
    )
    shutil.copy2(target, backup_path)

    final_bank = existing + accepted
    atomic_write(target, final_bank)
    reloaded = load_json_list(target)

    if (
        len(reloaded) != len(final_bank)
        or len({q.get("id") for q in reloaded}) != len(reloaded)
    ):
        shutil.copy2(backup_path, target)
        raise SystemExit(
            "Yazma sonrası doğrulama başarısız; tam yedek geri yüklendi."
        )

    print("\nBaşarıyla eklendi :", len(accepted))
    print("Yeni toplam       :", len(reloaded))
    print("Tam yedek         :", backup_path)
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
