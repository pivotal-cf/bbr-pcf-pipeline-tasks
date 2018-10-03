#!/usr/bin/env bash

set -euo pipefail

ensure_pksapi_stopped() {
  output=$(bosh -d "$DEPLOYMENT_NAME" ssh -c 'sudo /var/vcap/bosh/bin/monit summary' | grep pks-api)
  until [[ $output == *"not monitored"* && $output != *"stop pending"* ]]; do
    echo "waiting"
    sleep 1
    output=$(bosh -d "$DEPLOYMENT_NAME" ssh -c 'sudo /var/vcap/bosh/bin/monit summary' | grep pks-api)
  done
}

scripts="$(dirname "$0")/../../scripts"

# shellcheck disable=SC1090
source "$scripts/export-director-metadata"
# shellcheck disable=SC1090
source "$scripts/export-pks-metadata"

bosh -d "$DEPLOYMENT_NAME" ssh -c "sudo /var/vcap/bosh/bin/monit stop pks-api"

ensure_pksapi_stopped