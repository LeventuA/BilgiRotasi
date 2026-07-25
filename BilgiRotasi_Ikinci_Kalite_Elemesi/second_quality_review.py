#!/usr/bin/env python3
"""Bilgi Rotası ikinci kalite elemesi.

Bu betik mevcut assets/questions.json dosyasını:
- kesin kalacak,
- yeniden yazılabilecek,
- doğrudan elenecek
olmak üzere üç gruba ayırır.

--check ana dosyayı değiştirmez.
--apply yalnızca "kesin kalacak" soruları bırakır ve tam yedek alır.
ID'ler yeniden numaralandırılmaz.
"""

from __future__ import annotations

import argparse
import csv
import hashlib
import json
import os
import re
import shutil
import statistics
import tempfile
import unicodedata
from collections import Counter
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

EXPECTED_BLOB_SHA = "0e79e826226a044356a65f5b5fdb43737f76036d"

CATEGORY_NAMES = {
    0: "Coğrafya",
    1: "Eğlence",
    2: "Tarih",
    3: "Sanat & Edebiyat",
    4: "Bilim & Doğa",
    5: "Spor",
}

CATEGORY_CAPS = {
    0: 90,
    1: 90,
    2: 90,
    3: 110,
    4: 90,
    5: 90,
}

FAMILY_CAPS = {
    "capital": 10,
    "author": 40,
    "director": 25,
    "creator": 20,
    "year": 15,
    "element_symbol": 6,
    "formula": 4,
    "si_unit": 4,
    "location": 15,
    "literary_genre": 6,
    "music_form": 6,
    "champion": 15,
    "venue": 8,
    "geo": 75,
    "entertainment": 75,
    "history": 75,
    "art": 75,
    "science": 75,
    "sport": 75,
    "other": 50,
}

QUALITY_FLOOR = 1.5

ICONIC_PHRASES_RAW = [
    # Coğrafya
    "Türkiye", "İstanbul", "Ankara", "Kapadokya", "Pamukkale", "Everest",
    "Amazon", "Nil", "Sahra", "Antarktika", "Grand Canyon", "Fuji Dağı",
    "Baykal Gölü", "Ölü Deniz", "Machu Picchu", "Tac Mahal", "Petra",
    "Kolezyum", "Eyfel Kulesi", "Özgürlük Heykeli", "Galapagos",
    "Serengeti", "Venedik", "Paris", "Roma", "Tokyo",
    # Eğlence
    "Friends", "Breaking Bad", "Game of Thrones", "Stranger Things",
    "The Office", "Titanic", "Matrix", "Star Wars", "Harry Potter",
    "Yüzüklerin Efendisi", "Aslan Kral", "Oyuncak Hikâyesi", "Frozen",
    "Batman", "Superman", "Joker", "Avatar", "Jurassic Park",
    "Forrest Gump", "Rocky", "Gladyatör", "Ruhların Kaçışı",
    "Karayip Korsanları", "Terminatör", "Geleceğe Dönüş", "Baba",
    "Pulp Fiction", "Shrek", "Coco", "Kayıp Balık Nemo",
    # Tarih
    "Atatürk", "Fatih Sultan Mehmet", "Osmanlı", "Roma İmparatorluğu",
    "Antik Mısır", "Napolyon", "Berlin Duvarı", "Fransız Devrimi",
    "Sanayi Devrimi", "Soğuk Savaş", "Birinci Dünya Savaşı",
    "İkinci Dünya Savaşı", "Pompeii", "Troya", "Babil",
    "Küba Füze Krizi", "Apollo 11", "Hiroşima", "Magna Carta", "Kadeş",
    # Sanat ve edebiyat
    "Mona Lisa", "Yıldızlı Gece", "Guernica", "Çığlık",
    "Son Akşam Yemeği", "Hamlet", "Romeo ve Juliet", "Küçük Prens",
    "Don Kişot", "Suç ve Ceza", "Sefiller", "1984", "Hayvan Çiftliği",
    "Simyacı", "Şeker Portakalı", "Kürk Mantolu Madonna", "İnce Memed",
    "Nutuk", "İlahi Komedya", "Faust", "Dava", "Anna Karenina",
    "Savaş ve Barış", "Moby Dick", "Sherlock Holmes", "Dracula",
    "Frankenstein",
    # Bilim ve doğa
    "Albert Einstein", "Isaac Newton", "Charles Darwin", "Nikola Tesla",
    "Marie Curie", "DNA", "Güneş Sistemi", "Samanyolu", "kara delik",
    "ahtapot", "penguen", "köpekbalığı", "yunus", "arı", "bukalemun",
    "Venüs", "Mars", "Jüpiter", "Satürn", "Plüton", "fotosentez",
    "yer çekimi", "radyoaktivite", "periyodik tablo",
    # Spor
    "Dünya Kupası", "Şampiyonlar Ligi", "Olimpiyat", "NBA", "Formula 1",
    "Wimbledon", "Galatasaray", "Fenerbahçe", "Beşiktaş",
    "Michael Jordan", "Muhammad Ali", "Usain Bolt", "Lionel Messi",
    "Cristiano Ronaldo", "Pelé", "Maradona", "Roger Federer",
    "Rafael Nadal", "Serena Williams", "Michael Schumacher",
    "Lewis Hamilton",
]

HARD_PATTERNS = {
    "meta/eşleştirme şablonu": (
        r"\bdogru .* eslestirmesi\b|\bicin dogru\b|"
        r"\bdogru cevap dizisi\b|\bdogru yanit sirasi\b"
    ),
    "veri tabanı anlatımı": r"\bolarak verilir\b",
    "kanal-platform veri tabanı": (
        r"\bilk yayinci kanali\b|\bkanali veya platformu\b|"
        r"\bilk yayin platformu\b"
    ),
    "kod veri tabanı": (
        r"\bpara biriminin uluslararasi kodu\b|\binternet alan adi\b|"
        r"\btelefon kodu\b|\biso 3166\b|\biso 639\b"
    ),
    "birleşik soru": (
        r"\bile .* ortak olan\b|\biki .* ortak\b|"
        r"\bbirinci soru\b|\bikinci soru\b"
    ),
    "hesaplama alıştırması": (
        r"\bkac (metre|saniye|dakika|saat|joule|watt|amper|ohm|"
        r"sayfa|puan)\b|\btoplam kac\b"
    ),
}

TEMPLATE_PATTERNS = {
    "seri ülke-konum sorusu": r"\bhangi ulkede veya ulkelerde bulunur\b",
    "seri arkeoloji sorusu": (
        r"\barkeolojik alani gunumuzde hangi ulkededir\b|"
        r"\ben cok hangi uygarlik hanedan veya kulturle iliskilidir\b"
    ),
    "seri tarihsel önem sorusu": (
        r"\bolayinin temel sonucu veya tarihsel onemi\b"
    ),
    "seri edebî tür sorusu": r"\bhangi edebi ture aittir\b",
    "seri müzik biçimi sorusu": r"\bhangi muzik turu veya biciminde\b",
    "seri element sembolü sorusu": (
        r"\bkimyasal sembolu\b|\bkimyasal simgesi\b|"
        r"\belementinin sembolu\b"
    ),
    "seri kimyasal formül sorusu": (
        r"\bmolekuler veya formul gosterimi\b|"
        r"\bkimyasal formulu hangi bilesige\b"
    ),
    "seri SI birimi sorusu": (
        r"\bsimgesi hangi si birimini\b|\bbuyuklugunun si birimi\b"
    ),
    "seri spor mekânı sorusu": (
        r"\ben cok hangi spor veya sporlarla iliskilidir\b"
    ),
}

GENERIC_WORDS = {
    "hangi", "hangisi", "hangisidir", "kimdir", "nedir", "kac", "icin",
    "dogru", "eslestirmesi", "adli", "eser", "eseri", "filmi", "film",
    "dizisi", "dizi", "ulke", "ulkesi", "olarak", "ile", "bir", "ve",
}


def normalize(value: Any) -> str:
    value = str(value).replace("ı", "i").replace("İ", "I")
    value = unicodedata.normalize("NFKD", value)
    value = "".join(
        character
        for character in value
        if not unicodedata.combining(character)
    )
    value = value.casefold()
    value = re.sub(r"[^a-z0-9]+", " ", value)
    return " ".join(value.split())


ICONIC_PHRASES = [normalize(value) for value in ICONIC_PHRASES_RAW]


def git_blob_sha(raw: bytes) -> str:
    header = f"blob {len(raw)}\0".encode("utf-8")
    return hashlib.sha1(header + raw).hexdigest()


def question_number(question: dict[str, Any]) -> int:
    match = re.fullmatch(r"q(\d+)", str(question.get("id", "")))
    return int(match.group(1)) if match else 10**9


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


def validate(question: dict[str, Any]) -> list[str]:
    reasons: list[str] = []
    required = {
        "id", "categoryIndex", "question", "options",
        "answerIndex", "difficulty", "explanation",
    }
    missing = required - set(question)
    if missing:
        return [f"eksik alanlar: {sorted(missing)}"]

    if not re.fullmatch(r"q\d+", str(question.get("id", ""))):
        reasons.append("geçersiz ID")
    if question.get("categoryIndex") not in CATEGORY_NAMES:
        reasons.append("geçersiz kategori")

    text = str(question.get("question", "")).strip()
    if len(text) < 12:
        reasons.append("çok kısa soru")
    if len(text) > 150:
        reasons.append("aşırı uzun soru")
    if not text.endswith("?"):
        reasons.append("soru işareti eksik")
    if text.count("?") != 1:
        reasons.append("birden fazla soru içeriyor")

    options = question.get("options")
    if (
        not isinstance(options, list)
        or len(options) != 4
        or not all(isinstance(option, str) and option.strip() for option in options)
    ):
        reasons.append("dört geçerli seçenek yok")
    elif len({normalize(option) for option in options}) != 4:
        reasons.append("tekrarlanan seçenek")

    answer_index = question.get("answerIndex")
    if not isinstance(answer_index, int) or not 0 <= answer_index <= 3:
        reasons.append("geçersiz answerIndex")

    if len(str(question.get("explanation", "")).strip()) < 20:
        reasons.append("yetersiz açıklama")

    return reasons


def infer_family(question: dict[str, Any]) -> str:
    text = normalize(question.get("question", ""))
    category = question.get("categoryIndex")

    if " baskenti " in f" {text} ":
        return "capital"
    if re.search(
        r"adli eserin yazari kimdir|eserinin yazari kimdir|"
        r"tarafindan yazilan .* hangisidir",
        text,
    ):
        return "author"
    if re.search(
        r"filminin yonetmeni kimdir|tarafindan yonetilen film",
        text,
    ):
        return "director"
    if re.search(
        r"dizisinin yaraticisi|yaraticisi veya yaraticilari|"
        r"yapitinin yaraticisi|adli yapitin yaraticisi",
        text,
    ):
        return "creator"
    if re.search(r"hangi yilda gerceklesti|yayin yili", text):
        return "year"
    if re.search(
        r"kimyasal sembolu|kimyasal simgesi|elementinin sembolu",
        text,
    ):
        return "element_symbol"
    if re.search(
        r"molekuler veya formul gosterimi|kimyasal formulu hangi bilesige",
        text,
    ):
        return "formula"
    if re.search(r"simgesi hangi si birimini|buyuklugunun si birimi", text):
        return "si_unit"
    if re.search(
        r"hangi ulkede veya ulkelerde bulunur|hangi ulkededir|hangi kitadadir",
        text,
    ):
        return "location"
    if "edebi ture aittir" in text:
        return "literary_genre"
    if "muzik turu veya biciminde" in text:
        return "music_form"
    if re.search(r"dunya kupasi|euro \d|nba finalleri|sampiyonu", text):
        return "champion"
    if re.search(
        r"stadium|stadyum|park hangi sehirde|en cok hangi spor",
        text,
    ):
        return "venue"

    return {
        0: "geo",
        1: "entertainment",
        2: "history",
        3: "art",
        4: "science",
        5: "sport",
    }.get(category, "other")


def explanation_extra_tokens(question: dict[str, Any]) -> set[str]:
    stopwords = {
        "bir", "ve", "ile", "icin", "olarak", "tarafindan", "dogru",
        "bilgisi", "verilir", "eseridir", "filmidir", "dizisidir",
        "kullanilan", "kullanilir", "hangisidir", "kimdir", "nedir",
        "hangi",
    }
    question_tokens = set(normalize(question.get("question", "")).split())
    answer_tokens = set(normalize(correct_answer(question)).split())
    explanation_tokens = set(
        normalize(question.get("explanation", "")).split()
    )
    return explanation_tokens - question_tokens - answer_tokens - stopwords


def subject_key(question: dict[str, Any]) -> str:
    text = normalize(question.get("question", ""))
    cuts = [
        " icin dogru",
        " tarafindan yazilan",
        " tarafindan yonetilen",
        " filminin ",
        " dizisinin ",
        " eserinin ",
        " adli eserin ",
        " adli yapitin ",
        " hangi ulkede",
        " hangi kitada",
        " hangi yilda",
        " elementinin ",
        " simgesi ",
        " olayinin ",
        " en cok hangi",
        " icin one cikan",
        " kimdir",
        " nedir",
        " hangisidir",
    ]

    position = len(text)
    for marker in cuts:
        marker_position = text.find(marker)
        if marker_position >= 0:
            position = min(position, marker_position)

    subject = text[:position].strip()
    if not subject:
        tokens = [
            token
            for token in text.split()
            if token not in GENERIC_WORDS
        ]
        subject = " ".join(tokens[:6])

    return subject[:100]


def fact_key(question: dict[str, Any], family: str) -> str:
    subject = subject_key(question)
    answer = normalize(correct_answer(question))

    if family in {
        "author", "director", "creator", "element_symbol",
        "formula", "si_unit",
    }:
        pair = sorted(value for value in (subject, answer) if value)
        return f"{family}|" + "|".join(pair)

    return f"{question.get('categoryIndex')}|{subject}|{answer}"


def score_question(
    question: dict[str, Any],
) -> tuple[float, list[str], str, str, str]:
    validation_reasons = validate(question)
    family = infer_family(question)
    subject = subject_key(question)
    fingerprint = fact_key(question, family)

    if validation_reasons:
        return -100.0, validation_reasons, family, subject, fingerprint

    text = normalize(question.get("question", ""))
    explanation = normalize(question.get("explanation", ""))
    answer = normalize(correct_answer(question))
    reasons: list[str] = []

    for label, pattern in HARD_PATTERNS.items():
        if re.search(pattern, text) or re.search(pattern, explanation):
            return -100.0, [label], family, subject, fingerprint

    if answer and len(answer) >= 4 and answer in text:
        return -100.0, ["doğru cevap soru metninde açıkça geçiyor"], family, subject, fingerprint

    score = 0.0
    number = question_number(question)

    # Daha eski sorular yalnızca şablon filtresini geçtiklerinde küçük avantaj alır.
    if number <= 3000:
        score += 1.5
    elif number <= 6120:
        score += 0.5

    raw_text = str(question.get("question", ""))
    if 25 <= len(raw_text) <= 90:
        score += 1.5
    elif len(raw_text) > 130:
        score -= 2.0
        reasons.append("fazla uzun cümle")

    combined = f"{text} {answer}"
    iconic_hits = sum(
        1
        for phrase in ICONIC_PHRASES
        if phrase and phrase in combined
    )
    score += min(3.5, iconic_hits * 2.5)

    extra_tokens = explanation_extra_tokens(question)
    if len(extra_tokens) >= 5:
        score += 1.5
    elif len(extra_tokens) >= 2:
        score += 0.5
    else:
        score -= 1.0
        reasons.append("açıklama çoğunlukla cevabı tekrar ediyor")

    for label, pattern in TEMPLATE_PATTERNS.items():
        if re.search(pattern, text):
            score -= 4.0
            reasons.append(label)

    score += {
        "capital": -0.5,
        "author": 0.0,
        "director": 0.0,
        "creator": -0.5,
        "year": -0.5,
        "element_symbol": -2.5,
        "formula": -3.0,
        "si_unit": -3.0,
        "location": -1.5,
        "literary_genre": -2.5,
        "music_form": -2.5,
        "champion": 0.0,
        "venue": -2.0,
        "geo": 1.0,
        "entertainment": 1.0,
        "history": 1.0,
        "art": 0.5,
        "science": 1.0,
        "sport": 1.0,
        "other": 0.0,
    }.get(family, 0.0)

    options = question.get("options", [])
    option_lengths = [len(str(option).strip()) for option in options]
    median_length = statistics.median(option_lengths)
    correct_length = option_lengths[question["answerIndex"]]

    if median_length:
        length_ratio = max(
            correct_length / median_length,
            median_length / max(correct_length, 1),
        )
        if length_ratio > 2.4:
            score -= 1.0
            reasons.append("doğru seçenek uzunluğuyla ayrışıyor")

    return score, reasons, family, subject, fingerprint


def load_questions(path: Path) -> list[dict[str, Any]]:
    try:
        value = json.loads(path.read_text(encoding="utf-8"))
    except FileNotFoundError as error:
        raise SystemExit(f"Dosya bulunamadı: {path}") from error
    except json.JSONDecodeError as error:
        raise SystemExit(f"Geçersiz JSON: {error}") from error

    if not isinstance(value, list):
        raise SystemExit("questions.json kökü liste olmalıdır.")
    if not all(isinstance(item, dict) for item in value):
        raise SystemExit("Bütün soru kayıtları JSON nesnesi olmalıdır.")

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


def review_questions(
    questions: list[dict[str, Any]],
) -> tuple[list[dict[str, Any]], list[dict[str, Any]], list[dict[str, Any]]]:
    scored: list[dict[str, Any]] = []

    for question in questions:
        score, reasons, family, subject, fingerprint = score_question(question)
        scored.append(
            {
                "question": question,
                "score": score,
                "reasons": reasons,
                "family": family,
                "subject": subject,
                "fingerprint": fingerprint,
            }
        )

    scored.sort(
        key=lambda item: (
            item["score"],
            -question_number(item["question"]),
        ),
        reverse=True,
    )

    category_counts: Counter[int] = Counter()
    family_counts: Counter[str] = Counter()
    subject_counts: Counter[tuple[int, str]] = Counter()
    answer_counts: Counter[tuple[int, str]] = Counter()
    fingerprints: set[str] = set()

    keep: list[dict[str, Any]] = []
    rewrite: list[dict[str, Any]] = []
    reject: list[dict[str, Any]] = []

    for item in scored:
        question = item["question"]
        score = item["score"]
        category = question.get("categoryIndex")
        family = item["family"]
        subject = item["subject"]
        answer = normalize(correct_answer(question))
        fingerprint = item["fingerprint"]
        reasons = list(item["reasons"])

        if score < 0:
            item["decision"] = "REJECT"
            reject.append(item)
            continue

        if score < QUALITY_FLOOR:
            item["decision"] = "REWRITE"
            reasons.append("kalite puanı kesin koruma eşiğinin altında")
            item["reasons"] = reasons
            rewrite.append(item)
            continue

        if category_counts[category] >= CATEGORY_CAPS[category]:
            item["decision"] = "REWRITE"
            reasons.append("kategori yoğunluğu sınırı")
            item["reasons"] = reasons
            rewrite.append(item)
            continue

        if family_counts[family] >= FAMILY_CAPS.get(family, 50):
            item["decision"] = "REWRITE"
            reasons.append("aynı soru ailesi gereğinden fazla tekrar ediyor")
            item["reasons"] = reasons
            rewrite.append(item)
            continue

        if subject and subject_counts[(category, subject)] >= 1:
            item["decision"] = "REWRITE"
            reasons.append("aynı konu için daha iyi bir soru seçildi")
            item["reasons"] = reasons
            rewrite.append(item)
            continue

        if fingerprint in fingerprints:
            item["decision"] = "REWRITE"
            reasons.append("aynı bilgi farklı biçimde tekrar edilmiş")
            item["reasons"] = reasons
            rewrite.append(item)
            continue

        answer_cap = (
            2
            if family in {
                "author", "director", "creator", "capital",
                "element_symbol", "formula", "si_unit", "year",
            }
            else 3
        )
        if answer and answer_counts[(category, answer)] >= answer_cap:
            item["decision"] = "REWRITE"
            reasons.append("aynı doğru cevap gereğinden fazla tekrar ediyor")
            item["reasons"] = reasons
            rewrite.append(item)
            continue

        item["decision"] = "KEEP"
        keep.append(item)
        category_counts[category] += 1
        family_counts[family] += 1
        subject_counts[(category, subject)] += 1
        answer_counts[(category, answer)] += 1
        fingerprints.add(fingerprint)

    return keep, rewrite, reject


def record_for_output(item: dict[str, Any]) -> dict[str, Any]:
    question = item["question"]
    return {
        "id": question.get("id"),
        "decision": item["decision"],
        "score": round(float(item["score"]), 2),
        "family": item["family"],
        "subject": item["subject"],
        "reasons": item["reasons"],
        "question": question.get("question"),
        "correctAnswer": correct_answer(question),
        "record": question,
    }


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Bilgi Rotası ikinci kalite elemesini çalıştırır."
    )
    parser.add_argument("--repo-root", default=".")
    mode = parser.add_mutually_exclusive_group(required=True)
    mode.add_argument("--check", action="store_true")
    mode.add_argument("--apply", action="store_true")
    args = parser.parse_args()

    repo_root = Path(args.repo_root).resolve()
    target = repo_root / "assets" / "questions.json"
    script_root = Path(__file__).resolve().parent
    output_dir = repo_root / "question_second_review_output"
    output_dir.mkdir(parents=True, exist_ok=True)

    raw = target.read_bytes()
    current_blob_sha = git_blob_sha(raw)
    questions = load_questions(target)
    keep, rewrite, reject = review_questions(questions)

    timestamp = datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%SZ")

    keep_records = [record_for_output(item) for item in keep]
    rewrite_records = [record_for_output(item) for item in rewrite]
    reject_records = [record_for_output(item) for item in reject]

    kept_questions = [item["question"] for item in keep]

    category_before = Counter(
        CATEGORY_NAMES.get(question.get("categoryIndex"), "Geçersiz")
        for question in questions
    )
    category_after = Counter(
        CATEGORY_NAMES.get(question.get("categoryIndex"), "Geçersiz")
        for question in kept_questions
    )
    family_after = Counter(item["family"] for item in keep)

    report = {
        "timestampUtc": timestamp,
        "mode": "apply" if args.apply else "check",
        "sourcePath": str(target),
        "sourceBlobSha": current_blob_sha,
        "expectedBlobSha": EXPECTED_BLOB_SHA,
        "blobMatchesPreparedVersion": current_blob_sha == EXPECTED_BLOB_SHA,
        "sourceCount": len(questions),
        "keepCount": len(keep),
        "rewriteCount": len(rewrite),
        "rejectCount": len(reject),
        "keepRatePercent": round(100 * len(keep) / max(len(questions), 1), 2),
        "categoryBefore": dict(category_before),
        "categoryAfter": dict(category_after),
        "familyAfter": dict(family_after),
        "qualityFloor": QUALITY_FLOOR,
        "categoryCaps": {
            CATEGORY_NAMES[key]: value
            for key, value in CATEGORY_CAPS.items()
        },
        "familyCaps": FAMILY_CAPS,
    }

    paths = {
        "report": output_dir / f"second_review_report_{timestamp}.json",
        "keep": output_dir / f"keep_questions_{timestamp}.json",
        "rewrite": output_dir / f"rewrite_questions_{timestamp}.json",
        "reject": output_dir / f"reject_questions_{timestamp}.json",
        "csv": output_dir / f"second_review_{timestamp}.csv",
    }

    atomic_write(paths["report"], report)
    atomic_write(paths["keep"], keep_records)
    atomic_write(paths["rewrite"], rewrite_records)
    atomic_write(paths["reject"], reject_records)

    with paths["csv"].open("w", encoding="utf-8-sig", newline="") as handle:
        writer = csv.writer(handle)
        writer.writerow(
            [
                "id", "decision", "score", "category", "family",
                "question", "correct_answer", "reasons",
            ]
        )
        for item in keep + rewrite + reject:
            question = item["question"]
            writer.writerow(
                [
                    question.get("id"),
                    item["decision"],
                    round(float(item["score"]), 2),
                    CATEGORY_NAMES.get(question.get("categoryIndex"), "Geçersiz"),
                    item["family"],
                    question.get("question"),
                    correct_answer(question),
                    " | ".join(item["reasons"]),
                ]
            )

    print(f"Kaynak soru      : {len(questions)}")
    print(f"Kesin kalacak    : {len(keep)}")
    print(f"Yeniden yazılacak: {len(rewrite)}")
    print(f"Doğrudan elenecek: {len(reject)}")
    print(f"Koruma oranı     : %{report['keepRatePercent']}")
    print()
    print("Kalacak soruların kategori dağılımı:")
    for index in range(6):
        name = CATEGORY_NAMES[index]
        print(f"  {name:<18}: {category_after.get(name, 0)}")
    print()
    print(f"Rapor             : {paths['report']}")
    print(f"Yeniden yazılacak : {paths['rewrite']}")
    print(f"Elenecek          : {paths['reject']}")
    print(f"CSV inceleme      : {paths['csv']}")

    if current_blob_sha != EXPECTED_BLOB_SHA:
        print()
        print(
            "UYARI: questions.json paket hazırlanırken görülen GitHub "
            "sürümünden farklı. İnceleme yine tamamlandı; raporu kontrol edin."
        )

    if args.check:
        print()
        print("Kontrol tamamlandı; assets/questions.json değiştirilmedi.")
        return 0

    backup_dir = repo_root / ".question_backups"
    backup_dir.mkdir(parents=True, exist_ok=True)
    backup_path = (
        backup_dir
        / f"questions.json.{timestamp}.before_second_quality_review.bak"
    )
    shutil.copy2(target, backup_path)

    atomic_write(target, kept_questions)

    reloaded = load_questions(target)
    if (
        len(reloaded) != len(kept_questions)
        or [item.get("id") for item in reloaded]
        != [item.get("id") for item in kept_questions]
    ):
        shutil.copy2(backup_path, target)
        raise SystemExit(
            "Yazma sonrası kontrol başarısız; yedek geri yüklendi."
        )

    print()
    print(f"İkinci eleme uygulandı. Yeni soru sayısı: {len(reloaded)}")
    print(f"Tam yedek: {backup_path}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
