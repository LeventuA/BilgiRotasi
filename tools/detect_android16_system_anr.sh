#!/usr/bin/env bash
set -euo pipefail

tsv_path="${1:?TSV path required}"
reports_dir="${2:-reports}"
test -s "$tsv_path"

# Tesseract stores each recognized word on a separate TSV row. Reconstruct the
# visible sentence before matching Android system ANR dialogs.
screen_text="$(
  awk -F '\t' '
    NR > 1 && $12 != "" {
      if (seen) printf " "
      printf "%s", $12
      seen = 1
    }
    END { print "" }
  ' "$tsv_path"
)"

if ! printf '%s\n' "$screen_text" \
    | grep -Eqi '(System[[:space:]]+UI|Process[[:space:]]+system).{0,40}(isn.?t|not).{0,20}responding'; then
  exit 1
fi

# One isolated Android system ANR is tolerated. If another system-only ANR is
# observed in the same validation attempt, the emulator is demonstrably
# unstable. Keep this cumulative across clean/blank OCR frames so a transient
# frame cannot erase already-observed infrastructure evidence.
mkdir -p "$reports_dir"
observed_before=0
if test -s "$reports_dir/SYSTEM_ANR_DISMISSED.txt"; then
  observed_before="$(
    grep -Fc 'Android system ANR dialog observed.' \
      "$reports_dir/SYSTEM_ANR_DISMISSED.txt" || true
  )"
fi

if [ "$observed_before" -ge 1 ]; then
  {
    echo 'EMULATOR_HEALTH=UNHEALTHY'
    echo 'REASON=RECURRING_ANDROID_SYSTEM_ANR'
  } > "$reports_dir/ANDROID16_EMULATOR_HEALTH.txt"
fi

exit 0
