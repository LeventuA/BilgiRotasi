"""Render three deterministic, numbered perspective geometry previews."""

from __future__ import annotations

import argparse
import hashlib
import html
import json
from pathlib import Path
import tempfile
from typing import Any

from perspective_projection import (
    build_validation_report,
    load_camera_presets,
    load_geometry,
    project_geometry,
)
from render_debug_board import rasterize_svg


ROOT = Path(__file__).resolve().parent
DEFAULT_OUTPUT = ROOT / "output"
VIEWBOX_SIZE = 1000
COMPARISON_NAME = "board_perspective_camera_comparison.png"
VALIDATION_REPORT_NAME = "perspective_validation_report.json"

TYPE_COLORS = {
    "center": ("#F8FAFC", "#111827"),
    "badge": ("#FBBF24", "#111827"),
    "outer_tile": ("#2563EB", "#FFFFFF"),
    "inner_tile": ("#7C3AED", "#FFFFFF"),
}


def svg_name(camera_id: str) -> str:
    return f"board_perspective_{camera_id}_numbered.svg"


def png_name(camera_id: str) -> str:
    return f"board_perspective_{camera_id}_numbered_4096.png"


def _n(value: float) -> str:
    rendered = f"{value:.4f}".rstrip("0").rstrip(".")
    return rendered if rendered != "-0" else "0"


def _screen(value: float) -> float:
    return value * VIEWBOX_SIZE


def _points(points: list[dict[str, float]]) -> str:
    return " ".join(
        f"{_n(_screen(point['x']))},{_n(_screen(point['y']))}" for point in points
    )


def render_perspective_svg(projection: dict[str, Any]) -> str:
    camera = projection["camera"]
    lines = [
        '<?xml version="1.0" encoding="UTF-8"?>',
        '<svg xmlns="http://www.w3.org/2000/svg" width="4096" height="4096" viewBox="0 0 1000 1000">',
        f"  <title>Bilgi Rotasi perspective camera {camera['id']}</title>",
        "  <desc>Per-piece pinhole projection; numbered geometry only.</desc>",
        '  <rect width="1000" height="1000" fill="#0F172A"/>',
        f'  <polyline points="{_points(projection["board_outline"])}" fill="#111827" stroke="#475569" stroke-width="2"/>',
    ]

    for edge in projection["edges"]:
        lines.append(
            '  <line x1="{}" y1="{}" x2="{}" y2="{}" stroke="#64748B" stroke-width="2"/>'.format(
                _n(_screen(edge["start"]["x"])),
                _n(_screen(edge["start"]["y"])),
                _n(_screen(edge["end"]["x"])),
                _n(_screen(edge["end"]["y"])),
            )
        )

    # Far pieces are emitted first. The validated polygons do not overlap, but
    # stable depth ordering makes the intended camera model explicit.
    nodes = sorted(
        projection["nodes"], key=lambda node: (-node["center"]["depth"], node["id"])
    )
    for node in nodes:
        fill, text_color = TYPE_COLORS[node["type"]]
        lines.append(
            f'  <polygon points="{_points(node["polygon"])}" fill="{fill}" stroke="#CBD5E1" stroke-width="1.5"/>'
        )
        label = node["label"]
        font_size = _screen(label["font_size_normalized"])
        line_height = _screen(label["line_height_normalized"])
        center_x = _screen(node["center"]["x"])
        center_y = _screen(node["center"]["y"])
        first_y = center_y - (len(label["lines"]) - 1) * line_height / 2
        for index, raw_line in enumerate(label["lines"]):
            weight = "700" if index == 0 else "600"
            lines.append(
                f'  <text x="{_n(center_x)}" y="{_n(first_y + index * line_height)}" text-anchor="middle" dominant-baseline="middle" font-family="Arial, sans-serif" font-size="{_n(font_size)}" font-weight="{weight}" fill="{text_color}">{html.escape(raw_line)}</text>'
            )

    ratio = projection["near_far_scale_ratio"]
    lines.extend(
        [
            f'  <text x="28" y="38" font-family="Arial, sans-serif" font-size="18" font-weight="700" fill="#E2E8F0">CAMERA {camera["id"]} — NUMBERED PERSPECTIVE GEOMETRY</text>',
            f'  <text x="28" y="62" font-family="Arial, sans-serif" font-size="12" fill="#94A3B8">elevation {camera["elevation_degrees"]}° | azimuth {camera["azimuth_degrees"]}° | distance {camera["distance"]} | vertical FOV {camera["vertical_fov_degrees"]}° | near/far {ratio}</text>',
            '  <text x="972" y="38" text-anchor="end" font-family="Arial, sans-serif" font-size="11" font-weight="700" fill="#BFDBFE">FRONT / NEAR: SOUTH — NODES 52-56</text>',
            '  <text x="972" y="58" text-anchor="end" font-family="Arial, sans-serif" font-size="10" fill="#94A3B8">NORTH 1 | NE 7 | SE 13 | SOUTH 19 | SW 25 | NW 31</text>',
            "</svg>",
        ]
    )
    return "\n".join(lines) + "\n"


def render_comparison_svg(
    rendered_svgs: dict[str, str], projections: dict[str, dict[str, Any]]
) -> str:
    panels = []
    for index, camera_id in enumerate(("A", "B", "C")):
        x = 18 + index * 327
        projection = projections[camera_id]
        camera = projection["camera"]
        inner_svg = "\n".join(rendered_svgs[camera_id].splitlines()[2:-1])
        panels.extend(
            [
                f'  <rect x="{x}" y="150" width="309" height="309" fill="#111827" stroke="#475569" stroke-width="2"/>',
                f'  <g transform="translate({x} 150) scale(0.309)">',
                inner_svg,
                "  </g>",
                f'  <text x="{x + 154.5}" y="492" text-anchor="middle" font-family="Arial, sans-serif" font-size="21" font-weight="700" fill="#E2E8F0">CAMERA {camera_id}</text>',
                f'  <text x="{x + 154.5}" y="518" text-anchor="middle" font-family="Arial, sans-serif" font-size="12" fill="#CBD5E1">elevation {camera["elevation_degrees"]}° | near/far {projection["near_far_scale_ratio"]}</text>',
            ]
        )
    return "\n".join(
        [
            '<?xml version="1.0" encoding="UTF-8"?>',
            '<svg xmlns="http://www.w3.org/2000/svg" width="4096" height="4096" viewBox="0 0 1000 1000">',
            "  <title>Bilgi Rotasi perspective camera comparison</title>",
            '  <rect width="1000" height="1000" fill="#0F172A"/>',
            '  <text x="500" y="65" text-anchor="middle" font-family="Arial, sans-serif" font-size="28" font-weight="700" fill="#F8FAFC">DETERMINISTIC PERSPECTIVE CAMERA COMPARISON</text>',
            '  <text x="500" y="100" text-anchor="middle" font-family="Arial, sans-serif" font-size="14" fill="#94A3B8">Same live BoardMap orientation — south/front camera — per-piece pinhole projection</text>',
            *panels,
            '  <text x="500" y="610" text-anchor="middle" font-family="Arial, sans-serif" font-size="18" font-weight="700" fill="#BFDBFE">LIVE BOARDMAP DIRECTION LOCK</text>',
            '  <text x="500" y="646" text-anchor="middle" font-family="Arial, sans-serif" font-size="14" fill="#E2E8F0">North 1 Geography | NE 7 Entertainment | SE 13 History</text>',
            '  <text x="500" y="674" text-anchor="middle" font-family="Arial, sans-serif" font-size="14" fill="#E2E8F0">South 19 Art &amp; Literature | SW 25 Science &amp; Nature | NW 31 Sport</text>',
            '  <text x="500" y="736" text-anchor="middle" font-family="Arial, sans-serif" font-size="17" font-weight="700" fill="#FDE68A">67 nodes | six outer 1-5 intervals | six inner 1-5 paths</text>',
            '  <text x="500" y="774" text-anchor="middle" font-family="Arial, sans-serif" font-size="14" fill="#CBD5E1">South-facing inner path: nodes 52-56 — fully visible in A, B and C</text>',
            '  <text x="500" y="884" text-anchor="middle" font-family="Arial, sans-serif" font-size="13" fill="#64748B">Geometry only: no style, texture, shadow, logo, pawn, extrusion, Flutter or APK</text>',
            "</svg>",
        ]
    ) + "\n"


def _write_validation_report(output_dir: Path) -> Path:
    report_path = output_dir / VALIDATION_REPORT_NAME
    report_path.write_text(
        json.dumps(
            build_validation_report(), ensure_ascii=False, indent=2, sort_keys=True
        )
        + "\n",
        encoding="utf-8",
        newline="\n",
    )
    return report_path


def render_outputs(
    output_dir: Path = DEFAULT_OUTPUT, pixel_size: int = 4096
) -> dict[str, Path]:
    output_dir.mkdir(parents=True, exist_ok=True)
    geometry = load_geometry()
    rendered_svgs: dict[str, str] = {}
    projections: dict[str, dict[str, Any]] = {}
    outputs: dict[str, Path] = {}
    for camera in load_camera_presets():
        projection = project_geometry(geometry, camera)
        projections[camera.id] = projection
        svg = render_perspective_svg(projection)
        rendered_svgs[camera.id] = svg
        svg_path = output_dir / svg_name(camera.id)
        png_path = output_dir / png_name(camera.id)
        svg_path.write_text(svg, encoding="utf-8", newline="\n")
        rasterize_svg(svg_path, png_path, pixel_size=pixel_size)
        outputs[f"svg_{camera.id}"] = svg_path
        outputs[f"png_{camera.id}"] = png_path

    comparison_path = output_dir / COMPARISON_NAME
    with tempfile.TemporaryDirectory(prefix="board-camera-comparison-") as temporary:
        comparison_svg_path = Path(temporary) / "comparison.svg"
        comparison_svg_path.write_text(
            render_comparison_svg(rendered_svgs, projections),
            encoding="utf-8",
            newline="\n",
        )
        rasterize_svg(comparison_svg_path, comparison_path, pixel_size=pixel_size)
    outputs["comparison"] = comparison_path
    outputs["validation_report"] = _write_validation_report(output_dir)
    return outputs


def _digest(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--output-dir", type=Path, default=DEFAULT_OUTPUT)
    parser.add_argument("--pixel-size", type=int, default=4096)
    args = parser.parse_args()
    outputs = render_outputs(args.output_dir, args.pixel_size)
    for name, path in outputs.items():
        print(f"{name}: {path} ({_digest(path)})")


if __name__ == "__main__":
    main()
