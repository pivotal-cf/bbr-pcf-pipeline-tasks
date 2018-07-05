#!/bin/bash -eu

. "$(dirname $0)"/../../scripts/export-director-metadata


./binary/bbr director --host "${BOSH_ADDRESS}" \
--username bbr \
--private-key-path <(echo "${BBR_PRIVATE_KEY}") \
backup-cleanup
