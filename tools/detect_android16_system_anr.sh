#!/usr/bin/env bash
set -euo pipefail

tsv_path="${1:?TSV path required}"
test -s "$tsv_path"

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

printf '%s\n' "$screen_text" \
  | grep -Eqi '(System[[:space:]]+UI|Process[[:space:]]+system).{0,40}(isn.?t|not).{0,20}responding'
