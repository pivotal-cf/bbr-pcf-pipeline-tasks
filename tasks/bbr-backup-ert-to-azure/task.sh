#!/bin/bash

set -e 

# get script directory
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

# copy om into the path
cp om/om-linux /usr/local/bin/om
chmod +x /usr/local/bin/om

source $DIR/bbr-pipeline-tasks-repo/scripts/export-director-metadata
source $DIR/bbr-pipeline-tasks-repo/scripts/export-cf-metadata

(
    mkdir -p $DIR/ert-backup-artifact
    pushd $DIR/ert-backup-artifact

        # call backup_pas function
        backup_pas 

        echo "compressing backup"
        tar -cvzf ert-backup.tgz -- *

    popd

    echo "uploading backup to azure"
    export FILE_TO_UPLOAD=$DIR/ert-backup-artifact/ert-backup.tgz

    az storage blob upload \
        --file "$FILE_TO_UPLOAD" \
        --container-name "$AZURE_STORAGE_CONTAINER" \
        --name "$AZURE_STORAGE_VERSIONED_FILE"        
)

return_code=$?
set -e

# always cleanup
echo "cleaning up backup"
rm -rf $DIR/ert-backup-artifact

if [ $return_code -ne 0 ]; then
  exit $return_code
fi

function backup_pas(){
    set +x
    (
        try_backup_pas
    )
    return_code=$?
    if [ $return_code -ne 0 ]; then
        cleanup_pas_backup
    fi
    set -x
}

function try_backup_pas(){
    echo "backing up deployment"
    source $DIR/bbr-pipeline-tasks-repo/scripts/deployment-backup
}

function cleanup_pas_backup(){
    echo "cleaning up backup"
    $DIR/binary/bbr deployment --target "$BOSH_ENVIRONMENT" \
        --username "$BOSH_CLIENT" \
        --deployment "$DEPLOYMENT_NAME" \
        --ca-cert "$BOSH_CA_CERT_PATH" \
    backup-cleanup
}