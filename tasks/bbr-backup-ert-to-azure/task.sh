#!/bin/bash

# https://stackoverflow.com/a/25180186
function try()
{
    [[ $- = *e* ]]; SAVED_OPT_E=$?
    set +e
}

function catch()
{
    export ex_code=$?
    (( $SAVED_OPT_E )) && set +e
    return $ex_code
}

source pcf-pipelines-repo/scripts/export-director-metadata
source pcf-pipelines-repo/scripts/export-cf-metadata

pushd ert-backup-artifact
    try(
        echo "backing up deployment"
        source pcf-pipelines-repo/scripts/deployment-backup
        
        echo "compressing backup"
        tar -cvzf ert-backup.tgz -- *
    )
    catch || {
        echo "cleaning up backup"
        ../binary/bbr deployment --target "$BOSH_ENVIRONMENT" \
            --username "$BOSH_CLIENT" \
            --deployment "$DEPLOYMENT_NAME" \
            --ca-cert "$BOSH_CA_CERT_PATH" \
            backup-cleanup
    }
popd

echo "uploading backup to azure"
export FILE_TO_UPLOAD=ert-backup-artifact/ert-backup.tgz

az storage blob upload \
    --file "$FILE_TO_UPLOAD" \
    --container-name "$AZURE_STORAGE_CONTAINER" \
    --name "$AZURE_STORAGE_VERSIONED_FILE"        

# cleaning up backup
rm -rf ert-backup-artifact