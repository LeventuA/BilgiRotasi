#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""Build the closed-test release readiness report from live build facts."""

from __future__ import annotations

import argparse
import hashlib
import json
import re
from pathlib import Path

PACKAGE_NAME = "com.leventua.bilgirotasi"
CERTIFICATE_SHA1 = "00:0E:E4:3F:41:0A:BC:6B:4F:63:4C:4F:71:6D:76:EB:19:08:41:15"
FIREBASE_PROJECT = "bilgi-rotasi-f255d"


def _read_version(root: Path) -> tuple[str, str, str]:
    pubspec = (root / "pubspec.yaml").read_text(encoding="utf-8")
    match = re.search(r"(?m)^version:\s*([^\s]+)\s*$", pubspec)
    if not match:
        raise ValueError("pubspec.yaml version alanı bulunamadı")
    version = match.group(1)
    version_match = re.fullmatch(r"(\d+\.\d+\.\d+)\+(\d+)", version)
    if not version_match:
        raise ValueError(f"Geçersiz sürüm biçimi: {version}")
    return version, version_match.group(1), version_match.group(2)


def _read_question_facts(root: Path) -> tuple[int, str]:
    questions_path = root / "assets/questions.json"
    raw_bytes = questions_path.read_bytes()
    questions = json.loads(raw_bytes.decode("utf-8"))
    if not isinstance(questions, list):
        raise ValueError("assets/questions.json kökü liste değil")
    return len(questions), hashlib.sha256(raw_bytes).hexdigest()


def generate_report(
    *,
    root: Path,
    output: Path,
    source_sha: str,
    source_ref: str,
    aab_file: str,
    workflow_run_url: str,
) -> Path:
    version, version_name, version_code = _read_version(root)
    question_count, question_sha = _read_question_facts(root)
    resolved_aab = aab_file.strip() or (
        f"BilgiRotasi-{version_name}-{version_code}-closed-test.aab"
    )
    resolved_sha = source_sha.strip() or "DOĞRULANACAK"
    resolved_ref = source_ref.strip() or "DOĞRULANACAK"
    resolved_run = workflow_run_url.strip() or "DOĞRULANACAK"

    lines = [
        f"# Bilgi Rotası {version} Kapalı Test Yayın Hazırlığı",
        "",
        "## Otomatik yayın özeti",
        "",
        f"- Kaynak ref: `{resolved_ref}`",
        f"- Kaynak commit: `{resolved_sha}`",
        f"- Hedef paket: `{PACKAGE_NAME}`",
        f"- Sürüm: `{version}`",
        f"- Toplam soru: **{question_count}**",
        f"- Soru dosyası SHA-256: `{question_sha}`",
        f"- Hedef AAB: `{resolved_aab}`",
        f"- Workflow run: {resolved_run}",
        f"- Beklenen upload sertifika SHA-1: `{CERTIFICATE_SHA1}`",
        f"- Firebase profili: production / `{FIREBASE_PROJECT}`",
        "- Reklam profili: `closed_test` / Google demo reklam birimleri",
        "",
        "## Rapor kaynağı ve sınırı",
        "",
        "Bu rapor statik release geçmişinden kopyalanmaz. Sürüm `pubspec.yaml` ",
        "dosyasından, soru sayısı ve SHA-256 değeri gerçek `assets/questions.json` ",
        "dosyasından, kaynak commit/ref ile AAB adı ise GitHub Actions çalışma ",
        "ortamından üretilir.",
        "",
        "Workflow daha sonra test sonuçlarını ve Android 16 uygulama/release gate ",
        "kanıtlarını bu dosyaya ekler. Bu rapor tek başına Play Console veya canlı ",
        "Firebase deploy durumunu doğrulamaz.",
        "",
    ]

    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text("\n".join(lines), encoding="utf-8")
    return output


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--root", default=".")
    parser.add_argument("--output", required=True)
    parser.add_argument("--source-sha", default="")
    parser.add_argument("--source-ref", default="")
    parser.add_argument("--aab-file", default="")
    parser.add_argument("--workflow-run-url", default="")
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    root = Path(args.root).resolve()
    output = Path(args.output)
    if not output.is_absolute():
        output = root / output
    generated = generate_report(
        root=root,
        output=output,
        source_sha=args.source_sha,
        source_ref=args.source_ref,
        aab_file=args.aab_file,
        workflow_run_url=args.workflow_run_url,
    )
    print(f"Release readiness report: {generated}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
