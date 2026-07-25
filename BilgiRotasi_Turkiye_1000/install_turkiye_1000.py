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

REQUIRED_KEYS = {"id", "categoryIndex", "question", "options", "answerIndex", "difficulty", "explanation"}
DIFFICULTIES = {"Kolay", "Orta", "Zor"}
STOPWORDS = {
    "hangi","hangisi","nedir","kimdir","icin","ile","bir","ve","olarak","bilinen","olan",
    "ne","neden","nasil","kac","daha","en","nerede","ad","adi","denir","yilinda","yili",
    "gerceklesti","yapimi","odulu","filmi","dizisi","oyunu","gorevi","calismasi","hakkinda",
    "dogru","bilgi","organizasyonu","sampiyonu","ilk","kez","ilgili","tarihli"
}
BANNED_STEMS = (
    "hangi sehri temsil eder",
    "hangi bolgenin futbol takimi",
    "hangi ilin takimi",
    "dogru eslestirme",
    "hangisi sirasiyla",
)

def normalize(value: Any) -> str:
    text = str(value).replace("ı", "i").replace("İ", "I").replace("i\u0307", "i")
    text = unicodedata.normalize("NFKD", text)
    text = "".join(ch for ch in text if not unicodedata.combining(ch))
    return " ".join(re.sub(r"[^a-z0-9]+", " ", text.casefold()).split())

def content_tokens(value: Any) -> set[str]:
    return {t for t in normalize(value).split() if t not in STOPWORDS and len(t) > 2}

def correct_answer(q: dict[str, Any]) -> str:
    options = q.get("options")
    idx = q.get("answerIndex")
    if isinstance(options, list) and isinstance(idx, int) and idx in range(len(options)):
        return str(options[idx])
    return ""

def load(path: Path) -> list[dict[str, Any]]:
    try:
        value = json.loads(path.read_text(encoding="utf-8"))
    except Exception as exc:
        raise SystemExit(f"JSON okunamadı: {path} — {exc}")
    if not isinstance(value, list) or not all(isinstance(x, dict) for x in value):
        raise SystemExit(f"JSON kökünde nesne listesi gerekli: {path}")
    return value

def atomic_write(path: Path, value: list[dict[str, Any]]) -> None:
    payload = json.dumps(value, ensure_ascii=False, indent=2) + "\n"
    with tempfile.NamedTemporaryFile("w", encoding="utf-8", dir=path.parent, delete=False) as handle:
        handle.write(payload)
        temp_path = Path(handle.name)
    os.replace(temp_path, path)

def validate(q: dict[str, Any], label: str, require_id: bool = True) -> list[str]:
    errors: list[str] = []
    if set(q) != REQUIRED_KEYS:
        errors.append(f"{label}: şema anahtarları hatalı")
    if require_id and not re.fullmatch(r"q\d+", str(q.get("id", ""))):
        errors.append(f"{label}: ID biçimi hatalı")
    if q.get("categoryIndex") not in range(6):
        errors.append(f"{label}: kategori 0–5 arasında değil")
    text = q.get("question")
    if not isinstance(text, str) or not text.endswith("?") or text.count("?") != 1:
        errors.append(f"{label}: soru tek soru işaretiyle bitmeli")
    options = q.get("options")
    if not isinstance(options, list) or len(options) != 4 or len({normalize(x) for x in options}) != 4:
        errors.append(f"{label}: dört farklı seçenek gerekli")
    idx = q.get("answerIndex")
    if not isinstance(idx, int) or idx not in range(4):
        errors.append(f"{label}: answerIndex 0–3 arasında değil")
    if q.get("difficulty") not in DIFFICULTIES:
        errors.append(f"{label}: zorluk değeri hatalı")
    explanation = q.get("explanation")
    if not isinstance(explanation, str) or len(explanation.strip()) < 38:
        errors.append(f"{label}: açıklama çok kısa")
    if isinstance(text, str):
        nt = normalize(text)
        if any(stem in nt for stem in BANNED_STEMS):
            errors.append(f"{label}: yasaklanan aşırı kolay soru kalıbı")
        answer = normalize(correct_answer(q))
        if len(answer) >= 4 and answer in nt:
            errors.append(f"{label}: doğru cevap soru metninde açıkça yer alıyor")
    return errors

def probable_same_fact(a: dict[str, Any], b: dict[str, Any]) -> tuple[bool, float, float, int]:
    qa = normalize(a.get("question", ""))
    qb = normalize(b.get("question", ""))
    sequence = SequenceMatcher(None, qa, qb).ratio()
    ta = content_tokens(a.get("question", ""))
    tb = content_tokens(b.get("question", ""))
    union = ta | tb
    jaccard = len(ta & tb) / len(union) if union else 0.0
    shared = len(ta & tb)
    same_answer = normalize(correct_answer(a)) == normalize(correct_answer(b))
    years_a = set(re.findall(r"\b202[0-6]\b", str(a.get("question", ""))))
    years_b = set(re.findall(r"\b202[0-6]\b", str(b.get("question", ""))))
    duplicate = (
        same_answer
        and not (years_a and years_b and years_a != years_b)
        and sequence >= 0.94
        and jaccard >= 0.72
        and shared >= 4
    )
    return duplicate, sequence, jaccard, shared

class BankIndex:
    def __init__(self, questions: list[dict[str, Any]]) -> None:
        self.questions: list[dict[str, Any]] = []
        self.ids: set[str] = set()
        self.texts: dict[str, dict[str, Any]] = {}
        self.by_answer: defaultdict[tuple[int, str], list[int]] = defaultdict(list)
        self.token_index: defaultdict[tuple[int, str], list[int]] = defaultdict(list)
        for q in questions:
            self.add(q)

    def add(self, q: dict[str, Any]) -> None:
        pos = len(self.questions)
        self.questions.append(q)
        self.ids.add(str(q.get("id")))
        self.texts[normalize(q.get("question", ""))] = q
        cat = q.get("categoryIndex")
        if cat in range(6):
            self.by_answer[(cat, normalize(correct_answer(q)))].append(pos)
            for token in content_tokens(q.get("question", "")):
                self.token_index[(cat, token)].append(pos)

    def conflict_reasons(self, q: dict[str, Any]) -> list[str]:
        reasons: list[str] = []
        qid = str(q.get("id"))
        nq = normalize(q.get("question", ""))
        cat = q.get("categoryIndex")
        if qid in self.ids:
            reasons.append("ID mevcut")
        if nq in self.texts:
            reasons.append(f"Soru metni {self.texts[nq].get('id')} ile aynı")
        if reasons or cat not in range(6):
            return reasons

        candidates: Counter[int] = Counter()
        for token in content_tokens(q.get("question", "")):
            candidates.update(self.token_index.get((cat, token), []))
        for pos in self.by_answer.get((cat, normalize(correct_answer(q))), []):
            candidates[pos] += 3

        for pos, hits in candidates.most_common(120):
            if hits < 2:
                break
            old = self.questions[pos]
            duplicate, sequence, jaccard, shared = probable_same_fact(q, old)
            if duplicate:
                reasons.append(
                    f"{old.get('id')} ile olası aynı bilgi "
                    f"(J={jaccard:.2f}, S={sequence:.2f}, ortak={shared})"
                )
                break
        return reasons

def main() -> int:
    parser = argparse.ArgumentParser(
        description="Bilgi Rotası — Türkiye özel 1.000 soruyu güvenli biçimde ekler."
    )
    parser.add_argument("--repo-root", default=".")
    mode = parser.add_mutually_exclusive_group(required=True)
    mode.add_argument("--check", action="store_true")
    mode.add_argument("--apply", action="store_true")
    parser.add_argument(
        "--skip-conflicts",
        action="store_true",
        help="Yedek havuzla çözülemeyen çakışmaları atlayıp temiz soruları ekler.",
    )
    args = parser.parse_args()

    root = Path(args.repo_root).resolve()
    target = root / "assets" / "questions.json"
    package_root = Path(__file__).resolve().parent
    incoming_path = package_root / "turkiye_1000_q58121_q59120.json"
    reserve_path = package_root / "reserve_pool_120.json"

    if not target.exists():
        raise SystemExit(f"Ana soru dosyası bulunamadı: {target}")

    existing = load(target)
    incoming = load(incoming_path)
    reserves = load(reserve_path)

    errors: list[str] = []
    for pos, q in enumerate(incoming, 1):
        errors.extend(validate(q, f"yeni#{pos}"))
    if len(incoming) != 1000:
        errors.append("Yeni soru sayısı 1.000 değil")
    expected_ids = [f"q{x}" for x in range(58121, 59121)]
    if [q.get("id") for q in incoming] != expected_ids:
        errors.append("ID aralığı/sırası q58121–q59120 değil")
    if len({normalize(q["question"]) for q in incoming}) != len(incoming):
        errors.append("Paketin kendi içinde aynı soru metni var")

    for pos, reserve in enumerate(reserves, 1):
        candidate = dict(reserve)
        candidate["id"] = "q999999"
        errors.extend(validate(candidate, f"yedek#{pos}"))
    if len(reserves) != 120:
        errors.append("Yedek soru sayısı 120 değil")

    if errors:
        for error in errors:
            print("HATA:", error)
        return 2

    bank = BankIndex(existing)
    accepted: list[dict[str, Any]] = []
    unresolved: list[dict[str, Any]] = []
    substitutions: list[dict[str, Any]] = []
    used_reserves: set[int] = set()
    original_clean = 0

    for q in incoming:
        reasons = bank.conflict_reasons(q)
        if not reasons:
            accepted.append(q)
            bank.add(q)
            original_clean += 1
            continue

        replacement: dict[str, Any] | None = None
        replacement_pos: int | None = None

        # Önce aynı kategorideki yedekleri, ardından diğerlerini dene.
        order = [
            i for i, r in enumerate(reserves)
            if i not in used_reserves and r.get("categoryIndex") == q.get("categoryIndex")
        ]
        order += [
            i for i, r in enumerate(reserves)
            if i not in used_reserves and i not in order
        ]

        for reserve_pos in order:
            candidate = dict(reserves[reserve_pos])
            candidate["id"] = q["id"]
            candidate_reasons = bank.conflict_reasons(candidate)
            if not candidate_reasons:
                replacement = candidate
                replacement_pos = reserve_pos
                break

        if replacement is not None and replacement_pos is not None:
            used_reserves.add(replacement_pos)
            accepted.append(replacement)
            bank.add(replacement)
            substitutions.append(
                {
                    "id": q["id"],
                    "rejectedQuestion": q["question"],
                    "rejectedReasons": reasons,
                    "replacementReserveId": reserves[replacement_pos]["id"],
                    "replacementQuestion": replacement["question"],
                }
            )
        else:
            unresolved.append(
                {"id": q["id"], "question": q["question"], "reasons": reasons}
            )

    timestamp = datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%SZ")
    output_dir = root / "quality_turkiye_1000_install_output"
    output_dir.mkdir(exist_ok=True)
    report_path = output_dir / f"turkiye_1000_install_report_{timestamp}.json"
    report = {
        "existingCount": len(existing),
        "incomingCount": len(incoming),
        "originalCleanCount": original_clean,
        "reserveSubstitutionCount": len(substitutions),
        "acceptedCount": len(accepted),
        "unresolvedConflictCount": len(unresolved),
        "newTotalIfApplied": len(existing) + len(accepted),
        "substitutions": substitutions,
        "unresolvedConflicts": unresolved,
    }
    report_path.write_text(
        json.dumps(report, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )

    print("Mevcut soru          :", len(existing))
    print("Türkiye paketi       :", len(incoming))
    print("Doğrudan temiz       :", original_clean)
    print("Yedekle değiştirilen :", len(substitutions))
    print("Çözülemeyen çakışma  :", len(unresolved))
    print("Temiz kabul          :", len(accepted))
    print("Yeni olası toplam    :", len(existing) + len(accepted))
    print("Rapor                :", report_path)

    if unresolved and not args.skip_conflicts:
        print(
            "\nYedek havuzla çözülemeyen çakışma bulundu; questions.json değiştirilmedi. "
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
    backup = backup_dir / f"questions.json.{timestamp}.before_turkiye_1000.bak"
    shutil.copy2(target, backup)

    final = existing + accepted
    atomic_write(target, final)
    reloaded = load(target)

    if len(reloaded) != len(final) or len({q.get("id") for q in reloaded}) != len(reloaded):
        shutil.copy2(backup, target)
        raise SystemExit("Yazma sonrası doğrulama başarısız; yedek geri yüklendi.")

    print("\nBaşarıyla eklendi :", len(accepted))
    print("Yeni toplam       :", len(reloaded))
    print("Tam yedek         :", backup)
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
