#!/usr/bin/env bash

set -euo pipefail

ensure_pksapi_started() {
  output=$(bosh -d "$DEPLOYMENT_NAME" ssh -c 'sudo /var/vcap/bosh/bin/monit summary' | grep pks-api)
  until [[ $output == *"running"* ]]; do
    echo "waiting"
    sleep 1
    output=$(bosh -d "$DEPLOYMENT_NAME" ssh -c 'sudo /var/vcap/bosh/bin/monit summary' | grep pks-api)
  done
}
# timeout is a command and executed as a subprocess, so ensure_pksapi_started must be exported
export -f ensure_pksapi_started

scripts="$(dirname "$0")/../../scripts"

# shellcheck disable=SC1090
source "$scripts/export-director-metadata"
# shellcheck disable=SC1090
source "$scripts/export-pks-metadata"

bosh -d "$DEPLOYMENT_NAME" ssh -c "sudo /var/vcap/bosh/bin/monit start pks-api"

TIMEOUT=60

if timeout "$TIMEOUT" bash -c ensure_pksapi_started
then
  echo "PKS API has been started"
else
  echo "Timed out starting PKS API after $TIMEOUT seconds"
  exit 1
fi