#!/usr/bin/env bash
set -euo pipefail

: "${REPORT_DIR:?REPORT_DIR is required}"
: "${QA_PACKAGE:?QA_PACKAGE is required}"

APK="$REPORT_DIR/KelimeAvi-V6-B5-60s-Balance-QA.apk"
test -s "$APK"
mkdir -p "$REPORT_DIR"

wait_for_log() {
  local marker="$1"
  local attempts="${2:-100}"
  local i
  for i in $(seq 1 "$attempts"); do
    if adb logcat -d | grep -Fq "$marker"; then
      return 0
    fi
    sleep 0.25
  done
  adb logcat -d > "$REPORT_DIR/ANDROID_TIMEOUT_LOGCAT.txt"
  echo "Timed out waiting for: $marker" >&2
  return 1
}

capture_rich_render() {
  local output="$REPORT_DIR/B5_60S_BALANCE_INITIAL.png"
  local tmp="$REPORT_DIR/.b5_balance.tmp"
  local i size
  for i in $(seq 1 20); do
    adb exec-out screencap -p > "$tmp"
    size="$(stat -c '%s' "$tmp")"
    if (( size >= 1000000 )); then
      mv "$tmp" "$output"
      printf 'B5_60S_BALANCE_INITIAL_BYTES=%s\n' "$size" > "$REPORT_DIR/RENDER_SIZE_GATE.txt"
      return 0
    fi
    sleep 0.4
  done
  mv "$tmp" "$output"
  echo 'Full raster screenshot gate failed.' >&2
  return 1
}

adb install -r "$APK"
adb shell settings put secure immersive_mode_confirmations confirmed || true
adb shell wm size | tee "$REPORT_DIR/ANDROID_WM_SIZE.txt"
adb shell wm density | tee "$REPORT_DIR/ANDROID_WM_DENSITY.txt"
adb logcat -c
adb shell monkey -p "$QA_PACKAGE" -c android.intent.category.LAUNCHER 1 >/dev/null
wait_for_log '[WORD_HUNT_V6_B5_BALANCE_QA_READY] cells=64'
sleep 1
capture_rich_render
adb logcat -d > "$REPORT_DIR/ANDROID_LOGCAT.txt"

if grep -E "FATAL EXCEPTION|ANR in ${QA_PACKAGE}|am_crash.*${QA_PACKAGE}|Process: ${QA_PACKAGE}" "$REPORT_DIR/ANDROID_LOGCAT.txt"; then
  echo 'QA process failure detected.' >&2
  exit 1
fi

printf '%s\n' \
  'ANDROID_API=36' \
  "QA_PACKAGE=$QA_PACKAGE" \
  'APK_INSTALL=PASS' \
  'B5_64_CELL_RENDER=PASS' \
  'B5_FULL_RASTER_SCREENSHOT=PASS' \
  'B5_TARGET_SECONDS=60' \
  'PROCESS_FAILURE_SCAN=PASS' \
  'HUMAN_TIMING_RESULT=PENDING_USER_PLAYTEST' \
  | tee "$REPORT_DIR/ANDROID_RUNTIME_SUMMARY.txt"
