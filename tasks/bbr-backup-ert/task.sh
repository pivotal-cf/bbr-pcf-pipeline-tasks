#!/bin/bash

set -eu

# shellcheck disable=SC1090
source "$(dirname "$0")"/../../scripts/export-director-metadata

if [ ! -z "$OPSMAN_PRIVATE_KEY" ]; then
  echo -e "$OPSMAN_PRIVATE_KEY" > "${PWD}/ssh.key"
  chmod 0600 "${PWD}/ssh.key"
  opsman_private_key_path="${PWD}/ssh.key"
  opsman_host="$(basename "$OPSMAN_URL")"
  export BOSH_ALL_PROXY="ssh+socks5://ubuntu@${opsman_host}:22?private-key=${opsman_private_key_path}"
  echo "Using BOSH_ALL_PROXY"
fi

pushd ert-backup-artifact
  ../binary/bbr deployment --target "$BOSH_ADDRESS" \
    --username "$BOSH_CLIENT" \
    --deployment "$ERT_DEPLOYMENT_NAME" \
    --ca-cert "$BOSH_CA_CERT_PATH" \
    backup --with-manifest

  tar -cvf ert-backup.tar -- *
popd
