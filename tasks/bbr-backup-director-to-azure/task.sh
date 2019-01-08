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

pushd director-backup-artifact    
    try(
        echo "backing up director"    
        ../binary/bbr director --host "${BOSH_ENVIRONMENT}" \
            --username "$BOSH_USERNAME" \
            --private-key-path <(echo "${BOSH_PRIVATE_KEY}") \
            backup
        
        echo "compressing backup"
        tar -cvzf director-backup.tgz -- *        
    )
    catch || {
        echo "cleaning up backup"
        ../binary/bbr director --host "${BOSH_ENVIRONMENT}" \
            --username "$BOSH_USERNAME" \
            --private-key-path <(echo "${BOSH_PRIVATE_KEY}") \
            backup-cleanup
    }
popd

echo "uploading backup to azure"
export FILE_TO_UPLOAD=director-backup-artifact/director-backup.tgz

az storage blob upload \
    --file "$FILE_TO_UPLOAD" \
    --container-name "$AZURE_STORAGE_CONTAINER" \
    --name "$AZURE_STORAGE_VERSIONED_FILE"        

echo "cleaning up backup"
rm -rf director-backup-artifact