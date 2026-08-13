"""Render canonical Camera B structural 3D board previews."""

from __future__ import annotations

import argparse
import hashlib
import html
import json
from pathlib import Path
import tempfile
from typing import Any

from board_3d_structure import build_structural_report, build_structural_scene
from render_debug_board import rasterize_svg


ROOT = Path(__file__).resolve().parent
DEFAULT_OUTPUT = ROOT / "output"
MAIN_PNG_NAME = "board_structural_3d_camera_B_4096.png"
CLOSEUP_PNG_NAME = "board_structural_3d_camera_B_closeup_4096.png"
REPORT_JSON_NAME = "board_structural_3d_report.json"
REPORT_MD_NAME = "board_structural_3d_report.md"
VIEWBOX_SIZE = 1000

TOP_COLORS = {"center": "#E2E8F0", "badge": "#F59E0B", "outer_tile": "#3B82F6", "inner_tile": "#8B5CF6"}
SIDE_COLORS = {"center": "#64748B", "badge": "#92400E", "outer_tile": "#1E3A8A", "inner_tile": "#4C1D95"}
TEXT_COLORS = {"center": "#0F172A", "badge": "#111827", "outer_tile": "#F8FAFC", "inner_tile": "#F8FAFC"}


def _n(value: float) -> str:
    value = value * VIEWBOX_SIZE
    rendered = f"{value:.4f}".rstrip("0").rstrip(".")
    return rendered if rendered != "-0" else "0"


def _points(points: list[dict[str, float]]) -> str:
    return " ".join(f"{_n(point['x'])},{_n(point['y'])}" for point in points)


def render_structural_svg(scene: dict[str, Any], closeup: bool = False) -> str:
    viewbox = "245 320 510 570" if closeup else "0 0 1000 1000"
    title = "Camera B structural 3D close-up" if closeup else "Camera B structural 3D board"
    lines = [
        '<?xml version="1.0" encoding="UTF-8"?>',
        f'<svg xmlns="http://www.w3.org/2000/svg" width="4096" height="4096" viewBox="{viewbox}" preserveAspectRatio="xMidYMid meet">',
        f"  <title>{title}</title>",
        "  <desc>Deterministic structural geometry only: separate extruded parts, no final style.</desc>",
        '  <rect x="-1000" y="-1000" width="3000" height="3000" fill="#0B1120"/>',
    ]
    by_id = {piece["id"]: piece for piece in scene["pieces"]}
    for carrier in scene["carriers"]:
        lines.append(f'  <line x1="{_n(carrier["start"]["x"])}" y1="{_n(carrier["start"]["y"])}" x2="{_n(carrier["end"]["x"])}" y2="{_n(carrier["end"]["y"])}" stroke="#334155" stroke-width="{carrier["stroke_width_viewbox_units"]}" stroke-linecap="round"/>')
    for face in scene["faces_in_occlusion_order"]:
        piece = by_id[face["node_id"]]
        fill = TOP_COLORS[piece["type"]] if face["kind"] == "top" else SIDE_COLORS[piece["type"]]
        stroke = "#CBD5E1" if face["kind"] == "top" else "#1E293B"
        width = "1.8" if face["kind"] == "top" else "1.2"
        lines.append(f'  <polygon points="{_points(face["polygon"])}" fill="{fill}" stroke="{stroke}" stroke-width="{width}" stroke-linejoin="round"/>')
    # Labels deliberately follow every physical face so no nearer part can hide an ID.
    for piece in scene["pieces"]:
        label = piece["label"]
        font_size = label["font_size_normalized"] * VIEWBOX_SIZE
        line_height = label["line_height_normalized"] * VIEWBOX_SIZE
        start_y = piece["center"]["y"] * VIEWBOX_SIZE - (len(label["lines"]) - 1) * line_height / 2
        for index, line in enumerate(label["lines"]):
            lines.append(f'  <text x="{_n(piece["center"]["x"])}" y="{start_y + index * line_height:.4f}" text-anchor="middle" dominant-baseline="middle" font-family="Arial, sans-serif" font-size="{font_size:.4f}" font-weight="700" fill="{TEXT_COLORS[piece["type"]]}">{html.escape(line)}</text>')
    if not closeup:
        lines.extend([
            '  <text x="28" y="38" font-family="Arial, sans-serif" font-size="18" font-weight="700" fill="#E2E8F0">STRUCTURAL 3D — CAMERA B</text>',
            '  <text x="28" y="62" font-family="Arial, sans-serif" font-size="12" fill="#94A3B8">67 separate extruded parts | top + side faces | deterministic geometry</text>',
        ])
    lines.append("</svg>")
    return "\n".join(lines) + "\n"


def report_markdown(report: dict[str, Any]) -> str:
    camera = report["camera"]
    thickness = report["thickness_world_units"]
    return "\n".join([
        "# Structural 3D Board Validation",
        "",
        f"- Status: `{report['status']}`",
        f"- Camera B: elevation `{camera['elevation_degrees']}°`, azimuth `{camera['azimuth_degrees']}°`, distance `{camera['distance']}`, vertical FOV `{camera['vertical_fov_degrees']}°`",
        f"- Near/far scale ratio: `{report['near_far_scale_ratio']}`",
        f"- Visible nodes: `{report['visible_node_count']}` (`30 outer + 30 inner + 6 badge + 1 center`)",
        f"- Outer segment counts: `{report['outer_segment_counts']}`",
        f"- Inner path counts: `{report['inner_path_counts']}`",
        f"- South inner path: `{report['south_inner_node_ids']}`",
        f"- Sport inner path: `{report['sport_inner_node_ids']}`",
        f"- Carrier widths: radial `{report['carrier_stroke_width_viewbox_units']['radial']}` (+`{report['carrier_width_increase_percent']}%`), outer ring `{report['carrier_stroke_width_viewbox_units']['outer_ring']}`",
        f"- Carrier counts: `{report['carrier_counts']}`",
        "",
        "## Fixed thickness values (world units)",
        "",
        f"- Ring/base: `{thickness['ring_base']}`",
        f"- Outer tile: `{thickness['outer_tile']}`",
        f"- Inner tile: `{thickness['inner_tile']}`",
        f"- Badge: `{thickness['badge']}`",
        f"- Center: `{thickness['center']}`",
        "",
        "This is structural geometry only; it contains no final texture, logo, icons, pawns, glow, premium paint, Flutter integration, or APK work.",
        "",
    ])


def render_outputs(output_dir: Path = DEFAULT_OUTPUT, pixel_size: int = 4096) -> dict[str, Path]:
    output_dir.mkdir(parents=True, exist_ok=True)
    scene = build_structural_scene()
    report = build_structural_report(scene)
    if report["status"] != "PASS":
        raise ValueError("Structural scene validation failed: " + "; ".join(report["errors"]))
    main_path = output_dir / MAIN_PNG_NAME
    closeup_path = output_dir / CLOSEUP_PNG_NAME
    with tempfile.TemporaryDirectory(prefix="board-3d-svg-") as temporary:
        temp = Path(temporary)
        main_svg = temp / "main.svg"
        closeup_svg = temp / "closeup.svg"
        main_svg.write_text(render_structural_svg(scene), encoding="utf-8", newline="\n")
        closeup_svg.write_text(render_structural_svg(scene, closeup=True), encoding="utf-8", newline="\n")
        rasterize_svg(main_svg, main_path, pixel_size=pixel_size)
        rasterize_svg(closeup_svg, closeup_path, pixel_size=pixel_size)
    json_path = output_dir / REPORT_JSON_NAME
    md_path = output_dir / REPORT_MD_NAME
    json_path.write_text(json.dumps(report, ensure_ascii=False, indent=2, sort_keys=True) + "\n", encoding="utf-8", newline="\n")
    md_path.write_text(report_markdown(report), encoding="utf-8", newline="\n")
    return {"main": main_path, "closeup": closeup_path, "json": json_path, "markdown": md_path}


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--output-dir", type=Path, default=DEFAULT_OUTPUT)
    parser.add_argument("--pixel-size", type=int, default=4096)
    args = parser.parse_args()
    for name, path in render_outputs(args.output_dir, args.pixel_size).items():
        print(f"{name}: {path} ({hashlib.sha256(path.read_bytes()).hexdigest()})")


if __name__ == "__main__":
    main()
