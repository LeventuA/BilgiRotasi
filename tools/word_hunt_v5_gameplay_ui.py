#!/usr/bin/env python3
import re
import struct
import sys
import xml.etree.ElementTree as ET
from pathlib import Path

BOUNDS = re.compile(r"\[(\d+),(\d+)\]\[(\d+),(\d+)\]")
CELL_LOG = re.compile(
    r"\[WORD_HUNT_V5_QA_CELL\] level=(\d+) row=(\d+) col=(\d+) x=(\d+) y=(\d+)"
)
SELECTOR_LOG = re.compile(
    r"\[WORD_HUNT_V5_QA_SELECTOR\] id=([^ ]+) x=(\d+) y=(\d+)"
)


def nodes(path):
    root = ET.parse(path).getroot()
    return list(root.iter("node"))


def description(node):
    return node.attrib.get("content-desc", "") or node.attrib.get("text", "")


def node_bounds(node):
    match = BOUNDS.fullmatch(node.attrib.get("bounds", ""))
    if not match:
        raise SystemExit(f"invalid bounds: {node.attrib.get('bounds')}")
    return tuple(map(int, match.groups()))


def center(node):
    x1, y1, x2, y2 = node_bounds(node)
    return ((x1 + x2) // 2, (y1 + y2) // 2)


def labels(path):
    return [
        description(node).strip()
        for node in nodes(path)
        if description(node).strip()
    ]


def find_exact(path, label):
    matches = [node for node in nodes(path) if description(node).strip() == label]
    if not matches:
        raise SystemExit(f"label not found: {label!r}")
    return matches[0]


def one_char_cells(path):
    result = []
    for node in nodes(path):
        value = description(node).strip()
        if len(value) != 1 or not value.isalpha():
            continue
        x1, y1, x2, y2 = node_bounds(node)
        if x2 <= x1 or y2 <= y1:
            continue
        result.append((node, (x1, y1, x2, y2)))
    result.sort(key=lambda item: (item[1][1], item[1][0]))
    if len(result) != 64:
        raise SystemExit(f"expected 64 visible letter cells, got {len(result)}")
    rows = []
    for item in result:
        top = item[1][1]
        if not rows or abs(top - rows[-1][0][1][1]) > 4:
            rows.append([item])
        else:
            rows[-1].append(item)
    if len(rows) != 8 or any(len(row) != 8 for row in rows):
        raise SystemExit(
            f"expected 8x8 visible grid, got row sizes {[len(row) for row in rows]}"
        )
    for row in rows:
        row.sort(key=lambda item: item[1][0])
    return rows


def assert_grid(path, level, target_count, soft_min=0):
    visible_labels = labels(path)
    for expected in (
        f"Bölüm {level}",
        "Başlangıç Limanı",
        f"0/{target_count}",
        "0 hata",
        "İlk harfe dokun, parmağını kelimenin üzerinde sürükle.",
    ):
        if expected not in visible_labels:
            raise SystemExit(f"missing gameplay label: {expected!r}")

    grid = one_char_cells(path)
    flat = [item for row in grid for item in row]
    min_x = min(item[1][0] for item in flat)
    min_y = min(item[1][1] for item in flat)
    max_x = max(item[1][2] for item in flat)
    max_y = max(item[1][3] for item in flat)
    min_width = min(item[1][2] - item[1][0] for item in flat)
    min_height = min(item[1][3] - item[1][1] for item in flat)
    if not (0 <= min_x < max_x <= 1080 and 0 <= min_y < max_y <= 1920):
        raise SystemExit(f"grid outside viewport: {(min_x, min_y, max_x, max_y)}")
    if min_width < 70 or min_height < 70:
        raise SystemExit(
            f"grid cells too small for swipe: min={min_width}x{min_height}px"
        )

    if soft_min:
        elapsed = []
        for label in visible_labels:
            match = re.fullmatch(r"(\d+)s", label)
            if match:
                elapsed.append(int(match.group(1)))
        if not elapsed or max(elapsed) < soft_min:
            raise SystemExit(
                f"soft-time evidence missing; times={elapsed}, minimum={soft_min}"
            )

    print(
        f"PASS B{level}: cells=64 bounds={(min_x, min_y, max_x, max_y)} "
        f"min_cell={min_width}x{min_height} progress=0/{target_count}"
    )


def assert_png_size(path, width, height):
    data = Path(path).read_bytes()
    if data[:8] != b"\x89PNG\r\n\x1a\n":
        raise SystemExit(f"not a PNG: {path}")
    actual = struct.unpack(">II", data[16:24])
    if actual != (width, height):
        raise SystemExit(f"unexpected PNG size: {actual}, expected {(width, height)}")
    print(f"PASS PNG: {path} {width}x{height}")


def scan_logcat(path, package):
    lines = Path(path).read_text(encoding="utf-8", errors="replace").splitlines()
    failures = []
    for index, line in enumerate(lines):
        if package in line and re.search(r"ANR in|am_crash|am_proc_died", line):
            failures.append(line)
        if "FATAL EXCEPTION" in line:
            block = "\n".join(lines[index : index + 24])
            if package in block:
                failures.append(block)
    if failures:
        raise SystemExit("application process failure detected:\n" + "\n".join(failures))
    print("APP_PROCESS_FAILURE_SCAN=PASS")


def log_cell_center(path, level, row, column):
    text = Path(path).read_text(encoding="utf-8", errors="replace")
    matches = {
        (int(match.group(1)), int(match.group(2)), int(match.group(3))): (
            int(match.group(4)),
            int(match.group(5)),
        )
        for match in CELL_LOG.finditer(text)
    }
    key = (level, row, column)
    if key not in matches:
        raise SystemExit(f"logged cell center not found: {key}")
    print(*matches[key])


def log_selector_center(path, selector_id):
    text = Path(path).read_text(encoding="utf-8", errors="replace")
    matches = {
        match.group(1): (int(match.group(2)), int(match.group(3)))
        for match in SELECTOR_LOG.finditer(text)
    }
    if selector_id not in matches:
        raise SystemExit(f"logged selector center not found: {selector_id}")
    print(*matches[selector_id])


def assert_log_grid(path, level):
    text = Path(path).read_text(encoding="utf-8", errors="replace")
    cells = {
        (int(match.group(2)), int(match.group(3)))
        for match in CELL_LOG.finditer(text)
        if int(match.group(1)) == level
    }
    if len(cells) != 64:
        raise SystemExit(f"expected 64 logged cells for B{level}, got {len(cells)}")
    if f"[WORD_HUNT_V5_QA_GEOMETRY] level={level} cells=64" not in text:
        raise SystemExit(f"B{level} geometry completion marker missing")
    print(f"PASS B{level}: logged production cells=64")


def assert_grid_visual_change(before_path, after_path, log_path, level):
    from PIL import Image, ImageChops

    text = Path(log_path).read_text(encoding="utf-8", errors="replace")
    centers = [
        (int(match.group(4)), int(match.group(5)))
        for match in CELL_LOG.finditer(text)
        if int(match.group(1)) == level
    ]
    if len(set(centers)) != 64:
        raise SystemExit(f"expected 64 centers for visual comparison, got {len(set(centers))}")
    xs = [point[0] for point in centers]
    ys = [point[1] for point in centers]
    margin = 45
    box = (min(xs) - margin, min(ys) - margin, max(xs) + margin, max(ys) + margin)
    before = Image.open(before_path).convert("RGB").crop(box)
    after = Image.open(after_path).convert("RGB").crop(box)
    diff = ImageChops.difference(before, after)
    changed = sum(1 for pixel in diff.getdata() if max(pixel) >= 20)
    if changed < 1000:
        raise SystemExit(f"real gesture did not create visible grid change: {changed} pixels")
    print(f"PASS real gesture visual change: level={level} changed_pixels={changed}")


def main():
    if len(sys.argv) < 3:
        raise SystemExit("usage: ui.py <command> <path> ...")
    command, path = sys.argv[1:3]
    if command == "label-center":
        print(*center(find_exact(path, sys.argv[3])))
    elif command == "cell-center":
        grid = one_char_cells(path)
        print(*center(grid[int(sys.argv[3])][int(sys.argv[4])][0]))
    elif command == "assert-grid":
        soft = int(sys.argv[5]) if len(sys.argv) > 5 else 0
        assert_grid(path, int(sys.argv[3]), int(sys.argv[4]), soft)
    elif command == "assert-label":
        find_exact(path, sys.argv[3])
        print(f"PASS label: {sys.argv[3]}")
    elif command == "assert-no-label":
        if sys.argv[3] in labels(path):
            raise SystemExit(f"unexpected label found: {sys.argv[3]!r}")
        print(f"PASS absent label: {sys.argv[3]}")
    elif command == "assert-png-size":
        assert_png_size(path, int(sys.argv[3]), int(sys.argv[4]))
    elif command == "scan-logcat":
        scan_logcat(path, sys.argv[3])
    elif command == "log-cell-center":
        log_cell_center(path, int(sys.argv[3]), int(sys.argv[4]), int(sys.argv[5]))
    elif command == "log-selector-center":
        log_selector_center(path, sys.argv[3])
    elif command == "assert-log-grid":
        assert_log_grid(path, int(sys.argv[3]))
    elif command == "assert-grid-visual-change":
        assert_grid_visual_change(path, sys.argv[3], sys.argv[4], int(sys.argv[5]))
    else:
        raise SystemExit(f"unknown command: {command}")


if __name__ == "__main__":
    main()
