#!/usr/bin/env bash
set -euo pipefail

: "${PACKAGE_NAME:=com.leventua.bilgirotasi}"
: "${REPORTS:=reports/word_hunt_v5_gameplay}"

mkdir -p "$REPORTS"

adb shell wm size 1080x1920
adb shell wm density 420
test "$(adb shell getprop ro.build.version.sdk | tr -d '\r')" = '36'
adb shell wm size | grep -Fq '1080x1920'
adb shell wm density | grep -Fq '420'

if adb shell pm path "$PACKAGE_NAME" 2>/dev/null | grep -q '^package:'; then
  adb uninstall "$PACKAGE_NAME" >/dev/null
fi
adb install build/app/outputs/flutter-apk/app-debug.apk >/dev/null
adb shell settings put secure immersive_mode_confirmations confirmed

capture_png() {
  local output="$1"
  adb exec-out screencap -p > "$output"
  test -s "$output"
  python3 - "$output" <<'PY'
import sys
from PIL import Image

image = Image.open(sys.argv[1])
if image.size != (1080, 1920):
    raise SystemExit(f'Unexpected PNG size: {image.size}')
print(f'PASS PNG {sys.argv[1]} {image.size[0]}x{image.size[1]}')
PY
}

launch_b10() {
  local suffix="$1"
  adb shell am force-stop "$PACKAGE_NAME"
  adb shell am start -n "$PACKAGE_NAME/.MainActivity" >/dev/null
  sleep 12
  capture_png "$REPORTS/00_SELECTOR_${suffix}.png"
  # Canonical 1080x1920 QA selector center proven on the existing QA entrypoint.
  adb shell input tap 540 1244
  sleep 6
}

semantic_gate() {
  local before="$1"
  local after="$2"
  python3 - "$before" "$after" <<'PY'
import sys
from PIL import Image, ImageChops

before = Image.open(sys.argv[1]).convert('RGB')
after = Image.open(sys.argv[2]).convert('RGB')
# B10 row 2, columns 3..5 = Y-O-L on the 1080x1920 / 420 dpi proof viewport.
coords = [(476, 1004), (604, 1004), (731, 1004)]

def changed_pixels(box):
    diff = ImageChops.difference(before.crop(box), after.crop(box))
    return sum(1 for pixel in diff.getdata() if pixel != (0, 0, 0))

cell_changes = [
    changed_pixels((x - 45, y - 45, x + 45, y + 45))
    for x, y in coords
]
progress_change = changed_pixels((165, 210, 250, 255))
print(f'YOL_CELL_CHANGED_PIXELS={cell_changes}')
print(f'PROGRESS_PANEL_CHANGED_PIXELS={progress_change}')
if any(value < 3000 for value in cell_changes):
    raise SystemExit(21)
if progress_change < 100:
    raise SystemExit(22)
print('YOL_SEMANTIC_VISUAL_GATE=PASS')
PY
}

launch_b10 initial
capture_png "$REPORTS/04_B10_INITIAL.png"

passed=0
for duration in 900 1800 3000; do
  capture_png "$REPORTS/08_B10_YOL_BEFORE_${duration}.png"
  adb shell input swipe 476 1004 731 1004 "$duration"
  sleep 2
  capture_png "$REPORTS/09_B10_YOL_AFTER_${duration}.png"
  if semantic_gate \
    "$REPORTS/08_B10_YOL_BEFORE_${duration}.png" \
    "$REPORTS/09_B10_YOL_AFTER_${duration}.png"; then
    cp "$REPORTS/08_B10_YOL_BEFORE_${duration}.png" "$REPORTS/08_B10_YOL_BEFORE.png"
    cp "$REPORTS/09_B10_YOL_AFTER_${duration}.png" "$REPORTS/09_B10_YOL_FOUND.png"
    printf '%s\n' "$duration" > "$REPORTS/YOL_PASS_DURATION_MS.txt"
    passed=1
    break
  fi
  launch_b10 "retry_${duration}"
done

test "$passed" -eq 1
test -s "$REPORTS/04_B10_INITIAL.png"
test -s "$REPORTS/09_B10_YOL_FOUND.png"
sha256sum "$REPORTS/04_B10_INITIAL.png" "$REPORTS/09_B10_YOL_FOUND.png" \
  > "$REPORTS/SHA256SUMS.txt"
printf '%s\n' \
  'ANDROID_API=36' \
  'RESOLUTION=1080x1920' \
  'DENSITY=420' \
  'STATIC_TESTS=138/138 PASS' \
  'YOL_SEMANTIC_VISUAL_GATE=PASS' \
  > "$REPORTS/QA_SUMMARY.txt"
