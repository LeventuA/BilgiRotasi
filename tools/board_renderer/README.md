# Deterministic 67-node board geometry

This folder is the Stage 1 flat, numbered geometry preview for the live
`BoardMap` contract in `lib/main.dart`. It does not change gameplay, Flutter
rendering, production assets, or release builds.

## Contract

- Center: node `0`
- Outer ring: nodes `1-36`
- Badges: nodes `1, 7, 13, 19, 25, 31`
- Inner paths: nodes `37-66`, five nodes on each of six paths
- Each interval after a badge contains outer positions `1-5`
- The live south path is sector 3, nodes `52-56`, and is marked
  `SOUTH INNER 1-5` in the debug output.
- The live Sport badge is node `31` in the northwest; its inner path is
  nodes `62-66`.

The category mixes and reciprocal connections are copied from the live
`BoardMap`; this tool is a preview/validator and is not a second game map.

## Generate and validate

Run with Python 3 from the repository root:

```text
python3 tools/board_renderer/board_geometry.py
python3 tools/board_renderer/render_debug_board.py
python3 tools/board_renderer/board_map_parity.py
python3 tools/board_renderer/validate_board_geometry.py
python3 tools/board_renderer/render_perspective_debug.py
python3 tools/board_renderer/validate_perspective_geometry.py
python3 -m unittest discover tools/board_renderer/tests
```

The renderer writes a deterministic SVG first and rasterizes that SVG with a
locally installed Chromium-family browser (Chrome, Chromium, or Edge). The
default PNG is exactly `4096x4096`. The tests compare two consecutive SVG and
PNG renders byte-for-byte.

Generated review artifacts:

- `output/board_debug_numbered.svg`
- `output/board_debug_numbered_4096.png`
- `output/board_map_parity_report.json`
- `output/board_map_parity_report.md`

Stage 2 perspective review artifacts:

- `output/board_perspective_A_numbered.svg` / `_4096.png` — 58° elevation
- `output/board_perspective_B_numbered.svg` / `_4096.png` — 46° elevation
- `output/board_perspective_C_numbered.svg` / `_4096.png` — 34° elevation
- `output/board_perspective_camera_comparison.png`
- `output/perspective_validation_report.json`

Each node plane is projected independently through the same pinhole camera
function. Connections, node centers, polygon corners, and label centers share
that function; no completed raster or 2D board image is warped.

No texture, shadow, production style, 3D thickness/extrusion, production icons,
Flutter integration, APK, or AAB work belongs to these geometry stages.
