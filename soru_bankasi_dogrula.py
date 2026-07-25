#!/usr/bin/env python3
from collections import Counter
from pathlib import Path
import json
import sys

CATEGORY_NAMES = {
    0: "Coğrafya",
    1: "Eğlence",
    2: "Tarih",
    3: "Sanat & Edebiyat",
    4: "Bilim & Doğa",
    5: "Spor",
}

EXPECTED_DIFFICULTY = {
    "Kolay": 150,
    "Orta": 200,
    "Zor": 150,
}

def fail(message):
    print(f"❌ {message}")
    raise SystemExit(1)

def main():
    path = Path(
        sys.argv[1] if len(sys.argv) > 1
        else "assets/questions.json"
    )

    if not path.exists():
        fail(f"Dosya bulunamadı: {path}")

    try:
        data = json.loads(path.read_text(encoding="utf-8"))
    except Exception as error:
        fail(f"JSON okunamadı: {error}")

    if not isinstance(data, list):
        fail("Kök JSON değeri liste olmalı.")

    if len(data) != 3000:
        fail(f"3000 soru bekleniyordu, {len(data)} bulundu.")

    expected_ids = [
        f"q{index:03d}"
        for index in range(1, 3001)
    ]
    actual_ids = [item.get("id") for item in data]

    if actual_ids != expected_ids:
        fail("Soru kimlikleri q001–q3000 sırasında değil.")

    categories = Counter()
    difficulties = {
        category: Counter()
        for category in CATEGORY_NAMES
    }
    answer_positions = Counter()
    normalized_questions = set()

    for position, item in enumerate(data, start=1):
        if not isinstance(item, dict):
            fail(f"{position}. kayıt nesne değil.")

        category = item.get("categoryIndex")
        if category not in CATEGORY_NAMES:
            fail(f"{item.get('id')}: geçersiz kategori.")

        question = str(item.get("question", "")).strip()
        explanation = str(item.get("explanation", "")).strip()
        options = item.get("options")
        answer_index = item.get("answerIndex")
        difficulty = item.get("difficulty")

        if not question:
            fail(f"{item.get('id')}: soru metni boş.")

        if not explanation:
            fail(f"{item.get('id')}: açıklama boş.")

        normalized = " ".join(question.casefold().split())
        if normalized in normalized_questions:
            fail(f"{item.get('id')}: yinelenen soru metni.")

        normalized_questions.add(normalized)

        if not isinstance(options, list) or len(options) != 4:
            fail(f"{item.get('id')}: dört seçenek bulunmalı.")

        clean_options = [
            str(option).strip()
            for option in options
        ]

        if any(not option for option in clean_options):
            fail(f"{item.get('id')}: boş seçenek var.")

        if len({
            option.casefold()
            for option in clean_options
        }) != 4:
            fail(f"{item.get('id')}: seçenekler farklı değil.")

        if answer_index not in (0, 1, 2, 3):
            fail(f"{item.get('id')}: cevap indeksi geçersiz.")

        if difficulty not in EXPECTED_DIFFICULTY:
            fail(f"{item.get('id')}: zorluk geçersiz.")

        categories[category] += 1
        difficulties[category][difficulty] += 1
        answer_positions[answer_index] += 1

    for category, name in CATEGORY_NAMES.items():
        if categories[category] != 500:
            fail(
                f"{name}: 500 yerine "
                f"{categories[category]} soru var."
            )

        if difficulties[category] != Counter(
            EXPECTED_DIFFICULTY
        ):
            fail(
                f"{name}: zorluk dağılımı hatalı: "
                f"{dict(difficulties[category])}"
            )

    if answer_positions != Counter({
        0: 750,
        1: 750,
        2: 750,
        3: 750,
    }):
        fail(
            "Doğru şık dağılımı hatalı: "
            f"{dict(answer_positions)}"
        )

    print("✅ 3000 soru başarıyla doğrulandı.")
    print("✅ Her kategoride 500 soru bulunuyor.")
    print("✅ Her kategoride 150 Kolay, 200 Orta, 150 Zor.")
    print("✅ A, B, C ve D konumlarının her birinde 750 cevap.")
    print("✅ Yinelenen tam soru metni veya bozuk seçenek yok.")

if __name__ == "__main__":
    main()
