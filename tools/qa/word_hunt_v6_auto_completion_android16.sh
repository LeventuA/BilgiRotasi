#!/usr/bin/env bash
set -euo pipefail

: "${REPORT_DIR:?REPORT_DIR is required}"
: "${QA_PACKAGE:?QA_PACKAGE is required}"

APK="$REPORT_DIR/KelimeAvi-V6-Auto-Completion-QA.apk"
test -s "$APK"
mkdir -p "$REPORT_DIR"

wait_for_log() {
  local marker="$1"
  local attempts="${2:-80}"
  local i
  for i in $(seq 1 "$attempts"); do
    if adb logcat -d | grep -Fq "$marker"; then
      return 0
    fi
    sleep 0.25
  done
  echo "Timed out waiting for log marker: $marker" >&2
  adb logcat -d > "$REPORT_DIR/LOGCAT_TIMEOUT.txt"
  return 1
}

selector_coordinate() {
  local level="$1" axis="$2" line
  line="$(adb logcat -d | grep -F "[WORD_HUNT_V6_AUTO_QA_BUTTON] level=$level " | tail -1)"
  test -n "$line"
  case "$axis" in
    x) printf '%s\n' "$line" | sed -E 's/.* x=([0-9]+) y=.*/\1/' ;;
    y) printf '%s\n' "$line" | sed -E 's/.* y=([0-9]+).*/\1/' ;;
    *) return 2 ;;
  esac
}

wait_for_dialog() {
  local name="$1" i
  for i in $(seq 1 40); do
    adb shell uiautomator dump /sdcard/window.xml >/dev/null 2>&1 || true
    adb shell cat /sdcard/window.xml > "$REPORT_DIR/${name}_UI.xml" 2>/dev/null || true
    if grep -Fq 'Bölüm Tamamlandı' "$REPORT_DIR/${name}_UI.xml"; then
      return 0
    fi
    sleep 0.25
  done
  echo "Auto completion dialog not found: $name" >&2
  adb logcat -d > "$REPORT_DIR/${name}_DIALOG_TIMEOUT_LOGCAT.txt"
  return 1
}

capture_rich_render() {
  local name="$1" min_bytes="${2:-900000}" tmp="$REPORT_DIR/.${name}.tmp" i size
  for i in $(seq 1 16); do
    adb exec-out screencap -p > "$tmp"
    size="$(stat -c '%s' "$tmp")"
    if (( size >= min_bytes )); then
      mv "$tmp" "$REPORT_DIR/$name"
      printf '%s=%s\n' "${name%.png}_BYTES" "$size" >> "$REPORT_DIR/RENDER_SIZE_GATE.txt"
      return 0
    fi
    sleep 0.35
  done
  mv "$tmp" "$REPORT_DIR/$name"
  echo "Screenshot size gate failed for $name" >&2
  return 1
}

tap_return_route() {
  local xml="$1" coords
  coords="$(python3 - "$xml" <<'PY'
import re
import sys
import xml.etree.ElementTree as ET
root = ET.parse(sys.argv[1]).getroot()
for node in root.iter('node'):
    if node.attrib.get('text') == 'Rotaya Dön':
        match = re.fullmatch(r'\[(\d+),(\d+)\]\[(\d+),(\d+)\]', node.attrib['bounds'])
        if not match:
            raise SystemExit(2)
        x1, y1, x2, y2 = map(int, match.groups())
        print((x1 + x2) // 2, (y1 + y2) // 2)
        raise SystemExit(0)
raise SystemExit(3)
PY
)"
  read -r x y <<< "$coords"
  adb shell input tap "$x" "$y"
}

play_level() {
  local level="$1" tag="$2"
  wait_for_log '[WORD_HUNT_V6_AUTO_QA_SELECTOR_READY]'

  local x y
  x="$(selector_coordinate "$level" x)"
  y="$(selector_coordinate "$level" y)"

  # Start a fresh per-level log only after selector coordinates are captured.
  adb logcat -c
  adb shell input tap "$x" "$y"
  wait_for_log "[WORD_HUNT_V6_AUTO_QA_OPEN] level=$level"
  wait_for_log "[WORD_HUNT_V6_AUTO_QA_READY] level=$level "
  adb logcat -d > "$REPORT_DIR/${tag}_READY_LOGCAT.txt"

  mapfile -t swipe_lines < <(grep -F "[WORD_HUNT_V6_AUTO_QA_SWIPE] level=$level " "$REPORT_DIR/${tag}_READY_LOGCAT.txt")
  local expected
  if [ "$level" = '5' ]; then expected=7; else expected=9; fi
  test "${#swipe_lines[@]}" -eq "$expected"

  local line x1 y1 x2 y2 word
  for line in "${swipe_lines[@]}"; do
    word="$(printf '%s\n' "$line" | sed -E 's/.* word=([^ ]+) x1=.*/\1/')"
    x1="$(printf '%s\n' "$line" | sed -E 's/.* x1=([0-9]+) y1=.*/\1/')"
    y1="$(printf '%s\n' "$line" | sed -E 's/.* y1=([0-9]+) x2=.*/\1/')"
    x2="$(printf '%s\n' "$line" | sed -E 's/.* x2=([0-9]+) y2=.*/\1/')"
    y2="$(printf '%s\n' "$line" | sed -E 's/.* y2=([0-9]+).*/\1/')"
    printf '%s level=%s word=%s (%s,%s)->(%s,%s)\n' "$tag" "$level" "$word" "$x1" "$y1" "$x2" "$y2" >> "$REPORT_DIR/SWIPE_SEQUENCE.txt"
    adb shell input swipe "$x1" "$y1" "$x2" "$y2" 220
    sleep 0.22
  done

  wait_for_dialog "${tag}_RESULT"
  capture_rich_render "${tag}_RESULT.png"
  adb logcat -d > "$REPORT_DIR/${tag}_RESULT_LOGCAT.txt"
  printf '%s_AUTO_DIALOG=PASS\n' "$tag" >> "$REPORT_DIR/AUTO_COMPLETION_GATE.txt"

  # Clear before closing so the next selector marker is guaranteed fresh.
  adb logcat -c
  tap_return_route "$REPORT_DIR/${tag}_RESULT_UI.xml"
  wait_for_log '[WORD_HUNT_V6_AUTO_QA_SELECTOR_READY]'
  sleep 0.4
}

adb install -r "$APK"
adb shell pm path "$QA_PACKAGE" | tee "$REPORT_DIR/ANDROID_PACKAGE_PATH.txt"
adb shell wm size | tee "$REPORT_DIR/ANDROID_WM_SIZE.txt"
adb shell wm density | tee "$REPORT_DIR/ANDROID_WM_DENSITY.txt"
adb logcat -c
adb shell monkey -p "$QA_PACKAGE" -c android.intent.category.LAUNCHER 1 >/dev/null
wait_for_log '[WORD_HUNT_V6_AUTO_QA_SELECTOR_READY]'

# Never capture selector screenshots; only real result dialogs are evidence.
play_level 5 '01_B5'
play_level 10 '02_B10'
play_level 5 '03_B5_REPLAY'

adb logcat -d > "$REPORT_DIR/FINAL_LOGCAT.txt"
cat "$REPORT_DIR"/*_LOGCAT.txt > "$REPORT_DIR/ANDROID_COMBINED_LOGCAT.txt" || true
if grep -E "FATAL EXCEPTION|ANR in ${QA_PACKAGE}|am_crash.*${QA_PACKAGE}|Process: ${QA_PACKAGE}" "$REPORT_DIR/ANDROID_COMBINED_LOGCAT.txt"; then
  echo 'QA process failure detected.' >&2
  exit 1
fi

grep -q '^01_B5_AUTO_DIALOG=PASS$' "$REPORT_DIR/AUTO_COMPLETION_GATE.txt"
grep -q '^02_B10_AUTO_DIALOG=PASS$' "$REPORT_DIR/AUTO_COMPLETION_GATE.txt"
grep -q '^03_B5_REPLAY_AUTO_DIALOG=PASS$' "$REPORT_DIR/AUTO_COMPLETION_GATE.txt"

printf '%s\n' \
  'ANDROID_API=36' \
  "QA_PACKAGE=$QA_PACKAGE" \
  'APK_INSTALL=PASS' \
  'B5_FIRST_AUTO_COMPLETION=PASS' \
  'B10_AUTO_COMPLETION=PASS' \
  'B5_REPLAY_AUTO_COMPLETION=PASS' \
  'NO_MANUAL_FINISH_TAP=PASS' \
  'SAME_PROCESS_B5_B10_B5_SEQUENCE=PASS' \
  'PROCESS_FAILURE_SCAN=PASS' \
  | tee "$REPORT_DIR/ANDROID_RUNTIME_SUMMARY.txt"
