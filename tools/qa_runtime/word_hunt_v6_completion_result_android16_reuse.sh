#!/usr/bin/env bash
set -euo pipefail

: "${REPORT_DIR:?REPORT_DIR is required}"
: "${QA_PACKAGE:?QA_PACKAGE is required}"

APK="$REPORT_DIR/KelimeAvi-V6-Completion-QA.apk"
test -s "$APK"
mkdir -p "$REPORT_DIR"

has_marker() {
  local marker="$1"
  local tmp="$REPORT_DIR/.marker_logcat.tmp"
  adb logcat -d > "$tmp"
  grep -Fq "$marker" "$tmp"
}

wait_marker() {
  local marker="$1"
  local attempts="${2:-120}"
  local i
  for i in $(seq 1 "$attempts"); do
    if has_marker "$marker"; then
      return 0
    fi
    sleep 0.5
  done
  echo "Timed out waiting for: $marker" >&2
  adb logcat -d > "$REPORT_DIR/TIMEOUT_LOGCAT.txt"
  return 1
}

capture() {
  local name="$1"
  adb exec-out screencap -p > "$REPORT_DIR/$name"
  test -s "$REPORT_DIR/$name"
}

extract_coord() {
  local file="$1"
  local pattern="$2"
  local axis="$3"
  local line
  line="$(grep -F "$pattern" "$file" | tail -1)"
  test -n "$line"
  case "$axis" in
    x) printf '%s\n' "$line" | sed -E 's/.* x=([0-9]+) y=.*/\1/' ;;
    y) printf '%s\n' "$line" | sed -E 's/.* y=([0-9]+).*/\1/' ;;
    *) return 2 ;;
  esac
}

launch_selector() {
  local out="$1"
  adb logcat -c
  adb shell monkey -p "$QA_PACKAGE" -c android.intent.category.LAUNCHER 1 >/dev/null
  wait_marker '[COMP_QA_SELECTOR_READY] buttons=2'
  sleep 0.8
  adb logcat -d > "$out"
}

restart_selector() {
  local out="$1"
  adb shell am force-stop "$QA_PACKAGE"
  sleep 0.8
  launch_selector "$out"
}

open_level() {
  local level="$1"
  local selector_log="$2"
  local geometry_log="$3"
  local x y
  x="$(extract_coord "$selector_log" "[COMP_QA_BUTTON] level=$level " x)"
  y="$(extract_coord "$selector_log" "[COMP_QA_BUTTON] level=$level " y)"
  adb logcat -c
  adb shell input tap "$x" "$y"
  wait_marker "[COMP_QA_STATE] level=$level cells=64 targets=0 bonus=0 dialog=0"
  wait_marker "[COMP_QA_CELL] level=$level row=7 col=7 "
  sleep 0.5
  adb logcat -d > "$geometry_log"
}

cell_coord() {
  local geometry_log="$1"
  local level="$2"
  local row="$3"
  local col="$4"
  local axis="$5"
  extract_coord "$geometry_log" "[COMP_QA_CELL] level=$level row=$row col=$col " "$axis"
}

swipe_path() {
  local geometry_log="$1"
  local level="$2"
  local r1="$3"
  local c1="$4"
  local r2="$5"
  local c2="$6"
  local x1 y1 x2 y2
  x1="$(cell_coord "$geometry_log" "$level" "$r1" "$c1" x)"
  y1="$(cell_coord "$geometry_log" "$level" "$r1" "$c1" y)"
  x2="$(cell_coord "$geometry_log" "$level" "$r2" "$c2" x)"
  y2="$(cell_coord "$geometry_log" "$level" "$r2" "$c2" y)"
  adb shell input touchscreen swipe "$x1" "$y1" "$x2" "$y2" 1800
  sleep 0.35
}

wait_state() {
  local level="$1"
  local targets="$2"
  local bonus="$3"
  local dialog="$4"
  wait_marker "[COMP_QA_STATE] level=$level cells=64 targets=$targets bonus=$bonus dialog=$dialog"
}

return_to_selector() {
  local level="$1"
  local out="$2"
  local state_log="$REPORT_DIR/RETURN_${level}_STATE.txt"
  local x y
  adb logcat -d > "$state_log"
  x="$(extract_coord "$state_log" "[COMP_QA_RETURN] level=$level " x)"
  y="$(extract_coord "$state_log" "[COMP_QA_RETURN] level=$level " y)"
  adb logcat -c
  adb shell input tap "$x" "$y"
  wait_marker '[COMP_QA_SELECTOR_READY] buttons=2'
  sleep 0.8
  adb logcat -d > "$out"
}

play_b5_targets_no_bonus() {
  local geom="$1"
  swipe_path "$geom" 5 5 2 0 7; wait_state 5 1 0 0
  swipe_path "$geom" 5 7 6 7 2; wait_state 5 2 0 0
  swipe_path "$geom" 5 6 7 0 1; wait_state 5 3 0 0
  swipe_path "$geom" 5 6 4 0 4; wait_state 5 4 0 0
  swipe_path "$geom" 5 1 5 6 0; wait_state 5 5 0 0
  swipe_path "$geom" 5 4 0 1 3; wait_state 5 6 0 0
  swipe_path "$geom" 5 3 4 3 7; wait_state 5 7 0 0
}

play_b5_targets_after_bonus() {
  local geom="$1"
  swipe_path "$geom" 5 5 2 0 7; wait_state 5 1 1 0
  swipe_path "$geom" 5 7 6 7 2; wait_state 5 2 1 0
  swipe_path "$geom" 5 6 7 0 1; wait_state 5 3 1 0
  swipe_path "$geom" 5 6 4 0 4; wait_state 5 4 1 0
  swipe_path "$geom" 5 1 5 6 0; wait_state 5 5 1 0
  swipe_path "$geom" 5 4 0 1 3; wait_state 5 6 1 0
  swipe_path "$geom" 5 3 4 3 7
  wait_state 5 7 1 1
}

play_b10_targets_no_bonus() {
  local geom="$1"
  swipe_path "$geom" 10 6 1 1 6; wait_state 10 1 0 0
  swipe_path "$geom" 10 2 3 2 5; wait_state 10 2 0 0
  swipe_path "$geom" 10 7 7 3 7; wait_state 10 3 0 0
  swipe_path "$geom" 10 7 2 2 7; wait_state 10 4 0 0
  swipe_path "$geom" 10 0 1 0 5; wait_state 10 5 0 0
  swipe_path "$geom" 10 7 0 3 0; wait_state 10 6 0 0
  swipe_path "$geom" 10 6 2 1 7; wait_state 10 7 0 0
  swipe_path "$geom" 10 0 0 5 5; wait_state 10 8 0 0
  swipe_path "$geom" 10 1 5 1 0; wait_state 10 9 0 0
}

play_b10_targets_after_bonus() {
  local geom="$1"
  swipe_path "$geom" 10 6 1 1 6; wait_state 10 1 1 0
  swipe_path "$geom" 10 2 3 2 5; wait_state 10 2 1 0
  swipe_path "$geom" 10 7 7 3 7; wait_state 10 3 1 0
  swipe_path "$geom" 10 7 2 2 7; wait_state 10 4 1 0
  swipe_path "$geom" 10 0 1 0 5; wait_state 10 5 1 0
  swipe_path "$geom" 10 7 0 3 0; wait_state 10 6 1 0
  swipe_path "$geom" 10 6 2 1 7; wait_state 10 7 1 0
  swipe_path "$geom" 10 0 0 5 5; wait_state 10 8 1 0
  swipe_path "$geom" 10 1 5 1 0
  wait_state 10 9 1 1
}

adb install -r "$APK"
adb shell pm path "$QA_PACKAGE" | tee "$REPORT_DIR/ANDROID_PACKAGE_PATH.txt"

# B5: all main targets, no bonus => completion dialog must stay absent.
launch_selector "$REPORT_DIR/01_SELECTOR_LOGCAT.txt"
open_level 5 "$REPORT_DIR/01_SELECTOR_LOGCAT.txt" "$REPORT_DIR/02_B5_TARGET_ONLY_GEOMETRY_LOGCAT.txt"
play_b5_targets_no_bonus "$REPORT_DIR/02_B5_TARGET_ONLY_GEOMETRY_LOGCAT.txt"
wait_state 5 7 0 0
sleep 0.8
capture 03_B5_TARGETS_ONLY_NO_DIALOG.png
adb logcat -d > "$REPORT_DIR/03_B5_TARGETS_ONLY_LOGCAT.txt"

# Fresh B5: find ANIT before layout reflow, then last main target must auto-open result.
restart_selector "$REPORT_DIR/04_SELECTOR_B5_AUTO_LOGCAT.txt"
open_level 5 "$REPORT_DIR/04_SELECTOR_B5_AUTO_LOGCAT.txt" "$REPORT_DIR/05_B5_AUTO_GEOMETRY_LOGCAT.txt"
swipe_path "$REPORT_DIR/05_B5_AUTO_GEOMETRY_LOGCAT.txt" 5 0 0 3 0
wait_state 5 0 1 0
play_b5_targets_after_bonus "$REPORT_DIR/05_B5_AUTO_GEOMETRY_LOGCAT.txt"
sleep 0.8
capture 06_B5_AUTO_RESULT.png
adb logcat -d > "$REPORT_DIR/06_B5_AUTO_RESULT_LOGCAT.txt"

# Same app route cycle: return and replay B5; auto result must work again.
return_to_selector 5 "$REPORT_DIR/07_SELECTOR_B5_REPLAY_LOGCAT.txt"
open_level 5 "$REPORT_DIR/07_SELECTOR_B5_REPLAY_LOGCAT.txt" "$REPORT_DIR/08_B5_REPLAY_GEOMETRY_LOGCAT.txt"
swipe_path "$REPORT_DIR/08_B5_REPLAY_GEOMETRY_LOGCAT.txt" 5 0 0 3 0
wait_state 5 0 1 0
play_b5_targets_after_bonus "$REPORT_DIR/08_B5_REPLAY_GEOMETRY_LOGCAT.txt"
sleep 0.8
capture 09_B5_REPLAY_AUTO_RESULT.png
adb logcat -d > "$REPORT_DIR/09_B5_REPLAY_AUTO_RESULT_LOGCAT.txt"

# B10 target-only proof in a fresh process.
restart_selector "$REPORT_DIR/10_SELECTOR_B10_TARGET_ONLY_LOGCAT.txt"
open_level 10 "$REPORT_DIR/10_SELECTOR_B10_TARGET_ONLY_LOGCAT.txt" "$REPORT_DIR/11_B10_TARGET_ONLY_GEOMETRY_LOGCAT.txt"
play_b10_targets_no_bonus "$REPORT_DIR/11_B10_TARGET_ONLY_GEOMETRY_LOGCAT.txt"
wait_state 10 9 0 0
sleep 0.8
capture 12_B10_TARGETS_ONLY_NO_DIALOG.png
adb logcat -d > "$REPORT_DIR/12_B10_TARGETS_ONLY_LOGCAT.txt"

# Fresh B10: find HAZINE before layout reflow, then final target must auto-open result.
restart_selector "$REPORT_DIR/13_SELECTOR_B10_AUTO_LOGCAT.txt"
open_level 10 "$REPORT_DIR/13_SELECTOR_B10_AUTO_LOGCAT.txt" "$REPORT_DIR/14_B10_AUTO_GEOMETRY_LOGCAT.txt"
swipe_path "$REPORT_DIR/14_B10_AUTO_GEOMETRY_LOGCAT.txt" 10 0 1 5 1
wait_state 10 0 1 0
play_b10_targets_after_bonus "$REPORT_DIR/14_B10_AUTO_GEOMETRY_LOGCAT.txt"
sleep 0.8
capture 15_B10_AUTO_RESULT.png
adb logcat -d > "$REPORT_DIR/15_B10_AUTO_RESULT_LOGCAT.txt"

adb shell wm size | tee "$REPORT_DIR/ANDROID_WM_SIZE.txt"
adb shell wm density | tee "$REPORT_DIR/ANDROID_WM_DENSITY.txt"
cat "$REPORT_DIR"/*LOGCAT.txt > "$REPORT_DIR/ANDROID_COMBINED_LOGCAT.txt"
if grep -E "FATAL EXCEPTION|ANR in ${QA_PACKAGE}|am_crash.*${QA_PACKAGE}|Process: ${QA_PACKAGE}" "$REPORT_DIR/ANDROID_COMBINED_LOGCAT.txt"; then
  echo 'QA process failure detected.' >&2
  exit 1
fi

printf '%s\n' \
  'ANDROID_API=36' \
  "QA_PACKAGE=$QA_PACKAGE" \
  'APK_INSTALL=PASS' \
  'APP_LAUNCH=PASS' \
  'B5_TARGETS_ONLY_DIALOG=ABSENT_PASS' \
  'B5_ALL_WORDS_AUTO_DIALOG=PASS' \
  'B5_FRESH_REPLAY_AUTO_DIALOG=PASS' \
  'B10_TARGETS_ONLY_DIALOG=ABSENT_PASS' \
  'B10_ALL_WORDS_AUTO_DIALOG=PASS' \
  'PROCESS_FAILURE_SCAN=PASS' \
  | tee "$REPORT_DIR/ANDROID_RUNTIME_SUMMARY.txt"
