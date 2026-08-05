"""Deterministic flat geometry for the live 67-node BoardMap contract."""

from __future__ import annotations

import json
import math
from pathlib import Path
from typing import Any


CENTER_ID = 0
OUTER_START = 1
OUTER_COUNT = 36
SPOKE_START = 37
SPOKE_COUNT = 6
SPOKE_LENGTH = 5
SPORT_SECTOR = 5
SOUTH_SECTOR = 3

# BoardMap.armAngle(0) is -pi / 2: node 1 is north and angles advance
# clockwise in SVG coordinates. The preview must never rotate this mapping.
START_ANGLE_DEGREES = -90.0
CENTER_X = 0.5
CENTER_Y = 0.5
OUTER_RADIUS = 0.42
INNER_RADII = tuple(0.155 + step * 0.049 for step in range(SPOKE_LENGTH))

CATEGORY_NAMES = (
    "COĞRAFYA",
    "EĞLENCE",
    "TARİH",
    "SANAT & EDEBİYAT",
    "BİLİM & DOĞA",
    "SPOR",
)

DIRECTIONS = (
    "Kuzey",
    "Kuzeydoğu",
    "Güneydoğu",
    "Güney",
    "Güneybatı",
    "Kuzeybatı",
)

# Copied exactly from BoardMap in lib/main.dart. The values are category
# indexes; they are data here, not a replacement for the live game map.
SPOKE_MIX = (
    (3, 1, 5, 2, 4),
    (4, 2, 0, 5, 3),
    (5, 3, 1, 0, 4),
    (0, 4, 2, 1, 5),
    (1, 5, 3, 2, 0),
    (2, 0, 4, 3, 1),
)

OUTER_MIX = (
    (2, 5, 1, 4, 3),
    (3, 0, 4, 2, 5),
    (4, 1, 5, 3, 0),
    (5, 2, 0, 4, 1),
    (0, 3, 1, 5, 2),
    (1, 4, 2, 0, 3),
)


def _rounded(value: float) -> float:
    return round(value, 6)


def _point(radius: float, angle_degrees: float) -> tuple[float, float]:
    radians = math.radians(angle_degrees)
    return (
        _rounded(CENTER_X + math.cos(radians) * radius),
        _rounded(CENTER_Y + math.sin(radians) * radius),
    )


def _normalized_angle(angle_degrees: float) -> float:
    return _rounded(angle_degrees % 360.0)


def outer_id(ring: int) -> int:
    return OUTER_START + (ring % OUTER_COUNT)


def spoke_id(sector: int, step: int) -> int:
    return SPOKE_START + sector * SPOKE_LENGTH + step


def _outer_connections(ring: int) -> list[int]:
    result = [outer_id(ring - 1), outer_id(ring + 1)]
    if ring % 6 == 0:
        result.append(spoke_id(ring // 6, SPOKE_LENGTH - 1))
    return sorted(result)


def _spoke_connections(sector: int, step: int) -> list[int]:
    previous = CENTER_ID if step == 0 else spoke_id(sector, step - 1)
    following = (
        outer_id(sector * 6)
        if step == SPOKE_LENGTH - 1
        else spoke_id(sector, step + 1)
    )
    return sorted([previous, following])


def generate_geometry() -> dict[str, Any]:
    """Return the complete BoardMap geometry with stable ordering and values."""

    nodes: list[dict[str, Any]] = [
        {
            "id": CENTER_ID,
            "type": "center",
            "category_index": -1,
            "category_name": None,
            "is_badge": False,
            "ring": None,
            "arm": None,
            "step": None,
            "sector": None,
            "position_in_segment": 0,
            "x_normalized": CENTER_X,
            "y_normalized": CENTER_Y,
            "angle_degrees": 0.0,
            "width_normalized": 0.08,
            "height_normalized": 0.08,
            "connected_node_ids": [
                spoke_id(sector, 0) for sector in range(SPOKE_COUNT)
            ],
            "label": "CENTER 0",
        }
    ]

    for ring in range(OUTER_COUNT):
        node_id = outer_id(ring)
        sector = ring // 6
        position = ring % 6
        is_badge = position == 0
        category_index = sector if is_badge else OUTER_MIX[sector][position - 1]
        angle = START_ANGLE_DEGREES + ring * 10.0
        x, y = _point(OUTER_RADIUS, angle)
        node_type = "badge" if is_badge else "outer_tile"
        segment_position = 0 if is_badge else position
        prefix = "BADGE" if is_badge else f"OUTER {segment_position}/5"
        nodes.append(
            {
                "id": node_id,
                "type": node_type,
                "category_index": category_index,
                "category_name": CATEGORY_NAMES[category_index],
                "is_badge": is_badge,
                "ring": ring,
                "arm": None,
                "step": None,
                "sector": sector,
                "position_in_segment": segment_position,
                "x_normalized": x,
                "y_normalized": y,
                "angle_degrees": _normalized_angle(angle),
                "width_normalized": 0.06 if is_badge else 0.05,
                "height_normalized": 0.06 if is_badge else 0.034,
                "connected_node_ids": _outer_connections(ring),
                "label": f"{prefix} | {CATEGORY_NAMES[category_index]}",
            }
        )

    for sector in range(SPOKE_COUNT):
        angle = START_ANGLE_DEGREES + sector * 60.0
        for step in range(SPOKE_LENGTH):
            node_id = spoke_id(sector, step)
            category_index = SPOKE_MIX[sector][step]
            x, y = _point(INNER_RADII[step], angle)
            nodes.append(
                {
                    "id": node_id,
                    "type": "inner_tile",
                    "category_index": category_index,
                    "category_name": CATEGORY_NAMES[category_index],
                    "is_badge": False,
                    "ring": None,
                    "arm": sector,
                    "step": step,
                    "sector": sector,
                    "position_in_segment": step + 1,
                    "x_normalized": x,
                    "y_normalized": y,
                    "angle_degrees": _normalized_angle(angle),
                    "width_normalized": 0.042,
                    "height_normalized": 0.022,
                    "connected_node_ids": _spoke_connections(sector, step),
                    "label": (
                        f"INNER {step + 1}/5 | {CATEGORY_NAMES[category_index]}"
                    ),
                }
            )

    return {
        "schema_version": 2,
        "source": {
            "board_map": "lib/main.dart::BoardMap",
            "position_formula": "BoardMap.position(Size(1, 1), nodeId)",
        },
        "canvas": {"width_normalized": 1.0, "height_normalized": 1.0},
        "orientation": {
            "start_angle_degrees": START_ANGLE_DEGREES,
            "clockwise": True,
            "directions": list(DIRECTIONS),
            "south_sector": SOUTH_SECTOR,
            "south_inner_node_ids": [
                spoke_id(SOUTH_SECTOR, step) for step in range(SPOKE_LENGTH)
            ],
            "sport_sector": SPORT_SECTOR,
            "sport_badge_node_id": outer_id(SPORT_SECTOR * 6),
            "sport_direction": DIRECTIONS[SPORT_SECTOR],
        },
        "nodes": nodes,
    }


def canonical_json(geometry: dict[str, Any] | None = None) -> str:
    return json.dumps(
        geometry or generate_geometry(),
        ensure_ascii=False,
        indent=2,
        sort_keys=True,
    ) + "\n"


def write_geometry_file(path: Path) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(canonical_json(), encoding="utf-8", newline="\n")


if __name__ == "__main__":
    write_geometry_file(Path(__file__).with_name("board_geometry.json"))
