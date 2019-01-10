#!/bin/bash

set -eu

# get script and task root directories
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
ROOT="$( relpath $DIR/../../.. )"

# move om into the path
cp $ROOT/om/om-linux /usr/local/bin/om
chmod +x /usr/local/bin/om

# shellcheck disable=SC1090
source bbr-pipeline-tasks-repo/scripts/om-cmd

export BACKUP_FILE_DIRECTORY=$ROOT/om-installation
export BACKUP_FILE_PATH=$BACKUP_FILE_DIRECTORY/installation.zip

mkdir -p $BACKUP_FILE_DIRECTORY
echo "exporting director installation"
om_cmd --request-timeout 7200 export-installation --output-file $BACKUP_FILE_PATH

echo "uploading backup to azure"
az storage blob upload \
    --file "$BACKUP_FILE_PATH" \
    --container-name "$AZURE_STORAGE_CONTAINER" \
    --name "$AZURE_STORAGE_VERSIONED_FILE"   

echo "cleaning up backup"    
rm -rf $BACKUP_FILE_PATH