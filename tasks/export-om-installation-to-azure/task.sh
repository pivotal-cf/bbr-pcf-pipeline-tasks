#!/bin/bash

set -eu

cp om/om-linux /usr/local/bin/om
chmod +x /usr/local/bin/om

# shellcheck disable=SC1090
source bbr-pipeline-tasks-repo/scripts/om-cmd

echo "exporting director installation"
om_cmd --request-timeout 7200 export-installation --output-file om-installation/installation.zip

echo "uploading backup to azure"
export FILE_TO_UPLOAD=director-backup-artifact/director-backup.tgz

az storage blob upload \
    --file "$FILE_TO_UPLOAD" \
    --container-name "$AZURE_STORAGE_CONTAINER" \
    --name "$AZURE_STORAGE_VERSIONED_FILE"   

echo "cleaning up backup"    
rm -rf om-installation/installation.zip