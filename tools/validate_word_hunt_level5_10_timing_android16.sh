#!/usr/bin/env bash
set -euo pipefail

readonly package_name="com.leventua.bilgirotasi"
readonly report_dir="reports/word-hunt-level5-10-timing-android16"
mkdir -p "$report_dir"

wait_log() {
  local pattern="$1"
  local timeout_seconds="${2:-45}"
  local ticks=0
  until adb logcat -d | grep -Fq "$pattern"; do
    if (( ticks >= timeout_seconds * 5 )); then
      echo "Timed out waiting for log marker: $pattern" >&2
      adb logcat -d > "$report_dir/LOGCAT_TIMEOUT.txt"
      return 1
    fi
    sleep 0.2
    ticks=$((ticks + 1))
  done
}

wait_log_count() {
  local pattern="$1"
  local minimum="$2"
  local timeout_seconds="${3:-45}"
  local ticks=0
  while true; do
    local count
    count="$(adb logcat -d | grep -Fc "$pattern" || true)"
    if (( count >= minimum )); then return 0; fi
    if (( ticks >= timeout_seconds * 5 )); then
      echo "Timed out waiting for $minimum occurrences: $pattern" >&2
      return 1
    fi
    sleep 0.2
    ticks=$((ticks + 1))
  done
}

latest_geometry() {
  local key="$1"
  local line
  line="$(adb logcat -d | grep -F "[WORD_HUNT_TIMING_GEOMETRY] key=$key " | tail -n 1)"
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
    sleep 1
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

capture() {
  local name="$1"
  adb exec-out screencap -p > "$report_dir/$name"
  test -s "$report_dir/$name"
}

parse_result() {
  local level="$1"
  local line elapsed stars
  line="$(adb logcat -d | grep -F "[WORD_HUNT_TIMING_RESULT] level=$level " | tail -n 1)"
  test -n "$line"
  elapsed="$(sed -nE 's/.*elapsed=([0-9]+) saniye.*/\1/p' <<< "$line")"
  stars="$(sed -nE 's/.*stars=([0-9]+).*/\1/p' <<< "$line")"
  test -n "$elapsed"
  test -n "$stars"
  printf '%s,%s\n' "$elapsed" "$stars"
}

if adb shell pm path "$package_name" 2>/dev/null | grep -q '^package:'; then
  adb uninstall "$package_name"
fi
adb install build/app/outputs/flutter-apk/app-debug.apk
adb logcat -c
adb shell am force-stop "$package_name"
adb shell monkey -p "$package_name" -c android.intent.category.LAUNCHER 1 >/dev/null

wait_log '[WORD_HUNT_TIMING_GEOMETRY] key=word_hunt_timing_open_5 '
wait_log '[WORD_HUNT_TIMING_GEOMETRY] key=word_hunt_timing_open_10 '
sleep 2
capture 00_TIMING_QA_LAUNCHER.png

# Bölüm 5: gerçek wall-clock orta bant ~40-44s, 0 hata, beklenen 2 yıldız.
tap_key word_hunt_timing_open_5
wait_log '[WORD_HUNT_TIMING_VISIBLE] level=baslangic-5'
wait_log '[WORD_HUNT_TIMING_GEOMETRY] key=word_hunt_production_grid '
sleep 1
capture 01_LEVEL5_START.png
sleep 18
capture 02_LEVEL5_TIMER_RUNNING.png
sleep 20
# Opposite gesture kanıtı: KALE intended sola, burada aynı hattı sağa seçiyoruz.
drag_cells 5 0 5 3
wait_log '[WORD_HUNT_TIMING_FOUND] level=baslangic-5 kind=bonus word=KALE'
drag_cells 0 0 5 5
wait_log '[WORD_HUNT_TIMING_FOUND] level=baslangic-5 kind=target word=ANKARA'
drag_cells 0 5 4 5
wait_log '[WORD_HUNT_TIMING_FOUND] level=baslangic-5 kind=target word=ŞEHİR'
capture 03_LEVEL5_COMPLETE.png
ensure_key_visible word_hunt_production_finish
tap_key word_hunt_production_finish
wait_log '[WORD_HUNT_TIMING_RESULT] level=baslangic-5 '
wait_log '[WORD_HUNT_TIMING_GEOMETRY] key=word_hunt_production_return_route '
sleep 2.5
wait_log '[WORD_HUNT_TIMING_FREEZE] level=baslangic-5 '
capture 04_LEVEL5_RESULT.png
IFS=, read -r b5_elapsed b5_stars <<< "$(parse_result baslangic-5)"
if (( b5_elapsed < 36 || b5_elapsed > 50 )); then
  echo "B5 elapsed outside 2-star timing band: $b5_elapsed" >&2
  exit 1
fi
test "$b5_stars" -eq 2

tap_key word_hunt_production_return_route
wait_log '[WORD_HUNT_TIMING_RETURN] level=baslangic-5 stars=2'

# Bölüm 10: gerçek wall-clock orta bant ~82-88s, 0 hata, beklenen 2 yıldız.
tap_key word_hunt_timing_open_10
wait_log '[WORD_HUNT_TIMING_VISIBLE] level=baslangic-10'
wait_log_count '[WORD_HUNT_TIMING_GEOMETRY] key=word_hunt_production_grid ' 2
sleep 1
capture 05_LEVEL10_START.png
sleep 38
capture 06_LEVEL10_TIMER_RUNNING.png
sleep 42
drag_cells 3 0 3 5
wait_log '[WORD_HUNT_TIMING_FOUND] level=baslangic-10 kind=bonus word=YILDIZ'
drag_cells 0 0 0 5
wait_log '[WORD_HUNT_TIMING_FOUND] level=baslangic-10 kind=target word=PUSULA'
drag_cells 1 2 3 2
wait_log '[WORD_HUNT_TIMING_FOUND] level=baslangic-10 kind=target word=YOL'
drag_cells 1 4 5 0
wait_log '[WORD_HUNT_TIMING_FOUND] level=baslangic-10 kind=target word=BİLGİ'
capture 07_LEVEL10_COMPLETE.png
ensure_key_visible word_hunt_production_finish
tap_key word_hunt_production_finish
wait_log '[WORD_HUNT_TIMING_RESULT] level=baslangic-10 '
wait_log '[WORD_HUNT_TIMING_GEOMETRY] key=word_hunt_production_return_route '
sleep 2.5
wait_log '[WORD_HUNT_TIMING_FREEZE] level=baslangic-10 '
capture 08_LEVEL10_RESULT.png
IFS=, read -r b10_elapsed b10_stars <<< "$(parse_result baslangic-10)"
if (( b10_elapsed < 76 || b10_elapsed > 100 )); then
  echo "B10 elapsed outside 2-star timing band: $b10_elapsed" >&2
  exit 1
fi
test "$b10_stars" -eq 2

tap_key word_hunt_production_return_route
wait_log '[WORD_HUNT_TIMING_RETURN] level=baslangic-10 stars=2'

# Runtime timeout diagnostic: B5 60s geçildiğinde production screen hâlâ oynanabilir mi?
tap_key word_hunt_timing_open_5
wait_log_count '[WORD_HUNT_TIMING_OPEN] level=baslangic-5' 2
sleep 62
latest_elapsed_line="$(adb logcat -d | grep -F '[WORD_HUNT_TIMING_STATE] level=baslangic-5 elapsed=' | tail -n 1)"
test -n "$latest_elapsed_line"
after_limit_elapsed="$(sed -nE 's/.*elapsed=([0-9]+)s.*/\1/p' <<< "$latest_elapsed_line")"
test -n "$after_limit_elapsed"
if (( after_limit_elapsed < 61 )); then
  echo "B5 runtime did not pass configured limit during diagnostic: $after_limit_elapsed" >&2
  exit 1
fi
capture 09_LEVEL5_AFTER_LIMIT.png
printf 'B5_AFTER_LIMIT_ELAPSED=%s\nTIME_LIMIT_RUNTIME_ENFORCEMENT=FAIL\n' "$after_limit_elapsed" \
  > "$report_dir/TIME_LIMIT_RUNTIME_DIAGNOSTIC.txt"

adb shell dumpsys activity activities > "$report_dir/ACTIVITY.txt"
adb shell dumpsys window windows > "$report_dir/FOCUS.txt"
adb shell wm size > "$report_dir/WM_SIZE.txt"
adb logcat -d > "$report_dir/LOGCAT.txt"
grep -F '[WORD_HUNT_TIMING_' "$report_dir/LOGCAT.txt" > "$report_dir/RUNTIME_MARKERS.txt"

awk '
  /FATAL EXCEPTION/ { fatal=$0; next }
  /Process: com\.leventua\.bilgirotasi/ {
    if (fatal != "") { print fatal; print; fatal="" }
  }
  /ANR in com\.leventua\.bilgirotasi/ { print }
  /am_crash.*com\.leventua\.bilgirotasi/ { print }
  /am_proc_died.*com\.leventua\.bilgirotasi/ { print }
' "$report_dir/LOGCAT.txt" > "$report_dir/PACKAGE_FAILURES.txt"

fatal_count="$(grep -Fc 'FATAL EXCEPTION' "$report_dir/PACKAGE_FAILURES.txt" || true)"
anr_count="$(grep -Fc 'ANR in com.leventua.bilgirotasi' "$report_dir/PACKAGE_FAILURES.txt" || true)"
crash_count="$(grep -Fc 'am_crash' "$report_dir/PACKAGE_FAILURES.txt" || true)"
death_count="$(grep -Fc 'am_proc_died' "$report_dir/PACKAGE_FAILURES.txt" || true)"
printf 'FATAL_EXCEPTION=%s\nANR=%s\nAM_CRASH=%s\nPROCESS_DEATH=%s\n' \
  "$fatal_count" "$anr_count" "$crash_count" "$death_count" \
  > "$report_dir/CRASH_SCAN.txt"
test "$fatal_count" -eq 0
test "$anr_count" -eq 0
test "$crash_count" -eq 0
test "$death_count" -eq 0

grep -Fq "$package_name/.MainActivity" "$report_dir/ACTIVITY.txt"

cat > "$report_dir/TIMING_RESULTS.txt" <<EOF
B5_ELAPSED=$b5_elapsed
B5_STARS=$b5_stars
B10_ELAPSED=$b10_elapsed
B10_STARS=$b10_stars
B5_OPPOSITE_GESTURE_KALE=PASS
B5_RESULT_FREEZE=PASS
B10_RESULT_FREEZE=PASS
TIME_LIMIT_RUNTIME_ENFORCEMENT=FAIL
TECHNICAL_TIMING_GATE=FAIL
HUMAN_DIFFICULTY_GATE=PENDING
EOF
