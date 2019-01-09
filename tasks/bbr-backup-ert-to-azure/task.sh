#!/bin/bash

set -e 

function backup_pas(){
    set +e
    (
        try_backup_pas
    )
    return_code=$?
    if [ $return_code -ne 0 ]; then
        cleanup_pas_backup
    fi
    set -e
}

function try_backup_pas(){
    echo "backing up deployment"
    source $ROOT/bbr-pipeline-tasks-repo/scripts/deployment-backup
}

function cleanup_pas_backup(){
    echo "cleaning up backup"
    $ROOT/binary/bbr deployment 
        --target "$BOSH_ENVIRONMENT" \
        --username "$BOSH_CLIENT" \
        --deployment "$DEPLOYMENT_NAME" \
        --ca-cert "$BOSH_CA_CERT_PATH" \
    backup-cleanup
}

function upload_to_azure(){
    echo "uploading backup to azure"
    export FILE_TO_UPLOAD=$ROOT/ert-backup-artifact/ert-backup.tgz

    az storage blob upload \
        --file "$FILE_TO_UPLOAD" \
        --container-name "$AZURE_STORAGE_CONTAINER" \
        --name "$AZURE_STORAGE_VERSIONED_FILE"
}

# get script directory and sets the root of the container
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
ROOT=$DIR/../../..

# copy om into the path
cp om/om-linux /usr/local/bin/om
chmod +x /usr/local/bin/om

source $ROOT/bbr-pipeline-tasks-repo/scripts/export-director-metadata
source $ROOT/bbr-pipeline-tasks-repo/scripts/export-cf-metadata

# set the no proxy to contain the director ip if requested. this must follow export-director-metadata
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
    mkdir -p $ROOT/ert-backup-artifact
    pushd $ROOT/ert-backup-artifact

        # call backup_pas function
        backup_pas 

        echo "compressing backup"
        tar cvzf ert-backup.tgz -- * | xargs rm -f
    popd

    upload_to_azure
)

# capture subshell return code and go back to failing the script on error
return_code=$?
set -e

# always cleanup
echo "cleaning up backup"
rm -rf $ROOT/ert-backup-artifact/*

# if return code from the subshell above was non zero
if [ $return_code -ne 0 ]; then
  # return the return code (this will fail the task)
  exit $return_code
fi
