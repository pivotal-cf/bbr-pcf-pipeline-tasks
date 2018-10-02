#!/usr/bin/env bash

set -eu

# shellcheck disable=SC1090
source "$(dirname "$0")/../../scripts/export-director-metadata"
# shellcheck disable=SC1090
source "$(dirname "$0")/../../scripts/export-pks-metadata"

pushd pks-backup-artifact
  # shellcheck disable=SC1090
  source "$(dirname "$0")/../../scripts/deployment-backup"
  tar -cvf pks-backup.tar -- *
popd
