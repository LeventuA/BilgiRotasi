#!/usr/bin/env bash
set -euo pipefail

: "${PACKAGE_NAME:=com.leventua.bilgirotasi}"
: "${REPORTS:=reports/word_hunt_v6_error_state}"

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
  adb shell am force-stop "$PACKAGE_NAME"
  adb shell am start -n "$PACKAGE_NAME/.MainActivity" >/dev/null
  sleep 12
  adb shell input tap 540 1244
  sleep 6
}

error_cell_gate() {
  local before="$1"
  local after="$2"
  python3 - "$before" "$after" <<'PY'
import sys
from PIL import Image, ImageChops
before = Image.open(sys.argv[1]).convert('RGB')
after = Image.open(sys.argv[2]).convert('RGB')
# B10 row 0 col 0..1 = M-H. All canonical target/bonus words are >=3 letters,
# so this two-cell straight path is deterministically notAWord.
coords = [(92, 748), (220, 748)]
changes = []
for x, y in coords:
    box = (x - 45, y - 45, x + 45, y + 45)
    diff = ImageChops.difference(before.crop(box), after.crop(box))
    changes.append(sum(1 for px in diff.getdata() if px != (0, 0, 0)))
print(f'ERROR_CELL_CHANGED_PIXELS={changes}')
if any(value < 600 for value in changes):
    raise SystemExit(41)
print('ERROR_CELL_VISUAL_GATE=PASS')
PY
}

launch_b10
capture_png "$REPORTS/04_B10_INITIAL.png"

passed=0
for duration in 80 120 180; do
  launch_b10
  capture_png "$REPORTS/08_B10_ERROR_BEFORE_${duration}.png"
  remote="/sdcard/word_hunt_error_${duration}.png"
  adb shell rm -f "$remote"
  # Capture on-device immediately after pointer-up so the real 280 ms product
  # error feedback is preserved without changing product timing.
  adb shell "input swipe 92 748 220 748 ${duration}; screencap -p ${remote}"
  adb pull "$remote" "$REPORTS/09_B10_ERROR_AFTER_${duration}.png" >/dev/null
  adb shell rm -f "$remote"
  if error_cell_gate \
    "$REPORTS/08_B10_ERROR_BEFORE_${duration}.png" \
    "$REPORTS/09_B10_ERROR_AFTER_${duration}.png"; then
    cp "$REPORTS/08_B10_ERROR_BEFORE_${duration}.png" "$REPORTS/08_B10_ERROR_BEFORE.png"
    cp "$REPORTS/09_B10_ERROR_AFTER_${duration}.png" "$REPORTS/09_B10_ERROR_STATE.png"
    printf '%s\n' "$duration" > "$REPORTS/ERROR_CAPTURE_DURATION_MS.txt"
    passed=1
    break
  fi
done

test "$passed" -eq 1
sleep 1
capture_png "$REPORTS/10_B10_ERROR_CLEARED.png"
sha256sum \
  "$REPORTS/04_B10_INITIAL.png" \
  "$REPORTS/08_B10_ERROR_BEFORE.png" \
  "$REPORTS/09_B10_ERROR_STATE.png" \
  "$REPORTS/10_B10_ERROR_CLEARED.png" \
  > "$REPORTS/SHA256SUMS.txt"
printf '%s\n' \
  'ANDROID_API=36' \
  'RESOLUTION=1080x1920' \
  'DENSITY=420' \
  'ERROR_PATH=M-H (row0 col0->col1)' \
  'ERROR_CELL_VISUAL_GATE=PASS' \
  > "$REPORTS/QA_SUMMARY.txt"
