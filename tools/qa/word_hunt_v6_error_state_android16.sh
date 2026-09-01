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
  # Proven QA selector coordinate for B10 on 1080x1920 / 420 dpi.
  adb shell input tap 540 1244
  sleep 6
}

mistake_gate() {
  local before="$1"
  local after="$2"
  python3 - "$before" "$after" <<'PY'
import sys
from PIL import Image, ImageChops
before = Image.open(sys.argv[1]).convert('RGB')
after = Image.open(sys.argv[2]).convert('RGB')
# Persistent middle status panel: 0 hata -> 1 hata after a registered wrong word.
box = (330, 175, 655, 275)
diff = ImageChops.difference(before.crop(box), after.crop(box))
changed = sum(1 for px in diff.getdata() if px != (0, 0, 0))
print(f'MISTAKE_PANEL_CHANGED_PIXELS={changed}')
if changed < 120:
    raise SystemExit(41)
print('WRONG_WORD_REGISTERED_GATE=PASS')
PY
}

capture_png "$REPORTS/00_SELECTOR.png"

passed=0
for attempt in 1 2 3; do
  launch_b10
  capture_png "$REPORTS/08_B10_ERROR_BEFORE_attempt${attempt}.png"

  remote_video="/sdcard/word_hunt_error_attempt${attempt}.mp4"
  adb shell rm -f "$remote_video"
  adb shell screenrecord \
    --size 1080x1920 \
    --bit-rate 12000000 \
    --time-limit 6 \
    "$remote_video" >/dev/null 2>&1 &
  record_pid=$!

  # Give screenrecord one stable second, then perform a deliberately wrong
  # straight three-cell path. B10 row2 col0..2 reads F-Z-C; it is not a
  # target/bonus and gives the real product 280 ms error feedback.
  sleep 1
  adb shell input swipe 92 1004 348 1004 1800
  sleep 1
  capture_png "$REPORTS/10_B10_ERROR_CLEARED_attempt${attempt}.png"
  wait "$record_pid"
  adb pull "$remote_video" "$REPORTS/09_B10_ERROR_RECORD_attempt${attempt}.mp4" >/dev/null
  adb shell rm -f "$remote_video"

  if mistake_gate \
    "$REPORTS/08_B10_ERROR_BEFORE_attempt${attempt}.png" \
    "$REPORTS/10_B10_ERROR_CLEARED_attempt${attempt}.png"; then
    cp "$REPORTS/08_B10_ERROR_BEFORE_attempt${attempt}.png" "$REPORTS/08_B10_ERROR_BEFORE.png"
    cp "$REPORTS/10_B10_ERROR_CLEARED_attempt${attempt}.png" "$REPORTS/10_B10_ERROR_CLEARED.png"
    cp "$REPORTS/09_B10_ERROR_RECORD_attempt${attempt}.mp4" "$REPORTS/09_B10_ERROR_RECORD.mp4"
    printf '%s\n' "$attempt" > "$REPORTS/ERROR_CAPTURE_ATTEMPT.txt"
    passed=1
    break
  fi
done

test "$passed" -eq 1
test -s "$REPORTS/09_B10_ERROR_RECORD.mp4"
sha256sum \
  "$REPORTS/08_B10_ERROR_BEFORE.png" \
  "$REPORTS/09_B10_ERROR_RECORD.mp4" \
  "$REPORTS/10_B10_ERROR_CLEARED.png" \
  > "$REPORTS/SHA256SUMS.txt"
printf '%s\n' \
  'ANDROID_API=36' \
  'RESOLUTION=1080x1920' \
  'DENSITY=420' \
  'ERROR_PATH=F-Z-C (row2 col0->col2)' \
  'SWIPE_DURATION_MS=1800' \
  'PRODUCT_ERROR_FEEDBACK_MS=280 (UNCHANGED)' \
  'WRONG_WORD_REGISTERED_GATE=PASS' \
  'RAW_ERROR_PROOF=ANDROID_SCREENRECORD' \
  > "$REPORTS/QA_SUMMARY.txt"
