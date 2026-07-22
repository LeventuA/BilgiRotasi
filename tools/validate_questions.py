#!/usr/bin/env python3
"""Bilgi Rotası soru bankası için salt-okunur yapısal doğrulayıcı."""

from __future__ import annotations

import argparse
import json
import re
import sys
from collections import Counter, defaultdict
from pathlib import Path
from typing import Any

VALID_DIFFICULTIES = {"Kolay", "Orta", "Zor"}
CATEGORY_COUNT = 6
REQUIRED_KEYS = {
    "id",
    "categoryIndex",
    "question",
    "options",
    "answerIndex",
    "difficulty",
    "explanation",
}


def normalized(value: str) -> str:
    return re.sub(r"\s+", " ", value.strip().casefold())


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "path",
        nargs="?",
        default="assets/questions.json",
    )
    parser.add_argument(
        "--strict-warnings",
        action="store_true",
        help="Benzer soru ve boş açıklama uyarılarında da başarısız ol.",
    )
    args = parser.parse_args()

    path = Path(args.path)
    if not path.exists():
        print(f"❌ Dosya bulunamadı: {path}")
        return 2

    try:
        data = json.loads(path.read_text(encoding="utf-8"))
    except Exception as error:
        print(f"❌ JSON okunamadı: {error}")
        return 2

    if not isinstance(data, list):
        print("❌ En üst JSON yapısı liste olmalı.")
        return 2

    critical: list[str] = []
    warnings: list[str] = []
    ids: Counter[str] = Counter()
    texts: Counter[str] = Counter()
    category_counts: Counter[int] = Counter()
    difficulty_counts: Counter[str] = Counter()
    category_difficulty: dict[int, Counter[str]] = defaultdict(Counter)

    for index, item in enumerate(data, start=1):
        label = f"#{index}"

        if not isinstance(item, dict):
            critical.append(f"{label}: kayıt nesne değil.")
            continue

        missing = REQUIRED_KEYS - set(item)
        if missing:
            critical.append(
                f"{label}: eksik alanlar {sorted(missing)}"
            )

        question_id = str(item.get("id", "")).strip()
        question_text = str(item.get("question", "")).strip()
        explanation = str(item.get("explanation", "")).strip()
        options = item.get("options")
        category = item.get("categoryIndex")
        answer = item.get("answerIndex")
        difficulty = str(item.get("difficulty", "")).strip()

        if not question_id:
            critical.append(f"{label}: id boş.")
        else:
            ids[question_id] += 1

        if not question_text:
            critical.append(f"{label}: soru metni boş.")
        else:
            texts[normalized(question_text)] += 1

        if not isinstance(category, int) or not 0 <= category < CATEGORY_COUNT:
            critical.append(
                f"{label} ({question_id}): categoryIndex 0-5 olmalı."
            )
        else:
            category_counts[category] += 1
            category_difficulty[category][difficulty] += 1

        if not isinstance(options, list) or len(options) != 4:
            critical.append(
                f"{label} ({question_id}): tam 4 seçenek olmalı."
            )
        else:
            clean_options = [
                str(option).strip() for option in options
            ]
            if any(not option for option in clean_options):
                critical.append(
                    f"{label} ({question_id}): boş seçenek var."
                )
            if len({normalized(option) for option in clean_options}) != 4:
                critical.append(
                    f"{label} ({question_id}): seçenekler benzersiz değil."
                )

        if (
            not isinstance(answer, int)
            or not isinstance(options, list)
            or not 0 <= answer < len(options)
        ):
            critical.append(
                f"{label} ({question_id}): answerIndex geçersiz."
            )

        if difficulty not in VALID_DIFFICULTIES:
            critical.append(
                f"{label} ({question_id}): zorluk Kolay/Orta/Zor olmalı."
            )
        else:
            difficulty_counts[difficulty] += 1

        if not explanation:
            warnings.append(
                f"{label} ({question_id}): açıklama boş."
            )

    duplicate_ids = [
        key for key, count in ids.items() if count > 1
    ]
    duplicate_texts = [
        key for key, count in texts.items() if count > 1
    ]

    for question_id in duplicate_ids:
        critical.append(
            f"Yinelenen soru kimliği: {question_id} ({ids[question_id]} adet)"
        )

    for text in duplicate_texts[:50]:
        warnings.append(
            f"Benzer/aynı soru metni ({texts[text]} adet): {text[:100]}"
        )

    print("🧭 Bilgi Rotası soru bankası raporu")
    print(f"📝 Toplam: {len(data)}")
    print(
        "📊 Zorluk: "
        + ", ".join(
            f"{name}={difficulty_counts[name]}"
            for name in ("Kolay", "Orta", "Zor")
        )
    )

    for category in range(CATEGORY_COUNT):
        difficulty_summary = ", ".join(
            f"{name}={category_difficulty[category][name]}"
            for name in ("Kolay", "Orta", "Zor")
        )
        print(
            f"  Kategori {category}: "
            f"{category_counts[category]} soru • {difficulty_summary}"
        )

    print(f"❌ Kritik sorun: {len(critical)}")
    print(f"⚠️ Uyarı: {len(warnings)}")

    for issue in critical[:100]:
        print(f"  ❌ {issue}")

    for issue in warnings[:30]:
        print(f"  ⚠️ {issue}")

    if len(critical) > 100:
        print(
            f"  … {len(critical) - 100} kritik sorun daha var."
        )

    if len(warnings) > 30:
        print(
            f"  … {len(warnings) - 30} uyarı daha var."
        )

    if critical:
        return 1

    if args.strict_warnings and warnings:
        return 1

    print("✅ Yapısal doğrulama tamamlandı.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
