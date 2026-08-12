#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""Run the proven RC1 quality gate and refresh CI release-readiness facts."""

from __future__ import annotations

import os
import sys
from pathlib import Path

from rc1_quality_gate_impl import main as quality_gate_main
from release_readiness_report import generate_report

ROOT = Path(__file__).resolve().parents[1]
QUALITY_GATE_IMPL = ROOT / "tools/rc1_quality_gate_impl.py"
QUALITY_GATE_CONTRACT_MARKER = "AppBuildInfo sürümü uyuşmuyor"


def _assert_quality_gate_contract() -> None:
    source = QUALITY_GATE_IMPL.read_text(encoding="utf-8")
    if QUALITY_GATE_CONTRACT_MARKER not in source:
        raise RuntimeError(
            "RC1 kalite motoru AppBuildInfo sürüm uyuşmazlığı kapısını kaybetti"
        )


def _workflow_run_url() -> str:
    server = os.environ.get("GITHUB_SERVER_URL", "").strip()
    repository = os.environ.get("GITHUB_REPOSITORY", "").strip()
    run_id = os.environ.get("GITHUB_RUN_ID", "").strip()
    if server and repository and run_id:
        return f"{server}/{repository}/actions/runs/{run_id}"
    return ""


def main() -> int:
    _assert_quality_gate_contract()
    quality_exit = quality_gate_main()

    if os.environ.get("GITHUB_ACTIONS", "").lower() == "true":
        try:
            generate_report(
                root=ROOT,
                output=ROOT / "RELEASE_READINESS.md",
                source_sha=os.environ.get("GITHUB_SHA", ""),
                source_ref=os.environ.get("GITHUB_REF_NAME", ""),
                aab_file=os.environ.get("AAB_FILE", ""),
                workflow_run_url=_workflow_run_url(),
            )
        except Exception as exc:
            print(
                f"Release readiness raporu üretilemedi: {exc}",
                file=sys.stderr,
            )
            return 1

    return quality_exit


if __name__ == "__main__":
    raise SystemExit(main())
