#!/usr/bin/env bash

set -eu

scripts="$( dirname "$0" )/../../scripts"

# shellcheck disable=SC1090
source "${scripts}/export-director-metadata"
# shellcheck disable=SC1090
source "${scripts}/export-cf-metadata"

current_date="$( date +"%Y-%m-%d-%H-%M-%S" )"

pushd pas-backup-artifact
  # shellcheck disable=SC1090
  source "../${scripts}/deployment-backup"
  tar -cvf "pas-backup_${current_date}.tar" --remove-files -- */*
popd

