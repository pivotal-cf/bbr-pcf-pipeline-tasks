#!/bin/bash

set -e

function backup_director(){
    set +e
    (
        set -e
        try_backup_director
    )
    return_code=$?
    if [ $return_code -ne 0 ]; then
        cleanup_director
    fi
    set -e
    return $return_code
}

function try_backup_director(){
    echo "backing up director"
    $ROOT/binary/bbr director --host "${BOSH_ENVIRONMENT}" \
        --username "$BOSH_USERNAME" \
        --private-key-path <(echo "${BOSH_PRIVATE_KEY}") \
        backup            
}

function cleanup_backup(){
    echo "cleaning up backup"
    $ROOT/binary/bbr director --host "${BOSH_ENVIRONMENT}" \
        --username "$BOSH_USERNAME" \
        --private-key-path <(echo "${BOSH_PRIVATE_KEY}") \
        backup-cleanup 
}

function upload_to_azure(){
    echo "uploading backup to azure"
    export FILE_TO_UPLOAD=$ROOT/director-backup-artifact/director-backup.tgz

    az storage blob upload \
        --file "$FILE_TO_UPLOAD" \
        --container-name "$AZURE_STORAGE_CONTAINER" \
        --name "$AZURE_STORAGE_VERSIONED_FILE"        
}

# get script directory
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
ROOT=$DIR/../../..

# move om into the path
cp $ROOT/om/om-linux /usr/local/bin/om
chmod +x /usr/local/bin/om

source $ROOT/bbr-pipeline-tasks-repo/scripts/export-director-metadata

set +e
(
    set -e
    mkdir -p $ROOT/director-backup-artifact
    pushd $ROOT/director-backup-artifact

        # call backup director function
        backup_director   

        echo "compressing backup"
        tar -cvzf director-backup.tgz -- *

    popd

    upload_to_azure
)

return_code=$?
set -e

# always cleanup
echo "cleaning up backup"
rm -rf $ROOT/director-backup-artifact

if [ $return_code -ne 0 ]; then
  exit $return_code
fi
