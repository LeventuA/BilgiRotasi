"""Validate topology, geometry, committed outputs, and visibility constraints."""

from __future__ import annotations

import json
from pathlib import Path
import struct
from typing import Any

from board_geometry import (
    OUTER_COUNT,
    SPOKE_COUNT,
    SPOKE_LENGTH,
    SOUTH_SECTOR,
    SPORT_SECTOR,
    canonical_json,
    generate_geometry,
)
from render_debug_board import DEFAULT_OUTPUT, PNG_NAME, SVG_NAME, render_svg
from board_map_parity import build_parity_report, write_parity_reports


ROOT = Path(__file__).resolve().parent
GEOMETRY_PATH = ROOT / "board_geometry.json"


def _rect(node: dict[str, Any]) -> tuple[float, float, float, float]:
    half_width = node["width_normalized"] / 2
    half_height = node["height_normalized"] / 2
    return (
        node["x_normalized"] - half_width,
        node["y_normalized"] - half_height,
        node["x_normalized"] + half_width,
        node["y_normalized"] + half_height,
    )


def _overlaps(first: dict[str, Any], second: dict[str, Any]) -> bool:
    left_a, top_a, right_a, bottom_a = _rect(first)
    left_b, top_b, right_b, bottom_b = _rect(second)
    epsilon = 1e-9
    return (
        min(right_a, right_b) - max(left_a, left_b) > epsilon
        and min(bottom_a, bottom_b) - max(top_a, top_b) > epsilon
    )


def validate_geometry(geometry: dict[str, Any]) -> list[str]:
    errors: list[str] = []
    nodes = geometry.get("nodes", [])
    by_id = {node.get("id"): node for node in nodes}

    if len(nodes) != 67:
        errors.append(f"Expected 67 nodes, found {len(nodes)}.")
    expected_ids = set(range(67))
    actual_ids = set(by_id)
    if actual_ids != expected_ids:
        errors.append(
            f"Node IDs differ: missing={sorted(expected_ids - actual_ids)}, "
            f"extra={sorted(actual_ids - expected_ids)}."
        )
    if len(by_id) != len(nodes):
        errors.append("Node IDs are not unique.")

    expected_counts = {
        "center": 1,
        "badge": 6,
        "outer_tile": 30,
        "inner_tile": 30,
    }
    actual_counts = {
        node_type: sum(node.get("type") == node_type for node in nodes)
        for node_type in expected_counts
    }
    if actual_counts != expected_counts:
        errors.append(f"Type counts differ: {actual_counts}.")

    badge_ids = sorted(node["id"] for node in nodes if node.get("type") == "badge")
    if badge_ids != [1, 7, 13, 19, 25, 31]:
        errors.append(f"Badge IDs differ: {badge_ids}.")

    for sector in range(SPOKE_COUNT):
        outer = sorted(
            node["position_in_segment"]
            for node in nodes
            if node.get("type") == "outer_tile" and node.get("sector") == sector
        )
        inner = sorted(
            node["position_in_segment"]
            for node in nodes
            if node.get("type") == "inner_tile" and node.get("sector") == sector
        )
        if outer != list(range(1, 6)):
            errors.append(f"Sector {sector} outer interval differs: {outer}.")
        if inner != list(range(1, 6)):
            errors.append(f"Sector {sector} inner path differs: {inner}.")

    south_inner = [
        node
        for node in nodes
        if node.get("type") == "inner_tile" and node.get("sector") == SOUTH_SECTOR
    ]
    if len(south_inner) != SPOKE_LENGTH:
        errors.append(f"South inner path expected 5 nodes, found {len(south_inner)}.")
    if south_inner and not all(node["y_normalized"] > 0.5 for node in south_inner):
        errors.append("South inner path is not fully below the center.")

    sport_badges = [
        node
        for node in nodes
        if node.get("type") == "badge" and node.get("sector") == SPORT_SECTOR
    ]
    if len(sport_badges) != 1 or sport_badges[0].get("id") != 31:
        errors.append("Live Sport badge must be node 31 in the northwest sector.")

    for node in nodes:
        left, top, right, bottom = _rect(node)
        if left < 0 or top < 0 or right > 1 or bottom > 1:
            errors.append(f"Node {node['id']} is partially outside the canvas.")
        connections = node.get("connected_node_ids", [])
        if len(connections) != len(set(connections)):
            errors.append(f"Node {node['id']} has duplicate connections.")
        for connected_id in connections:
            if connected_id not in by_id:
                errors.append(f"Node {node['id']} references missing node {connected_id}.")
            elif node["id"] not in by_id[connected_id].get("connected_node_ids", []):
                errors.append(
                    f"Connection {node['id']} -> {connected_id} is not reciprocal."
                )

    for index, first in enumerate(nodes):
        for second in nodes[index + 1 :]:
            if "tile" not in first["type"] and "tile" not in second["type"]:
                continue
            if _overlaps(first, second):
                errors.append(
                    f"Nodes {first['id']} ({first['type']}) and "
                    f"{second['id']} ({second['type']}) overlap."
                )

    return errors


def validate_files() -> list[str]:
    errors: list[str] = []
    expected = generate_geometry()
    try:
        raw = GEOMETRY_PATH.read_text(encoding="utf-8")
        geometry = json.loads(raw)
    except (OSError, json.JSONDecodeError) as error:
        return [f"Geometry file cannot be read: {error}"]

    errors.extend(validate_geometry(geometry))
    if geometry != expected:
        errors.append("board_geometry.json differs from deterministic generation.")
    if raw != canonical_json(expected):
        errors.append("board_geometry.json is not in canonical deterministic form.")

    parity_report = build_parity_report()
    write_parity_reports(parity_report)
    if parity_report["status"] != "PASS":
        errors.append(
            "Live BoardMap parity failed: "
            f"{parity_report['matched_nodes']}/{parity_report['total_nodes']} nodes."
        )

    svg_path = DEFAULT_OUTPUT / SVG_NAME
    png_path = DEFAULT_OUTPUT / PNG_NAME
    if not svg_path.is_file():
        errors.append(f"Missing SVG output: {svg_path}")
    elif svg_path.read_text(encoding="utf-8") != render_svg(expected):
        errors.append("Committed SVG differs from deterministic rendering.")
    if not png_path.is_file():
        errors.append(f"Missing PNG output: {png_path}")
    else:
        try:
            png = png_path.read_bytes()
            if png[:8] != b"\x89PNG\r\n\x1a\n" or png[12:16] != b"IHDR":
                raise ValueError("invalid PNG signature or missing IHDR")
            image_size = struct.unpack(">II", png[16:24])
            if image_size != (4096, 4096):
                errors.append(
                    f"PNG size is {image_size}, expected (4096, 4096)."
                )
        except OSError as error:
            errors.append(f"PNG cannot be decoded: {error}")
        except (ValueError, struct.error) as error:
            errors.append(f"PNG cannot be decoded: {error}")
    return errors


def main() -> None:
    errors = validate_files()
    if errors:
        for error in errors:
            print(f"FAIL: {error}")
        raise SystemExit(1)
    print("PASS: 67 nodes (1 center, 6 badges, 30 outer, 30 inner).")
    print("PASS: six outer intervals and six inner paths each contain positions 1-5.")
    print("PASS: SOUTH INNER 1-5 (nodes 52-56) is below center and fully visible.")
    print("PASS: live Sport badge is node 31 in the northwest sector.")
    print("PASS: live BoardMap parity is 67/67 within coordinate epsilon.")
    print("PASS: all connections are valid/reciprocal; no node overlap or clipping.")
    print("PASS: committed JSON/SVG are deterministic and PNG is 4096x4096.")


if __name__ == "__main__":
    main()
