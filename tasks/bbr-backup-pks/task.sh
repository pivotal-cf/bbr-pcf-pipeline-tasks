#!/usr/bin/env bash

set -eu

scripts="$( dirname "$0" )/../../scripts"

# shellcheck disable=SC1090
source "${scripts}/export-director-metadata"
# shellcheck disable=SC1090
source "${scripts}/export-pks-metadata"

current_date="$( date +"%Y-%m-%d-%H-%M-%S" )"

pushd pks-backup-artifact
  # shellcheck disable=SC1090
  source "../${scripts}/deployment-backup"
  tar -cvf "pks-backup_${current_date}.tar" --remove-files -- */*
popd
