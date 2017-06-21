#!/bin/bash -eu

echo "${OPSMAN_SSH_KEY}" > opsman.pem
chmod 600 opsman.pem

. bbr-pcf-pipeline-tasks/scripts/export-director-metadata

sshuttle -e "ssh -i opsman.pem ubuntu@${OPSMAN_HOST}" 0/0 --daemon

pushd ert-backup-artifact
  ../binary/bbr deployment --target "${BOSH_ADDRESS}" \
  --username "${BOSH_CLIENT}" \
  --deployment "${ERT_DEPLOYMENT_NAME}" \
  --ca-cert "${BOSH_CA_CERT_PATH}" \
  backup --with-manifest

  tar -cvf ert-backup.tar -- *
popd