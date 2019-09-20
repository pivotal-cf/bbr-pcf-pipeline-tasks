#!/usr/bin/env bash

set -eu

scripts="$(dirname "$0")/../../scripts"

# shellcheck disable=SC1090
source "$scripts/export-director-metadata"
# shellcheck disable=SC1090
source "$scripts/export-cf-metadata"

pushd pas-backup-artifact
  # shellcheck disable=SC1090
  source "../$scripts/deployment-backup"
  tar -cvf pas-backup.tar --remove-files -- */*
popd

