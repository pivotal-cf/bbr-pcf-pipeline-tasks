#!/usr/bin/env bash

set -eu

# shellcheck disable=SC1090
source "$(dirname "$0")/../../scripts/export-director-metadata"
# shellcheck disable=SC1090
source "$(dirname "$0")/../../scripts/export-cf-metadata"

pushd ert-backup-artifact
  ../binary/bbr deployment --target "$BOSH_ENVIRONMENT" \
    --username "$BOSH_CLIENT" \
    --deployment "$CF_DEPLOYMENT_NAME" \
    --ca-cert "$BOSH_CA_CERT_PATH" \
    backup --with-manifest

  tar -cvf ert-backup.tar -- *
popd
