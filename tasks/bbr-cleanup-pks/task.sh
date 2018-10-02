#!/usr/bin/env bash

set -eu

# shellcheck disable=SC1090
source "$(dirname "$0")/../../scripts/export-director-metadata"
# shellcheck disable=SC1090
source "$(dirname "$0")/../../scripts/export-pks-metadata"

# shellcheck disable=SC1090
source "$(dirname "$0")/../../scripts/deployment-backup-cleanup"