#!/usr/bin/env python3
"""Bilgi Rotası soru paketlerini mevcut assets/questions.json dosyasına güvenli biçimde ekler.

Bu betik hiçbir zaman paketin içinde tam questions.json taşımaz. Kurulum anında repodaki
mevcut dosyayı okur, doğrular, yedekler ve yalnızca yeni soruları listenin sonuna ekler.
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
from collections import Counter
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


def validate_question(question: dict[str, Any], origin: str, min_id: int) -> list[str]:
    errors: list[str] = []
    missing = REQUIRED_KEYS - set(question)
    if missing:
        errors.append(f"{origin}: eksik alanlar: {sorted(missing)}")
        return errors

    qid = question.get("id")
    match = ID_RE.fullmatch(qid) if isinstance(qid, str) else None
    if not match:
        errors.append(f"{origin}: geçersiz id: {qid!r}")
    elif int(match.group(1)) < min_id:
        errors.append(f"{origin}: yeni soru ID'si q{min_id} veya daha büyük olmalı: {qid}")

    category = question.get("categoryIndex")
    if not isinstance(category, int) or category not in CATEGORY_NAMES:
        errors.append(f"{origin}/{qid}: categoryIndex 0-5 arasında tam sayı olmalı")

    text = question.get("question")
    if not isinstance(text, str) or len(text.strip()) < 12:
        errors.append(f"{origin}/{qid}: soru metni çok kısa veya geçersiz")
    elif not text.strip().endswith("?"):
        errors.append(f"{origin}/{qid}: soru metni '?' ile bitmeli")

    options = question.get("options")
    if not isinstance(options, list) or len(options) != 4 or not all(isinstance(x, str) and x.strip() for x in options):
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
        if not isinstance(qid, str) or not ID_RE.fullmatch(qid):
            errors.append(f"Mevcut dosya satırı {index + 1}: geçersiz id {qid!r}")
        else:
            ids.append(qid)
    duplicate_ids = [qid for qid, count in Counter(ids).items() if count > 1]
    if duplicate_ids:
        errors.append(f"Mevcut questions.json içinde tekrarlanan ID'ler var: {duplicate_ids[:20]}")
    return errors


def discover_packages(script_root: Path, selected: list[str] | None) -> list[Path]:
    package_dir = script_root / "packages"
    if selected:
        paths = []
        for raw in selected:
            path = Path(raw)
            if not path.is_absolute():
                direct = (Path.cwd() / path).resolve()
                bundled = (package_dir / path).resolve()
                path = direct if direct.exists() else bundled
            paths.append(path)
    else:
        paths = sorted(package_dir.glob("package_*.json"))
    if not paths:
        raise SystemExit("Kurulacak paket bulunamadı.")
    return paths


def correct_answer_norm(question: dict[str, Any]) -> str:
    options = question.get("options")
    answer_index = question.get("answerIndex")
    if (
        isinstance(options, list)
        and isinstance(answer_index, int)
        and 0 <= answer_index < len(options)
        and isinstance(options[answer_index], str)
    ):
        return normalize_text(options[answer_index])
    return ""


def conflict_scan(
    existing: list[dict[str, Any]],
    incoming: list[dict[str, Any]],
    near_threshold: float,
) -> tuple[list[dict[str, Any]], list[dict[str, Any]]]:
    existing_ids = {str(q.get("id")) for q in existing}
    existing_norms: dict[str, tuple[str, str]] = {}
    existing_norm_list: list[str] = []
    for q in existing:
        text = q.get("question")
        if isinstance(text, str):
            norm = normalize_text(text)
            existing_norms.setdefault(
                norm,
                (str(q.get("id")), correct_answer_norm(q)),
            )
            existing_norm_list.append(norm)

    accepted: list[dict[str, Any]] = []
    conflicts: list[dict[str, Any]] = []
    incoming_ids: set[str] = set()
    incoming_norms: dict[str, tuple[str, str]] = {}

    for q in incoming:
        qid = q["id"]
        norm = normalize_text(q["question"])
        answer_norm = correct_answer_norm(q)
        reasons: list[str] = []

        if qid in existing_ids:
            reasons.append("ID mevcut dosyada zaten var")
        if qid in incoming_ids:
            reasons.append("ID paketler içinde tekrar ediyor")
        if norm in existing_norms:
            reasons.append(f"Soru metni mevcut {existing_norms[norm][0]} ile birebir aynı")
        if norm in incoming_norms:
            reasons.append(f"Soru metni paket içindeki {incoming_norms[norm][0]} ile birebir aynı")

        # Yakın metin kontrolünde aynı doğru cevabı da ararız.
        # Böylece dekatlon/heptatlon gibi benzer kalıplı fakat farklı bilgiler
        # yanlışlıkla tekrar sayılmaz. Aşırı yüksek benzerlik (>= 0.985) ise
        # doğru cevap farklı olsa bile güvenlik amacıyla engellenir.
        if not reasons and near_threshold > 0:
            matches = difflib.get_close_matches(norm, existing_norm_list, n=3, cutoff=near_threshold)
            for match_norm in matches:
                other_id, other_answer = existing_norms[match_norm]
                ratio = difflib.SequenceMatcher(None, norm, match_norm).ratio()
                if answer_norm == other_answer or ratio >= 0.985:
                    reasons.append(
                        f"Mevcut {other_id} ile çok benzer ({ratio:.3f}); "
                        f"doğru cevap eşleşmesi={answer_norm == other_answer}"
                    )
                    break

            if not reasons:
                for other_norm, (other_id, other_answer) in incoming_norms.items():
                    ratio = difflib.SequenceMatcher(None, norm, other_norm).ratio()
                    if ratio >= near_threshold and (
                        answer_norm == other_answer or ratio >= 0.985
                    ):
                        reasons.append(
                            f"Paket içindeki {other_id} ile çok benzer ({ratio:.3f}); "
                            f"doğru cevap eşleşmesi={answer_norm == other_answer}"
                        )
                        break

        if reasons:
            conflicts.append({"id": qid, "question": q["question"], "reasons": reasons})
        else:
            accepted.append(q)
            incoming_ids.add(qid)
            incoming_norms[norm] = (qid, answer_norm)

    return accepted, conflicts


def atomic_write_json(path: Path, data: list[dict[str, Any]]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    encoded = json.dumps(data, ensure_ascii=False, indent=2) + "\n"
    with tempfile.NamedTemporaryFile("w", encoding="utf-8", dir=path.parent, delete=False) as handle:
        handle.write(encoded)
        temp_name = handle.name
    os.replace(temp_name, path)


def main() -> int:
    parser = argparse.ArgumentParser(description="Bilgi Rotası soru paketlerini güvenli biçimde kurar.")
    parser.add_argument("--repo-root", default=".", help="BilgiRotasi reposunun kök klasörü")
    mode = parser.add_mutually_exclusive_group(required=True)
    mode.add_argument("--check", action="store_true", help="Yalnızca doğrula; dosyayı değiştirme")
    mode.add_argument("--apply", action="store_true", help="Kontroller geçerse soruları ekle")
    parser.add_argument("--package", action="append", help="Belirli paket dosyası; birden fazla kullanılabilir")
    parser.add_argument("--min-id", type=int, default=3001, help="İzin verilen en küçük yeni soru numarası")
    parser.add_argument("--near-threshold", type=float, default=0.93, help="Yakın metin benzerliği eşiği")
    parser.add_argument("--skip-conflicts", action="store_true", help="Çakışan soruları atlayıp kalanları kur")
    args = parser.parse_args()

    script_root = Path(__file__).resolve().parent
    repo_root = Path(args.repo_root).resolve()
    target = repo_root / "assets" / "questions.json"
    existing = load_json_list(target)

    existing_errors = validate_existing(existing)
    if existing_errors:
        print("\n".join(f"HATA: {e}" for e in existing_errors), file=sys.stderr)
        return 2

    package_paths = discover_packages(script_root, args.package)
    incoming: list[dict[str, Any]] = []
    schema_errors: list[str] = []
    package_stats: list[dict[str, Any]] = []

    for package_path in package_paths:
        package_questions = load_json_list(package_path)
        if len(package_questions) > 500:
            schema_errors.append(f"{package_path.name}: paket 500 sorudan büyük ({len(package_questions)})")
        for index, question in enumerate(package_questions):
            schema_errors.extend(validate_question(question, f"{package_path.name}#{index + 1}", args.min_id))
        incoming.extend(package_questions)
        package_stats.append({"file": str(package_path), "count": len(package_questions)})

    if schema_errors:
        print("\n".join(f"HATA: {e}" for e in schema_errors), file=sys.stderr)
        return 2

    accepted, conflicts = conflict_scan(existing, incoming, args.near_threshold)
    timestamp = datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%SZ")
    report = {
        "timestampUtc": timestamp,
        "mode": "apply" if args.apply else "check",
        "target": str(target),
        "packages": package_stats,
        "existingCount": len(existing),
        "incomingCount": len(incoming),
        "acceptedCount": len(accepted),
        "conflictCount": len(conflicts),
        "conflicts": conflicts,
        "incomingByCategory": {
            CATEGORY_NAMES[i]: sum(1 for q in incoming if q["categoryIndex"] == i)
            for i in CATEGORY_NAMES
        },
    }
    report_path = script_root / f"install_report_{timestamp}.json"
    report_path.write_text(json.dumps(report, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")

    print(f"Mevcut soru sayısı : {len(existing)}")
    print(f"Paketteki soru     : {len(incoming)}")
    print(f"Kabul edilen       : {len(accepted)}")
    print(f"Çakışma            : {len(conflicts)}")
    print(f"Rapor               : {report_path}")

    if conflicts and not args.skip_conflicts:
        print("\nKurulum durduruldu. Çakışmaları rapordan inceleyin.", file=sys.stderr)
        print("Bilinçli olarak atlamak için --skip-conflicts kullanılabilir.", file=sys.stderr)
        return 3

    if args.check:
        print("\nKontrol tamamlandı; questions.json değiştirilmedi.")
        return 0

    if not accepted:
        print("Eklenecek çakışmasız soru kalmadı; dosya değiştirilmedi.")
        return 0

    backup_dir = repo_root / ".question_backups"
    backup_dir.mkdir(parents=True, exist_ok=True)
    backup_path = backup_dir / f"questions.json.{timestamp}.bak"
    shutil.copy2(target, backup_path)

    final_data = existing + accepted
    atomic_write_json(target, final_data)

    # Yazma sonrası temel bütünlük kontrolü.
    reloaded = load_json_list(target)
    final_ids = [str(q.get("id")) for q in reloaded]
    if len(reloaded) != len(final_data) or len(final_ids) != len(set(final_ids)):
        shutil.copy2(backup_path, target)
        raise SystemExit("Yazma sonrası bütünlük kontrolü başarısız oldu; yedek geri yüklendi.")

    print(f"\nBaşarıyla eklendi   : {len(accepted)}")
    print(f"Yeni toplam         : {len(reloaded)}")
    print(f"Yedek               : {backup_path}")
    print("Sonraki adım: git diff -- assets/questions.json")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
