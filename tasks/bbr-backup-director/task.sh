#!/bin/bash -eu

. "$(dirname $0)"/../../scripts/export-director-metadata

om_cmd curl -p /api/v0/deployed/director/credentials/bbr_ssh_credentials > bbr_keys.json
BOSH_PRIVATE_KEY=$(jq -r '.credential.value.private_key_pem' bbr_keys.json)

pushd director-backup-artifact
  ../binary/bbr director --host "${BOSH_ADDRESS}" \
  --username bbr \
  --private-key-path <(echo "${BBR_PRIVATE_KEY}") \
  backup

  tar -cvf director-backup.tar -- *
  rm -rf ${BOSH_ADDRESS}_*
popd
