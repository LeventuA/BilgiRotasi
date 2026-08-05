"""Validate committed structural 3D Camera B previews and reports."""

from __future__ import annotations

import json
from pathlib import Path
import struct

from board_3d_structure import build_structural_report, build_structural_scene
from board_map_parity import build_parity_report
from render_structural_3d_preview import (
    CLOSEUP_PNG_NAME,
    DEFAULT_OUTPUT,
    MAIN_PNG_NAME,
    REPORT_JSON_NAME,
    REPORT_MD_NAME,
    report_markdown,
)


def _png_size(path: Path) -> tuple[int, int]:
    raw = path.read_bytes()
    if raw[:8] != b"\x89PNG\r\n\x1a\n" or raw[12:16] != b"IHDR":
        raise ValueError(f"Invalid PNG: {path}")
    return struct.unpack(">II", raw[16:24])


def validate_files(output_dir: Path = DEFAULT_OUTPUT) -> list[str]:
    errors: list[str] = []
    parity = build_parity_report()
    if parity["status"] != "PASS" or parity["matched_nodes"] != 67:
        errors.append(f"Live BoardMap parity is {parity['status']} ({parity['matched_nodes']}/67).")
    scene = build_structural_scene()
    report = build_structural_report(scene)
    if report["status"] != "PASS":
        errors.extend(report["errors"])
    for name in (MAIN_PNG_NAME, CLOSEUP_PNG_NAME):
        path = output_dir / name
        if not path.is_file():
            errors.append(f"Missing structural PNG: {path}")
            continue
        try:
            if _png_size(path) != (4096, 4096):
                errors.append(f"{name} is {_png_size(path)}, expected 4096x4096.")
        except (OSError, ValueError, struct.error) as error:
            errors.append(str(error))
    expected_json = json.dumps(report, ensure_ascii=False, indent=2, sort_keys=True) + "\n"
    json_path = output_dir / REPORT_JSON_NAME
    if not json_path.is_file():
        errors.append(f"Missing structural JSON report: {json_path}")
    elif json_path.read_text(encoding="utf-8") != expected_json:
        errors.append("Structural JSON report is not deterministic/current.")
    md_path = output_dir / REPORT_MD_NAME
    if not md_path.is_file():
        errors.append(f"Missing structural Markdown report: {md_path}")
    elif md_path.read_text(encoding="utf-8") != report_markdown(report):
        errors.append("Structural Markdown report is not deterministic/current.")
    return errors


def main() -> None:
    errors = validate_files()
    if errors:
        for error in errors:
            print(f"FAIL: {error}")
        raise SystemExit(1)
    report = build_structural_report()
    print("PASS: live BoardMap parity remains 67/67.")
    print("PASS: canonical Camera B parameters and near/far ratio are unchanged.")
    print(f"PASS: {report['visible_node_count']} structural node parts are visible (30 outer, 30 inner, 6 badge, 1 center).")
    print("PASS: outer=5/5/5/5/5/5; inner=5/5/5/5/5/5; south=52-56; sport=62-66.")
    print("PASS: labels, center clearance, badge clearance and far-to-near occlusion order are valid.")
    print("PASS: main and close-up PNG outputs are 4096x4096.")


if __name__ == "__main__":
    main()
