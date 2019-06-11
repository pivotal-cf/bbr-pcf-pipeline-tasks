#!/usr/bin/env bash

set -euo pipefail

scripts="$(dirname "$0")/../../scripts"

# shellcheck source=../../scripts/om-cmd
source "${scripts}/om-cmd"

status="$(om_cmd installations --format json | jq .[0].status)"
trimmed_status="$(xargs <<< "$status")"

if [ "$trimmed_status" == "running" ]; then
  echo "\"Apply Changes\" is in flight." 2>&1
  exit 1
fi

echo "No \"Apply Changes\" in flight."
