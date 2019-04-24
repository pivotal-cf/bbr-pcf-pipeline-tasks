#!/usr/bin/env bash

set -eu

scripts="$(dirname "$0")/../../scripts"

# shellcheck disable=SC1090
source "$scripts/export-director-metadata"
# shellcheck disable=SC1090
source "$scripts/export-pks-metadata"

pushd pks-backup-artifact
  # shellcheck disable=SC1090
  source "../$scripts/deployment-backup"
  tar -cvf pks-backup.tar --remove-files -- *
popd
