#!/usr/bin/env bash
set -euo pipefail

source_script="tools/qa_runtime/word_hunt_v6_completion_result_android16_reuse.sh"
retry_script="/tmp/word_hunt_v6_completion_compact_runtime_retry.sh"
test -s "$source_script"

python3 - "$source_script" "$retry_script" <<'PY'
from pathlib import Path
import sys

source = Path(sys.argv[1])
out = Path(sys.argv[2])
text = source.read_text(encoding='utf-8')
old = '''  adb logcat -c
  adb shell input tap "$x" "$y"
  wait_marker "[COMP_QA_STATE] level=$level cells=64 targets=0 bonus=0 dialog=0"
  wait_marker "[COMP_QA_CELL] level=$level row=7 col=7 "
'''
new = '''  adb logcat -c
  local opened=0 attempt probe
  for attempt in 1 2 3; do
    adb shell input tap "$x" "$y"
    for probe in $(seq 1 16); do
      if has_marker "[COMP_QA_OPEN] level=$level"; then
        opened=1
        break
      fi
      sleep 0.25
    done
    if [ "$opened" -eq 1 ]; then
      break
    fi
    sleep 0.6
  done
  if [ "$opened" -ne 1 ]; then
    capture "OPEN_LEVEL_${level}_FAILED.png"
    adb logcat -d > "$REPORT_DIR/OPEN_LEVEL_${level}_FAILED_LOGCAT.txt"
    echo "Level $level tap did not reach callback after retries." >&2
    return 1
  fi
  wait_marker "[COMP_QA_STATE] level=$level cells=64 targets=0 bonus=0 dialog=0"
  wait_marker "[COMP_QA_CELL] level=$level row=7 col=7 "
'''
count = text.count(old)
if count != 1:
    raise SystemExit(f'open_level patch target count={count}')
out.write_text(text.replace(old, new), encoding='utf-8')
PY

bash -n "$retry_script"
bash "$retry_script"
