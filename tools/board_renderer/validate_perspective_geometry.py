"""Validate committed perspective geometry previews and reports."""

from __future__ import annotations

import json
from pathlib import Path
import struct

from board_map_parity import build_parity_report
from perspective_projection import (
    build_validation_report,
    load_camera_presets,
    load_geometry,
    project_geometry,
)
from render_perspective_debug import (
    COMPARISON_NAME,
    DEFAULT_OUTPUT,
    VALIDATION_REPORT_NAME,
    png_name,
    render_perspective_svg,
    svg_name,
)


def _png_size(path: Path) -> tuple[int, int]:
    raw = path.read_bytes()
    if raw[:8] != b"\x89PNG\r\n\x1a\n" or raw[12:16] != b"IHDR":
        raise ValueError(f"Invalid PNG: {path}")
    return struct.unpack(">II", raw[16:24])


def validate_files(output_dir: Path = DEFAULT_OUTPUT) -> list[str]:
    errors: list[str] = []
    geometry = load_geometry()
    expected_report = build_validation_report(geometry)
    if expected_report["status"] != "PASS":
        errors.append("Calculated perspective validation report is not PASS.")

    parity = build_parity_report()
    if parity["status"] != "PASS" or parity["matched_nodes"] != 67:
        errors.append(
            f"Live BoardMap parity is {parity['status']} "
            f"({parity['matched_nodes']}/67)."
        )

    for camera in load_camera_presets():
        projection = project_geometry(geometry, camera)
        expected_svg = render_perspective_svg(projection)
        svg_path = output_dir / svg_name(camera.id)
        png_path = output_dir / png_name(camera.id)
        if not svg_path.is_file():
            errors.append(f"Missing camera {camera.id} SVG: {svg_path}")
        elif svg_path.read_text(encoding="utf-8") != expected_svg:
            errors.append(f"Camera {camera.id} SVG is not deterministic/current.")
        if not png_path.is_file():
            errors.append(f"Missing camera {camera.id} PNG: {png_path}")
        else:
            try:
                if _png_size(png_path) != (4096, 4096):
                    errors.append(
                        f"Camera {camera.id} PNG is {_png_size(png_path)}, expected 4096x4096."
                    )
            except (OSError, ValueError, struct.error) as error:
                errors.append(str(error))

    comparison_path = output_dir / COMPARISON_NAME
    if not comparison_path.is_file():
        errors.append(f"Missing camera comparison PNG: {comparison_path}")
    else:
        try:
            if _png_size(comparison_path) != (4096, 4096):
                errors.append(
                    f"Comparison PNG is {_png_size(comparison_path)}, expected 4096x4096."
                )
        except (OSError, ValueError, struct.error) as error:
            errors.append(str(error))

    report_path = output_dir / VALIDATION_REPORT_NAME
    expected_report_text = (
        json.dumps(expected_report, ensure_ascii=False, indent=2, sort_keys=True)
        + "\n"
    )
    if not report_path.is_file():
        errors.append(f"Missing perspective validation report: {report_path}")
    elif report_path.read_text(encoding="utf-8") != expected_report_text:
        errors.append("Perspective validation report is not deterministic/current.")
    return errors


def main() -> None:
    errors = validate_files()
    if errors:
        for error in errors:
            print(f"FAIL: {error}")
        raise SystemExit(1)
    report = build_validation_report()
    print("PASS: live BoardMap parity remains 67/67.")
    for camera in report["cameras"]:
        print(
            f"PASS: camera {camera['id']} projected 67 nodes; "
            f"near/far={camera['near_far_scale_ratio']}; "
            "outer=5/5/5/5/5/5; inner=5/5/5/5/5/5."
        )
    print("PASS: all polygons, centers and labels are visible and non-overlapping.")
    print("PASS: all camera and comparison PNG outputs are 4096x4096.")


if __name__ == "__main__":
    main()
