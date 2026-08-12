#!/usr/bin/env bash
set -euo pipefail

apk_path="${1:-build/app/outputs/flutter-apk/app-release.apk}"
reports_dir="${REPORTS_DIR:-reports}"
startup_wait_seconds="${STARTUP_WAIT_SECONDS:-25}"
retry_wait_seconds="${RETRY_WAIT_SECONDS:-5}"
package_name='com.leventua.bilgirotasi'
activity_name="${package_name}/.MainActivity"

mkdir -p "$reports_dir"
rm -f "$reports_dir/ADMOB_ANDROID16_APP_GATE.txt" \
  "$reports_dir/ADMOB_ANDROID16_VALIDATION_RESULT.txt" \
  "$reports_dir/ADMOB_ANDROID16_EMULATOR_HEALTH.txt" \
  "$reports_dir/ADMOB_ANDROID16_INSTALL_ATTEMPTS.txt" \
  "$reports_dir/ADMOB_ANDROID16_COLD_START_LOG.txt" \
  "$reports_dir/ADMOB_ANDROID16_ACTIVITY_STATE.txt" \
  "$reports_dir/ADMOB_ANDROID16_APP_PID.txt"

adb_call() {
  local timeout_seconds="$1"
  shift
  if test -n "${ADB_FAKE_SCRIPT:-}"; then
    bash "$ADB_FAKE_SCRIPT" "$@"
  else
    timeout "$timeout_seconds" adb "$@"
  fi
}

capture_diagnostics() {
  adb_call 30 logcat -d \
    > "$reports_dir/ADMOB_ANDROID16_COLD_START_LOG.txt" 2>&1 || true
  adb_call 30 shell dumpsys activity activities \
    > "$reports_dir/ADMOB_ANDROID16_ACTIVITY_STATE.txt" 2>&1 || true
  adb_call 15 shell pidof "$package_name" \
    > "$reports_dir/ADMOB_ANDROID16_APP_PID.txt" 2>&1 || true
}

has_app_failure() {
  local log_file="$reports_dir/ADMOB_ANDROID16_COLD_START_LOG.txt"
  test -s "$log_file" || return 1
  if grep -Eqi \
      'ANR in com\.leventua\.bilgirotasi|Process com\.leventua\.bilgirotasi .*has died|Cmdline: com\.leventua\.bilgirotasi|MobileAdsInitProvider.*IllegalStateException' \
      "$log_file"; then
    return 0
  fi
  awk '
    /FATAL EXCEPTION/ { fatal_window = 12 }
    fatal_window > 0 && /Process: com\.leventua\.bilgirotasi/ { found = 1 }
    fatal_window > 0 { fatal_window-- }
    END { exit(found ? 0 : 1) }
  ' "$log_file"
}

is_infrastructure_failure_text() {
  grep -Eqi \
    "Failure calling service (package|activity)|Can't find service: (package|activity)|Broken pipe|device offline|no devices/emulators found|device .* not found|transport error|closed|protocol fault"
}

write_app_failure() {
  {
    echo 'RESULT=FAIL'
    echo 'RELEASE_GATE=FAIL'
    echo 'REASON=APPLICATION_CRASH_ANR_FATAL_OR_PROCESS_DEATH'
  } > "$reports_dir/ADMOB_ANDROID16_VALIDATION_RESULT.txt"
}

write_infrastructure_retry() {
  local reason="$1"
  {
    echo 'EMULATOR_HEALTH=UNHEALTHY'
    printf 'REASON=%s\n' "$reason"
  } > "$reports_dir/ADMOB_ANDROID16_EMULATOR_HEALTH.txt"
  {
    echo 'RESULT=INFRASTRUCTURE_RETRY_REQUIRED'
    echo 'RELEASE_GATE=FAIL'
    printf 'REASON=%s\n' "$reason"
  } > "$reports_dir/ADMOB_ANDROID16_VALIDATION_RESULT.txt"
}

fail_or_retry() {
  local infrastructure_reason="$1"
  local default_reason="$2"
  local evidence_file="${3:-}"
  capture_diagnostics
  if has_app_failure; then
    write_app_failure
    return 1
  fi
  if test -n "$evidence_file" \
      && test -s "$evidence_file" \
      && is_infrastructure_failure_text < "$evidence_file"; then
    write_infrastructure_retry "$infrastructure_reason"
    return 75
  fi
  {
    echo 'RESULT=FAIL'
    echo 'RELEASE_GATE=FAIL'
    printf 'REASON=%s\n' "$default_reason"
  } > "$reports_dir/ADMOB_ANDROID16_VALIDATION_RESULT.txt"
  return 1
}

test -s "$apk_path"

installed=false
install_infrastructure_failures=0
for attempt in 1 2 3; do
  set +e
  install_output="$(adb_call 180 install -r "$apk_path" 2>&1)"
  install_status="$?"
  set -e
  {
    printf 'ATTEMPT=%s STATUS=%s\n' "$attempt" "$install_status"
    printf '%s\n' "$install_output"
  } >> "$reports_dir/ADMOB_ANDROID16_INSTALL_ATTEMPTS.txt"
  if [ "$install_status" -eq 0 ] \
      && printf '%s' "$install_output" | grep -Fq 'Success'; then
    installed=true
    break
  fi
  if printf '%s\n' "$install_output" | is_infrastructure_failure_text; then
    install_infrastructure_failures=$((install_infrastructure_failures + 1))
  fi
  if [ "$attempt" -lt 3 ]; then
    adb_call 20 wait-for-device || true
    sleep "$retry_wait_seconds"
  fi
done

if [ "$installed" != true ]; then
  capture_diagnostics
  if has_app_failure; then
    write_app_failure
    exit 1
  fi
  if [ "$install_infrastructure_failures" -eq 3 ]; then
    write_infrastructure_retry 'ANDROID_PACKAGE_SERVICE_UNAVAILABLE'
    exit 75
  fi
  {
    echo 'RESULT=FAIL'
    echo 'RELEASE_GATE=FAIL'
    echo 'REASON=APK_INSTALL_FAILED_WITHOUT_INFRASTRUCTURE_EVIDENCE'
  } > "$reports_dir/ADMOB_ANDROID16_VALIDATION_RESULT.txt"
  exit 1
fi
echo 'APK_INSTALL=PASS' >> "$reports_dir/ADMOB_ANDROID16_APP_GATE.txt"

for command_name in clear_logcat force_stop launch; do
  command_failures="$reports_dir/ADMOB_ANDROID16_COMMAND_${command_name^^}_FAILURES.txt"
  rm -f "$command_failures"
  command_succeeded=false
  for attempt in 1 2 3; do
    case "$command_name" in
      clear_logcat)
        command_args=(logcat -c)
        ;;
      force_stop)
        command_args=(shell am force-stop "$package_name")
        ;;
      launch)
        command_args=(shell am start -W -n "$activity_name")
        ;;
    esac
    set +e
    command_output="$(adb_call 30 "${command_args[@]}" 2>&1)"
    command_status="$?"
    set -e
    if [ "$command_status" -eq 0 ]; then
      command_succeeded=true
      break
    fi
    {
      printf 'COMMAND=%s ATTEMPT=%s STATUS=%s\n' \
        "$command_name" "$attempt" "$command_status"
      printf '%s\n' "$command_output"
    } >> "$command_failures"
    if [ "$attempt" -lt 3 ]; then
      adb_call 20 wait-for-device || true
      sleep "$retry_wait_seconds"
    fi
  done
  if [ "$command_succeeded" != true ]; then
    if fail_or_retry \
        'ANDROID_ADB_OR_SYSTEM_SERVICE_UNAVAILABLE' \
        'APP_LAUNCH_COMMAND_FAILED_WITHOUT_INFRASTRUCTURE_EVIDENCE' \
        "$command_failures"; then
      exit 0
    else
      exit "$?"
    fi
  fi
done
echo 'APP_LAUNCH=PASS' >> "$reports_dir/ADMOB_ANDROID16_APP_GATE.txt"

sleep "$startup_wait_seconds"
capture_diagnostics
if has_app_failure; then
  write_app_failure
  exit 1
fi

app_pid="$(tr -d '\r\n' < "$reports_dir/ADMOB_ANDROID16_APP_PID.txt")"
if test -z "$app_pid" \
    || ! grep -Fq "$activity_name" \
      "$reports_dir/ADMOB_ANDROID16_ACTIVITY_STATE.txt" \
    || ! grep -Fq 'ResumedActivity' \
      "$reports_dir/ADMOB_ANDROID16_ACTIVITY_STATE.txt"; then
  if grep -Eqi \
      'Failure calling service|Broken pipe|device offline|Input dispatching timed out|ANR in (com\.(android|google)|system)' \
      "$reports_dir/ADMOB_ANDROID16_COLD_START_LOG.txt" \
      "$reports_dir/ADMOB_ANDROID16_ACTIVITY_STATE.txt"; then
    write_infrastructure_retry 'ANDROID_EMULATOR_RUNTIME_UNHEALTHY'
    exit 75
  fi
  {
    echo 'RESULT=FAIL'
    echo 'RELEASE_GATE=FAIL'
    echo 'REASON=MANDATORY_APP_GATE_INCOMPLETE'
  } > "$reports_dir/ADMOB_ANDROID16_VALIDATION_RESULT.txt"
  exit 1
fi

{
  echo 'APP_PID=PASS'
  echo 'APP_ACTIVITY=PASS'
  echo 'APP_LOGCAT=PASS'
  echo 'APP_GATE=PASS'
} >> "$reports_dir/ADMOB_ANDROID16_APP_GATE.txt"
{
  echo 'RESULT=PASS'
  echo 'RELEASE_GATE=PASS'
  echo 'APP_GATE=PASS'
} > "$reports_dir/ADMOB_ANDROID16_VALIDATION_RESULT.txt"
