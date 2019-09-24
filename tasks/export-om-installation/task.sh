#!/bin/bash

set -eu

# shellcheck disable=SC1090
source "$(dirname "$0")/../../scripts/om-cmd"

current_date="$( date +"%Y-%m-%d-%H-%M-%S" )"

om_cmd --request-timeout 7200 export-installation --output-file "om-installation/installation_${current_date}.zip"
