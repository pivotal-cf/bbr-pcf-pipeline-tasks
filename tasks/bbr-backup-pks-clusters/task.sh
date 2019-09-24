#!/usr/bin/env bash

set -eu

scripts="$( dirname "$0" )/../../scripts"

# shellcheck disable=SC1090
source "${scripts}/export-director-metadata"
# shellcheck disable=SC1090
source "${scripts}/export-pks-metadata"

current_date="$( date +"%Y-%m-%d-%H-%M-%S" )"

pushd pks-clusters-backup-artifact
  # shellcheck disable=SC1090

  ../binary/bbr deployment --target "$BOSH_ENVIRONMENT" \
    --username "$BOSH_TEAM_CLIENT" \
    --password "$BOSH_TEAM_CLIENT_SECRET" \
    --ca-cert "$BOSH_CA_CERT_PATH" \
    --all-deployments \
    backup --with-manifest

  tar -cvf "pks-clusters-backup_${current_date}.tar" --remove-files -- */*
popd
