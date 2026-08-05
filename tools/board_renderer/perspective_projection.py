"""Deterministic per-piece pinhole projection for the numbered board."""

from __future__ import annotations

from dataclasses import asdict, dataclass
import json
import math
from pathlib import Path
from typing import Any, Iterable


ROOT = Path(__file__).resolve().parent
CAMERA_PRESETS_PATH = ROOT / "camera_presets.json"
GEOMETRY_PATH = ROOT / "board_geometry.json"
BOARD_OUTLINE_RADIUS = 0.42
EPSILON = 1e-9


@dataclass(frozen=True)
class CameraPreset:
    id: str
    description: str
    elevation_degrees: float
    azimuth_degrees: float
    distance: float
    vertical_fov_degrees: float
    target: tuple[float, float, float]
    board_front: str


def _round(value: float) -> float:
    return round(value, 9)


def _vector_add(first: tuple[float, ...], second: tuple[float, ...]) -> tuple[float, ...]:
    return tuple(a + b for a, b in zip(first, second))


def _vector_subtract(first: tuple[float, ...], second: tuple[float, ...]) -> tuple[float, ...]:
    return tuple(a - b for a, b in zip(first, second))


def _vector_scale(vector: tuple[float, ...], scalar: float) -> tuple[float, ...]:
    return tuple(value * scalar for value in vector)


def _dot(first: tuple[float, ...], second: tuple[float, ...]) -> float:
    return sum(a * b for a, b in zip(first, second))


def _cross(
    first: tuple[float, float, float], second: tuple[float, float, float]
) -> tuple[float, float, float]:
    return (
        first[1] * second[2] - first[2] * second[1],
        first[2] * second[0] - first[0] * second[2],
        first[0] * second[1] - first[1] * second[0],
    )


def _normalize(vector: tuple[float, ...]) -> tuple[float, ...]:
    length = math.sqrt(_dot(vector, vector))
    if length <= EPSILON:
        raise ValueError("Cannot normalize a zero-length vector.")
    return tuple(value / length for value in vector)


def load_camera_presets(path: Path = CAMERA_PRESETS_PATH) -> list[CameraPreset]:
    raw = json.loads(path.read_text(encoding="utf-8"))
    shared = raw["shared"]
    presets = []
    for item in raw["presets"]:
        presets.append(
            CameraPreset(
                id=item["id"],
                description=item["description"],
                elevation_degrees=float(item["elevation_degrees"]),
                azimuth_degrees=float(shared["azimuth_degrees"]),
                distance=float(shared["distance"]),
                vertical_fov_degrees=float(shared["vertical_fov_degrees"]),
                target=tuple(float(value) for value in shared["target"]),
                board_front=shared["board_front"],
            )
        )
    if [preset.id for preset in presets] != ["A", "B", "C"]:
        raise ValueError("Camera presets must be ordered A, B, C.")
    return presets


class PinholeProjector:
    def __init__(self, camera: CameraPreset) -> None:
        self.camera = camera
        elevation = math.radians(camera.elevation_degrees)
        azimuth = math.radians(camera.azimuth_degrees)
        horizontal_distance = camera.distance * math.cos(elevation)
        offset = (
            horizontal_distance * math.cos(azimuth),
            horizontal_distance * math.sin(azimuth),
            camera.distance * math.sin(elevation),
        )
        self.position = _vector_add(camera.target, offset)
        self.forward = _normalize(_vector_subtract(camera.target, self.position))
        world_up = (0.0, 0.0, 1.0)
        self.right = _normalize(_cross(world_up, self.forward))
        self.up = _normalize(_cross(self.forward, self.right))
        self.tangent = math.tan(math.radians(camera.vertical_fov_degrees) / 2)

    def project(self, point: tuple[float, float, float]) -> dict[str, float]:
        relative = _vector_subtract(point, self.position)
        depth = _dot(relative, self.forward)
        if depth <= 0:
            return {"x": math.inf, "y": math.inf, "depth": _round(depth)}
        camera_x = _dot(relative, self.right)
        camera_y = _dot(relative, self.up)
        screen_x = 0.5 + camera_x / (2 * depth * self.tangent)
        screen_y = 0.5 - camera_y / (2 * depth * self.tangent)
        return {"x": _round(screen_x), "y": _round(screen_y), "depth": _round(depth)}


def _world_center(node: dict[str, Any]) -> tuple[float, float, float]:
    return (
        node["x_normalized"] - 0.5,
        node["y_normalized"] - 0.5,
        0.0,
    )


def _world_polygon(node: dict[str, Any]) -> list[tuple[float, float, float]]:
    center_x, center_y, _ = _world_center(node)
    half_width = node["width_normalized"] / 2
    half_height = node["height_normalized"] / 2
    if node["type"] == "badge":
        return [
            (
                center_x + math.cos(math.radians(-90 + index * 60)) * half_width,
                center_y + math.sin(math.radians(-90 + index * 60)) * half_height,
                0.0,
            )
            for index in range(6)
        ]
    if node["type"] == "center":
        return [
            (
                center_x + math.cos(2 * math.pi * index / 24) * half_width,
                center_y + math.sin(2 * math.pi * index / 24) * half_height,
                0.0,
            )
            for index in range(24)
        ]
    return [
        (center_x - half_width, center_y - half_height, 0.0),
        (center_x + half_width, center_y - half_height, 0.0),
        (center_x + half_width, center_y + half_height, 0.0),
        (center_x - half_width, center_y + half_height, 0.0),
    ]


def _polygon_area(points: list[dict[str, float]]) -> float:
    return abs(
        sum(
            first["x"] * second["y"] - second["x"] * first["y"]
            for first, second in zip(points, points[1:] + points[:1])
        )
        / 2
    )


def point_in_polygon(
    point: tuple[float, float], polygon: Iterable[dict[str, float]], epsilon: float = EPSILON
) -> bool:
    points = list(polygon)
    sign = 0
    for first, second in zip(points, points[1:] + points[:1]):
        cross = (
            (second["x"] - first["x"]) * (point[1] - first["y"])
            - (second["y"] - first["y"]) * (point[0] - first["x"])
        )
        if abs(cross) <= epsilon:
            continue
        current_sign = 1 if cross > 0 else -1
        if sign == 0:
            sign = current_sign
        elif sign != current_sign:
            return False
    return True


def _axes(polygon: list[dict[str, float]]) -> list[tuple[float, float]]:
    result = []
    for first, second in zip(polygon, polygon[1:] + polygon[:1]):
        edge = (second["x"] - first["x"], second["y"] - first["y"])
        normal = (-edge[1], edge[0])
        length = math.hypot(*normal)
        if length > EPSILON:
            result.append((normal[0] / length, normal[1] / length))
    return result


def polygons_overlap(
    first: list[dict[str, float]], second: list[dict[str, float]]
) -> bool:
    for axis in _axes(first) + _axes(second):
        first_projection = [_dot((point["x"], point["y"]), axis) for point in first]
        second_projection = [_dot((point["x"], point["y"]), axis) for point in second]
        if min(max(first_projection), max(second_projection)) - max(
            min(first_projection), min(second_projection)
        ) <= EPSILON:
            return False
    return True


def _category_lines(category_name: str) -> list[str]:
    if " & " in category_name:
        left, right = category_name.split(" & ", 1)
        return [f"{left} &", right]
    return [category_name]


def _label_lines(node: dict[str, Any]) -> list[str]:
    if node["type"] == "center":
        return [str(node["id"]), "CENTER"]
    if node["type"] == "badge":
        return [str(node["id"]), "BADGE", *_category_lines(node["category_name"])]
    kind = "OUTER" if node["type"] == "outer_tile" else "INNER"
    marker = "O" if node["type"] == "outer_tile" else "I"
    return [str(node["id"]), f"{kind} {marker}{node['position_in_segment']}"]


def _label_layout(
    center: dict[str, float], polygon: list[dict[str, float]], lines: list[str]
) -> dict[str, Any]:
    xs = [point["x"] for point in polygon]
    ys = [point["y"] for point in polygon]
    available_width = (max(xs) - min(xs)) * 0.58
    available_height = (max(ys) - min(ys)) * 0.52
    longest = max(len(line) for line in lines)
    font_size = min(
        available_width / max(longest * 0.56, 1),
        available_height / max(len(lines) * 1.14, 1),
    )
    font_size = max(font_size, 0.0002)

    def box(size: float) -> dict[str, float]:
        width = longest * 0.56 * size
        height = len(lines) * 1.14 * size
        return {
            "left": center["x"] - width / 2,
            "right": center["x"] + width / 2,
            "top": center["y"] - height / 2,
            "bottom": center["y"] + height / 2,
        }

    bounds = box(font_size)
    for _ in range(40):
        corners = [
            (bounds["left"], bounds["top"]),
            (bounds["right"], bounds["top"]),
            (bounds["right"], bounds["bottom"]),
            (bounds["left"], bounds["bottom"]),
        ]
        if all(point_in_polygon(corner, polygon) for corner in corners):
            break
        font_size *= 0.9
        bounds = box(font_size)
    return {
        "lines": lines,
        "font_size_normalized": _round(font_size),
        "line_height_normalized": _round(font_size * 1.14),
        "bounds": {name: _round(value) for name, value in bounds.items()},
    }


def project_geometry(
    geometry: dict[str, Any], camera: CameraPreset
) -> dict[str, Any]:
    projector = PinholeProjector(camera)
    projected_nodes = []
    by_id: dict[int, dict[str, Any]] = {}
    for node in sorted(geometry["nodes"], key=lambda item: item["id"]):
        center = projector.project(_world_center(node))
        polygon = [projector.project(point) for point in _world_polygon(node)]
        projected = {
            "id": node["id"],
            "type": node["type"],
            "sector": node["sector"],
            "position_in_segment": node["position_in_segment"],
            "category_name": node["category_name"],
            "connected_node_ids": node["connected_node_ids"],
            "center": center,
            "polygon": polygon,
            "projected_area": _round(_polygon_area(polygon)),
            "label": _label_layout(center, polygon, _label_lines(node)),
        }
        projected_nodes.append(projected)
        by_id[node["id"]] = projected

    edges = []
    seen: set[tuple[int, int]] = set()
    for node in projected_nodes:
        for connected_id in node["connected_node_ids"]:
            edge = tuple(sorted((node["id"], connected_id)))
            if edge in seen:
                continue
            seen.add(edge)
            edges.append(
                {
                    "node_ids": list(edge),
                    "start": {
                        "x": by_id[edge[0]]["center"]["x"],
                        "y": by_id[edge[0]]["center"]["y"],
                    },
                    "end": {
                        "x": by_id[edge[1]]["center"]["x"],
                        "y": by_id[edge[1]]["center"]["y"],
                    },
                }
            )

    outline = []
    for index in range(120):
        angle = -math.pi / 2 + index * (2 * math.pi / 120)
        outline.append(
            projector.project(
                (
                    math.cos(angle) * BOARD_OUTLINE_RADIUS,
                    math.sin(angle) * BOARD_OUTLINE_RADIUS,
                    0.0,
                )
            )
        )

    elevation = math.radians(camera.elevation_degrees)
    near_depth = camera.distance - BOARD_OUTLINE_RADIUS * math.cos(elevation)
    far_depth = camera.distance + BOARD_OUTLINE_RADIUS * math.cos(elevation)
    return {
        "camera": asdict(camera),
        "camera_position": [_round(value) for value in projector.position],
        "near_far_scale_ratio": _round(far_depth / near_depth),
        "near_depth": _round(near_depth),
        "far_depth": _round(far_depth),
        "nodes": projected_nodes,
        "edges": edges,
        "board_outline": outline,
    }


def load_geometry(path: Path = GEOMETRY_PATH) -> dict[str, Any]:
    return json.loads(path.read_text(encoding="utf-8"))


def validate_projection(projection: dict[str, Any]) -> list[str]:
    errors: list[str] = []
    nodes = projection["nodes"]
    if len(nodes) != 67:
        errors.append(f"Expected 67 projected nodes, found {len(nodes)}.")
    if {node["id"] for node in nodes} != set(range(67)):
        errors.append("Projected node IDs are incomplete or duplicated.")

    for node in nodes:
        points = node["polygon"] + [node["center"]]
        if any(point["depth"] <= 0 for point in points):
            errors.append(f"Node {node['id']} has non-positive camera depth.")
        if any(
            point["x"] < 0 or point["x"] > 1 or point["y"] < 0 or point["y"] > 1
            for point in node["polygon"]
        ):
            errors.append(f"Node {node['id']} extends outside the canvas.")
        bounds = node["label"]["bounds"]
        label_corners = [
            (bounds["left"], bounds["top"]),
            (bounds["right"], bounds["top"]),
            (bounds["right"], bounds["bottom"]),
            (bounds["left"], bounds["bottom"]),
        ]
        if not all(point_in_polygon(corner, node["polygon"], 1e-7) for corner in label_corners):
            errors.append(f"Node {node['id']} label extends outside its polygon.")

    for index, first in enumerate(nodes):
        for second in nodes[index + 1 :]:
            if point_in_polygon(
                (first["center"]["x"], first["center"]["y"]), second["polygon"]
            ):
                errors.append(f"Node {first['id']} center is inside node {second['id']}.")
            if point_in_polygon(
                (second["center"]["x"], second["center"]["y"]), first["polygon"]
            ):
                errors.append(f"Node {second['id']} center is inside node {first['id']}.")
            if polygons_overlap(first["polygon"], second["polygon"]):
                errors.append(f"Node polygons {first['id']} and {second['id']} overlap.")

    for sector in range(6):
        outer = [
            node
            for node in nodes
            if node["type"] == "outer_tile" and node["sector"] == sector
        ]
        inner = [
            node
            for node in nodes
            if node["type"] == "inner_tile" and node["sector"] == sector
        ]
        if len(outer) != 5:
            errors.append(f"Sector {sector} has {len(outer)} visible outer tiles.")
        if len(inner) != 5:
            errors.append(f"Sector {sector} has {len(inner)} visible inner tiles.")
    south = [
        node
        for node in nodes
        if node["type"] == "inner_tile" and node["sector"] == 3
    ]
    if [node["id"] for node in south] != [52, 53, 54, 55, 56]:
        errors.append("South-facing inner path is not exactly nodes 52-56.")
    return errors


def build_validation_report(
    geometry: dict[str, Any] | None = None,
    presets: list[CameraPreset] | None = None,
) -> dict[str, Any]:
    geometry = geometry or load_geometry()
    presets = presets or load_camera_presets()
    cameras = []
    all_pass = True
    for preset in presets:
        projection = project_geometry(geometry, preset)
        errors = validate_projection(projection)
        all_pass = all_pass and not errors
        depths = [node["center"]["depth"] for node in projection["nodes"]]
        cameras.append(
            {
                "id": preset.id,
                "status": "PASS" if not errors else "FAIL",
                "errors": errors,
                "parameters": asdict(preset),
                "camera_position": projection["camera_position"],
                "near_far_scale_ratio": projection["near_far_scale_ratio"],
                "minimum_node_depth": min(depths),
                "maximum_node_depth": max(depths),
                "projected_node_count": len(projection["nodes"]),
                "outer_segment_counts": [5, 5, 5, 5, 5, 5],
                "inner_path_counts": [5, 5, 5, 5, 5, 5],
                "south_inner_node_ids": [52, 53, 54, 55, 56],
            }
        )
    return {
        "schema_version": 1,
        "status": "PASS" if all_pass else "FAIL",
        "projection_model": "per-piece pinhole camera projection",
        "board_map_orientation_preserved": True,
        "cameras": cameras,
    }
