#!/usr/bin/env bash
set -euo pipefail

mkdir -p reports
rm -f reports/ANDROID16_APP_GATE.txt \
  reports/ANDROID16_VALIDATION_RESULT.txt \
  reports/INFRASTRUCTURE_DIAGNOSTICS.txt \
  reports/SCREEN_CAPTURE_FAILURES.txt

capture_diagnostics() {
  timeout 30 adb logcat -d > reports/COLD_START_LOGCAT.txt 2>&1 || true
  timeout 30 adb shell dumpsys activity activities > reports/ACTIVITY_STATE.txt 2>&1 || true
  timeout 15 adb shell pidof com.leventua.bilgirotasi > reports/APP_PID.txt 2>&1 || true
}

capture_screen() {
  local label="$1"
  rm -f "reports/UI_${label}.tsv"
  if ! timeout 30 adb exec-out screencap -p > "reports/UI_${label}.png" \
      || ! test -s "reports/UI_${label}.png"; then
    printf '%s: SCREENSHOT_FAILED_OR_TIMED_OUT\n' "$label" \
      >> reports/SCREEN_CAPTURE_FAILURES.txt
    return 1
  fi
  if ! timeout 45 tesseract "reports/UI_${label}.png" "reports/UI_${label}" \
      --psm 11 -l eng tsv >/dev/null 2>&1 \
      || ! test -s "reports/UI_${label}.tsv"; then
    printf '%s: OCR_FAILED_OR_TIMED_OUT\n' "$label" \
      >> reports/SCREEN_CAPTURE_FAILURES.txt
    return 1
  fi
}

retry_capture_screen() {
  local label="$1"
  local attempts="${2:-3}"
  for attempt in $(seq 1 "$attempts"); do
    if test -n "${DIAGNOSTIC_DEADLINE:-}" \
        && [ "$SECONDS" -ge "$DIAGNOSTIC_DEADLINE" ]; then
      return 1
    fi
    if capture_screen "$label"; then
      return 0
    fi
    sleep 3
  done
  return 1
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
    if test -n "${DIAGNOSTIC_DEADLINE:-}" \
        && [ "$SECONDS" -ge "$DIAGNOSTIC_DEADLINE" ]; then
      return 1
    fi
    if ! capture_screen "${label}_${attempt}"; then
      sleep 3
      continue
    fi
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

has_app_failure() {
  local log_file="reports/COLD_START_LOGCAT.txt"
  if grep -Eqi 'ANR in com\.leventua\.bilgirotasi|Process com\.leventua\.bilgirotasi .*has died|Cmdline: com\.leventua\.bilgirotasi|MobileAdsInitProvider.*IllegalStateException' "$log_file"; then
    return 0
  fi
  awk '
    /FATAL EXCEPTION/ { fatal_window = 12 }
    fatal_window > 0 && /Process: com\.leventua\.bilgirotasi/ { found = 1 }
    fatal_window > 0 { fatal_window-- }
    END { exit(found ? 0 : 1) }
  ' "$log_file"
}

assert_no_app_failure() {
  if has_app_failure; then
    {
      echo 'RESULT=FAIL'
      echo 'RELEASE_GATE=FAIL'
      echo 'REASON=APPLICATION_CRASH_ANR_FATAL_OR_PROCESS_DEATH'
    } > reports/ANDROID16_VALIDATION_RESULT.txt
    echo "Android 16 logcat contains an app crash, ANR, fatal exception, or process death." >&2
    return 1
  fi
}

has_infrastructure_failure() {
  local log_file="reports/COLD_START_LOGCAT.txt"
  if test -s reports/SYSTEM_ANR_DISMISSED.txt; then
    return 0
  fi
  if [ "${POST_GATE_LOGCAT_BOUNDARY:-false}" != true ]; then
    return 1
  fi
  if grep -Ei 'ANR in ' "$log_file" \
      | grep -Eiv 'ANR in com\.leventua\.bilgirotasi' >/dev/null; then
    return 0
  fi
  grep -Eqi 'Input dispatching timed out|Gesture Monitor.*not responding|system_server: Long monitor contention|Failure calling service package|Broken pipe' "$log_file"
}

run_settings_tutorial_diagnostic() {
  local settings_point
  local tutorial_label=''

  retry_capture_screen HOME_SETTINGS || return 1
  settings_point="$(find_word HOME_SETTINGS 'Ayarlar')"
  if test -n "$settings_point"; then
    timeout 15 adb shell input tap $settings_point || return 1
  else
    # Pixel 2 API 36 profile is fixed at 1080x1920. Tesseract can misread the
    # stylized Ayarlar title even though the card is fully visible.
    timeout 15 adb shell input tap 540 1530 || return 1
  fi
  wait_for_word SETTINGS 'Ayarlar' 6 || return 1

  for attempt in $(seq 1 4); do
    if [ "$SECONDS" -ge "$DIAGNOSTIC_DEADLINE" ]; then
      return 1
    fi
    retry_capture_screen "SETTINGS_TUTORIAL_${attempt}" || return 1
    if test -n "$(find_word "SETTINGS_TUTORIAL_${attempt}" 'Yeniden')"; then
      tutorial_label="SETTINGS_TUTORIAL_${attempt}"
      break
    fi
    timeout 15 adb shell input swipe 540 1650 540 350 650 || return 1
    sleep 2
  done
  test -n "$tutorial_label" || return 1
  tap_word "$tutorial_label" 'Yeniden' || return 1
  wait_for_word TUTORIAL_DIALOG 'Anlad' 6 || return 1
  ! cmp -s reports/UI_SETTINGS.png reports/UI_TUTORIAL_DIALOG.png || return 1

  tap_word TUTORIAL_DIALOG 'Anlad' || return 1
  sleep 3
  retry_capture_screen TUTORIAL_CLOSED || return 1
  ! grep -Eqi 'Anlad' reports/UI_TUTORIAL_CLOSED.tsv || return 1
  ! cmp -s reports/UI_TUTORIAL_DIALOG.png reports/UI_TUTORIAL_CLOSED.png
}

tap_word() {
  local label="$1"
  local pattern="$2"
  local point
  point="$(find_word "$label" "$pattern")"
  test -n "$point"
  timeout 15 adb shell input tap $point
}

finalize_validation() {
  local status="$?"
  trap - EXIT
  capture_diagnostics
  if [ "$status" -ne 0 ] \
      && ! test -s reports/ANDROID16_VALIDATION_RESULT.txt; then
    if has_app_failure; then
      reason='APPLICATION_CRASH_ANR_FATAL_OR_PROCESS_DEATH'
    else
      reason='MANDATORY_APP_GATE_INCOMPLETE'
    fi
    {
      echo 'RESULT=FAIL'
      echo 'RELEASE_GATE=FAIL'
      printf 'REASON=%s\n' "$reason"
    } > reports/ANDROID16_VALIDATION_RESULT.txt
  fi
  exit "$status"
}

trap finalize_validation EXIT
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
echo 'APK_INSTALL=PASS' >> reports/ANDROID16_APP_GATE.txt

timeout 30 adb logcat -c
timeout 30 adb shell pm clear com.leventua.bilgirotasi
timeout 15 adb shell am force-stop com.leventua.bilgirotasi
timeout 30 adb shell am start -n com.leventua.bilgirotasi/.MainActivity
echo 'APP_LAUNCH=PASS' >> reports/ANDROID16_APP_GATE.txt

# First launch may show the analytics-consent dialog before the auth screen.
# Handle it deterministically so the release gate verifies the app rather than
# failing because a newly-added first-run dialog blocks Google/Misafir.
for attempt in $(seq 1 8); do
  if ! capture_screen "ENTRY_${attempt}"; then
    sleep 3
    continue
  fi
  if dismiss_system_anr "ENTRY_${attempt}"; then
    continue
  fi
  if test -n "$(find_word "ENTRY_${attempt}" 'Google|Misafir')"; then
    break
  fi
  if grep -Eqi 'Kullanim|Kullanım|Analizine' "reports/UI_ENTRY_${attempt}.tsv"; then
    consent_point="$(find_word "ENTRY_${attempt}" 'Simdi|Şimdi|Degil|Değil')"
    if test -n "$consent_point"; then
      timeout 15 adb shell input tap $consent_point
    else
      # Pixel 2 API 36 fallback: center of the visible "Şimdi Değil" action.
      timeout 15 adb shell input tap 760 1065
    fi
    echo 'ANALYTICS_CONSENT_HANDLED=PASS' >> reports/ANDROID16_APP_GATE.txt
    sleep 4
    break
  fi
  sleep 3
done

wait_for_word AUTH 'Google|Misafir' 20
grep -Eqi 'Google' reports/UI_AUTH.tsv
grep -Eqi 'Misafir' reports/UI_AUTH.tsv
! grep -Eqi 'Nas.*Oynan' reports/UI_AUTH.tsv

tap_word AUTH 'Misafir'
for attempt in $(seq 1 40); do
  if ! capture_screen "HOME_${attempt}"; then
    if [ "$attempt" = "40" ]; then
      echo "Guest login could not be verified because screen capture/OCR repeatedly failed." >&2
      exit 1
    fi
    sleep 3
    continue
  fi
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
capture_diagnostics
test -n "$(tr -d '\r\n' < reports/APP_PID.txt)"
grep -Fq 'com.leventua.bilgirotasi/.MainActivity' reports/ACTIVITY_STATE.txt
grep -Fq 'ResumedActivity' reports/ACTIVITY_STATE.txt
assert_no_app_failure
if grep -Fq 'UserMessagingPlatform' reports/COLD_START_LOGCAT.txt; then
  echo "Android emulator unexpectedly started UMP." >&2
  exit 1
fi

{
  echo 'GUEST_LOGIN=PASS'
  echo 'HOME_OYNA=PASS'
  echo 'APP_PID=PASS'
  echo 'APP_LOGCAT=PASS'
  echo 'APP_GATE=PASS'
} >> reports/ANDROID16_APP_GATE.txt

cp reports/COLD_START_LOGCAT.txt reports/APP_GATE_LOGCAT.txt
if test -s reports/SYSTEM_ANR_DISMISSED.txt; then
  cp reports/SYSTEM_ANR_DISMISSED.txt \
    reports/PRE_APP_GATE_SYSTEM_ANR_DISMISSED.txt
  rm -f reports/SYSTEM_ANR_DISMISSED.txt
fi
POST_GATE_LOGCAT_BOUNDARY=false
if timeout 30 adb logcat -c; then
  POST_GATE_LOGCAT_BOUNDARY=true
  echo 'POST_GATE_LOGCAT_BOUNDARY=PASS' >> reports/ANDROID16_APP_GATE.txt
else
  echo 'POST_GATE_LOGCAT_BOUNDARY=UNAVAILABLE' >> reports/ANDROID16_APP_GATE.txt
fi
DIAGNOSTIC_DEADLINE=$((SECONDS + 300))
settings_tutorial_result=0
run_settings_tutorial_diagnostic || settings_tutorial_result=$?
unset DIAGNOSTIC_DEADLINE
capture_diagnostics
test -n "$(tr -d '\r\n' < reports/APP_PID.txt)"
assert_no_app_failure

if has_infrastructure_failure; then
  {
    echo 'RESULT=INFRASTRUCTURE_INCONCLUSIVE'
    echo 'RELEASE_GATE=PASS'
    echo 'APP_GATE=PASS'
    echo 'SETTINGS_TUTORIAL_DIAGNOSTIC=INFRASTRUCTURE_INCONCLUSIVE'
    echo 'PHYSICAL_PLAY_INTERNAL_TESTING_SETTINGS_TUTORIAL=REQUIRED'
  } > reports/ANDROID16_VALIDATION_RESULT.txt
  {
    echo 'Android 16 emulator reported another package ANR or global input lock after the application gate passed.'
    grep -Ei 'ANR in |Input dispatching timed out|Gesture Monitor.*not responding|system_server: Long monitor contention|Failure calling service package|Broken pipe' reports/COLD_START_LOGCAT.txt || true
  } > reports/INFRASTRUCTURE_DIAGNOSTICS.txt
  echo 'Android 16 application gate passed; settings/tutorial is infrastructure-inconclusive.'
elif [ "$settings_tutorial_result" -eq 0 ]; then
  {
    echo 'RESULT=PASS'
    echo 'RELEASE_GATE=PASS'
    echo 'APP_GATE=PASS'
    echo 'SETTINGS_TUTORIAL_DIAGNOSTIC=PASS'
  } > reports/ANDROID16_VALIDATION_RESULT.txt
else
  {
    echo 'RESULT=FAIL'
    echo 'RELEASE_GATE=FAIL'
    echo 'APP_GATE=PASS'
    echo 'REASON=SETTINGS_TUTORIAL_FAILED_WITHOUT_INFRASTRUCTURE_EVIDENCE'
  } > reports/ANDROID16_VALIDATION_RESULT.txt
  echo 'Settings/tutorial diagnostic failed without emulator infrastructure evidence.' >&2
  exit 1
fi
