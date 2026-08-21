#!/usr/bin/env python3
"""Export the live question-bank records referenced by pending Sheet feedback.

Read-only with respect to assets/questions.json. The generated audit report is
used to review text, options, correct index, explanation, category and difficulty
before any correction is applied.
"""

from __future__ import annotations

import hashlib
import json
from pathlib import Path

QUESTIONS = Path("assets/questions.json")
REPORT = Path("reports/pending_question_feedback_live_audit_20260821.json")
TARGET_IDS = ['q1674', 'q3637', 'q4133', 'q4651', 'q5881', 'q5895', 'q5923', 'q53177', 'q53487', 'q53516', 'q53762', 'q53795', 'q53840', 'q53895', 'q54089', 'q54117', 'q54456', 'q54458', 'q54542', 'q54578', 'q54698', 'q54720', 'q54859', 'q54864', 'q54906', 'q55048', 'q55622', 'q55642', 'q55644', 'q55769', 'q55884', 'q55897', 'q55974', 'q56205', 'q56212', 'q56291', 'q56292', 'q56421', 'q56438', 'q56483', 'q56525', 'q56603', 'q56652', 'q56838', 'q56861', 'q56874', 'q56990', 'q57009', 'q57245', 'q57273', 'q57344', 'q57392', 'q57582', 'q57606', 'q57626', 'q57669', 'q57837', 'q57878', 'q58001', 'q58048', 'q58182', 'q58331', 'q58413', 'q58469', 'q59101', 'q59379', 'q59438', 'q59474', 'q59480', 'q59537', 'q59729', 'q60051', 'q60058', 'q60099', 'q60204', 'q60223', 'q60324', 'q60346', 'q60481', 'q60506', 'q60513', 'q60525', 'q60547', 'q60592', 'q60598', 'q60649', 'q60652', 'q60654', 'q60665', 'q60668', 'q60705', 'q60714', 'q60739', 'q60746', 'q60753', 'q60756', 'q60765', 'q60766', 'q60774', 'q60788', 'q60810', 'q60813', 'q60818', 'q60836', 'q60857', 'q60872', 'q60874', 'q60880', 'q60889', 'q60898', 'q60899', 'q60904', 'q60908', 'q60920', 'q61051', 'q61062', 'q61074', 'q61075', 'q61081', 'q61083', 'q61094', 'q61097']


def fail(message: str) -> None:
    raise SystemExit(f"ERROR: {message}")


def main() -> int:
    if not QUESTIONS.exists():
        fail(f"missing {QUESTIONS}")

    raw = QUESTIONS.read_bytes()
    try:
        data = json.loads(raw.decode("utf-8"))
    except Exception as error:
        fail(f"questions.json could not be parsed: {error}")

    if not isinstance(data, list):
        fail("questions.json top-level value must be a list")

    by_id: dict[str, dict] = {}
    duplicates: list[str] = []
    for item in data:
        if not isinstance(item, dict):
            continue
        question_id = str(item.get("id", "")).strip()
        if not question_id:
            continue
        if question_id in by_id:
            duplicates.append(question_id)
        by_id[question_id] = item

    if duplicates:
        fail("duplicate ids: " + ", ".join(sorted(set(duplicates))))

    missing = [question_id for question_id in TARGET_IDS if question_id not in by_id]
    if missing:
        fail("missing target ids: " + ", ".join(missing))

    records: list[dict] = []
    for question_id in TARGET_IDS:
        item = by_id[question_id]
        options = item.get("options")
        answer_index = item.get("answerIndex")
        if not isinstance(options, list) or len(options) != 4:
            fail(f"{question_id} must have exactly four options")
        if not isinstance(answer_index, int) or not 0 <= answer_index < 4:
            fail(f"{question_id} has invalid answerIndex {answer_index!r}")

        records.append({
            "id": question_id,
            "categoryIndex": item.get("categoryIndex"),
            "question": item.get("question"),
            "options": options,
            "answerIndex": answer_index,
            "correctAnswer": options[answer_index],
            "difficulty": item.get("difficulty"),
            "explanation": item.get("explanation"),
        })

    payload = {
        "source": "assets/questions.json",
        "questionBankSha256": hashlib.sha256(raw).hexdigest(),
        "questionBankCount": len(data),
        "targetCount": len(TARGET_IDS),
        "targets": records,
    }

    REPORT.parent.mkdir(parents=True, exist_ok=True)
    REPORT.write_text(
        json.dumps(payload, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )
    print(
        f"PASS: exported {len(records)} pending-feedback questions "
        f"to {REPORT}"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
