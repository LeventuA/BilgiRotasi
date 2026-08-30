#!/usr/bin/env bash
set -euo pipefail

PACKAGE_NAME='com.leventua.bilgirotasi'
APK='build/app/outputs/flutter-apk/app-debug.apk'
REPORTS='reports/word_hunt_v5_gameplay'
UI='tools/word_hunt_v5_gameplay_ui.py'
mkdir -p "$REPORTS"

dump_ui() {
  local remote="$1"
  local local_path="$2"
  local attempt
  for attempt in 1 2 3 4 5; do
    # The 8x8 production screen has a deliberately rich semantics tree.
    # Android 16's uncompressed uiautomator dump can terminate the ATD
    # emulator while serialising it; compressed mode keeps all labelled
    # gameplay nodes needed by this proof without the decorative wrappers.
    if adb shell uiautomator dump --compressed "$remote" >/dev/null 2>&1 &&
      adb pull "$remote" "$local_path" >/dev/null 2>&1 &&
      test -s "$local_path"; then
      return 0
    fi
    sleep 2
  done
  echo "UI hierarchy could not be captured: $local_path" >&2
  return 1
}

capture_png() {
  local output="$1"
  adb exec-out screencap -p > "$output"
  test -s "$output"
  python3 "$UI" assert-png-size "$output" 1080 1920
}

launch_selector() {
  adb shell am force-stop "$PACKAGE_NAME"
  adb shell monkey -p "$PACKAGE_NAME" -c android.intent.category.LAUNCHER 1 >/dev/null
  sleep 3
  dump_ui /sdcard/word_hunt_v5_selector.xml "$REPORTS/SELECTOR.xml"
}

open_level() {
  local label="$1"
  local state_name="$2"
  launch_selector
  read -r tap_x tap_y < <(python3 "$UI" label-center "$REPORTS/SELECTOR.xml" "$label")
  adb shell input tap "$tap_x" "$tap_y"
  sleep 3
  dump_ui "/sdcard/${state_name}.xml" "$REPORTS/${state_name}.xml"
}

capture_initial() {
  local level="$1"
  local target_count="$2"
  local output="$3"
  local xml_name="${output%.png}"
  launch_selector
  read -r tap_x tap_y < <(
    python3 "$UI" label-center "$REPORTS/SELECTOR.xml" "QA B$level"
  )
  adb shell input tap "$tap_x" "$tap_y"
  sleep 3
  # Preserve the real render before asking Android's accessibility service to
  # serialise the larger gameplay hierarchy.
  capture_png "$REPORTS/$output"
  dump_ui "/sdcard/${xml_name}.xml" "$REPORTS/${xml_name}.xml"
  python3 "$UI" assert-grid "$REPORTS/${xml_name}.xml" "$level" "$target_count" 0
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
python3 "$UI" assert-label "$REPORTS/02_B5_INITIAL.xml" 'ANKARA'
python3 "$UI" assert-label "$REPORTS/02_B5_INITIAL.xml" 'BAŞKENT'
python3 "$UI" assert-label "$REPORTS/02_B5_INITIAL.xml" 'ANIT'

capture_initial 8 7 '03_B8_INITIAL.png'
python3 "$UI" assert-label "$REPORTS/03_B8_INITIAL.xml" 'HIZ'
python3 "$UI" assert-label "$REPORTS/03_B8_INITIAL.xml" 'SKOR'

capture_initial 10 9 '04_B10_INITIAL.png'
python3 "$UI" assert-label "$REPORTS/04_B10_INITIAL.xml" 'YOL'
python3 "$UI" assert-label "$REPORTS/04_B10_INITIAL.xml" 'HAZİNE'
python3 "$UI" assert-no-label "$REPORTS/04_B10_INITIAL.xml" 'ROTA'

# B5 ANKARA: gerçek uzun çapraz gesture (5,2) -> (0,7).
open_level 'QA B5' '05_B5_ANKARA_BEFORE'
read -r ankara_x1 ankara_y1 < <(
  python3 "$UI" cell-center "$REPORTS/05_B5_ANKARA_BEFORE.xml" 5 2
)
read -r ankara_x2 ankara_y2 < <(
  python3 "$UI" cell-center "$REPORTS/05_B5_ANKARA_BEFORE.xml" 0 7
)
adb shell input swipe "$ankara_x1" "$ankara_y1" "$ankara_x2" "$ankara_y2" 1200
sleep 1
capture_png "$REPORTS/05_B5_ANKARA_FOUND.png"
dump_ui /sdcard/05_B5_ANKARA_FOUND.xml "$REPORTS/05_B5_ANKARA_FOUND.xml"
python3 "$UI" assert-label "$REPORTS/05_B5_ANKARA_FOUND.xml" 'Bilgi kartı açıldı: Ankara'
python3 "$UI" assert-label "$REPORTS/05_B5_ANKARA_FOUND.xml" '1/7'

# B5 BAŞKENT: canonical (6,4)->(0,4), gerçek reverse gesture (0,4)->(6,4).
open_level 'QA B5' '06_B5_BASKENT_REVERSE_BEFORE'
read -r baskent_x1 baskent_y1 < <(
  python3 "$UI" cell-center "$REPORTS/06_B5_BASKENT_REVERSE_BEFORE.xml" 0 4
)
read -r baskent_x2 baskent_y2 < <(
  python3 "$UI" cell-center "$REPORTS/06_B5_BASKENT_REVERSE_BEFORE.xml" 6 4
)
adb shell input swipe "$baskent_x1" "$baskent_y1" "$baskent_x2" "$baskent_y2" 1200
sleep 1
capture_png "$REPORTS/06_B5_BASKENT_REVERSE_FOUND.png"
dump_ui /sdcard/06_B5_BASKENT_REVERSE_FOUND.xml "$REPORTS/06_B5_BASKENT_REVERSE_FOUND.xml"
python3 "$UI" assert-label "$REPORTS/06_B5_BASKENT_REVERSE_FOUND.xml" 'BAŞKENT bulundu!'
python3 "$UI" assert-label "$REPORTS/06_B5_BASKENT_REVERSE_FOUND.xml" '1/7'

open_level 'QA B5+65' '07_B5_AFTER_65_SECONDS'
sleep 2
capture_png "$REPORTS/07_B5_AFTER_65_SECONDS.png"
dump_ui /sdcard/07_B5_AFTER_65_SECONDS.xml "$REPORTS/07_B5_AFTER_65_SECONDS.xml"
python3 "$UI" assert-grid "$REPORTS/07_B5_AFTER_65_SECONDS.xml" 5 7 65

adb shell pidof "$PACKAGE_NAME" | tee "$REPORTS/APP_PID.txt"
test -s "$REPORTS/APP_PID.txt"
adb shell dumpsys activity activities > "$REPORTS/ACTIVITY_STATE.txt"
grep -Eq "mResumedActivity.*${PACKAGE_NAME}|topResumedActivity=.*${PACKAGE_NAME}|mCurrentFocus=.*${PACKAGE_NAME}" "$REPORTS/ACTIVITY_STATE.txt"
adb logcat -d > "$REPORTS/LOGCAT.txt"
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
