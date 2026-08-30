#!/usr/bin/env bash
set -euo pipefail

PACKAGE_NAME='com.leventua.bilgirotasi'
APK='build/app/outputs/flutter-apk/app-debug.apk'
REPORTS='reports/word_hunt_v5_gameplay'
UI='tools/word_hunt_v5_gameplay_ui.py'
mkdir -p "$REPORTS"

capture_png() {
  local output="$1"
  adb exec-out screencap -p > "$output"
  test -s "$output"
  python3 "$UI" assert-png-size "$output" 1080 1920
}

flutter_log() {
  timeout 10s adb logcat -d -t 500 -s flutter:I '*:S'
}

launch_selector() {
  adb shell am force-stop "$PACKAGE_NAME"
  timeout 10s adb shell am start \
    -n "$PACKAGE_NAME/.MainActivity" >/dev/null
  sleep 3
}

open_level() {
  local label="$1"
  local state_name="$2"
  local selector_id
  local selector_log="$REPORTS/SELECTOR.logcat"
  local tap_x
  local tap_y
  local marker
  local before_count
  local after_count
  local attempt
  launch_selector
  case "$label" in
    'QA B1') selector_id='1'; marker='level=1 rows=8 cols=8' ;;
    'QA B5') selector_id='5'; marker='level=5 rows=8 cols=8' ;;
    'QA B8') selector_id='8'; marker='level=8 rows=8 cols=8' ;;
    'QA B10') selector_id='10'; marker='level=10 rows=8 cols=8' ;;
    'QA B5+65') selector_id='5_soft_time'; marker='level=5 rows=8 cols=8 targets=7 bonus=1 timeOffset=65' ;;
    *) echo "Unknown selector label: $label" >&2; return 1 ;;
  esac
  flutter_log > "$selector_log"
  read -r tap_x tap_y < <(
    python3 "$UI" log-selector-center "$selector_log" "$selector_id"
  )
  before_count=$(flutter_log | grep -Fc "$marker" || true)
  for attempt in 1 2 3; do
    adb shell input tap "$tap_x" "$tap_y"
    sleep 1
    after_count=$(flutter_log | grep -Fc "$marker" || true)
    if (( after_count > before_count )); then
      sleep 2
      break
    fi
  done
  if (( after_count <= before_count )); then
    echo "Gameplay level did not open after bounded taps: $label" >&2
    return 1
  fi
  flutter_log > "$REPORTS/${state_name}.logcat"
}

capture_initial() {
  local level="$1"
  local target_count="$2"
  local output="$3"
  local xml_name="${output%.png}"
  open_level "QA B$level" "$xml_name"
  capture_png "$REPORTS/$output"
  python3 "$UI" assert-log-grid "$REPORTS/${xml_name}.logcat" "$level"
}

if adb shell pm path "$PACKAGE_NAME" 2>/dev/null | grep -q '^package:'; then
  adb uninstall "$PACKAGE_NAME" >/dev/null
fi
adb install "$APK" >/dev/null
adb logcat -c

{
  echo "ANDROID_API=$(adb shell getprop ro.build.version.sdk | tr -d '\r')"
  echo "ANDROID_RELEASE=$(adb shell getprop ro.build.version.release | tr -d '\r')"
  adb shell wm size
  adb shell wm density
} | tee "$REPORTS/ANDROID_DISPLAY.txt"

test "$(adb shell getprop ro.build.version.sdk | tr -d '\r')" = '36'
adb shell wm size | grep -Fq '1080x1920'
adb shell wm density | grep -Fq '420'

capture_initial 1 5 '01_B1_INITIAL.png'
capture_initial 5 7 '02_B5_INITIAL.png'

capture_initial 8 7 '03_B8_INITIAL.png'

capture_initial 10 9 '04_B10_INITIAL.png'

# B5 ANKARA: gerçek uzun çapraz gesture (5,2) -> (0,7).
open_level 'QA B5' '05_B5_ANKARA_BEFORE'
capture_png "$REPORTS/05_B5_ANKARA_BEFORE.png"
read -r ankara_x1 ankara_y1 < <(
  python3 "$UI" log-cell-center "$REPORTS/05_B5_ANKARA_BEFORE.logcat" 5 5 2
)
read -r ankara_x2 ankara_y2 < <(
  python3 "$UI" log-cell-center "$REPORTS/05_B5_ANKARA_BEFORE.logcat" 5 0 7
)
adb shell input swipe "$ankara_x1" "$ankara_y1" "$ankara_x2" "$ankara_y2" 1200
sleep 1
capture_png "$REPORTS/05_B5_ANKARA_FOUND.png"
flutter_log > "$REPORTS/05_B5_ANKARA_FOUND.logcat"
python3 "$UI" assert-grid-visual-change \
  "$REPORTS/05_B5_ANKARA_BEFORE.png" \
  "$REPORTS/05_B5_ANKARA_FOUND.png" \
  "$REPORTS/05_B5_ANKARA_BEFORE.logcat" 5

# B5 BAŞKENT: canonical (6,4)->(0,4), gerçek reverse gesture (0,4)->(6,4).
open_level 'QA B5' '06_B5_BASKENT_REVERSE_BEFORE'
capture_png "$REPORTS/06_B5_BASKENT_REVERSE_BEFORE.png"
read -r baskent_x1 baskent_y1 < <(
  python3 "$UI" log-cell-center "$REPORTS/06_B5_BASKENT_REVERSE_BEFORE.logcat" 5 0 4
)
read -r baskent_x2 baskent_y2 < <(
  python3 "$UI" log-cell-center "$REPORTS/06_B5_BASKENT_REVERSE_BEFORE.logcat" 5 6 4
)
adb shell input swipe "$baskent_x1" "$baskent_y1" "$baskent_x2" "$baskent_y2" 1200
sleep 1
capture_png "$REPORTS/06_B5_BASKENT_REVERSE_FOUND.png"
flutter_log > "$REPORTS/06_B5_BASKENT_REVERSE_FOUND.logcat"
python3 "$UI" assert-grid-visual-change \
  "$REPORTS/06_B5_BASKENT_REVERSE_BEFORE.png" \
  "$REPORTS/06_B5_BASKENT_REVERSE_FOUND.png" \
  "$REPORTS/06_B5_BASKENT_REVERSE_BEFORE.logcat" 5

open_level 'QA B5+65' '07_B5_AFTER_65_SECONDS'
sleep 2
capture_png "$REPORTS/07_B5_AFTER_65_SECONDS.png"
python3 "$UI" assert-log-grid "$REPORTS/07_B5_AFTER_65_SECONDS.logcat" 5

adb shell pidof "$PACKAGE_NAME" | tee "$REPORTS/APP_PID.txt"
test -s "$REPORTS/APP_PID.txt"
adb shell dumpsys activity activities > "$REPORTS/ACTIVITY_STATE.txt"
grep -Eq "mResumedActivity.*${PACKAGE_NAME}|topResumedActivity=.*${PACKAGE_NAME}|mCurrentFocus=.*${PACKAGE_NAME}" "$REPORTS/ACTIVITY_STATE.txt"
timeout 20s adb logcat -d -t 5000 > "$REPORTS/LOGCAT.txt"
python3 "$UI" scan-logcat "$REPORTS/LOGCAT.txt" "$PACKAGE_NAME" \
  | tee "$REPORTS/APP_PROCESS_FAILURE_SCAN.txt"

for level in 1 5 8 10; do
  grep -Fq "[WORD_HUNT_V5_QA_CONFIG] level=$level rows=8 cols=8" "$REPORTS/LOGCAT.txt"
  grep -Fq "[WORD_HUNT_V5_QA_READY] level=$level" "$REPORTS/LOGCAT.txt"
done
grep -Fq '[WORD_HUNT_V5_QA_SELECTOR_READY]' "$REPORTS/LOGCAT.txt"

cat > "$REPORTS/QA_SUMMARY.txt" <<EOF
BRANCH=${QA_BRANCH:-$(git branch --show-current)}
EXACT_TESTED_SHA=$(git rev-parse HEAD)
ANDROID_API=36
RESOLUTION=1080x1920
DENSITY=420
B1_64_OF_64=PASS
B5_64_OF_64=PASS
B8_64_OF_64=PASS
B10_64_OF_64=PASS
ANKARA_REAL_GESTURE=PASS
BASKENT_REVERSE_REAL_GESTURE=PASS
B5_SOFT_TIME_OVER_60_SECONDS=PASS
APP_PROCESS_FAILURE_SCAN=PASS
EOF

find "$REPORTS" -maxdepth 1 -type f ! -name SHA256SUMS.txt -print0 \
  | sort -z \
  | xargs -0 sha256sum > "$REPORTS/SHA256SUMS.txt"

echo 'Kelime Avı V5 Android 16 gameplay visual QA PASS'
