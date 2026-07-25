#!/usr/bin/env python3
from collections import Counter
from pathlib import Path
import json
import sys

VALID_DIFFICULTIES = {"Kolay", "Orta", "Zor"}
VALID_CATEGORIES = set(range(6))


def normalize(value: str) -> str:
    return " ".join(value.casefold().split())


def fail(message: str) -> None:
    print(f"❌ {message}")
    raise SystemExit(1)


def main() -> None:
    path = Path(
        sys.argv[1]
        if len(sys.argv) > 1
        else "assets/questions.json"
    )

    if not path.exists():
        fail(f"Soru dosyası bulunamadı: {path}")

    try:
        data = json.loads(path.read_text(encoding="utf-8"))
    except Exception as error:
        fail(f"JSON okunamadı: {error}")

    if not isinstance(data, list):
        fail("Kök JSON değeri liste olmalı.")

    if len(data) < 3000:
        fail(
            "Yayın adayı için en az 3000 soru gerekiyor; "
            f"{len(data)} bulundu."
        )

    ids: set[str] = set()
    question_texts: set[str] = set()
    duplicate_ids = 0
    duplicate_texts = 0
    empty_explanations = 0
    invalid = 0
    categories: Counter[int] = Counter()
    difficulties: Counter[str] = Counter()
    answer_positions: Counter[int] = Counter()

    for index, item in enumerate(data, start=1):
        if not isinstance(item, dict):
            print(f"⚠️ {index}. kayıt nesne değil.")
            invalid += 1
            continue

        question_id = str(item.get("id", "")).strip()
        question = str(item.get("question", "")).strip()
        explanation = str(item.get("explanation", "")).strip()
        options = item.get("options")
        answer_index = item.get("answerIndex")
        category = item.get("categoryIndex")
        difficulty = str(item.get("difficulty", "")).strip()

        if not question_id or question_id in ids:
            duplicate_ids += 1
        ids.add(question_id)

        normalized = normalize(question)
        if normalized and normalized in question_texts:
            duplicate_texts += 1
        question_texts.add(normalized)

        options_valid = (
            isinstance(options, list)
            and len(options) == 4
            and all(str(option).strip() for option in options)
            and len({normalize(str(option)) for option in options}) == 4
        )

        record_valid = (
            bool(question_id)
            and bool(question)
            and options_valid
            and answer_index in (0, 1, 2, 3)
            and category in VALID_CATEGORIES
            and difficulty in VALID_DIFFICULTIES
        )

        if not record_valid:
            invalid += 1

        if not explanation:
            empty_explanations += 1

        if category in VALID_CATEGORIES:
            categories[category] += 1

        if difficulty in VALID_DIFFICULTIES:
            difficulties[difficulty] += 1

        if answer_index in (0, 1, 2, 3):
            answer_positions[answer_index] += 1

    if duplicate_ids:
        fail(f"{duplicate_ids} yinelenen veya boş kimlik var.")

    if invalid:
        fail(f"{invalid} geçersiz soru kaydı var.")

    missing = [
        category
        for category in sorted(VALID_CATEGORIES)
        if categories[category] == 0
    ]
    if missing:
        fail("Boş kategoriler var: " + ", ".join(map(str, missing)))

    print(f"✅ {len(data)} soru yapısal kontrolden geçti.")
    print("✅ Altı kategorinin tamamında soru bulunuyor.")
    print("✅ Yinelenen soru kimliği bulunmadı.")
    print("✅ Bütün sorularda dört farklı seçenek var.")
    print(
        "ℹ️ Zorluk dağılımı: "
        + ", ".join(
            f"{key}={value}"
            for key, value in sorted(difficulties.items())
        )
    )
    print(
        "ℹ️ Doğru şık konumları: "
        + ", ".join(
            f"{key}={value}"
            for key, value in sorted(answer_positions.items())
        )
    )

    if duplicate_texts:
        print(
            "⚠️ Tam normalleştirilmiş metne göre "
            f"{duplicate_texts} yinelenen soru uyarısı."
        )

    if empty_explanations:
        print(f"⚠️ {empty_explanations} soruda açıklama boş.")


if __name__ == "__main__":
    main()
