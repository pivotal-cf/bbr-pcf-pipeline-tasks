#!/bin/bash

set -e 

# https://stackoverflow.com/a/25180186
function try()
{
    [[ $- = *e* ]]; SAVED_OPT_E=$?
    set +e
}

function throw()
{
    exit $1
}

function catch()
{
    export ex_code=$?
    (( $SAVED_OPT_E )) && set +e
    return $ex_code
}

function throwErrors()
{
    set -e
}

function ignoreErrors()
{
    set +e
}

cp om/om-linux /usr/local/bin/om
chmod +x /usr/local/bin/om

source bbr-pipeline-tasks-repo/scripts/export-director-metadata
source bbr-pipeline-tasks-repo/scripts/export-cf-metadata

mkdir -p ert-backup-artifact
pushd ert-backup-artifact
    try
    (
        throwErrors
        echo "backing up deployment"
        source bbr-pipeline-tasks-repo/scripts/deployment-backup
    )
    catch || {
        echo "cleaning up backup"
        ../binary/bbr deployment --target "$BOSH_ENVIRONMENT" \
            --username "$BOSH_CLIENT" \
            --deployment "$DEPLOYMENT_NAME" \
            --ca-cert "$BOSH_CA_CERT_PATH" \
            backup-cleanup
    }    
        
    echo "compressing backup"
    tar -cvzf ert-backup.tgz -- *

popd

throwErrors

echo "uploading backup to azure"
export FILE_TO_UPLOAD=ert-backup-artifact/ert-backup.tgz

az storage blob upload \
    --file "$FILE_TO_UPLOAD" \
    --container-name "$AZURE_STORAGE_CONTAINER" \
    --name "$AZURE_STORAGE_VERSIONED_FILE"        

# cleaning up backup
rm -rf ert-backup-artifact