"""Static, deterministic parity check against the live Dart BoardMap source."""

from __future__ import annotations

import hashlib
import json
import math
from pathlib import Path
import re
from typing import Any


ROOT = Path(__file__).resolve().parent
REPO_ROOT = ROOT.parents[1]
LIVE_SOURCE_PATH = REPO_ROOT / "lib" / "main.dart"
GEOMETRY_PATH = ROOT / "board_geometry.json"
OUTPUT_DIR = ROOT / "output"
JSON_REPORT_PATH = OUTPUT_DIR / "board_map_parity_report.json"
MARKDOWN_REPORT_PATH = OUTPUT_DIR / "board_map_parity_report.md"
EPSILON = 0.000001


class BoardMapParseError(RuntimeError):
    pass


def _require_match(pattern: str, text: str, description: str) -> re.Match[str]:
    match = re.search(pattern, text, flags=re.DOTALL)
    if match is None:
        raise BoardMapParseError(f"Live BoardMap source is missing {description}.")
    return match


def _scalar(name: str, board_map_source: str) -> int:
    match = _require_match(
        rf"static\s+const\s+{re.escape(name)}\s*=\s*(\d+)\s*;",
        board_map_source,
        name,
    )
    return int(match.group(1))


def _string_list(name: str, board_map_source: str) -> list[str]:
    body = _require_match(
        rf"static\s+const\s+{re.escape(name)}\s*=\s*\[(.*?)\]\s*;",
        board_map_source,
        name,
    ).group(1)
    return re.findall(r"'([^']+)'", body)


def _int_matrix(name: str, board_map_source: str) -> list[list[int]]:
    body = _require_match(
        rf"static\s+const\s+{re.escape(name)}\s*=\s*<List<int>>\[(.*?)\]\s*;",
        board_map_source,
        name,
    ).group(1)
    return [
        [int(value) for value in re.findall(r"\d+", row)]
        for row in re.findall(r"\[([^\]]+)\]", body)
    ]


def _round(value: float) -> float:
    return round(value, 6)


def _point(radius: float, angle_radians: float) -> tuple[float, float]:
    return (
        _round(0.5 + math.cos(angle_radians) * radius),
        _round(0.5 + math.sin(angle_radians) * radius),
    )


def _extract_live_contract(source_path: Path = LIVE_SOURCE_PATH) -> dict[str, Any]:
    source = source_path.read_text(encoding="utf-8")
    board_map_source = _require_match(
        r"class\s+BoardMap\s*\{(.*?)\n\}", source, "BoardMap class"
    ).group(1)

    center_id = _scalar("centerId", board_map_source)
    outer_count = _scalar("outerCount", board_map_source)
    spoke_count = _scalar("spokeCount", board_map_source)
    spoke_length = _scalar("spokeLength", board_map_source)
    outer_start = _scalar("outerStart", board_map_source)
    spoke_start = _scalar("spokeStart", board_map_source)
    directions = _string_list("directions", board_map_source)
    spoke_mix = _int_matrix("spokeMix", board_map_source)
    outer_mix = _int_matrix("outerMix", board_map_source)

    outer_radius = float(
        _require_match(
            r"n\.kind\s*==\s*BoardNodeKind\.outer.*?\*\s*b\s*\*\s*(0?\.\d+)",
            board_map_source,
            "outer position radius",
        ).group(1)
    )
    inner_radius_match = _require_match(
        r"final\s+radius\s*=\s*b\s*\*\s*\(\s*(0?\.\d+)\s*\+\s*n\.step!\s*\*\s*(0?\.\d+)\s*\)",
        board_map_source,
        "inner position radius formula",
    )
    inner_radius_start = float(inner_radius_match.group(1))
    inner_radius_step = float(inner_radius_match.group(2))

    # These anchors make the static extractor fail loudly if live topology
    # behavior changes instead of silently validating an obsolete mirror.
    required_logic = {
        "outer_id_wrap": r"return\s+outerStart\s*\+\s*value\s*;",
        "spoke_id_order": r"return\s+spokeStart\s*\+\s*arm\s*\*\s*spokeLength\s*\+\s*step\s*;",
        "badge_rule": r"final\s+badge\s*=\s*ring\s*%\s*6\s*==\s*0\s*;",
        "center_neighbors": r"List\.generate\(spokeCount,\s*\(arm\)\s*=>\s*spokeId\(arm,\s*0\)\)",
        "outer_neighbors": r"outerId\(n\.ring!\s*-\s*1\).*?outerId\(n\.ring!\s*\+\s*1\)",
        "badge_spoke_neighbor": r"spokeId\(n\.ring!\s*~/\s*6,\s*spokeLength\s*-\s*1\)",
        "north_start_angle": r"return\s+-pi\s*/\s*2\s*\+\s*arm\s*\*\s*\(2\s*\*\s*pi\s*/\s*spokeCount\)\s*;",
    }
    for description, pattern in required_logic.items():
        _require_match(pattern, board_map_source, description)

    category_enum = _require_match(
        r"enum\s+GameCategory\s*\{(.*?)\}", source, "GameCategory enum"
    ).group(1)
    category_keys = [
        value.strip()
        for value in category_enum.split(",")
        if value.strip()
    ]
    label_source = _require_match(
        r"String\s+get\s+label\s*\{(.*?)\n\s*\}\s*\n\s*String\s+get\s+emoji",
        source,
        "GameCategory label getter",
    ).group(1)
    label_pairs = re.findall(
        r"case\s+GameCategory\.(\w+)\s*:\s*return\s+'([^']+)'\s*;",
        label_source,
    )
    label_by_key = dict(label_pairs)
    category_names = [label_by_key[key] for key in category_keys]

    def outer_id(ring: int) -> int:
        return outer_start + (ring % outer_count)

    def spoke_id(arm: int, step: int) -> int:
        return spoke_start + arm * spoke_length + step

    nodes: list[dict[str, Any]] = [
        {
            "id": center_id,
            "type": "center",
            "category_index": -1,
            "is_badge": False,
            "ring": None,
            "arm": None,
            "step": None,
            "connected_node_ids": [spoke_id(arm, 0) for arm in range(spoke_count)],
            "x_normalized": 0.5,
            "y_normalized": 0.5,
        }
    ]

    for ring in range(outer_count):
        node_id = outer_id(ring)
        is_badge = ring % 6 == 0
        category_index = ring // 6 if is_badge else outer_mix[ring // 6][ring % 6 - 1]
        angle = -math.pi / 2 + ring * (2 * math.pi / outer_count)
        x, y = _point(outer_radius, angle)
        connections = [outer_id(ring - 1), outer_id(ring + 1)]
        if is_badge:
            connections.append(spoke_id(ring // 6, spoke_length - 1))
        nodes.append(
            {
                "id": node_id,
                "type": "badge" if is_badge else "outer_tile",
                "category_index": category_index,
                "is_badge": is_badge,
                "ring": ring,
                "arm": None,
                "step": None,
                "connected_node_ids": sorted(connections),
                "x_normalized": x,
                "y_normalized": y,
            }
        )

    for arm in range(spoke_count):
        angle = -math.pi / 2 + arm * (2 * math.pi / spoke_count)
        for step in range(spoke_length):
            node_id = spoke_id(arm, step)
            previous = center_id if step == 0 else spoke_id(arm, step - 1)
            following = (
                outer_id(arm * 6)
                if step == spoke_length - 1
                else spoke_id(arm, step + 1)
            )
            radius = inner_radius_start + step * inner_radius_step
            x, y = _point(radius, angle)
            nodes.append(
                {
                    "id": node_id,
                    "type": "inner_tile",
                    "category_index": spoke_mix[arm][step],
                    "is_badge": False,
                    "ring": None,
                    "arm": arm,
                    "step": step,
                    "connected_node_ids": sorted([previous, following]),
                    "x_normalized": x,
                    "y_normalized": y,
                }
            )

    badges = []
    for arm, direction in enumerate(directions):
        badge_id = outer_id(arm * 6)
        badges.append(
            {
                "direction": direction,
                "arm": arm,
                "badge_node_id": badge_id,
                "category_index": arm,
                "category_name": category_names[arm],
                "inner_node_ids": [spoke_id(arm, step) for step in range(spoke_length)],
            }
        )

    return {
        "source_path": source_path.relative_to(REPO_ROOT).as_posix(),
        "source_sha256": hashlib.sha256(source.encode("utf-8")).hexdigest(),
        "constants": {
            "center_id": center_id,
            "outer_count": outer_count,
            "spoke_count": spoke_count,
            "spoke_length": spoke_length,
            "outer_start": outer_start,
            "spoke_start": spoke_start,
            "outer_radius": outer_radius,
            "inner_radius_start": inner_radius_start,
            "inner_radius_step": inner_radius_step,
        },
        "category_names": category_names,
        "directions": badges,
        "nodes": nodes,
    }


def build_parity_report(
    geometry_path: Path = GEOMETRY_PATH,
    source_path: Path = LIVE_SOURCE_PATH,
) -> dict[str, Any]:
    live = _extract_live_contract(source_path)
    geometry = json.loads(geometry_path.read_text(encoding="utf-8"))
    actual_by_id = {node["id"]: node for node in geometry.get("nodes", [])}
    comparisons = []
    all_match = len(actual_by_id) == len(live["nodes"]) == 67
    exact_fields = (
        "type",
        "category_index",
        "is_badge",
        "ring",
        "arm",
        "step",
        "connected_node_ids",
    )
    max_coordinate_delta = 0.0

    for expected in live["nodes"]:
        actual = actual_by_id.get(expected["id"])
        field_matches: dict[str, bool] = {}
        coordinate_deltas: dict[str, float | None] = {"x": None, "y": None}
        if actual is not None:
            for field in exact_fields:
                field_matches[field] = actual.get(field) == expected[field]
            coordinate_deltas = {
                "x": abs(actual.get("x_normalized", math.inf) - expected["x_normalized"]),
                "y": abs(actual.get("y_normalized", math.inf) - expected["y_normalized"]),
            }
            max_coordinate_delta = max(
                max_coordinate_delta,
                coordinate_deltas["x"],
                coordinate_deltas["y"],
            )
        node_match = (
            actual is not None
            and all(field_matches.values())
            and coordinate_deltas["x"] <= EPSILON
            and coordinate_deltas["y"] <= EPSILON
        )
        all_match = all_match and node_match
        comparisons.append(
            {
                "node_id": expected["id"],
                "match": node_match,
                "field_matches": field_matches,
                "coordinate_delta": coordinate_deltas,
                "live": expected,
                "geometry": actual,
            }
        )

    south = next(item for item in live["directions"] if item["direction"] == "Güney")
    sport = next(item for item in live["directions"] if item["category_name"] == "Spor")
    matched_nodes = sum(item["match"] for item in comparisons)
    return {
        "status": "PASS" if all_match else "FAIL",
        "epsilon": EPSILON,
        "matched_nodes": matched_nodes,
        "total_nodes": 67,
        "max_coordinate_delta": _round(max_coordinate_delta),
        "checks": {
            "node_ids": set(actual_by_id) == set(range(67)),
            "node_types": all(item["field_matches"].get("type", False) for item in comparisons),
            "category_indexes": all(item["field_matches"].get("category_index", False) for item in comparisons),
            "badge_states": all(item["field_matches"].get("is_badge", False) for item in comparisons),
            "connections": all(item["field_matches"].get("connected_node_ids", False) for item in comparisons),
            "outer_ring_order": all(item["field_matches"].get("ring", False) for item in comparisons),
            "inner_arm_order": all(
                item["field_matches"].get("arm", False) and item["field_matches"].get("step", False)
                for item in comparisons
            ),
            "coordinates_within_epsilon": all(
                item["coordinate_delta"]["x"] is not None
                and item["coordinate_delta"]["x"] <= EPSILON
                and item["coordinate_delta"]["y"] <= EPSILON
                for item in comparisons
            ),
        },
        "live_source": {
            "path": live["source_path"],
            "sha256": live["source_sha256"],
            "constants": live["constants"],
        },
        "direction_mapping": live["directions"],
        "south_inner_node_ids": south["inner_node_ids"],
        "sport_badge": {
            "node_id": sport["badge_node_id"],
            "direction": sport["direction"],
            "category_name": sport["category_name"],
        },
        "nodes": comparisons,
    }


def _markdown(report: dict[str, Any]) -> str:
    lines = [
        "# BoardMap parity report",
        "",
        f"**Result:** `{report['status']}` — {report['matched_nodes']}/{report['total_nodes']} nodes match.",
        "",
        f"- Live source: `{report['live_source']['path']}`",
        f"- Live source SHA-256: `{report['live_source']['sha256']}`",
        f"- Coordinate epsilon: `{report['epsilon']}`",
        f"- Maximum coordinate delta: `{report['max_coordinate_delta']}`",
        "",
        "## Direction and badge mapping",
        "",
        "| Direction | Badge node | Category | Inner nodes |",
        "|---|---:|---|---|",
    ]
    for item in report["direction_mapping"]:
        inner = ", ".join(str(node_id) for node_id in item["inner_node_ids"])
        lines.append(
            f"| {item['direction']} | {item['badge_node_id']} | {item['category_name']} | {inner} |"
        )
    lines.extend(
        [
            "",
            f"- South/bottom inner path: `{report['south_inner_node_ids']}`",
            f"- Sport badge: node `{report['sport_badge']['node_id']}`, direction `{report['sport_badge']['direction']}`",
            "",
            "## Checks",
            "",
        ]
    )
    for name, passed in report["checks"].items():
        lines.append(f"- `{name}`: {'PASS' if passed else 'FAIL'}")
    mismatches = [item for item in report["nodes"] if not item["match"]]
    if mismatches:
        lines.extend(["", "## Mismatched nodes", ""])
        for item in mismatches:
            failed_fields = [name for name, match in item["field_matches"].items() if not match]
            lines.append(
                f"- Node `{item['node_id']}`: fields={failed_fields}, "
                f"coordinate_delta={item['coordinate_delta']}"
            )
    return "\n".join(lines) + "\n"


def write_parity_reports(report: dict[str, Any]) -> tuple[Path, Path]:
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    JSON_REPORT_PATH.write_text(
        json.dumps(report, ensure_ascii=False, indent=2, sort_keys=True) + "\n",
        encoding="utf-8",
        newline="\n",
    )
    MARKDOWN_REPORT_PATH.write_text(
        _markdown(report), encoding="utf-8", newline="\n"
    )
    return JSON_REPORT_PATH, MARKDOWN_REPORT_PATH


def main() -> None:
    report = build_parity_report()
    json_path, markdown_path = write_parity_reports(report)
    print(
        f"{report['status']}: BoardMap parity "
        f"{report['matched_nodes']}/{report['total_nodes']} nodes."
    )
    print(f"JSON: {json_path}")
    print(f"Markdown: {markdown_path}")
    if report["status"] != "PASS":
        raise SystemExit(1)


if __name__ == "__main__":
    main()
