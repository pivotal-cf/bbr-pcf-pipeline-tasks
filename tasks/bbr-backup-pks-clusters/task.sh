#!/usr/bin/env bash

set -eu

scripts="$(dirname "$0")/../../scripts"

# shellcheck disable=SC1090
source "$scripts/export-director-metadata"
# shellcheck disable=SC1090
source "$scripts/export-pks-metadata"


pushd pks-clusters-backup-artifact
  # shellcheck disable=SC1090
  source "../$scripts/all-deployment-backup"
  tar -cvf pks-clusters-backup.tar -- *
popd
