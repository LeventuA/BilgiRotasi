"""Render the deterministic numbered board to SVG and a 4096px PNG."""

from __future__ import annotations

import argparse
import hashlib
import html
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import time
from typing import Any

from board_geometry import generate_geometry


ROOT = Path(__file__).resolve().parent
DEFAULT_OUTPUT = ROOT / "output"
SVG_NAME = "board_debug_numbered.svg"
PNG_NAME = "board_debug_numbered_4096.png"
VIEWBOX_SIZE = 1000

TYPE_COLORS = {
    "center": ("#F8FAFC", "#111827"),
    "badge": ("#FBBF24", "#111827"),
    "outer_tile": ("#2563EB", "#FFFFFF"),
    "inner_tile": ("#7C3AED", "#FFFFFF"),
}


def _n(value: float) -> str:
    rendered = f"{value:.3f}".rstrip("0").rstrip(".")
    return rendered if rendered != "-0" else "0"


def _svg_coord(value: float) -> float:
    return value * VIEWBOX_SIZE


def _node_by_id(geometry: dict[str, Any]) -> dict[int, dict[str, Any]]:
    return {node["id"]: node for node in geometry["nodes"]}


def render_svg(geometry: dict[str, Any] | None = None) -> str:
    geometry = geometry or generate_geometry()
    nodes = sorted(geometry["nodes"], key=lambda node: node["id"])
    by_id = _node_by_id(geometry)
    lines = [
        '<?xml version="1.0" encoding="UTF-8"?>',
        '<svg xmlns="http://www.w3.org/2000/svg" width="4096" height="4096" viewBox="0 0 1000 1000">',
        "  <title>Bilgi Rotasi deterministic 67-node debug geometry</title>",
        "  <desc>Flat numbered geometry only; no production style or perspective.</desc>",
        '  <rect width="1000" height="1000" fill="#0F172A"/>',
        '  <circle cx="500" cy="500" r="420" fill="none" stroke="#334155" stroke-width="2"/>',
    ]

    drawn_edges: set[tuple[int, int]] = set()
    for node in nodes:
        for connected_id in node["connected_node_ids"]:
            edge = tuple(sorted((node["id"], connected_id)))
            if edge in drawn_edges:
                continue
            drawn_edges.add(edge)
            other = by_id[connected_id]
            lines.append(
                '  <line x1="{}" y1="{}" x2="{}" y2="{}" stroke="#64748B" stroke-width="2"/>'.format(
                    _n(_svg_coord(node["x_normalized"])),
                    _n(_svg_coord(node["y_normalized"])),
                    _n(_svg_coord(other["x_normalized"])),
                    _n(_svg_coord(other["y_normalized"])),
                )
            )

    for node in nodes:
        x = _svg_coord(node["x_normalized"])
        y = _svg_coord(node["y_normalized"])
        width = _svg_coord(node["width_normalized"])
        height = _svg_coord(node["height_normalized"])
        fill, text_color = TYPE_COLORS[node["type"]]
        node_type = node["type"]
        if node_type == "badge":
            radius = width / 2
            points = []
            for index in range(6):
                angle = -90 + index * 60
                radians = angle * 3.141592653589793 / 180
                points.append(
                    f"{_n(x + radius * __import__('math').cos(radians))},{_n(y + radius * __import__('math').sin(radians))}"
                )
            lines.append(
                f'  <polygon points="{" ".join(points)}" fill="{fill}" stroke="#FEF3C7" stroke-width="3"/>'
            )
        elif node_type == "center":
            lines.append(
                f'  <circle cx="{_n(x)}" cy="{_n(y)}" r="{_n(width / 2)}" fill="{fill}" stroke="#CBD5E1" stroke-width="3"/>'
            )
        else:
            lines.append(
                f'  <rect x="{_n(x - width / 2)}" y="{_n(y - height / 2)}" width="{_n(width)}" height="{_n(height)}" rx="6" fill="{fill}" stroke="#CBD5E1" stroke-width="2"/>'
            )

        id_font = 17 if node_type in {"center", "badge"} else 14
        id_y = y + (2 if node_type in {"center", "badge"} else -1)
        lines.append(
            f'  <text x="{_n(x)}" y="{_n(id_y)}" text-anchor="middle" dominant-baseline="middle" font-family="Arial, sans-serif" font-size="{id_font}" font-weight="700" fill="{text_color}">{node["id"]}</text>'
        )
        if node_type in {"outer_tile", "inner_tile"}:
            marker = (
                f"O{node['position_in_segment']}"
                if node_type == "outer_tile"
                else f"I{node['position_in_segment']}"
            )
            lines.append(
                f'  <text x="{_n(x)}" y="{_n(y + 11)}" text-anchor="middle" font-family="Arial, sans-serif" font-size="7.5" font-weight="700" fill="{text_color}">{marker}</text>'
            )
        elif node_type == "badge":
            category = html.escape(node["category_name"])
            lines.append(
                f'  <text x="{_n(x)}" y="{_n(y + 16)}" text-anchor="middle" font-family="Arial, sans-serif" font-size="5.2" font-weight="700" fill="{text_color}">{category}</text>'
            )

    lines.extend(
        [
            '  <rect x="718" y="18" width="254" height="50" rx="8" fill="#172554" stroke="#93C5FD" stroke-width="2"/>',
            '  <text x="845" y="40" text-anchor="middle" font-family="Arial, sans-serif" font-size="15" font-weight="700" fill="#DBEAFE">SOUTH INNER 1-5</text>',
            '  <text x="845" y="58" text-anchor="middle" font-family="Arial, sans-serif" font-size="9" fill="#BFDBFE">ARM 3 | NODES 52-56 | BADGE 19</text>',
            '  <text x="28" y="38" font-family="Arial, sans-serif" font-size="18" font-weight="700" fill="#E2E8F0">67-NODE DETERMINISTIC GEOMETRY</text>',
            '  <text x="28" y="62" font-family="Arial, sans-serif" font-size="13" fill="#94A3B8">0 center | 6 badges | 30 outer tiles | 30 inner tiles</text>',
            "</svg>",
        ]
    )
    return "\n".join(lines) + "\n"


def _browser_candidates() -> list[Path]:
    candidates: list[Path] = []
    for name in ("chrome", "chromium", "chromium-browser", "msedge"):
        found = shutil.which(name)
        if found:
            candidates.append(Path(found))
    if os.name == "nt":
        candidates.extend(
            Path(path)
            for path in (
                r"C:\Program Files\Google\Chrome\Application\chrome.exe",
                r"C:\Program Files (x86)\Google\Chrome\Application\chrome.exe",
                r"C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe",
                r"C:\Program Files\Microsoft\Edge\Application\msedge.exe",
            )
        )
    return [candidate for candidate in candidates if candidate.is_file()]


def rasterize_svg(svg_path: Path, png_path: Path, pixel_size: int = 4096) -> None:
    browsers = _browser_candidates()
    if not browsers:
        raise RuntimeError(
            "SVG rasterization requires Chrome, Chromium, or Microsoft Edge."
        )
    png_path.parent.mkdir(parents=True, exist_ok=True)
    png_path.unlink(missing_ok=True)
    with tempfile.TemporaryDirectory(
        prefix="board-render-", ignore_cleanup_errors=True
    ) as profile:
        command = [
            str(browsers[0]),
            "--headless=new",
            "--disable-gpu",
            "--disable-background-networking",
            "--disable-extensions",
            "--hide-scrollbars",
            "--no-first-run",
            "--run-all-compositor-stages-before-draw",
            "--virtual-time-budget=1000",
            "--force-device-scale-factor=1",
            f"--user-data-dir={profile}",
            f"--window-size={pixel_size},{pixel_size}",
            f"--screenshot={png_path.resolve()}",
            svg_path.resolve().as_uri(),
        ]
        process = subprocess.Popen(
            command,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
        )
        deadline = time.monotonic() + 90
        previous_size = -1
        stable_reads = 0
        completed = False
        while time.monotonic() < deadline:
            if png_path.is_file():
                try:
                    raw = png_path.read_bytes()
                    valid_png = (
                        raw[:8] == b"\x89PNG\r\n\x1a\n"
                        and raw[12:16] == b"IHDR"
                        and raw[-12:] == b"\x00\x00\x00\x00IEND\xaeB`\x82"
                    )
                    if valid_png and len(raw) == previous_size:
                        stable_reads += 1
                    else:
                        stable_reads = 0
                    previous_size = len(raw)
                    if valid_png and stable_reads >= 2:
                        completed = True
                        break
                except OSError:
                    stable_reads = 0
            if process.poll() is not None and not png_path.is_file():
                break
            time.sleep(0.1)

        if process.poll() is None:
            if os.name == "nt":
                try:
                    subprocess.run(
                        ["taskkill", "/PID", str(process.pid), "/T", "/F"],
                        stdout=subprocess.DEVNULL,
                        stderr=subprocess.DEVNULL,
                        timeout=10,
                        check=False,
                    )
                except subprocess.TimeoutExpired:
                    # The PNG is already complete at this point. Windows can
                    # briefly retain a Chromium descendant while taskkill is
                    # returning; fall through to the bounded process wait.
                    pass
            else:
                process.terminate()
            try:
                process.wait(timeout=5)
            except subprocess.TimeoutExpired:
                process.kill()
                try:
                    process.wait(timeout=5)
                except subprocess.TimeoutExpired:
                    # The rendered PNG was already verified as complete. A
                    # lingering Windows browser handle must not invalidate a
                    # deterministic artifact after both bounded shutdowns.
                    pass
        # Windows may keep short-lived Chromium profile handles after the
        # process tree exits. Give them a bounded release window; cleanup is
        # best-effort and never changes the rendered artifact.
        time.sleep(0.75)
        if not completed:
            raise RuntimeError("Browser SVG rasterization did not produce a complete PNG.")


def render_outputs(output_dir: Path = DEFAULT_OUTPUT, pixel_size: int = 4096) -> tuple[Path, Path]:
    output_dir.mkdir(parents=True, exist_ok=True)
    svg_path = output_dir / SVG_NAME
    png_path = output_dir / PNG_NAME
    svg_path.write_text(render_svg(), encoding="utf-8", newline="\n")
    rasterize_svg(svg_path, png_path, pixel_size=pixel_size)
    return svg_path, png_path


def _digest(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--output-dir", type=Path, default=DEFAULT_OUTPUT)
    parser.add_argument("--pixel-size", type=int, default=4096)
    args = parser.parse_args()
    svg_path, png_path = render_outputs(args.output_dir, args.pixel_size)
    print(f"SVG: {svg_path} ({_digest(svg_path)})")
    print(f"PNG: {png_path} ({_digest(png_path)})")


if __name__ == "__main__":
    main()
