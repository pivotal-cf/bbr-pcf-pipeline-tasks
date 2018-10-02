#!/usr/bin/env bash

set -eu

scripts="$(dirname "$0")/../../scripts"


# shellcheck disable=SC1090
source "$scripts/export-director-metadata"
# shellcheck disable=SC1090
source "$scripts/export-pks-metadata"

# shellcheck disable=SC1090
source "$scripts/deployment-backup-cleanup"