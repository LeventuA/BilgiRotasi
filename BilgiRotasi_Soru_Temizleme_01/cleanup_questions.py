#!/usr/bin/env python3
"""Bilgi Rotası soru bankası kalite temizliği.

Bu betik yeni soru üretmez. Mevcut assets/questions.json dosyasını okur,
kötü/tekrarlı/yapay soruları ayırır, ayrıntılı rapor oluşturur ve --apply
kullanılırsa yalnızca seçilen soruları ana dosyada bırakır.

ID'ler yeniden numaralandırılmaz; aralarda boşluk kalması normaldir.
"""

from __future__ import annotations

import argparse
import csv
import hashlib
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
EXPECTED_GITHUB_BLOB_SHA = "2b97abd83d58a5d32b02ee7ded47adbf79a360ab"
KNOWN_AUDITED_RANGES = ((3001, 6120), (13121, 53120))
CATEGORY_NAMES = {
    0: "Coğrafya",
    1: "Eğlence",
    2: "Tarih",
    3: "Sanat & Edebiyat",
    4: "Bilim & Doğa",
    5: "Spor",
}

# q001-q3000: ilk banka, sıkı ama nispeten daha yüksek koruma kotası.
# q6121-q13120: yerel arşivde bulunmayan seri, çok daha sıkı kota.
CATEGORY_LIMITS = {
    "original": 260,
    "missing_generated": 80,
}
FAMILY_LIMITS = {
    "original": {
        "capital": 20,
        "director_creator": 50,
        "author": 50,
        "year": 25,
        "location": 55,
        "sports_result": 25,
        "science_fact": 65,
        "art_fact": 70,
        "entertainment_fact": 70,
        "history_fact": 60,
        "sport_fact": 60,
        "geo_fact": 60,
        "other": 80,
    },
    "missing_generated": {
        "capital": 10,
        "director_creator": 20,
        "author": 20,
        "year": 10,
        "location": 20,
        "sports_result": 10,
        "science_fact": 20,
        "art_fact": 25,
        "entertainment_fact": 25,
        "history_fact": 20,
        "sport_fact": 20,
        "geo_fact": 20,
        "other": 30,
    },
}

STOPWORDS = {
    "hangi", "hangisi", "hangisidir", "nedir", "kimdir", "olarak", "icin",
    "ile", "bir", "ve", "de", "da", "mi", "mı", "mu", "mü", "asagidaki",
    "dogru", "olan", "oldugu", "yer", "yil", "tarih", "soru", "cevap",
}


def normalize(value: str, *, keep_digits: bool = True) -> str:
    value = value.replace("ı", "i").replace("İ", "I")
    value = unicodedata.normalize("NFKD", value)
    value = "".join(ch for ch in value if not unicodedata.combining(ch))
    value = value.casefold()
    pattern = r"[^a-z0-9]+" if keep_digits else r"[^a-z]+"
    value = re.sub(pattern, " ", value)
    return " ".join(value.split())


def question_number(qid: Any) -> int | None:
    if not isinstance(qid, str):
        return None
    match = ID_RE.fullmatch(qid)
    return int(match.group(1)) if match else None


def correct_answer(question: dict[str, Any]) -> str:
    options = question.get("options")
    answer_index = question.get("answerIndex")
    if (
        isinstance(options, list)
        and isinstance(answer_index, int)
        and 0 <= answer_index < len(options)
        and isinstance(options[answer_index], str)
    ):
        return options[answer_index]
    return ""


def git_blob_sha(raw: bytes) -> str:
    header = f"blob {len(raw)}\0".encode("utf-8")
    return hashlib.sha1(header + raw).hexdigest()


def token_set(question: dict[str, Any]) -> set[str]:
    tokens = normalize(str(question.get("question", ""))).split()
    return {token for token in tokens if token not in STOPWORDS and len(token) > 2}


def infer_family(question: dict[str, Any]) -> str:
    text = normalize(str(question.get("question", "")))
    category = question.get("categoryIndex")

    if " baskenti " in f" {text} " or text.endswith(" baskenti hangisidir"):
        return "capital"
    if any(word in text for word in (" yonetmeni ", " yaraticisi ", " bestecisi ")):
        return "director_creator"
    if any(word in text for word in (" yazari ", " kim tarafindan yazilmistir", " kaleme almistir")):
        return "author"
    if any(phrase in text for phrase in (" hangi yilda ", " kac yilinda ", " hangi tarihte ")):
        return "year"
    if any(
        phrase in text
        for phrase in (
            " hangi ulkede ", " hangi ulkeye ", " hangi kitada ",
            " hangi sehirde ", " nerededir ", " nerede bulunur ",
        )
    ):
        return "location"
    if any(
        phrase in text
        for phrase in (
            " hangi takim kazandi", " kim sampiyon oldu", " turnuvasini kim kazandi",
            " finalini kim kazandi", " kupasini kim kazandi",
        )
    ):
        return "sports_result"

    if category == 0:
        return "geo_fact"
    if category == 1:
        return "entertainment_fact"
    if category == 2:
        return "history_fact"
    if category == 3:
        return "art_fact"
    if category == 4:
        return "science_fact"
    if category == 5:
        return "sport_fact"
    return "other"


def hard_reasons(question: dict[str, Any]) -> list[str]:
    reasons: list[str] = []
    qid = question.get("id")
    text_raw = str(question.get("question", "")).strip()
    text = normalize(text_raw)
    explanation = str(question.get("explanation", "")).strip()
    options = question.get("options")
    answer_index = question.get("answerIndex")

    if question_number(qid) is None:
        reasons.append("geçersiz ID")
    if question.get("categoryIndex") not in CATEGORY_NAMES:
        reasons.append("geçersiz kategori")
    if not text_raw.endswith("?"):
        reasons.append("soru işareti eksik")
    if len(text_raw) < 12:
        reasons.append("çok kısa soru")
    if len(text_raw) > 165:
        reasons.append("aşırı uzun soru")
    if text_raw.count("?") > 1:
        reasons.append("birden fazla soru içeriyor")
    if not isinstance(options, list) or len(options) != 4:
        reasons.append("dört seçenek yok")
    elif not all(isinstance(option, str) and option.strip() for option in options):
        reasons.append("boş/geçersiz seçenek")
    elif len({normalize(option) for option in options}) != 4:
        reasons.append("tekrarlanan seçenek")
    if not isinstance(answer_index, int) or not 0 <= answer_index <= 3:
        reasons.append("geçersiz answerIndex")
    if len(explanation) < 20:
        reasons.append("yetersiz açıklama")

    pattern_groups = {
        "birleşik veya meta soru": (
            r"\bbirinci soru\b|\bikinci soru\b|\biki soruya\b|"
            r"\bdogru yanit sirasi\b|\bdogru cevap dizisi\b|"
            r"\bilk olarak\b|\bsirasiyla hangi secenekte\b|"
            r"\basagidaki seceneklerden hangisi hem\b"
        ),
        "sıralama/karşılaştırma şablonu": (
            r"eskiden yeniye|yeniden eskiye|tarihlerine gore|yillarina gore|"
            r"ayni yuzyilda|tarihi .* en yakin|dogru siralama|nasil siralanir|"
            r"arasindan hangisi .* ayni|hangisinin tarihi .* yakindir"
        ),
        "temel hesaplama/alıştırma": (
            r"kac (metre|saniye|dakika|saat|joule|watt|amper|ohm|gram|"
            r"kilogram|sayfa|bolum|puan|gol fark|vurus|tur|santimetre|"
            r"kelvin|derece)|toplam kac|geriye kac|farkla kazan|"
            r"olcekli haritada|sabit .* km sa|yolculuk suresi|"
            r"okunduysa geriye|tamamlandiysa kac"
        ),
        "kod veya idari veri": (
            r"iso 3166|iso 639|ulke kodlu internet|internet alan adi|"
            r"uluslararasi telefon kodu|idari bol|yonetim sistemine dahil|"
            r"alt yonetim|cografi siniflandir|alpha 2|alpha 3|"
            r"iki harfli .* kodu|uc harfli .* kodu"
        ),
        "müzik teorisi alıştırması": (
            r"dortluk vurus hizinda|olculu .* olculuk|nota suresi|"
            r"piyanodaki hangi ses|buyuk uclu|kucuk uclu|akorun cevrimi|"
            r"olcu isaretinde toplam"
        ),
        "yüzyıl/on yıl alıştırması": (
            r"hangi yuzyil|hangi on yillik|yuzyila aittir|yuzyilin icindedir"
        ),
        "formül alıştırması": (
            r"atom numarasi .* kutle numarasi|yuklu iyon|direnci .* ohm|"
            r"gerilim .* amper|sicaklik .* celsius|fahrenheit|"
            r"kutlesi .* hacmi|hacmi .* kutlesi|kuvvet .* ivme|"
            r"saniyede .* hareket eden|yol =|is =|guc ="
        ),
        "yapay veri kaydı ifadesi": (
            r"countryinfo kaydindaki|temel olarak hangi oyun turunde "
            r"siniflandirilir|ilk gosterim yillarina gore"
        ),
    }
    for label, pattern in pattern_groups.items():
        if re.search(pattern, text):
            reasons.append(label)

    if any(symbol in text_raw for symbol in ("→", "•", " × ", " ÷ ")):
        reasons.append("karmaşık/yapay gösterim")

    # Sayısal alıştırma sinyali: soru içinde üçten fazla ayrı sayı.
    if len(re.findall(r"\d+", text_raw)) >= 3:
        reasons.append("fazla sayısal veri")

    # Doğru seçeneğin görünüşü bariz biçimde diğerlerinden farklıysa.
    if isinstance(options, list) and len(options) == 4 and isinstance(answer_index, int) and 0 <= answer_index <= 3:
        lengths = [len(str(option).strip()) for option in options]
        correct_len = lengths[answer_index]
        other_lengths = [lengths[i] for i in range(4) if i != answer_index]
        if correct_len > 38 and other_lengths and correct_len > 2.8 * max(1, sum(other_lengths) / len(other_lengths)):
            reasons.append("doğru seçenek uzunluğuyla ele veriliyor")

    return sorted(set(reasons))


def quality_score(question: dict[str, Any]) -> int:
    text = str(question.get("question", "")).strip()
    explanation = str(question.get("explanation", "")).strip()
    score = 100

    if 25 <= len(text) <= 95:
        score += 12
    elif len(text) > 125:
        score -= 18
    elif len(text) < 20:
        score -= 8

    digit_count = len(re.findall(r"\d+", text))
    if digit_count == 0:
        score += 6
    elif digit_count == 1:
        score += 1
    else:
        score -= 8 * (digit_count - 1)

    lowered = normalize(text)
    if lowered.startswith("asagidaki"):
        score -= 7
    if "en cok hangi" in lowered:
        score -= 4
    if any(
        lowered.endswith(ending)
        for ending in (
            "kimdir", "hangisidir", "hangidir", "adi nedir",
            "ne denir", "hangi ulkededir", "hangi kitadadir",
        )
    ):
        score += 8

    if len(explanation) >= 35:
        score += 4
    if len(explanation) > 180:
        score -= 4

    options = question.get("options")
    if isinstance(options, list) and len(options) == 4:
        lengths = [len(str(option).strip()) for option in options]
        average = sum(lengths) / 4
        if average and max(lengths) <= average * 2.2:
            score += 3

    return score


def segment_for(number: int) -> str:
    if 1 <= number <= 3000:
        return "original"
    if 6121 <= number <= 13120:
        return "missing_generated"
    return "other"


def near_duplicate(
    question: dict[str, Any],
    previous: dict[str, Any],
    threshold: float = 0.72,
) -> bool:
    current_tokens = token_set(question)
    previous_tokens = token_set(previous)
    if not current_tokens or not previous_tokens:
        return False
    union = current_tokens | previous_tokens
    return bool(union) and len(current_tokens & previous_tokens) / len(union) >= threshold


def atomic_write_json(path: Path, data: Any) -> None:
    encoded = json.dumps(data, ensure_ascii=False, indent=2) + "\n"
    path.parent.mkdir(parents=True, exist_ok=True)
    with tempfile.NamedTemporaryFile(
        "w",
        encoding="utf-8",
        dir=path.parent,
        delete=False,
    ) as handle:
        handle.write(encoded)
        temp_name = handle.name
    os.replace(temp_name, path)


def load_questions(path: Path) -> tuple[list[dict[str, Any]], bytes]:
    raw = path.read_bytes()
    try:
        value = json.loads(raw.decode("utf-8"))
    except (UnicodeDecodeError, json.JSONDecodeError) as exc:
        raise SystemExit(f"Geçersiz questions.json: {exc}") from exc
    if not isinstance(value, list) or not all(isinstance(item, dict) for item in value):
        raise SystemExit("questions.json kökü soru nesnelerinden oluşan bir liste olmalı.")
    return value, raw


def choose_questions(
    questions: list[dict[str, Any]],
    known_keep_ids: set[str],
) -> tuple[list[dict[str, Any]], list[dict[str, Any]], list[dict[str, Any]]]:
    decisions: dict[str, dict[str, Any]] = {}
    candidates: list[dict[str, Any]] = []

    for original_index, question in enumerate(questions):
        qid = str(question.get("id", ""))
        number = question_number(qid)
        reasons = hard_reasons(question)

        decision = {
            "id": qid,
            "originalIndex": original_index,
            "number": number,
            "question": question,
            "score": quality_score(question),
            "family": infer_family(question),
            "segment": segment_for(number) if number is not None else "invalid",
            "reasons": list(reasons),
            "priority": 0,
        }

        if reasons:
            decision["status"] = "REJECT"
        elif qid in known_keep_ids:
            decision["status"] = "CANDIDATE"
            decision["priority"] = 2
            decision["segment"] = "known_curated"
            candidates.append(decision)
        elif number is not None and any(start <= number <= end for start, end in KNOWN_AUDITED_RANGES):
            decision["status"] = "REJECT"
            decision["reasons"].append("önceden denetlenmiş kalite elemesinde elendi")
        elif number is not None and segment_for(number) in CATEGORY_LIMITS:
            if decision["score"] < 78:
                decision["status"] = "REJECT"
                decision["reasons"].append("doğallık/oynanabilirlik puanı düşük")
            else:
                decision["status"] = "CANDIDATE"
                decision["priority"] = 3 if number <= 3000 else 1
                candidates.append(decision)
        else:
            # Beklenmedik gelecekteki ID'leri veri kaybı olmaması için koru.
            decision["status"] = "CANDIDATE"
            decision["priority"] = 4
            decision["segment"] = "future_preserved"
            candidates.append(decision)

        decisions[qid or f"invalid-{original_index}"] = decision

    # Önce daha güvenilir, ardından daha yüksek puanlı sorular.
    candidates.sort(
        key=lambda item: (
            item["priority"],
            item["score"],
            -(item["number"] or 10**9),
        ),
        reverse=True,
    )

    category_counts: Counter[tuple[str, int]] = Counter()
    family_counts: Counter[tuple[str, str]] = Counter()
    answer_counts: Counter[tuple[int, str]] = Counter()
    skeleton_counts: Counter[tuple[int, str]] = Counter()
    exact_questions: set[str] = set()
    by_answer: defaultdict[tuple[int, str], list[dict[str, Any]]] = defaultdict(list)
    kept_decisions: list[dict[str, Any]] = []

    for decision in candidates:
        question = decision["question"]
        category = int(question.get("categoryIndex", -1))
        segment = decision["segment"]
        family = decision["family"]
        normalized_question = normalize(str(question.get("question", "")))
        normalized_answer = normalize(correct_answer(question))
        skeleton = re.sub(r"\d+", "<n>", normalized_question)

        if segment in CATEGORY_LIMITS:
            if category_counts[(segment, category)] >= CATEGORY_LIMITS[segment]:
                decision["status"] = "REJECT"
                decision["reasons"].append("kategori kalite kotasının dışında kaldı")
                continue
            limit = FAMILY_LIMITS[segment].get(family, FAMILY_LIMITS[segment]["other"])
            if family_counts[(segment, family)] >= limit:
                decision["status"] = "REJECT"
                decision["reasons"].append("aynı soru ailesinden fazla örnek")
                continue

        if normalized_question in exact_questions:
            decision["status"] = "REJECT"
            decision["reasons"].append("birebir soru tekrarı")
            continue

        answer_key = (category, normalized_answer)
        if answer_counts[answer_key] >= 5:
            decision["status"] = "REJECT"
            decision["reasons"].append("aynı doğru cevap aşırı tekrar ediyor")
            continue

        skeleton_key = (category, skeleton)
        if skeleton_counts[skeleton_key] >= 10:
            decision["status"] = "REJECT"
            decision["reasons"].append("aynı cümle kalıbı aşırı tekrar ediyor")
            continue

        if any(near_duplicate(question, previous) for previous in by_answer[answer_key]):
            decision["status"] = "REJECT"
            decision["reasons"].append("aynı bilginin yeniden yazılmış biçimi")
            continue

        decision["status"] = "KEEP"
        kept_decisions.append(decision)
        exact_questions.add(normalized_question)
        answer_counts[answer_key] += 1
        skeleton_counts[skeleton_key] += 1
        by_answer[answer_key].append(question)
        if segment in CATEGORY_LIMITS:
            category_counts[(segment, category)] += 1
            family_counts[(segment, family)] += 1

    kept_ids = {decision["id"] for decision in kept_decisions}
    kept_questions = [
        question for question in questions if str(question.get("id", "")) in kept_ids
    ]
    rejected_decisions = [
        decision for decision in decisions.values() if decision.get("status") == "REJECT"
    ]
    rejected_questions = [decision["question"] for decision in rejected_decisions]

    # Puanı yeterli olup sadece kota/tekrar yüzünden elenenler ayrı incelenebilir.
    borderline = [
        {
            "id": decision["id"],
            "score": decision["score"],
            "family": decision["family"],
            "reasons": decision["reasons"],
            "question": decision["question"].get("question"),
            "correctAnswer": correct_answer(decision["question"]),
        }
        for decision in rejected_decisions
        if decision["score"] >= 88
        and any(
            marker in " ".join(decision["reasons"])
            for marker in ("kota", "fazla", "tekrar", "yeniden")
        )
    ]

    return kept_questions, rejected_questions, borderline


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Bilgi Rotası soru bankasını ciddi kalite elemesinden geçirir."
    )
    parser.add_argument("--repo-root", default=".", help="BilgiRotasi repo kökü")
    mode = parser.add_mutually_exclusive_group(required=True)
    mode.add_argument("--check", action="store_true", help="Raporla; ana dosyayı değiştirme")
    mode.add_argument("--apply", action="store_true", help="Yedek alıp temiz dosyayı uygula")
    parser.add_argument(
        "--min-kept",
        type=int,
        default=500,
        help="Bu sayının altında soru kalırsa uygulamayı durdur",
    )
    args = parser.parse_args()

    script_root = Path(__file__).resolve().parent
    repo_root = Path(args.repo_root).resolve()
    target = repo_root / "assets" / "questions.json"
    keep_path = script_root / "data" / "known_keep_ids.json"

    if not target.exists():
        raise SystemExit(f"Dosya bulunamadı: {target}")
    if not keep_path.exists():
        raise SystemExit(f"Kalite allowlist dosyası bulunamadı: {keep_path}")

    known_keep_ids = set(json.loads(keep_path.read_text(encoding="utf-8")))
    questions, raw = load_questions(target)
    current_blob_sha = git_blob_sha(raw)

    kept, rejected, borderline = choose_questions(questions, known_keep_ids)
    if len(kept) < args.min_kept:
        raise SystemExit(
            f"Güvenlik durdurması: yalnızca {len(kept)} soru kaldı; "
            f"--min-kept={args.min_kept} sınırının altında."
        )

    timestamp = datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%SZ")
    output_dir = repo_root / "question_audit_output"
    output_dir.mkdir(parents=True, exist_ok=True)

    keep_by_category = Counter(
        CATEGORY_NAMES.get(int(q.get("categoryIndex", -1)), "Bilinmeyen")
        for q in kept
    )
    reject_by_category = Counter(
        CATEGORY_NAMES.get(int(q.get("categoryIndex", -1)), "Bilinmeyen")
        for q in rejected
    )

    report = {
        "timestampUtc": timestamp,
        "mode": "apply" if args.apply else "check",
        "sourceFile": str(target),
        "sourceQuestionCount": len(questions),
        "keptQuestionCount": len(kept),
        "rejectedQuestionCount": len(rejected),
        "keptPercentage": round(100 * len(kept) / max(1, len(questions)), 2),
        "rejectedPercentage": round(100 * len(rejected) / max(1, len(questions)), 2),
        "keptByCategory": dict(keep_by_category),
        "rejectedByCategory": dict(reject_by_category),
        "knownAllowlistSize": len(known_keep_ids),
        "expectedGitBlobSha": EXPECTED_GITHUB_BLOB_SHA,
        "actualGitBlobSha": current_blob_sha,
        "sourceMatchesExpectedBlob": current_blob_sha == EXPECTED_GITHUB_BLOB_SHA,
        "idPolicy": "ID'ler korunur; boşluklar normaldir.",
        "newQuestionsGenerated": 0,
        "borderlineCount": len(borderline),
    }

    report_path = output_dir / f"audit_report_{timestamp}.json"
    kept_path = output_dir / f"kept_questions_{timestamp}.json"
    rejected_path = output_dir / f"rejected_questions_{timestamp}.json"
    borderline_path = output_dir / f"borderline_questions_{timestamp}.json"

    atomic_write_json(report_path, report)
    atomic_write_json(kept_path, kept)
    atomic_write_json(rejected_path, rejected)
    atomic_write_json(borderline_path, borderline)

    print("\n=== BİLGİ ROTASI SORU KALİTE DENETİMİ ===")
    print(f"Kaynak soru        : {len(questions)}")
    print(f"Kalacak soru       : {len(kept)}")
    print(f"Elenecek soru      : {len(rejected)}")
    print(f"Koruma oranı       : %{report['keptPercentage']}")
    print(f"Eleme oranı        : %{report['rejectedPercentage']}")
    print("\nKalacak soruların kategori dağılımı:")
    for category in CATEGORY_NAMES.values():
        print(f"  {category:<18}: {keep_by_category.get(category, 0)}")
    print(f"\nRapor              : {report_path}")
    print(f"Elenenler arşivi   : {rejected_path}")
    print(f"Sınırda kalanlar   : {borderline_path}")

    if current_blob_sha != EXPECTED_GITHUB_BLOB_SHA:
        print(
            "\nUYARI: questions.json, denetim hazırlanırken görülen GitHub sürümünden "
            "farklı. Betik yine güncel yerel dosyayı analiz etti.",
            file=sys.stderr,
        )

    if args.check:
        print("\nKontrol tamamlandı; assets/questions.json değiştirilmedi.")
        return 0

    backup_dir = repo_root / ".question_backups"
    backup_dir.mkdir(parents=True, exist_ok=True)
    backup_path = backup_dir / f"questions.json.{timestamp}.before_quality_cleanup.bak"
    shutil.copy2(target, backup_path)
    atomic_write_json(target, kept)

    reloaded, _ = load_questions(target)
    if len(reloaded) != len(kept):
        shutil.copy2(backup_path, target)
        raise SystemExit(
            "Yazma sonrası sayı kontrolü başarısız; yedek otomatik geri yüklendi."
        )
    ids = [str(q.get("id", "")) for q in reloaded]
    if len(ids) != len(set(ids)):
        shutil.copy2(backup_path, target)
        raise SystemExit(
            "Yazma sonrası ID tekrarı bulundu; yedek otomatik geri yüklendi."
        )

    print(f"\nTemizlik uygulandı : {len(kept)} soru kaldı")
    print(f"Yedek              : {backup_path}")
    print("Git kontrolü        : git diff -- assets/questions.json")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
