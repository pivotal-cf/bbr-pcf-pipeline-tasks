#!/usr/bin/env bash

set -eu

# shellcheck disable=SC1090
source "$(dirname "$0")/../../scripts/export-director-metadata"

pushd director-backup-artifact
  ../binary/bbr director --host "${BOSH_ENVIRONMENT}" \
    --username "$BOSH_USERNAME" \
    --private-key-path <(echo "${BOSH_PRIVATE_KEY}") \
    backup

  tar -cvf director-backup.tar --remove-files -- */*
  # shellcheck disable=SC2086
popd
