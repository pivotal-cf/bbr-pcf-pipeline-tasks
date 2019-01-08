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

cp om/om-linux /usr/local/bin/om
chmod +x /usr/local/bin/om

source pcf-pipelines-repo/scripts/export-director-metadata
source pcf-pipelines-repo/scripts/export-cf-metadata

pushd ert-backup-artifact
    try
    (
        echo "backing up deployment"
        source pcf-pipelines-repo/scripts/deployment-backup
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

echo "uploading backup to azure"
export FILE_TO_UPLOAD=ert-backup-artifact/ert-backup.tgz

az storage blob upload \
    --file "$FILE_TO_UPLOAD" \
    --container-name "$AZURE_STORAGE_CONTAINER" \
    --name "$AZURE_STORAGE_VERSIONED_FILE"        

# cleaning up backup
rm -rf ert-backup-artifact