from __future__ import annotations

import hashlib
from pathlib import Path
import struct
import sys
import tempfile
import unittest

RENDERER_ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(RENDERER_ROOT))

from board_geometry import SOUTH_SECTOR, SPORT_SECTOR, generate_geometry  # noqa: E402
from board_map_parity import build_parity_report  # noqa: E402
from render_debug_board import render_outputs, render_svg  # noqa: E402
from validate_board_geometry import validate_geometry  # noqa: E402


class BoardGeometryTest(unittest.TestCase):
    def setUp(self) -> None:
        self.geometry = generate_geometry()
        self.nodes = self.geometry["nodes"]

    def test_exact_live_board_map_counts_and_ids(self) -> None:
        self.assertEqual(len(self.nodes), 67)
        self.assertEqual({node["id"] for node in self.nodes}, set(range(67)))
        self.assertEqual(
            [node["id"] for node in self.nodes if node["type"] == "badge"],
            [1, 7, 13, 19, 25, 31],
        )
        self.assertEqual(
            {node["type"]: sum(item["type"] == node["type"] for item in self.nodes)
             for node in self.nodes},
            {"center": 1, "badge": 6, "outer_tile": 30, "inner_tile": 30},
        )

    def test_each_outer_interval_and_inner_path_is_numbered_one_to_five(self) -> None:
        for sector in range(6):
            for node_type in ("outer_tile", "inner_tile"):
                positions = sorted(
                    node["position_in_segment"]
                    for node in self.nodes
                    if node["type"] == node_type and node["sector"] == sector
                )
                self.assertEqual(positions, [1, 2, 3, 4, 5])

    def test_live_south_inner_path_has_five_visible_nodes_below_center(self) -> None:
        south = [
            node
            for node in self.nodes
            if node["type"] == "inner_tile" and node["sector"] == SOUTH_SECTOR
        ]
        self.assertEqual([node["id"] for node in south], [52, 53, 54, 55, 56])
        self.assertEqual(
            sorted(node["position_in_segment"] for node in south),
            [1, 2, 3, 4, 5],
        )
        self.assertTrue(all(node["y_normalized"] > 0.5 for node in south))

    def test_live_sport_badge_is_node_31_in_northwest(self) -> None:
        sport = next(
            node
            for node in self.nodes
            if node["type"] == "badge" and node["sector"] == SPORT_SECTOR
        )
        self.assertEqual(sport["id"], 31)
        self.assertEqual(sport["category_index"], 5)
        self.assertLess(sport["x_normalized"], 0.5)
        self.assertLess(sport["y_normalized"], 0.5)

    def test_board_geometry_matches_live_board_map_for_all_67_nodes(self) -> None:
        report = build_parity_report()
        self.assertEqual(report["status"], "PASS")
        self.assertEqual(report["matched_nodes"], 67)
        self.assertEqual(report["south_inner_node_ids"], [52, 53, 54, 55, 56])
        self.assertEqual(report["sport_badge"]["node_id"], 31)
        self.assertEqual(report["sport_badge"]["direction"], "Kuzeybatı")

    def test_connections_canvas_and_overlap_contract(self) -> None:
        self.assertEqual(validate_geometry(self.geometry), [])

    def test_svg_marks_all_node_ids_and_live_south_path(self) -> None:
        svg = render_svg(self.geometry)
        self.assertIn("SOUTH INNER 1-5", svg)
        self.assertIn("NODES 52-56", svg)
        for node_id in range(67):
            self.assertIn(f">{node_id}</text>", svg)

    def test_two_consecutive_svg_and_png_outputs_are_byte_identical(self) -> None:
        with tempfile.TemporaryDirectory(prefix="board-determinism-a-") as first_dir:
            with tempfile.TemporaryDirectory(prefix="board-determinism-b-") as second_dir:
                first_svg, first_png = render_outputs(Path(first_dir), pixel_size=512)
                second_svg, second_png = render_outputs(Path(second_dir), pixel_size=512)
                self.assertEqual(
                    hashlib.sha256(first_svg.read_bytes()).digest(),
                    hashlib.sha256(second_svg.read_bytes()).digest(),
                )
                self.assertEqual(
                    hashlib.sha256(first_png.read_bytes()).digest(),
                    hashlib.sha256(second_png.read_bytes()).digest(),
                )
                png = first_png.read_bytes()
                self.assertEqual(png[:8], b"\x89PNG\r\n\x1a\n")
                self.assertEqual(struct.unpack(">II", png[16:24]), (512, 512))


if __name__ == "__main__":
    unittest.main()
