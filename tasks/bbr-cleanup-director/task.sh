#!/usr/bin/env bash

set -eu

# shellcheck disable=SC1090
source "$(dirname "$0")/../../scripts/export-director-metadata"

./binary/bbr director --host "${BOSH_ENVIRONMENT}" \
  --username "$BOSH_USERNAME" \
  --private-key-path <(echo "${BOSH_PRIVATE_KEY}") \
  backup-cleanup
