#!/usr/bin/env bash
set -euo pipefail

scenario="${FAKE_ADB_SCENARIO:?FAKE_ADB_SCENARIO is required}"
command_line="$*"

if [ "$1" = "install" ]; then
  case "$scenario" in
    transient_infrastructure_install)
      state_file="${FAKE_ADB_STATE_DIR:?FAKE_ADB_STATE_DIR is required}/install_failed_once"
      if [ ! -f "$state_file" ]; then
        touch "$state_file"
        echo 'adb: failed to install app-release.apk: cmd: Failure calling service package: Broken pipe (32)' >&2
        exit 1
      fi
      echo 'Success'
      exit 0
      ;;
    infrastructure_install)
      echo 'adb: failed to install app-release.apk: cmd: Failure calling service package: Broken pipe (32)' >&2
      exit 1
      ;;
    missing_package_service)
      echo "adb: failed to install app-release.apk: cmd: Can't find service: package" >&2
      exit 1
      ;;
    invalid_apk)
      echo 'Failure [INSTALL_FAILED_INVALID_APK]' >&2
      exit 1
      ;;
    *)
      echo 'Success'
      exit 0
      ;;
  esac
fi

if [ "$command_line" = 'logcat -d' ]; then
  case "$scenario" in
    app_crash)
      cat <<'EOF'
08-11 12:00:00.000  1000  1000 E AndroidRuntime: FATAL EXCEPTION: main
08-11 12:00:00.001  1000  1000 E AndroidRuntime: Process: com.leventua.bilgirotasi, PID: 4242
08-11 12:00:00.002  1000  1000 E AndroidRuntime: java.lang.IllegalStateException: regression fixture
EOF
      ;;
    *)
      echo '08-11 12:00:00.000 4242 4242 I BilgiRotasi: cold start healthy'
      ;;
  esac
  exit 0
fi

if [ "$command_line" = 'shell pidof com.leventua.bilgirotasi' ]; then
  if [ "$scenario" != 'infrastructure_install' ] \
      && [ "$scenario" != 'missing_package_service' ] \
      && [ "$scenario" != 'invalid_apk' ]; then
    echo '4242'
  fi
  exit 0
fi

if [ "$command_line" = 'shell dumpsys activity activities' ]; then
  if [ "$scenario" != 'infrastructure_install' ] \
      && [ "$scenario" != 'missing_package_service' ] \
      && [ "$scenario" != 'invalid_apk' ]; then
    echo 'ResumedActivity: ActivityRecord com.leventua.bilgirotasi/.MainActivity'
  fi
  exit 0
fi

if [ "$command_line" = 'shell am start -W -n com.leventua.bilgirotasi/.MainActivity' ]; then
  echo 'Starting: Intent { cmp=com.leventua.bilgirotasi/.MainActivity }'
fi

exit 0
