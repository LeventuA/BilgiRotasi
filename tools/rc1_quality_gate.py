#!/usr/bin/env python3
# -*- coding: utf-8 -*-

# Bilgi Rotası RC2 hızlı kalite kapısı.

from __future__ import annotations

import argparse
import hashlib
import json
import re
import sys
from collections import Counter
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
EXPECTED_VERSION = "1.48.4+68"
MIN_TOTAL_QUESTIONS = 5000
MIN_QUESTIONS_PER_CATEGORY = 500
CATEGORY_COUNT = 6

REQUIRED_FILES = [
    "lib/main.dart",
    "lib/app_build_info.dart",
    "assets/questions.json",
    "assets/branding/app_icon.png",
    "assets/branding/app_icon_foreground.png",
    "assets/branding/splash_logo.png",
    "lib/account_cloud.dart",
    "firebase/google-services.json",
    "firestore.rules",
    "test/account_cloud_storage_backend_test.dart",
    "assets/sounds/dice_roll.mp3",
    "assets/sounds/landing.mp3",
    "assets/sounds/correct.mp3",
    "assets/sounds/wrong.mp3",
    "assets/sounds/badge.mp3",
    "assets/sounds/win.mp3",
]

USER_FACING_FILES = [
    "lib/main_navigation.dart",
    "lib/visual_collection.dart",
    "lib/about_privacy.dart",
    "lib/social_features.dart",
]

FORBIDDEN_TEXTS = [
    "Ses Atmosferi",
    "ses atmosferini seç",
    "Sistem Sağlığını Aç",
    "Meydan Okuma artık Oyna bölümünde",
]


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--report",
        default="reports/RC1_AUTOMATED_REPORT.md",
    )
    return parser.parse_args()


def normalize(value: str) -> str:
    return re.sub(r"\s+", " ", value.strip().casefold())


def main() -> int:
    args = parse_args()
    errors: list[str] = []
    warnings: list[str] = []

    for relative in REQUIRED_FILES:
        path = ROOT / relative
        if not path.is_file():
            errors.append(f"Eksik dosya: {relative}")
        elif path.stat().st_size <= 0:
            errors.append(f"Boş dosya: {relative}")

    pubspec_path = ROOT / "pubspec.yaml"
    version = "?"
    if not pubspec_path.is_file():
        errors.append("pubspec.yaml bulunamadı.")
    else:
        pubspec = pubspec_path.read_text(encoding="utf-8")
        match = re.search(
            r"(?m)^version:\s*([^\s]+)\s*$",
            pubspec,
        )
        version = match.group(1) if match else "?"
        if version != EXPECTED_VERSION:
            errors.append(
                f"Sürüm uyuşmuyor: {version} "
                f"(beklenen {EXPECTED_VERSION})"
            )

    questions_path = ROOT / "assets/questions.json"
    questions: list[dict] = []
    category_counts = Counter()
    duplicate_text_count = 0
    question_sha = "?"

    if questions_path.is_file():
        question_sha = hashlib.sha256(
            questions_path.read_bytes()
        ).hexdigest()

        try:
            raw = json.loads(
                questions_path.read_text(encoding="utf-8")
            )
        except Exception as exc:
            errors.append(f"Soru JSON okunamadı: {exc}")
            raw = []

        if not isinstance(raw, list):
            errors.append("Soru bankasının kökü liste değil.")
        else:
            questions = raw

    if len(questions) < MIN_TOTAL_QUESTIONS:
        errors.append(
            f"Toplam soru sayısı {len(questions)}; "
            f"en az {MIN_TOTAL_QUESTIONS} olmalı."
        )

    seen_ids: set[str] = set()
    seen_texts: set[str] = set()

    for index, item in enumerate(questions, start=1):
        label = f"Soru {index}"

        if not isinstance(item, dict):
            errors.append(f"{label}: nesne değil.")
            continue

        question_id = str(item.get("id", "")).strip()
        question = str(item.get("question", "")).strip()
        explanation = str(
            item.get("explanation", "")
        ).strip()
        options = item.get("options")
        category = item.get("categoryIndex")
        answer = item.get("answerIndex")
        difficulty = str(
            item.get("difficulty", "")
        ).strip()

        if not question_id:
            errors.append(f"{label}: id boş.")
        elif question_id in seen_ids:
            errors.append(
                f"{label}: yinelenen id {question_id}."
            )
        else:
            seen_ids.add(question_id)

        if not question:
            errors.append(
                f"{label} ({question_id}): metin boş."
            )
        else:
            normalized = normalize(question)
            if normalized in seen_texts:
                duplicate_text_count += 1
            else:
                seen_texts.add(normalized)

        if not explanation:
            errors.append(
                f"{label} ({question_id}): açıklama boş."
            )

        if not isinstance(category, int) or not (
            0 <= category < CATEGORY_COUNT
        ):
            errors.append(
                f"{label} ({question_id}): kategori geçersiz."
            )
        else:
            category_counts[category] += 1

        if not isinstance(options, list) or len(options) != 4:
            errors.append(
                f"{label} ({question_id}): dört seçenek yok."
            )
        elif any(not str(option).strip() for option in options):
            errors.append(
                f"{label} ({question_id}): boş seçenek var."
            )

        if not isinstance(answer, int) or not 0 <= answer <= 3:
            errors.append(
                f"{label} ({question_id}): "
                "cevap indeksi geçersiz."
            )

        if difficulty not in {"Kolay", "Orta", "Zor"}:
            errors.append(
                f"{label} ({question_id}): zorluk geçersiz."
            )

    for category in range(CATEGORY_COUNT):
        count = category_counts[category]
        if count < MIN_QUESTIONS_PER_CATEGORY:
            errors.append(
                f"Kategori {category}: {count} soru; "
                f"en az {MIN_QUESTIONS_PER_CATEGORY} olmalı."
            )

    if duplicate_text_count:
        warnings.append(
            "Normalize edilmiş yinelenen soru metni: "
            f"{duplicate_text_count}"
        )

    for relative in USER_FACING_FILES:
        path = ROOT / relative
        if not path.is_file():
            continue
        source = path.read_text(encoding="utf-8")
        for forbidden in FORBIDDEN_TEXTS:
            if forbidden in source:
                errors.append(
                    f"{relative}: kaldırılmış metin bulundu: "
                    f"{forbidden!r}"
                )

    report_path = ROOT / args.report
    report_path.parent.mkdir(parents=True, exist_ok=True)

    status = "BAŞARILI" if not errors else "BAŞARISIZ"
    report_lines = [
        "# Bilgi Rotası RC2 Otomatik Kalite Raporu",
        "",
        f"- Durum: **{status}**",
        f"- Sürüm: `{version}`",
        f"- Toplam soru: **{len(questions)}**",
        f"- Soru dosyası SHA-256: `{question_sha}`",
        "",
        "## Kategori dağılımı",
        "",
    ]

    for category in range(CATEGORY_COUNT):
        report_lines.append(
            f"- Kategori {category}: "
            f"**{category_counts[category]}**"
        )

    report_lines.extend(
        [
            "",
            "## Uyarılar",
            "",
            *(
                [f"- {warning}" for warning in warnings]
                if warnings
                else ["- Uyarı yok."]
            ),
            "",
            "## Hatalar",
            "",
            *(
                [f"- {error}" for error in errors]
                if errors
                else ["- Kritik hata yok."]
            ),
            "",
        ]
    )

    report_path.write_text(
        "\n".join(report_lines),
        encoding="utf-8",
    )

    print("=" * 64)
    print(f"Bilgi Rotası RC2 kalite kapısı: {status}")
    print(f"Sürüm: {version}")
    print(f"Toplam soru: {len(questions)}")
    print(
        "Kategori dağılımı: "
        + ", ".join(
            f"{index}={category_counts[index]}"
            for index in range(CATEGORY_COUNT)
        )
    )
    if warnings:
        print("Uyarılar:")
        for warning in warnings:
            print(f"  - {warning}")
    if errors:
        print("Hatalar:")
        for error in errors[:40]:
            print(f"  - {error}")
        if len(errors) > 40:
            print(f"  ... ve {len(errors) - 40} hata daha")
    print(f"Rapor: {report_path.relative_to(ROOT)}")
    print("=" * 64)

    return 1 if errors else 0


if __name__ == "__main__":
    sys.exit(main())
