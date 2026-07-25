#!/usr/bin/env python3
"""Bilgi Rotası ikinci 10.000 soru paketini mevcut assets/questions.json dosyasına güvenle ekler.

Tam questions.json dosyası taşımaz. Repo içindeki güncel dosyayı okur, yedekler,
ID/metin/şema çakışmalarını kontrol eder ve yalnızca yeni soruları sona ekler.
"""

from __future__ import annotations

import argparse
import difflib
import json
import os
import re
import shutil
import sys
import tempfile
import unicodedata
from collections import Counter, defaultdict
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

ID_RE = re.compile(r"^q(\d+)$")
ALLOWED_DIFFICULTIES = {"Kolay", "Orta", "Zor"}
REQUIRED_KEYS = {
    "id", "categoryIndex", "question", "options",
    "answerIndex", "difficulty", "explanation",
}
CATEGORY_NAMES = {
    0: "Coğrafya",
    1: "Eğlence",
    2: "Tarih",
    3: "Sanat & Edebiyat",
    4: "Bilim & Doğa",
    5: "Spor",
}


def normalize_text(value: str) -> str:
    value = value.replace("−", "-")
    value = re.sub(r"(?<!\\w)-(?=\\d)", " eksi ", value)
    value = value.replace("ı", "i").replace("İ", "I")
    value = unicodedata.normalize("NFKD", value)
    value = "".join(ch for ch in value if not unicodedata.combining(ch))
    value = value.casefold()
    value = re.sub(r"[^a-z0-9]+", " ", value)
    return " ".join(value.split())


def load_json_list(path: Path) -> list[dict[str, Any]]:
    try:
        data = json.loads(path.read_text(encoding="utf-8"))
    except FileNotFoundError as exc:
        raise SystemExit(f"Dosya bulunamadı: {path}") from exc
    except json.JSONDecodeError as exc:
        raise SystemExit(f"Geçersiz JSON: {path} — {exc}") from exc
    if not isinstance(data, list):
        raise SystemExit(f"JSON kökü liste olmalı: {path}")
    if not all(isinstance(item, dict) for item in data):
        raise SystemExit(f"Bütün soru kayıtları nesne olmalı: {path}")
    return data


def question_number(qid: Any) -> int | None:
    if not isinstance(qid, str):
        return None
    match = ID_RE.fullmatch(qid)
    return int(match.group(1)) if match else None


def validate_question(question: dict[str, Any], origin: str, min_id: int) -> list[str]:
    errors: list[str] = []
    missing = REQUIRED_KEYS - set(question)
    if missing:
        return [f"{origin}: eksik alanlar: {sorted(missing)}"]

    qid = question.get("id")
    number = question_number(qid)
    if number is None:
        errors.append(f"{origin}: geçersiz id: {qid!r}")
    elif number < min_id:
        errors.append(f"{origin}: yeni ID q{min_id} veya daha büyük olmalı: {qid}")

    category = question.get("categoryIndex")
    if not isinstance(category, int) or category not in CATEGORY_NAMES:
        errors.append(f"{origin}/{qid}: categoryIndex 0-5 arasında tam sayı olmalı")

    text = question.get("question")
    if not isinstance(text, str) or len(text.strip()) < 12:
        errors.append(f"{origin}/{qid}: soru metni çok kısa veya geçersiz")
    elif not text.strip().endswith("?"):
        errors.append(f"{origin}/{qid}: soru metni '?' ile bitmeli")

    options = question.get("options")
    if (
        not isinstance(options, list)
        or len(options) != 4
        or not all(isinstance(x, str) and x.strip() for x in options)
    ):
        errors.append(f"{origin}/{qid}: options tam olarak dört dolu metin içermeli")
    elif len({normalize_text(x) for x in options}) != 4:
        errors.append(f"{origin}/{qid}: seçenekler birbirinden farklı olmalı")

    answer = question.get("answerIndex")
    if not isinstance(answer, int) or not 0 <= answer <= 3:
        errors.append(f"{origin}/{qid}: answerIndex 0-3 arasında tam sayı olmalı")

    difficulty = question.get("difficulty")
    if difficulty not in ALLOWED_DIFFICULTIES:
        errors.append(f"{origin}/{qid}: difficulty Kolay, Orta veya Zor olmalı")

    explanation = question.get("explanation")
    if not isinstance(explanation, str) or len(explanation.strip()) < 25:
        errors.append(f"{origin}/{qid}: açıklama en az 25 karakter olmalı")

    return errors


def validate_existing(existing: list[dict[str, Any]]) -> list[str]:
    errors: list[str] = []
    ids: list[str] = []
    for index, question in enumerate(existing):
        qid = question.get("id")
        if question_number(qid) is None:
            errors.append(f"Mevcut dosya kaydı {index + 1}: geçersiz id {qid!r}")
        else:
            ids.append(qid)
    duplicates = [qid for qid, count in Counter(ids).items() if count > 1]
    if duplicates:
        errors.append(f"Mevcut questions.json içinde tekrarlanan ID'ler: {duplicates[:20]}")
    return errors


def discover_packages(script_root: Path, selected: list[str] | None) -> list[Path]:
    package_dir = script_root / "packages"
    if selected:
        paths: list[Path] = []
        for raw in selected:
            candidate = Path(raw)
            if not candidate.is_absolute():
                direct = (Path.cwd() / candidate).resolve()
                bundled = (package_dir / candidate).resolve()
                candidate = direct if direct.exists() else bundled
            paths.append(candidate)
    else:
        paths = sorted(package_dir.glob("package_*.json"))
    if not paths:
        raise SystemExit("Kurulacak paket bulunamadı.")
    return paths


def correct_answer_norm(question: dict[str, Any]) -> str:
    options = question.get("options")
    index = question.get("answerIndex")
    if (
        isinstance(options, list)
        and isinstance(index, int)
        and 0 <= index < len(options)
        and isinstance(options[index], str)
    ):
        return normalize_text(options[index])
    return ""


def conflict_scan(
    existing: list[dict[str, Any]],
    incoming_with_origin: list[tuple[dict[str, Any], str]],
    near_threshold: float,
) -> tuple[list[tuple[dict[str, Any], str]], list[dict[str, Any]]]:
    existing_ids = {str(q.get("id")) for q in existing}
    existing_norms: dict[str, tuple[str, str]] = {}
    existing_norm_list: list[str] = []

    for q in existing:
        text = q.get("question")
        if isinstance(text, str):
            ntext = normalize_text(text)
            existing_norms.setdefault(
                ntext,
                (str(q.get("id")), correct_answer_norm(q)),
            )
            existing_norm_list.append(ntext)

    accepted: list[tuple[dict[str, Any], str]] = []
    conflicts: list[dict[str, Any]] = []
    incoming_ids: set[str] = set()
    incoming_norms: dict[str, tuple[str, str]] = {}

    for question, origin in incoming_with_origin:
        qid = question["id"]
        ntext = normalize_text(question["question"])
        answer_norm = correct_answer_norm(question)
        reasons: list[str] = []

        if qid in existing_ids:
            reasons.append("ID mevcut dosyada zaten var")
        if qid in incoming_ids:
            reasons.append("ID paketler içinde tekrar ediyor")
        if ntext in existing_norms:
            reasons.append(f"Soru metni mevcut {existing_norms[ntext][0]} ile birebir aynı")
        if ntext in incoming_norms:
            reasons.append(f"Soru metni paket içindeki {incoming_norms[ntext][0]} ile birebir aynı")

        # Şablon serilerinde farklı bilgi ve farklı doğru cevapların yanlışlıkla
        # engellenmemesi için yakın benzerlik, aynı doğru cevap varsa veya metin
        # neredeyse birebir ise çatışma sayılır.
        if not reasons and near_threshold > 0:
            matches = difflib.get_close_matches(
                ntext, existing_norm_list, n=3, cutoff=near_threshold
            )
            for match_norm in matches:
                other_id, other_answer = existing_norms[match_norm]
                ratio = difflib.SequenceMatcher(None, ntext, match_norm).ratio()
                if answer_norm == other_answer:
                    reasons.append(
                        f"Mevcut {other_id} ile çok benzer ({ratio:.3f}); "
                        f"doğru cevap eşleşmesi={answer_norm == other_answer}"
                    )
                    break

            if not reasons:
                for other_norm, (other_id, other_answer) in incoming_norms.items():
                    ratio = difflib.SequenceMatcher(None, ntext, other_norm).ratio()
                    if ratio >= near_threshold and answer_norm == other_answer:
                        reasons.append(
                            f"Paket içindeki {other_id} ile çok benzer ({ratio:.3f}); "
                            f"doğru cevap eşleşmesi={answer_norm == other_answer}"
                        )
                        break

        if reasons:
            conflicts.append({
                "id": qid,
                "question": question["question"],
                "package": origin,
                "reasons": reasons,
            })
        else:
            accepted.append((question, origin))
            incoming_ids.add(qid)
            incoming_norms[ntext] = (qid, answer_norm)

    return accepted, conflicts


def atomic_write_json(path: Path, data: list[dict[str, Any]]) -> None:
    encoded = json.dumps(data, ensure_ascii=False, indent=2) + "\n"
    with tempfile.NamedTemporaryFile(
        "w", encoding="utf-8", dir=path.parent, delete=False
    ) as handle:
        handle.write(encoded)
        temporary = handle.name
    os.replace(temporary, path)


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Bilgi Rotası soru paketlerini güvenli biçimde kurar."
    )
    parser.add_argument("--repo-root", default=".", help="BilgiRotasi repo kökü")
    mode = parser.add_mutually_exclusive_group(required=True)
    mode.add_argument("--check", action="store_true", help="Doğrula; dosyayı değiştirme")
    mode.add_argument("--apply", action="store_true", help="Kontroller geçerse ekle")
    parser.add_argument(
        "--package", action="append",
        help="Belirli paket dosyası; birden fazla kez kullanılabilir",
    )
    parser.add_argument("--min-id", type=int, default=13121)
    parser.add_argument("--max-package-size", type=int, default=1000)
    parser.add_argument("--near-threshold", type=float, default=0.0)
    parser.add_argument(
        "--skip-conflicts", action="store_true",
        help="Çakışan kayıtları atlayıp temiz kayıtlarla devam et",
    )
    args = parser.parse_args()

    script_root = Path(__file__).resolve().parent
    repo_root = Path(args.repo_root).resolve()
    target = repo_root / "assets" / "questions.json"

    existing = load_json_list(target)
    existing_errors = validate_existing(existing)
    if existing_errors:
        for error in existing_errors:
            print(f"HATA: {error}", file=sys.stderr)
        return 2

    package_paths = discover_packages(script_root, args.package)
    incoming_with_origin: list[tuple[dict[str, Any], str]] = []
    schema_errors: list[str] = []
    package_stats: list[dict[str, Any]] = []

    for package_path in package_paths:
        package_questions = load_json_list(package_path)
        if len(package_questions) > args.max_package_size:
            schema_errors.append(
                f"{package_path.name}: paket sınırı aşıldı "
                f"({len(package_questions)} > {args.max_package_size})"
            )
        for index, question in enumerate(package_questions):
            schema_errors.extend(
                validate_question(
                    question,
                    f"{package_path.name}#{index + 1}",
                    args.min_id,
                )
            )
            incoming_with_origin.append((question, package_path.name))
        package_stats.append({
            "file": str(package_path),
            "count": len(package_questions),
        })

    if schema_errors:
        for error in schema_errors:
            print(f"HATA: {error}", file=sys.stderr)
        return 2

    accepted, conflicts = conflict_scan(
        existing, incoming_with_origin, args.near_threshold
    )

    accepted_by_package: dict[str, int] = defaultdict(int)
    for _, origin in accepted:
        accepted_by_package[origin] += 1

    timestamp = datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%SZ")
    report = {
        "timestampUtc": timestamp,
        "mode": "apply" if args.apply else "check",
        "target": str(target),
        "packages": package_stats,
        "existingCount": len(existing),
        "incomingCount": len(incoming_with_origin),
        "acceptedCount": len(accepted),
        "acceptedByPackage": dict(accepted_by_package),
        "conflictCount": len(conflicts),
        "conflicts": conflicts,
    }
    report_path = script_root / f"install_report_{timestamp}.json"
    report_path.write_text(
        json.dumps(report, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )

    print(f"Mevcut soru sayısı : {len(existing)}")
    print(f"Paketlerdeki soru  : {len(incoming_with_origin)}")
    print(f"Kabul edilen       : {len(accepted)}")
    print(f"Çakışma            : {len(conflicts)}")
    for package_name, count in sorted(accepted_by_package.items()):
        print(f"  {package_name}: {count}")
    print(f"Rapor              : {report_path}")

    if conflicts and not args.skip_conflicts:
        print("\nKurulum durduruldu. Çakışmaları rapordan inceleyin.", file=sys.stderr)
        print(
            "Temiz kayıtları eklemek için --skip-conflicts kullanılabilir.",
            file=sys.stderr,
        )
        return 3

    if args.check:
        print("\nKontrol tamamlandı; questions.json değiştirilmedi.")
        return 0

    clean_questions = [question for question, _ in accepted]
    if not clean_questions:
        print("Eklenecek çakışmasız soru yok; dosya değiştirilmedi.")
        return 0

    backup_dir = repo_root / ".question_backups"
    backup_dir.mkdir(parents=True, exist_ok=True)
    backup_path = backup_dir / f"questions.json.{timestamp}.bak"
    shutil.copy2(target, backup_path)

    final_data = existing + clean_questions
    atomic_write_json(target, final_data)

    reloaded = load_json_list(target)
    final_ids = [str(q.get("id")) for q in reloaded]
    if len(reloaded) != len(final_data) or len(final_ids) != len(set(final_ids)):
        shutil.copy2(backup_path, target)
        raise SystemExit(
            "Yazma sonrası bütünlük kontrolü başarısız; yedek geri yüklendi."
        )

    print(f"\nBaşarıyla eklendi   : {len(clean_questions)}")
    print(f"Yeni toplam         : {len(reloaded)}")
    print(f"Yedek               : {backup_path}")
    print("İnceleme komutu     : git diff -- assets/questions.json")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
