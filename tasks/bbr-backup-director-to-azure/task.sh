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

# get script and task root directories
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
ROOT=$DIR/../../..

# move om into the path
cp $ROOT/om/om-linux /usr/local/bin/om
chmod +x /usr/local/bin/om

source $ROOT/bbr-pipeline-tasks-repo/scripts/export-director-metadata

# add director IP to no_proxy if requested. this must follow export-director-metadata
[[ ",$no_proxy," != *",${BOSH_ENVIRONMENT},"* ]] \
&& [[ "$ADD_DIRECTOR_TO_NO_PROXY" == "true" ]] \
&& no_proxy="${BOSH_ENVIRONMENT},${no_proxy}"

# subshell trick to implement a try/catch style command.
# we always want to cleanup our mess so capture any error in the subshell.
# this will capture the error code in the subshell and if it is non zero, return a failure after cleanup
set +e
(
    # exit subshell on error
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

# capture subshell return code and go back to failing the script on error
return_code=$?
set -e

# always cleanup
echo "cleaning up backup"
rm -rf $ROOT/director-backup-artifact/*

# if return code from the subshell above was non zero
if [ $return_code -ne 0 ]; then
  # return the return code (this will fail the task)
  exit $return_code
fi