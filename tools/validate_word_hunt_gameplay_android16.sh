#!/usr/bin/env bash
set -euo pipefail

readonly package_name="com.leventua.bilgirotasi"
readonly report_dir="reports/word-hunt-gameplay-android16"
mkdir -p "$report_dir"

wait_log() {
  local pattern="$1"
  local timeout_seconds="${2:-45}"
  local elapsed=0
  until adb logcat -d | grep -Fq "$pattern"; do
    if (( elapsed >= timeout_seconds * 5 )); then
      echo "Timed out waiting for log marker: $pattern" >&2
      adb logcat -d > "$report_dir/WORD_HUNT_GAMEPLAY_ANDROID16_LOGCAT_TIMEOUT.txt"
      return 1
    fi
    sleep 0.2
    elapsed=$((elapsed + 1))
  done
}

wait_log_count() {
  local pattern="$1"
  local minimum="$2"
  local timeout_seconds="${3:-45}"
  local elapsed=0
  local count=0
  while true; do
    count="$(adb logcat -d | grep -Fc "$pattern" || true)"
    if (( count >= minimum )); then return 0; fi
    if (( elapsed >= timeout_seconds * 5 )); then
      echo "Timed out waiting for $minimum occurrences: $pattern (found $count)" >&2
      return 1
    fi
    sleep 0.2
    elapsed=$((elapsed + 1))
  done
}

latest_geometry() {
  local key="$1"
  local line
  line="$(adb logcat -d | grep -F "[WORD_HUNT_PROOF_GEOMETRY] key=$key " | tail -n 1)"
  test -n "$line"
  printf '%s\n' "$line"
}

tap_key() {
  local key="$1"
  local line center x y
  line="$(latest_geometry "$key")"
  center="$(sed -E 's/.* center=([0-9]+,[0-9]+).*/\1/' <<< "$line")"
  IFS=, read -r x y <<< "$center"
  adb shell input tap "$x" "$y"
}

ensure_key_visible() {
  local key="$1"
  local line center y screen_height
  line="$(latest_geometry "$key")"
  center="$(sed -E 's/.* center=([0-9]+,[0-9]+).*/\1/' <<< "$line")"
  y="${center#*,}"
  screen_height="$(adb shell wm size | tr -d '\r' | sed -nE 's/.*Physical size: [0-9]+x([0-9]+).*/\1/p')"
  if test -z "$screen_height"; then
    screen_height="$(adb shell wm size | tr -d '\r' | sed -nE 's/.*Override size: [0-9]+x([0-9]+).*/\1/p')"
  fi
  test -n "$screen_height"
  if (( y > screen_height - 80 )); then
    adb shell input swipe 540 $((screen_height - 180)) 540 420 500
    sleep 0.8
  fi
}

cell_center() {
  local row="$1"
  local column="$2"
  local line left top width height x y
  line="$(latest_geometry word_hunt_production_grid)"
  left="$(sed -E 's/.* left=([0-9]+).*/\1/' <<< "$line")"
  top="$(sed -E 's/.* top=([0-9]+).*/\1/' <<< "$line")"
  width="$(sed -E 's/.* width=([0-9]+).*/\1/' <<< "$line")"
  height="$(sed -E 's/.* height=([0-9]+).*/\1/' <<< "$line")"
  x=$((left + width * (2 * column + 1) / 12))
  y=$((top + height * (2 * row + 1) / 12))
  printf '%s,%s\n' "$x" "$y"
}

drag_cells() {
  local start_row="$1"
  local start_column="$2"
  local end_row="$3"
  local end_column="$4"
  local start end x1 y1 x2 y2
  start="$(cell_center "$start_row" "$start_column")"
  end="$(cell_center "$end_row" "$end_column")"
  IFS=, read -r x1 y1 <<< "$start"
  IFS=, read -r x2 y2 <<< "$end"
  adb shell input swipe "$x1" "$y1" "$x2" "$y2" 350
}

drag_cells_and_capture_error() {
  local start_row="$1"
  local start_column="$2"
  local end_row="$3"
  local end_column="$4"
  local screenshot="$5"
  local start end x1 y1 x2 y2
  start="$(cell_center "$start_row" "$start_column")"
  end="$(cell_center "$end_row" "$end_column")"
  IFS=, read -r x1 y1 <<< "$start"
  IFS=, read -r x2 y2 <<< "$end"
  adb shell input swipe "$x1" "$y1" "$x2" "$y2" 80
  sleep 0.12
  capture "$screenshot"
}

capture() {
  local name="$1"
  adb exec-out screencap -p > "$report_dir/$name"
  test -s "$report_dir/$name"
}

if adb shell pm path "$package_name" 2>/dev/null | grep -q '^package:'; then
  adb uninstall "$package_name"
fi
adb install build/app/outputs/flutter-apk/app-debug.apk
adb logcat -c
adb shell am force-stop "$package_name"
adb shell monkey -p "$package_name" -c android.intent.category.LAUNCHER 1 >/dev/null

wait_log '[WORD_HUNT_PROOF_ROUTE_VISIBLE] visit=1 total=0 level1=0 node2Unlocked=false'
wait_log '[WORD_HUNT_PROOF_GEOMETRY] key=word_hunt_pixel_proof_level_1 '
sleep 3
capture 01_ROUTE_BEFORE.png
test "$(wc -c < "$report_dir/01_ROUTE_BEFORE.png")" -gt 500000

tap_key word_hunt_pixel_proof_level_1
wait_log '[WORD_HUNT_PROOF_GAMEPLAY_VISIBLE] attempt=1'
wait_log '[WORD_HUNT_PROOF_GEOMETRY] key=word_hunt_production_grid '
sleep 1
capture 02_LEVEL1_INITIAL.png
test "$(sha256sum "$report_dir/01_ROUTE_BEFORE.png" | cut -d' ' -f1)" != \
  "$(sha256sum "$report_dir/02_LEVEL1_INITIAL.png" | cut -d' ' -f1)"

drag_cells 0 0 0 4
wait_log '[WORD_HUNT_PROOF_TARGET_FOUND] attempt=1 word=KALEM'
capture 03_KALEM_FOUND.png

drag_cells_and_capture_error 3 0 3 1 04_ERROR_FEEDBACK.png
wait_log '[WORD_HUNT_PROOF_STATE] attempt=1 mistakes=1 hata'
wait_log '[WORD_HUNT_PROOF_ERROR_VISIBLE] attempt=1 anchor=3,0'

sleep 0.6
drag_cells 3 0 4 2
wait_log_count '[WORD_HUNT_PROOF_ERROR_VISIBLE] attempt=1 anchor=3,0' 2
if adb logcat -d | grep -Fq '[WORD_HUNT_PROOF_STATE] attempt=1 mistakes=2 hata'; then
  echo 'Invalid path unexpectedly incremented mistakes.' >&2
  exit 1
fi

sleep 0.6
drag_cells 2 0 2 3
wait_log '[WORD_HUNT_PROOF_BONUS_FOUND] attempt=1 word=ELMA'
tap_key word_hunt_production_back
wait_log '[WORD_HUNT_PROOF_EXIT_CONFIRMATION] attempt=1'
wait_log '[WORD_HUNT_PROOF_GEOMETRY] key=word_hunt_production_exit_confirm '
tap_key word_hunt_production_exit_confirm
wait_log '[WORD_HUNT_PROOF_ROUTE_VISIBLE] visit=2 total=0 level1=0 node2Unlocked=false'
if adb logcat -d | grep -Fq '[WORD_HUNT_PROOF_PROGRESS_RECORDED]'; then
  echo 'Partial exit unexpectedly recorded progress.' >&2
  exit 1
fi

wait_log_count '[WORD_HUNT_PROOF_GEOMETRY] key=word_hunt_pixel_proof_level_1 ' 2
tap_key word_hunt_pixel_proof_level_1
wait_log '[WORD_HUNT_PROOF_GAMEPLAY_VISIBLE] attempt=2'
wait_log_count '[WORD_HUNT_PROOF_GEOMETRY] key=word_hunt_production_grid ' 2

drag_cells 2 0 2 3
wait_log '[WORD_HUNT_PROOF_BONUS_FOUND] attempt=2 word=ELMA'
drag_cells 0 0 0 4
wait_log '[WORD_HUNT_PROOF_TARGET_FOUND] attempt=2 word=KALEM'
drag_cells 1 0 1 3
wait_log '[WORD_HUNT_PROOF_TARGET_FOUND] attempt=2 word=MASA'
wait_log '[WORD_HUNT_PROOF_STATE] attempt=2 progress=2/2'
capture 05_LEVEL1_2_OF_2.png

ensure_key_visible word_hunt_production_finish
tap_key word_hunt_production_finish
wait_log '[WORD_HUNT_PROOF_RESULT_DIALOG] attempt=2'
wait_log '[WORD_HUNT_PROOF_RESULT_STARS] attempt=2 value=3'
wait_log '[WORD_HUNT_PROOF_GEOMETRY] key=word_hunt_production_return_route '
capture 06_RESULT_3_STARS.png

tap_key word_hunt_production_return_route
wait_log '[WORD_HUNT_PROOF_PROGRESS_RECORDED] level1=3 total=3 node2Unlocked=true'
wait_log '[WORD_HUNT_PROOF_ROUTE_VISIBLE] visit=3 total=3 level1=3 node2Unlocked=true'
capture 07_ROUTE_AFTER.png
test "$(wc -c < "$report_dir/07_ROUTE_AFTER.png")" -gt 500000

adb shell dumpsys activity activities > "$report_dir/WORD_HUNT_GAMEPLAY_ANDROID16_ACTIVITY.txt"
adb shell dumpsys window windows > "$report_dir/WORD_HUNT_GAMEPLAY_ANDROID16_FOCUS.txt"
adb shell wm size > "$report_dir/WORD_HUNT_GAMEPLAY_ANDROID16_WM_SIZE.txt"
adb logcat -d > "$report_dir/WORD_HUNT_GAMEPLAY_ANDROID16_LOGCAT.txt"

grep -F '[WORD_HUNT_PROOF_' "$report_dir/WORD_HUNT_GAMEPLAY_ANDROID16_LOGCAT.txt" \
  > "$report_dir/WORD_HUNT_GAMEPLAY_ANDROID16_RUNTIME.txt"

awk '
  /FATAL EXCEPTION/ { fatal=$0; next }
  /Process: com\.leventua\.bilgirotasi/ {
    if (fatal != "") { print fatal; print; fatal="" }
  }
  /ANR in com\.leventua\.bilgirotasi/ { print }
  /am_crash.*com\.leventua\.bilgirotasi/ { print }
  /am_proc_died.*com\.leventua\.bilgirotasi/ { print }
' "$report_dir/WORD_HUNT_GAMEPLAY_ANDROID16_LOGCAT.txt" \
  > "$report_dir/WORD_HUNT_GAMEPLAY_ANDROID16_PACKAGE_FAILURES.txt"

fatal_count="$(grep -Fc 'FATAL EXCEPTION' "$report_dir/WORD_HUNT_GAMEPLAY_ANDROID16_PACKAGE_FAILURES.txt" || true)"
anr_count="$(grep -Fc 'ANR in com.leventua.bilgirotasi' "$report_dir/WORD_HUNT_GAMEPLAY_ANDROID16_PACKAGE_FAILURES.txt" || true)"
crash_count="$(grep -Fc 'am_crash' "$report_dir/WORD_HUNT_GAMEPLAY_ANDROID16_PACKAGE_FAILURES.txt" || true)"
death_count="$(grep -Fc 'am_proc_died' "$report_dir/WORD_HUNT_GAMEPLAY_ANDROID16_PACKAGE_FAILURES.txt" || true)"
printf 'FATAL_EXCEPTION=%s\nANR=%s\nAM_CRASH=%s\nPROCESS_DEATH=%s\n' \
  "$fatal_count" "$anr_count" "$crash_count" "$death_count" \
  > "$report_dir/WORD_HUNT_GAMEPLAY_ANDROID16_FAILURE_COUNTS.txt"
test "$fatal_count" -eq 0
test "$anr_count" -eq 0
test "$crash_count" -eq 0
test "$death_count" -eq 0

grep -Fq "$package_name/.MainActivity" "$report_dir/WORD_HUNT_GAMEPLAY_ANDROID16_ACTIVITY.txt"
grep -Eq "mResumedActivity.*$package_name|topResumedActivity=.*$package_name|mCurrentFocus=.*$package_name" \
  "$report_dir/WORD_HUNT_GAMEPLAY_ANDROID16_ACTIVITY.txt" \
  "$report_dir/WORD_HUNT_GAMEPLAY_ANDROID16_FOCUS.txt"

cat > "$report_dir/WORD_HUNT_GAMEPLAY_ANDROID16_RESULT.txt" <<'EOF'
ROUTE_BEFORE_RENDER=PASS
NODE_1_OPENED_GAMEPLAY=PASS
KALEM_REAL_GESTURE=PASS
MASA_REAL_GESTURE=PASS
BONUS_ELMA_GESTURE=PASS
WRONG_WORD_MISTAKE_INCREMENT=PASS
INVALID_PATH_NO_MISTAKE=PASS
ERROR_VISUAL_FEEDBACK=PASS
COMPLETION_2_OF_2=PASS
RESULT_3_STARS=PASS
RETURN_TO_ROUTE=PASS
NODE_1_THREE_STARS=PASS
NODE_2_UNLOCKED=PASS
TOTAL_STARS_3_OF_30=PASS
PARTIAL_EXIT_NO_PROGRESS=PASS
APP_PROCESS_FAILURE_SCAN=PASS
EOF
