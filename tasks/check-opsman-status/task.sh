#!/usr/bin/env bash

set -euo pipefail

scripts="$(dirname "$0")/../../scripts"

# shellcheck source=../../scripts/om-cmd
source "${scripts}/om-cmd" > /dev/null

status="$(om_cmd installations --format json | jq .[0].status)"
trimmed_status="$(xargs <<< "$status")"

if [ "$trimmed_status" == "running" ]; then
  echo "\"Apply Changes\" is in flight." | tee /dev/stderr
  exit 1
fi

echo "No \"Apply Changes\" in flight."
