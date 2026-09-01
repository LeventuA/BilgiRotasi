#!/usr/bin/env bash
set -euo pipefail

: "${REPORT_DIR:?REPORT_DIR is required}"
: "${QA_PACKAGE:?QA_PACKAGE is required}"

APK="$REPORT_DIR/KelimeAvi-V6-B5-B10-Playtest.apk"
test -s "$APK"

wait_for_log() {
  local marker="$1"
  local attempts="${2:-50}"
  local i
  for i in $(seq 1 "$attempts"); do
    if adb logcat -d | grep -Fq "$marker"; then
      return 0
    fi
    sleep 0.5
  done
  echo "Timed out waiting for log marker: $marker" >&2
  adb logcat -d > "$REPORT_DIR/LOGCAT_TIMEOUT.txt"
  return 1
}

extract_button_coordinate() {
  local log_file="$1"
  local level="$2"
  local axis="$3"
  local line
  line="$(grep -F "[WORD_HUNT_V6_HUMAN_QA_BUTTON] level=$level " "$log_file" | tail -1)"
  test -n "$line"
  case "$axis" in
    x) printf '%s\n' "$line" | sed -E 's/.* x=([0-9]+) y=.*/\1/' ;;
    y) printf '%s\n' "$line" | sed -E 's/.* y=([0-9]+).*/\1/' ;;
    *) echo "Unsupported axis: $axis" >&2; return 2 ;;
  esac
}

capture_rich_render() {
  local name="$1"
  local min_bytes="${2:-1000000}"
  local tmp="$REPORT_DIR/.${name}.tmp"
  local i size
  for i in $(seq 1 16); do
    adb exec-out screencap -p > "$tmp"
    size="$(stat -c '%s' "$tmp")"
    if (( size >= min_bytes )); then
      mv "$tmp" "$REPORT_DIR/$name"
      printf '%s=%s\n' "${name%.png}_BYTES" "$size" >> "$REPORT_DIR/RENDER_SIZE_GATE.txt"
      return 0
    fi
    sleep 0.5
  done
  mv "$tmp" "$REPORT_DIR/$name"
  echo "Full raster render did not reach ${min_bytes} bytes for $name" >&2
  return 1
}

adb install -r "$APK"
adb shell pm path "$QA_PACKAGE" | tee "$REPORT_DIR/ANDROID_PACKAGE_PATH.txt"
adb logcat -c
adb shell monkey -p "$QA_PACKAGE" -c android.intent.category.LAUNCHER 1 >/dev/null
wait_for_log '[WORD_HUNT_V6_HUMAN_QA_SELECTOR_READY]'
sleep 1
adb logcat -d > "$REPORT_DIR/01_SELECTOR_LOGCAT.txt"
grep -Fq '[WORD_HUNT_V6_HUMAN_QA_SELECTOR_GEOMETRY] buttons=2' "$REPORT_DIR/01_SELECTOR_LOGCAT.txt"

b5_x="$(extract_button_coordinate "$REPORT_DIR/01_SELECTOR_LOGCAT.txt" 5 x)"
b5_y="$(extract_button_coordinate "$REPORT_DIR/01_SELECTOR_LOGCAT.txt" 5 y)"
adb shell input tap "$b5_x" "$b5_y"
wait_for_log '[WORD_HUNT_V6_HUMAN_QA_OPEN] level=5 targetSeconds=60'
wait_for_log '[WORD_HUNT_V6_HUMAN_QA_READY] level=5 cells=64'
adb logcat -d > "$REPORT_DIR/02_B5_LOGCAT.txt"
capture_rich_render 02_B5_INITIAL.png

# Return through Flutter navigation instead of force-stopping/relaunching the app.
adb logcat -c
adb shell input keyevent KEYCODE_BACK
wait_for_log '[WORD_HUNT_V6_HUMAN_QA_SELECTOR_READY]'
sleep 1
adb logcat -d > "$REPORT_DIR/03_SELECTOR_RETURN_LOGCAT.txt"
grep -Fq '[WORD_HUNT_V6_HUMAN_QA_SELECTOR_GEOMETRY] buttons=2' "$REPORT_DIR/03_SELECTOR_RETURN_LOGCAT.txt"

b10_x="$(extract_button_coordinate "$REPORT_DIR/03_SELECTOR_RETURN_LOGCAT.txt" 10 x)"
b10_y="$(extract_button_coordinate "$REPORT_DIR/03_SELECTOR_RETURN_LOGCAT.txt" 10 y)"
adb shell input tap "$b10_x" "$b10_y"
wait_for_log '[WORD_HUNT_V6_HUMAN_QA_OPEN] level=10 targetSeconds=120'
wait_for_log '[WORD_HUNT_V6_HUMAN_QA_READY] level=10 cells=64'
adb logcat -d > "$REPORT_DIR/04_B10_LOGCAT.txt"
capture_rich_render 04_B10_INITIAL.png

adb shell wm size | tee "$REPORT_DIR/ANDROID_WM_SIZE.txt"
adb shell wm density | tee "$REPORT_DIR/ANDROID_WM_DENSITY.txt"
cat \
  "$REPORT_DIR/01_SELECTOR_LOGCAT.txt" \
  "$REPORT_DIR/02_B5_LOGCAT.txt" \
  "$REPORT_DIR/03_SELECTOR_RETURN_LOGCAT.txt" \
  "$REPORT_DIR/04_B10_LOGCAT.txt" \
  > "$REPORT_DIR/ANDROID_COMBINED_LOGCAT.txt"

if grep -E "FATAL EXCEPTION|ANR in ${QA_PACKAGE}|am_crash.*${QA_PACKAGE}|Process: ${QA_PACKAGE}" "$REPORT_DIR/ANDROID_COMBINED_LOGCAT.txt"; then
  echo 'QA process failure detected.' >&2
  exit 1
fi

printf '%s\n' \
  'ANDROID_API=36' \
  "QA_PACKAGE=$QA_PACKAGE" \
  'APK_INSTALL=PASS' \
  'APP_LAUNCH=PASS' \
  'B5_64_CELL_RENDER=PASS' \
  'B10_64_CELL_RENDER=PASS' \
  'B5_FULL_RASTER_SCREENSHOT=PASS' \
  'B10_FULL_RASTER_SCREENSHOT=PASS' \
  'B5_TARGET_SECONDS=60' \
  'B10_TARGET_SECONDS=120' \
  'SAME_PROCESS_B5_TO_B10_NAVIGATION=PASS' \
  'PROCESS_FAILURE_SCAN=PASS' \
  'HUMAN_TIMING_RESULT=PENDING_USER_PLAYTEST' \
  | tee "$REPORT_DIR/ANDROID_RUNTIME_SUMMARY.txt"
