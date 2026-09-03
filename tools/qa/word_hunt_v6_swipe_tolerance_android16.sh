#!/usr/bin/env bash
set -euo pipefail

: "${REPORT_DIR:?REPORT_DIR is required}"
: "${QA_PACKAGE:?QA_PACKAGE is required}"

APK="$REPORT_DIR/KelimeAvi-V6-Swipe-Tolerance-QA.apk"
test -s "$APK"
mkdir -p "$REPORT_DIR"

wait_for_log() {
  local marker="$1"
  local attempts="${2:-160}"
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

capture() {
  local name="$1"
  adb exec-out screencap -p > "$REPORT_DIR/$name"
  test "$(stat -c '%s' "$REPORT_DIR/$name")" -ge 100000
}

adb install -r "$APK"
adb shell settings put secure immersive_mode_confirmations confirmed || true
adb logcat -c
adb shell monkey -p "$QA_PACKAGE" -c android.intent.category.LAUNCHER 1 >/dev/null
wait_for_log '[WORD_HUNT_SWIPE_QA_READY] cells=64'
sleep 1
capture '01_B5_INITIAL.png'

adb logcat -d -v raw > "$REPORT_DIR/READY_LOGCAT.txt"
coords_text="$(tail -n 400 "$REPORT_DIR/READY_LOGCAT.txt" | tr '\n' ' ')"
start_x="$(grep -oE 'startX=[0-9]+' <<<"$coords_text" | tail -1 | cut -d= -f2 || true)"
start_y="$(grep -oE 'startY=[0-9]+' <<<"$coords_text" | tail -1 | cut -d= -f2 || true)"
end_x="$(grep -oE 'endX=[0-9]+' <<<"$coords_text" | tail -1 | cut -d= -f2 || true)"
end_y="$(grep -oE 'endY=[0-9]+' <<<"$coords_text" | tail -1 | cut -d= -f2 || true)"
test -n "$start_x" && test -n "$start_y" && test -n "$end_x" && test -n "$end_y"

density="$(adb shell wm density | sed -n 's/.*Physical density: \([0-9][0-9]*\).*/\1/p' | tail -1)"
test -n "$density"
start_x=$(((start_x * density + 80) / 160))
start_y=$(((start_y * density + 80) / 160))
end_x=$(((end_x * density + 80) / 160))
end_y=$(((end_y * density + 80) / 160))
printf 'ANDROID_DENSITY=%s GESTURE=%s,%s->%s,%s\n' \
  "$density" "$start_x" "$start_y" "$end_x" "$end_y" \
  | tee "$REPORT_DIR/GESTURE_COORDINATES.txt"

adb shell input swipe "$start_x" "$start_y" "$end_x" "$end_y" 1400
wait_for_log '[WORD_HUNT_SWIPE_QA_PASS] target=ANKARA progress=1/7 mistakes=0'
sleep 1
capture '02_B5_ANKARA_OVERSHOOT_PASS.png'
adb logcat -d > "$REPORT_DIR/ANDROID_LOGCAT.txt"

if grep -E "FATAL EXCEPTION|ANR in ${QA_PACKAGE}|am_crash.*${QA_PACKAGE}|Process: ${QA_PACKAGE}" "$REPORT_DIR/ANDROID_LOGCAT.txt"; then
  echo 'QA process failure detected.' >&2
  exit 1
fi

printf '%s\n' \
  'ANDROID_API=36' \
  "QA_PACKAGE=$QA_PACKAGE" \
  'B5_64_CELL_RENDER=PASS' \
  'REAL_GESTURE_ANKARA_PLUS_ONE_CELL=PASS' \
  'TARGET_PROGRESS_0_TO_1_OF_7=PASS' \
  'MISTAKES_REMAINED_ZERO=PASS' \
  'PROCESS_FAILURE_SCAN=PASS' \
  | tee "$REPORT_DIR/ANDROID_RUNTIME_SUMMARY.txt"
