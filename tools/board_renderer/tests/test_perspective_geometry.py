from __future__ import annotations

import hashlib
from pathlib import Path
import struct
import sys
import tempfile
import unittest


RENDERER_ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(RENDERER_ROOT))

from board_map_parity import build_parity_report  # noqa: E402
from perspective_projection import (  # noqa: E402
    build_validation_report,
    load_camera_presets,
    load_geometry,
    point_in_polygon,
    project_geometry,
    validate_projection,
)
from render_perspective_debug import (  # noqa: E402
    COMPARISON_NAME,
    png_name,
    render_outputs,
    render_perspective_svg,
)


class PerspectiveGeometryTest(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.geometry = load_geometry()
        cls.presets = load_camera_presets()
        cls.projections = [
            project_geometry(cls.geometry, preset) for preset in cls.presets
        ]

    def test_camera_presets_are_fixed_and_share_south_azimuth(self) -> None:
        self.assertEqual([preset.id for preset in self.presets], ["A", "B", "C"])
        self.assertEqual(
            [preset.elevation_degrees for preset in self.presets], [58.0, 46.0, 34.0]
        )
        self.assertTrue(all(preset.azimuth_degrees == 90.0 for preset in self.presets))
        self.assertTrue(all(preset.distance == 1.55 for preset in self.presets))
        self.assertTrue(
            all(preset.vertical_fov_degrees == 42.0 for preset in self.presets)
        )
        self.assertTrue(all(preset.board_front == "south" for preset in self.presets))

    def test_all_67_nodes_are_visible_positive_and_non_overlapping(self) -> None:
        for projection in self.projections:
            self.assertEqual(validate_projection(projection), [])
            self.assertEqual(len(projection["nodes"]), 67)
            self.assertTrue(
                all(node["center"]["depth"] > 0 for node in projection["nodes"])
            )

    def test_each_outer_interval_and_inner_path_has_five_tiles(self) -> None:
        for projection in self.projections:
            for sector in range(6):
                outer = [
                    node
                    for node in projection["nodes"]
                    if node["type"] == "outer_tile" and node["sector"] == sector
                ]
                inner = [
                    node
                    for node in projection["nodes"]
                    if node["type"] == "inner_tile" and node["sector"] == sector
                ]
                self.assertEqual(len(outer), 5)
                self.assertEqual(len(inner), 5)

    def test_south_inner_path_52_to_56_is_fully_visible(self) -> None:
        for projection in self.projections:
            south = [
                node
                for node in projection["nodes"]
                if node["type"] == "inner_tile" and node["sector"] == 3
            ]
            self.assertEqual([node["id"] for node in south], [52, 53, 54, 55, 56])
            self.assertTrue(all(node["center"]["y"] > 0.5 for node in south))

    def test_every_label_box_is_inside_its_own_polygon(self) -> None:
        for projection in self.projections:
            for node in projection["nodes"]:
                bounds = node["label"]["bounds"]
                corners = [
                    (bounds["left"], bounds["top"]),
                    (bounds["right"], bounds["top"]),
                    (bounds["right"], bounds["bottom"]),
                    (bounds["left"], bounds["bottom"]),
                ]
                self.assertTrue(
                    all(point_in_polygon(corner, node["polygon"], 1e-7) for corner in corners),
                    msg=f"camera={projection['camera']['id']} node={node['id']}",
                )

    def test_projection_and_svg_are_deterministic(self) -> None:
        for preset, first in zip(self.presets, self.projections):
            second = project_geometry(self.geometry, preset)
            self.assertEqual(first, second)
            self.assertEqual(
                hashlib.sha256(render_perspective_svg(first).encode("utf-8")).digest(),
                hashlib.sha256(render_perspective_svg(second).encode("utf-8")).digest(),
            )

    def test_validation_report_contains_parameters_and_scale_ratios(self) -> None:
        report = build_validation_report(self.geometry, self.presets)
        self.assertEqual(report["status"], "PASS")
        self.assertEqual(
            [camera["near_far_scale_ratio"] for camera in report["cameras"]],
            [1.335332839, 1.463752079, 1.579455081],
        )
        self.assertTrue(
            all(camera["projected_node_count"] == 67 for camera in report["cameras"])
        )

    def test_live_board_map_parity_still_passes(self) -> None:
        report = build_parity_report()
        self.assertEqual(report["status"], "PASS")
        self.assertEqual(report["matched_nodes"], 67)

    def test_two_consecutive_png_sets_are_byte_identical(self) -> None:
        with tempfile.TemporaryDirectory(prefix="perspective-a-") as first_dir:
            with tempfile.TemporaryDirectory(prefix="perspective-b-") as second_dir:
                first = render_outputs(Path(first_dir), pixel_size=256)
                second = render_outputs(Path(second_dir), pixel_size=256)
                names = [png_name(camera_id) for camera_id in ("A", "B", "C")]
                names.append(COMPARISON_NAME)
                for name in names:
                    first_path = Path(first_dir) / name
                    second_path = Path(second_dir) / name
                    self.assertEqual(
                        hashlib.sha256(first_path.read_bytes()).digest(),
                        hashlib.sha256(second_path.read_bytes()).digest(),
                        msg=name,
                    )
                    raw = first_path.read_bytes()
                    self.assertEqual(raw[:8], b"\x89PNG\r\n\x1a\n")
                    self.assertEqual(struct.unpack(">II", raw[16:24]), (256, 256))


if __name__ == "__main__":
    unittest.main()
