#!/usr/bin/env bash
set -euo pipefail

mkdir -p reports

capture_diagnostics() {
  timeout 30 adb logcat -d > reports/COLD_START_LOGCAT.txt 2>&1 || true
  timeout 30 adb shell dumpsys activity activities > reports/ACTIVITY_STATE.txt 2>&1 || true
  timeout 15 adb shell pidof com.leventua.bilgirotasi > reports/APP_PID.txt 2>&1 || true
}

capture_screen() {
  local label="$1"
  timeout 30 adb exec-out screencap -p > "reports/UI_${label}.png"
  test -s "reports/UI_${label}.png"
  tesseract "reports/UI_${label}.png" "reports/UI_${label}" \
    --psm 11 -l eng tsv >/dev/null 2>&1
}

find_word() {
  local label="$1"
  local pattern="$2"
  awk -F '\t' -v pattern="$pattern" '
    BEGIN { IGNORECASE = 1 }
    NR > 1 && $12 ~ pattern {
      print int($7 + ($9 / 2)), int($8 + ($10 / 2))
      exit
    }
  ' "reports/UI_${label}.tsv"
}

dismiss_system_anr() {
  local label="$1"
  local wait_point
  if ! grep -Eqi 'system' "reports/UI_${label}.tsv" \
      || ! grep -Eqi 'responding' "reports/UI_${label}.tsv" \
      || ! grep -Eqi 'Process|System[[:space:]]+UI' "reports/UI_${label}.tsv"; then
    return 1
  fi
  wait_point="$(find_word "$label" 'Wait')"
  if test -z "$wait_point"; then
    return 1
  fi
  cp "reports/UI_${label}.png" reports/UI_SYSTEM_ANR.png
  cp "reports/UI_${label}.tsv" reports/UI_SYSTEM_ANR.tsv
  printf '%s: Android system ANR dialog dismissed with Wait.\n' "$label" \
    >> reports/SYSTEM_ANR_DISMISSED.txt
  timeout 15 adb shell input tap $wait_point
  sleep 5
}

wait_for_word() {
  local label="$1"
  local pattern="$2"
  local attempts="${3:-40}"
  for attempt in $(seq 1 "$attempts"); do
    capture_screen "${label}_${attempt}"
    if dismiss_system_anr "${label}_${attempt}"; then
      continue
    fi
    if test -n "$(find_word "${label}_${attempt}" "$pattern")"; then
      cp "reports/UI_${label}_${attempt}.png" "reports/UI_${label}.png"
      cp "reports/UI_${label}_${attempt}.tsv" "reports/UI_${label}.tsv"
      return 0
    fi
    sleep 3
  done
  return 1
}

tap_word() {
  local label="$1"
  local pattern="$2"
  local point
  point="$(find_word "$label" "$pattern")"
  test -n "$point"
  timeout 15 adb shell input tap $point
}

trap capture_diagnostics EXIT
command -v tesseract >/dev/null

timeout 120 adb wait-for-device
for attempt in $(seq 1 30); do
  sdk_version="$(timeout 10 adb shell getprop ro.build.version.sdk 2>/dev/null | tr -d '\r' || true)"
  if [ "$sdk_version" = "36" ]; then break; fi
  if [ "$attempt" = "30" ]; then
    echo "Android 16 emulator did not return a stable SDK version." >&2
    exit 1
  fi
  sleep 2
done

stable_service_checks=0
sleep 15
for attempt in $(seq 1 120); do
  package_service="$(timeout 10 adb shell service check package 2>/dev/null | tr -d '\r' || true)"
  activity_service="$(timeout 10 adb shell service check activity 2>/dev/null | tr -d '\r' || true)"
  if printf '%s' "$package_service" | grep -Fq 'found' \
      && printf '%s' "$activity_service" | grep -Fq 'found' \
      && timeout 10 adb shell pm path android >/dev/null 2>&1; then
    stable_service_checks=$((stable_service_checks + 1))
    if [ "$stable_service_checks" -ge 3 ]; then break; fi
  else
    stable_service_checks=0
  fi
  if [ "$attempt" = "120" ]; then
    echo "Android 16 package and activity services did not become stable." >&2
    exit 1
  fi
  timeout 20 adb wait-for-device || true
  sleep 3
done

APK="dist/BilgiRotasi-${VERSION_LABEL}-closed-test-universal.apk"
test -s "$APK"
REMOTE_APK="/data/local/tmp/bilgirotasi-closed-test.apk"
for attempt in $(seq 1 3); do
  if timeout 300 adb push "$APK" "$REMOTE_APK"; then break; fi
  if [ "$attempt" = "3" ]; then
    echo "AAB-derived universal APK could not be transferred." >&2
    exit 1
  fi
  timeout 20 adb wait-for-device || true
  sleep 6
done

installed=false
for attempt in $(seq 1 3); do
  install_output="$(timeout 300 adb shell pm install -r "$REMOTE_APK" 2>&1 || true)"
  printf '%s\n' "$install_output"
  if printf '%s' "$install_output" | grep -Fq 'Success'; then
    installed=true
    break
  fi
  timeout 20 adb wait-for-device || true
  sleep 10
done
timeout 30 adb shell rm -f "$REMOTE_APK" || true
if [ "$installed" != true ]; then
  echo "AAB-derived universal APK could not be installed." >&2
  exit 1
fi

timeout 30 adb logcat -c
timeout 30 adb shell pm clear com.leventua.bilgirotasi
timeout 15 adb shell am force-stop com.leventua.bilgirotasi
timeout 30 adb shell am start -n com.leventua.bilgirotasi/.MainActivity

wait_for_word AUTH 'Google|Misafir'
grep -Eqi 'Google' reports/UI_AUTH.tsv
grep -Eqi 'Misafir' reports/UI_AUTH.tsv
! grep -Eqi 'Nas.*Oynan' reports/UI_AUTH.tsv

tap_word AUTH 'Misafir'
for attempt in $(seq 1 40); do
  capture_screen "HOME_${attempt}"
  if test -n "$(find_word "HOME_${attempt}" 'Oyna')"; then
    cp "reports/UI_HOME_${attempt}.png" reports/UI_HOME.png
    cp "reports/UI_HOME_${attempt}.tsv" reports/UI_HOME.tsv
    break
  fi
  guest_point="$(find_word "HOME_${attempt}" 'Misafir')"
  if test -n "$guest_point"; then
    timeout 15 adb shell input tap $guest_point
  fi
  if [ "$attempt" = "40" ]; then
    echo "Guest button did not reach the home screen." >&2
    exit 1
  fi
  sleep 3
done
grep -Eqi 'Oyna' reports/UI_HOME.tsv
! cmp -s reports/UI_AUTH.png reports/UI_HOME.png

capture_screen HOME_SETTINGS
settings_point="$(find_word HOME_SETTINGS 'Ayarlar')"
if test -n "$settings_point"; then
  timeout 15 adb shell input tap $settings_point
else
  # Pixel 2 API 36 profile is fixed at 1080x1920. Tesseract can misread the
  # stylized Ayarlar title even though the card is fully visible.
  timeout 15 adb shell input tap 540 1530
fi
wait_for_word SETTINGS 'Ayarlar'

tutorial_label=''
for attempt in $(seq 1 8); do
  capture_screen "SETTINGS_TUTORIAL_${attempt}"
  if test -n "$(find_word "SETTINGS_TUTORIAL_${attempt}" 'Yeniden')"; then
    tutorial_label="SETTINGS_TUTORIAL_${attempt}"
    break
  fi
  timeout 15 adb shell input swipe 540 1650 540 350 650
  sleep 2
done
test -n "$tutorial_label"
tap_word "$tutorial_label" 'Yeniden'
wait_for_word TUTORIAL_DIALOG 'Anlad'
! cmp -s reports/UI_SETTINGS.png reports/UI_TUTORIAL_DIALOG.png

tap_word TUTORIAL_DIALOG 'Anlad'
sleep 3
capture_screen TUTORIAL_CLOSED
! grep -Eqi 'Anlad' reports/UI_TUTORIAL_CLOSED.tsv
! cmp -s reports/UI_TUTORIAL_DIALOG.png reports/UI_TUTORIAL_CLOSED.png

capture_diagnostics
test -n "$(tr -d '\r\n' < reports/APP_PID.txt)"
grep -Fq 'com.leventua.bilgirotasi/.MainActivity' reports/ACTIVITY_STATE.txt
grep -Fq 'ResumedActivity' reports/ACTIVITY_STATE.txt
if grep -Eqi 'FATAL EXCEPTION.*com\.leventua\.bilgirotasi|ANR in com\.leventua\.bilgirotasi|Process com\.leventua\.bilgirotasi .*has died|Cmdline: com\.leventua\.bilgirotasi|MobileAdsInitProvider.*IllegalStateException' reports/COLD_START_LOGCAT.txt; then
  echo "Android 16 logcat contains an app crash or ANR." >&2
  exit 1
fi
if grep -Fq 'UserMessagingPlatform' reports/COLD_START_LOGCAT.txt; then
  echo "Android emulator unexpectedly started UMP." >&2
  exit 1
fi
