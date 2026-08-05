"""Deterministic structural 3D mesh for canonical board camera B."""

from __future__ import annotations

from dataclasses import asdict
import math
from typing import Any

from perspective_projection import (
    PinholeProjector,
    load_camera_presets,
    load_geometry,
    point_in_polygon,
    polygons_overlap,
)


THICKNESS = {
    "ring_base": 0.012,
    "outer_tile": 0.024,
    "inner_tile": 0.020,
    "badge": 0.034,
    "center": 0.040,
}
FOOTPRINT_SCALE = {
    "outer_tile": 0.90,
    "inner_tile": 0.88,
    "badge": 0.90,
    "center": 0.92,
}
EXPECTED_NEAR_FAR_RATIO = 1.463752079
TYPE_COUNTS = {"outer_tile": 30, "inner_tile": 30, "badge": 6, "center": 1}


def canonical_camera_b():
    camera = next(camera for camera in load_camera_presets() if camera.id == "B")
    expected = (46.0, 90.0, 1.55, 42.0)
    actual = (
        camera.elevation_degrees,
        camera.azimuth_degrees,
        camera.distance,
        camera.vertical_fov_degrees,
    )
    if actual != expected:
        raise ValueError(f"Canonical camera B changed: {actual!r} != {expected!r}")
    return camera


def _round(value: float) -> float:
    return round(value, 9)


def _footprint(node: dict[str, Any]) -> list[tuple[float, float]]:
    cx = node["x_normalized"] - 0.5
    cy = node["y_normalized"] - 0.5
    scale = FOOTPRINT_SCALE[node["type"]]
    rx = node["width_normalized"] * scale / 2
    ry = node["height_normalized"] * scale / 2
    if node["type"] == "badge":
        return [
            (
                cx + math.cos(math.radians(-90 + index * 60)) * rx,
                cy + math.sin(math.radians(-90 + index * 60)) * ry,
            )
            for index in range(6)
        ]
    if node["type"] == "center":
        return [
            (
                cx + math.cos(2 * math.pi * index / 24) * rx,
                cy + math.sin(2 * math.pi * index / 24) * ry,
            )
            for index in range(24)
        ]
    return [
        (cx - rx, cy - ry),
        (cx + rx, cy - ry),
        (cx + rx, cy + ry),
        (cx - rx, cy + ry),
    ]


def _project_polygon(
    projector: PinholeProjector, points: list[tuple[float, float]], z: float
) -> list[dict[str, float]]:
    return [projector.project((x, y, z)) for x, y in points]


def _area(points: list[dict[str, float]]) -> float:
    return abs(
        sum(
            first["x"] * second["y"] - second["x"] * first["y"]
            for first, second in zip(points, points[1:] + points[:1])
        )
        / 2
    )


def _bounds(center: dict[str, float], font_size: float, lines: list[str]) -> dict[str, float]:
    width = max(len(line) for line in lines) * font_size * 0.54
    height = len(lines) * font_size * 1.12
    return {
        "left": _round(center["x"] - width / 2),
        "right": _round(center["x"] + width / 2),
        "top": _round(center["y"] - height / 2),
        "bottom": _round(center["y"] + height / 2),
    }


def _label(node: dict[str, Any], center: dict[str, float], top: list[dict[str, float]]) -> dict[str, Any]:
    lines = [str(node["id"])]
    if node["type"] == "center":
        lines.append("CENTER")
    elif node["type"] == "badge":
        lines.append(node["category_name"])
    xs = [point["x"] for point in top]
    ys = [point["y"] for point in top]
    available_width = (max(xs) - min(xs)) * 0.72
    available_height = (max(ys) - min(ys)) * 0.65
    font_size = min(
        available_width / (max(len(line) for line in lines) * 0.54),
        available_height / (len(lines) * 1.12),
    )
    bounds = _bounds(center, font_size, lines)
    for _ in range(50):
        corners = [
            (bounds["left"], bounds["top"]),
            (bounds["right"], bounds["top"]),
            (bounds["right"], bounds["bottom"]),
            (bounds["left"], bounds["bottom"]),
        ]
        if all(point_in_polygon(corner, top, 1e-7) for corner in corners):
            break
        font_size *= 0.92
        bounds = _bounds(center, font_size, lines)
    return {
        "lines": lines,
        "font_size_normalized": _round(font_size),
        "line_height_normalized": _round(font_size * 1.12),
        "bounds": bounds,
    }


def build_structural_scene(geometry: dict[str, Any] | None = None) -> dict[str, Any]:
    geometry = geometry or load_geometry()
    camera = canonical_camera_b()
    projector = PinholeProjector(camera)
    pieces = []
    all_faces = []
    base_z = THICKNESS["ring_base"]
    for node in sorted(geometry["nodes"], key=lambda item: item["id"]):
        footprint = _footprint(node)
        top_z = base_z + THICKNESS[node["type"]]
        bottom = _project_polygon(projector, footprint, base_z)
        top = _project_polygon(projector, footprint, top_z)
        center = projector.project(
            (node["x_normalized"] - 0.5, node["y_normalized"] - 0.5, top_z)
        )
        faces = []
        for index in range(len(footprint)):
            next_index = (index + 1) % len(footprint)
            polygon = [bottom[index], bottom[next_index], top[next_index], top[index]]
            face = {
                "node_id": node["id"],
                "kind": "side",
                "edge_index": index,
                "polygon": polygon,
                "average_depth": _round(sum(point["depth"] for point in polygon) / 4),
            }
            faces.append(face)
            all_faces.append(face)
        top_face = {
            "node_id": node["id"],
            "kind": "top",
            "edge_index": -1,
            "polygon": top,
            "average_depth": _round(sum(point["depth"] for point in top) / len(top)),
        }
        faces.append(top_face)
        all_faces.append(top_face)
        pieces.append(
            {
                "id": node["id"],
                "type": node["type"],
                "sector": node["sector"],
                "position_in_segment": node["position_in_segment"],
                "category_name": node["category_name"],
                "connected_node_ids": node["connected_node_ids"],
                "base_z": base_z,
                "top_z": _round(top_z),
                "thickness": THICKNESS[node["type"]],
                "bottom": bottom,
                "top": top,
                "top_area": _round(_area(top)),
                "center": center,
                "label": _label(node, center, top),
                "faces": faces,
            }
        )
    all_faces.sort(
        key=lambda face: (
            -face["average_depth"],
            0 if face["kind"] == "side" else 1,
            face["node_id"],
            face["edge_index"],
        )
    )
    elevation = math.radians(camera.elevation_degrees)
    near_depth = camera.distance - 0.42 * math.cos(elevation)
    far_depth = camera.distance + 0.42 * math.cos(elevation)
    return {
        "schema_version": 1,
        "model": "individually extruded deterministic board parts",
        "camera": asdict(camera),
        "camera_position": [_round(value) for value in projector.position],
        "near_far_scale_ratio": _round(far_depth / near_depth),
        "thickness_world_units": THICKNESS.copy(),
        "footprint_scale": FOOTPRINT_SCALE.copy(),
        "pieces": pieces,
        "faces_in_occlusion_order": all_faces,
    }


def _rect_polygon(bounds: dict[str, float]) -> list[dict[str, float]]:
    return [
        {"x": bounds["left"], "y": bounds["top"]},
        {"x": bounds["right"], "y": bounds["top"]},
        {"x": bounds["right"], "y": bounds["bottom"]},
        {"x": bounds["left"], "y": bounds["bottom"]},
    ]


def validate_structural_scene(scene: dict[str, Any]) -> list[str]:
    errors: list[str] = []
    camera = scene["camera"]
    if (camera["id"], camera["elevation_degrees"], camera["azimuth_degrees"], camera["distance"], camera["vertical_fov_degrees"]) != ("B", 46.0, 90.0, 1.55, 42.0):
        errors.append("Canonical camera B parameters changed.")
    if scene["near_far_scale_ratio"] != EXPECTED_NEAR_FAR_RATIO:
        errors.append("Canonical camera B near/far ratio changed.")
    pieces = scene["pieces"]
    if len(pieces) != 67 or {piece["id"] for piece in pieces} != set(range(67)):
        errors.append("Structural scene does not contain exactly node IDs 0-66.")
    for node_type, expected in TYPE_COUNTS.items():
        actual = sum(piece["type"] == node_type for piece in pieces)
        if actual != expected:
            errors.append(f"Expected {expected} {node_type} parts, found {actual}.")
    for sector in range(6):
        for node_type in ("outer_tile", "inner_tile"):
            count = sum(piece["type"] == node_type and piece["sector"] == sector for piece in pieces)
            if count != 5:
                errors.append(f"Sector {sector} has {count} {node_type} parts.")
    by_id = {piece["id"]: piece for piece in pieces}
    for expected_ids, name in ((list(range(52, 57)), "south"), (list(range(62, 67)), "sport")):
        if any(node_id not in by_id for node_id in expected_ids):
            errors.append(f"The {name} inner path is incomplete.")
    for piece in pieces:
        expected_face_count = len(piece["top"]) + 1
        if len(piece["faces"]) != expected_face_count:
            errors.append(f"Node {piece['id']} does not have top plus all side faces.")
        if piece["thickness"] <= 0 or piece["top_area"] <= 0:
            errors.append(f"Node {piece['id']} has invalid thickness/top area.")
        if any(point["depth"] <= 0 for face in piece["faces"] for point in face["polygon"]):
            errors.append(f"Node {piece['id']} has non-positive projected depth.")
        bounds = piece["label"]["bounds"]
        corners = [(bounds["left"], bounds["top"]), (bounds["right"], bounds["top"]), (bounds["right"], bounds["bottom"]), (bounds["left"], bounds["bottom"])]
        if not all(point_in_polygon(corner, piece["top"], 1e-7) for corner in corners):
            errors.append(f"Node {piece['id']} label is outside its top face.")
    for first in pieces:
        label_polygon = _rect_polygon(first["label"]["bounds"])
        for second in pieces:
            if first["id"] == second["id"]:
                continue
            if polygons_overlap(label_polygon, second["top"]):
                errors.append(f"Node {second['id']} top covers node {first['id']} label.")
                break
    if polygons_overlap(by_id[0]["top"], by_id[52]["top"]):
        errors.append("Center overlaps nearest southern inner tile 52.")
    for badge_id in (1, 7, 13, 19, 25, 31):
        for adjacent in by_id[badge_id]["connected_node_ids"]:
            if by_id[adjacent]["type"] == "outer_tile" and polygons_overlap(by_id[badge_id]["top"], by_id[adjacent]["top"]):
                errors.append(f"Badge {badge_id} overlaps adjacent outer tile {adjacent}.")
    depths = [face["average_depth"] for face in scene["faces_in_occlusion_order"]]
    if depths != sorted(depths, reverse=True):
        errors.append("Face occlusion order is not consistently far-to-near.")
    return errors


def build_structural_report(scene: dict[str, Any] | None = None) -> dict[str, Any]:
    scene = scene or build_structural_scene()
    errors = validate_structural_scene(scene)
    pieces = scene["pieces"]
    return {
        "schema_version": 1,
        "status": "PASS" if not errors else "FAIL",
        "errors": errors,
        "model": scene["model"],
        "camera": scene["camera"],
        "near_far_scale_ratio": scene["near_far_scale_ratio"],
        "thickness_world_units": scene["thickness_world_units"],
        "visible_node_count": len(pieces),
        "visible_type_counts": {key: sum(piece["type"] == key for piece in pieces) for key in TYPE_COUNTS},
        "outer_segment_counts": [sum(piece["type"] == "outer_tile" and piece["sector"] == sector for piece in pieces) for sector in range(6)],
        "inner_path_counts": [sum(piece["type"] == "inner_tile" and piece["sector"] == sector for piece in pieces) for sector in range(6)],
        "south_inner_node_ids": list(range(52, 57)),
        "sport_inner_node_ids": list(range(62, 67)),
        "labels_drawn_after_all_faces": True,
        "occlusion_order": "far-to-near by average camera depth",
    }
