#!/bin/bash -eu

echo "${JUMPBOX_SSH_KEY}" > jumpbox.pem
chmod 600 jumpbox.pem
eval "$(ssh-agent)" && ssh-add jumpbox.pem

. $(dirname $0)/../../scripts/export-director-metadata

sshuttle -r "${JUMPBOX_USER}@${JUMPBOX_HOST}" 0/0 --daemon

pushd ert-backup-artifact
  ../binary/bbr deployment --target "${BOSH_ADDRESS}" \
  --username "${BOSH_CLIENT}" \
  --deployment "${ERT_DEPLOYMENT_NAME}" \
  --ca-cert "${BOSH_CA_CERT_PATH}" \
  backup --with-manifest

  tar -cvf ert-backup.tar -- *
popd