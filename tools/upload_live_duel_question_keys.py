#!/usr/bin/env python3
"""Bilgi Rotası Canlı Düello özel cevap anahtarlarını Firestore'a yükler."""

from __future__ import annotations

import argparse
import json
import sys
from dataclasses import dataclass
from pathlib import Path
from typing import Any, Iterable

DEFAULT_BANK_PATH = Path("assets/questions.json")
COLLECTION_NAME = "live_duel_question_keys"
DEFAULT_EXPECTED_COUNT = 6710
BATCH_SIZE = 400


class QuestionKeyError(RuntimeError):
    pass


@dataclass(frozen=True)
class QuestionKey:
    question_id: str
    answer_index: int
    option_count: int

    def firestore_payload(self) -> dict[str, Any]:
        return {
            "answerIndex": self.answer_index,
            "optionCount": self.option_count,
            "schemaVersion": 1,
        }


def load_question_keys(path: Path) -> list[QuestionKey]:
    try:
        raw = json.loads(path.read_text(encoding="utf-8"))
    except FileNotFoundError as error:
        raise QuestionKeyError(f"Soru bankası bulunamadı: {path}") from error
    except json.JSONDecodeError as error:
        raise QuestionKeyError(f"Geçersiz JSON: {error}") from error

    if not isinstance(raw, list):
        raise QuestionKeyError("Soru bankasının kökü liste olmalıdır.")

    result: list[QuestionKey] = []
    seen_ids: set[str] = set()

    for row_number, item in enumerate(raw, start=1):
        if not isinstance(item, dict):
            raise QuestionKeyError(f"{row_number}. kayıt nesne değil.")

        question_id = str(item.get("id", "")).strip()
        answer_index = item.get("answerIndex")
        options = item.get("options")

        if not question_id:
            raise QuestionKeyError(f"{row_number}. kaydın kimliği boş.")
        if "/" in question_id:
            raise QuestionKeyError(
                f"Soru kimliği '/' içeremez: {question_id}"
            )
        if question_id in seen_ids:
            raise QuestionKeyError(
                f"Tekrarlanan soru kimliği: {question_id}"
            )
        if not isinstance(options, list) or len(options) < 2:
            raise QuestionKeyError(
                f"Seçenek listesi geçersiz: {question_id}"
            )
        if not isinstance(answer_index, int):
            raise QuestionKeyError(
                f"answerIndex tam sayı değil: {question_id}"
            )
        if answer_index < 0 or answer_index >= len(options):
            raise QuestionKeyError(
                f"answerIndex seçenek aralığı dışında: {question_id}"
            )

        seen_ids.add(question_id)
        result.append(
            QuestionKey(
                question_id=question_id,
                answer_index=answer_index,
                option_count=len(options),
            )
        )

    result.sort(key=lambda item: item.question_id)
    return result


def chunks(
    items: list[QuestionKey],
    size: int,
) -> Iterable[list[QuestionKey]]:
    for index in range(0, len(items), size):
        yield items[index : index + size]


def validate_count(
    keys: list[QuestionKey],
    expected_count: int,
) -> None:
    if len(keys) != expected_count:
        raise QuestionKeyError(
            f"Soru sayısı uyuşmuyor: "
            f"beklenen={expected_count}, bulunan={len(keys)}"
        )


def upload(
    *,
    project_id: str,
    keys: list[QuestionKey],
) -> None:
    try:
        from google.cloud import firestore
    except ImportError as error:
        raise QuestionKeyError(
            "google-cloud-firestore kurulu değil. "
            "Önce: python3 -m pip install --user google-cloud-firestore"
        ) from error

    client = firestore.Client(project=project_id)
    collection = client.collection(COLLECTION_NAME)
    uploaded = 0

    for batch_number, part in enumerate(
        chunks(keys, BATCH_SIZE),
        start=1,
    ):
        batch = client.batch()

        for key in part:
            reference = collection.document(key.question_id)
            payload = key.firestore_payload()
            payload["updatedAt"] = firestore.SERVER_TIMESTAMP
            batch.set(reference, payload)

        batch.commit()
        uploaded += len(part)
        print(
            f"Paket {batch_number}: {uploaded}/{len(keys)} yüklendi.",
            flush=True,
        )

    print(
        f"ANAHTAR YÜKLEME TAMAMLANDI: {uploaded} belge",
        flush=True,
    )


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--project")
    parser.add_argument(
        "--bank",
        type=Path,
        default=DEFAULT_BANK_PATH,
    )
    parser.add_argument(
        "--expected-count",
        type=int,
        default=DEFAULT_EXPECTED_COUNT,
    )
    parser.add_argument(
        "--validate-only",
        action="store_true",
    )
    return parser.parse_args()


def main() -> int:
    args = parse_args()

    try:
        keys = load_question_keys(args.bank)
        validate_count(keys, args.expected_count)
        print(
            f"Soru anahtarı doğrulandı: {len(keys)} benzersiz kayıt.",
            flush=True,
        )

        if args.validate_only:
            print("DOĞRULAMA TAMAMLANDI", flush=True)
            return 0

        if not args.project:
            raise QuestionKeyError(
                "Yükleme için --project zorunludur."
            )

        upload(project_id=args.project, keys=keys)
        return 0
    except QuestionKeyError as error:
        print(f"HATA: {error}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
