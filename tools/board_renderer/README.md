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
- The Sport path (sector 5, nodes `62-66`) is fixed below the center and marked
  `SPORT INNER 1-5` in the debug output.

The category mixes and reciprocal connections are copied from the live
`BoardMap`; this tool is a preview/validator and is not a second game map.

## Generate and validate

Run with Python 3 from the repository root:

```text
python3 tools/board_renderer/board_geometry.py
python3 tools/board_renderer/render_debug_board.py
python3 tools/board_renderer/validate_board_geometry.py
python3 -m unittest discover tools/board_renderer/tests
```

The renderer writes a deterministic SVG first and rasterizes that SVG with a
locally installed Chromium-family browser (Chrome, Chromium, or Edge). The
default PNG is exactly `4096x4096`. The tests compare two consecutive SVG and
PNG renders byte-for-byte.

Generated review artifacts:

- `output/board_debug_numbered.svg`
- `output/board_debug_numbered_4096.png`

No perspective, 3D styling, production icons, Flutter integration, APK, or AAB
work belongs to this stage.
