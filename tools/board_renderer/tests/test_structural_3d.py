from __future__ import annotations

import hashlib
from pathlib import Path
import struct
import sys
import tempfile
import unittest


RENDERER_ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(RENDERER_ROOT))

from board_3d_structure import (  # noqa: E402
    EXPECTED_NEAR_FAR_RATIO,
    THICKNESS,
    build_structural_report,
    build_structural_scene,
    validate_structural_scene,
)
from board_map_parity import build_parity_report  # noqa: E402
from render_structural_3d_preview import (  # noqa: E402
    CLOSEUP_PNG_NAME,
    MAIN_PNG_NAME,
    render_outputs,
    render_structural_svg,
)


class Structural3DTest(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.scene = build_structural_scene()
        cls.by_id = {piece["id"]: piece for piece in cls.scene["pieces"]}

    def test_camera_b_is_canonical_and_unchanged(self) -> None:
        camera = self.scene["camera"]
        self.assertEqual(camera["id"], "B")
        self.assertEqual(camera["elevation_degrees"], 46.0)
        self.assertEqual(camera["azimuth_degrees"], 90.0)
        self.assertEqual(camera["distance"], 1.55)
        self.assertEqual(camera["vertical_fov_degrees"], 42.0)
        self.assertEqual(self.scene["near_far_scale_ratio"], EXPECTED_NEAR_FAR_RATIO)

    def test_board_map_parity_and_all_67_parts_are_visible(self) -> None:
        parity = build_parity_report()
        self.assertEqual(parity["status"], "PASS")
        self.assertEqual(parity["matched_nodes"], 67)
        self.assertEqual(validate_structural_scene(self.scene), [])
        self.assertEqual({piece["id"] for piece in self.scene["pieces"]}, set(range(67)))
        self.assertEqual(
            {kind: sum(piece["type"] == kind for piece in self.scene["pieces"]) for kind in ("outer_tile", "inner_tile", "badge", "center")},
            {"outer_tile": 30, "inner_tile": 30, "badge": 6, "center": 1},
        )

    def test_every_part_has_top_sides_and_fixed_positive_thickness(self) -> None:
        self.assertEqual(self.scene["thickness_world_units"], THICKNESS)
        for piece in self.scene["pieces"]:
            self.assertGreater(piece["thickness"], 0)
            self.assertGreater(piece["top_area"], 0)
            self.assertEqual(sum(face["kind"] == "top" for face in piece["faces"]), 1)
            self.assertEqual(sum(face["kind"] == "side" for face in piece["faces"]), len(piece["top"]))

    def test_every_outer_interval_and_inner_path_has_five_parts(self) -> None:
        report = build_structural_report(self.scene)
        self.assertEqual(report["status"], "PASS")
        self.assertEqual(report["outer_segment_counts"], [5, 5, 5, 5, 5, 5])
        self.assertEqual(report["inner_path_counts"], [5, 5, 5, 5, 5, 5])
        self.assertEqual(report["south_inner_node_ids"], [52, 53, 54, 55, 56])
        self.assertEqual(report["sport_inner_node_ids"], [62, 63, 64, 65, 66])

    def test_labels_center_badges_and_occlusion_pass(self) -> None:
        self.assertEqual(validate_structural_scene(self.scene), [])
        depths = [face["average_depth"] for face in self.scene["faces_in_occlusion_order"]]
        self.assertEqual(depths, sorted(depths, reverse=True))

    def test_scene_and_svg_are_deterministic(self) -> None:
        second = build_structural_scene()
        self.assertEqual(self.scene, second)
        self.assertEqual(
            hashlib.sha256(render_structural_svg(self.scene).encode()).digest(),
            hashlib.sha256(render_structural_svg(second).encode()).digest(),
        )
        self.assertEqual(
            hashlib.sha256(render_structural_svg(self.scene, closeup=True).encode()).digest(),
            hashlib.sha256(render_structural_svg(second, closeup=True).encode()).digest(),
        )

    def test_two_consecutive_png_sets_are_byte_identical(self) -> None:
        with tempfile.TemporaryDirectory(prefix="structure-a-") as first_dir:
            with tempfile.TemporaryDirectory(prefix="structure-b-") as second_dir:
                render_outputs(Path(first_dir), pixel_size=256)
                render_outputs(Path(second_dir), pixel_size=256)
                for name in (MAIN_PNG_NAME, CLOSEUP_PNG_NAME):
                    first = (Path(first_dir) / name).read_bytes()
                    second = (Path(second_dir) / name).read_bytes()
                    self.assertEqual(hashlib.sha256(first).digest(), hashlib.sha256(second).digest())
                    self.assertEqual(first[:8], b"\x89PNG\r\n\x1a\n")
                    self.assertEqual(struct.unpack(">II", first[16:24]), (256, 256))


if __name__ == "__main__":
    unittest.main()
