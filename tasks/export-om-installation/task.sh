#!/bin/bash -eu

skip_ssl=${SKIP_SSL_VALIDATION:-false}
skip_ssl_flag=""

if ${skip_ssl}; then
    skip_ssl_flag="--skip-ssl-validation"
fi

om \
    ${skip_ssl_flag} \
    --target "${OPSMAN_URL}" \
    --username "${OPSMAN_USERNAME}" \
    --password "${OPSMAN_PASSWORD}" \
    export-installation \
        --output-file om-installation/installation.zip