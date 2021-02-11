#!/usr/bin/env bash

set -eu

pushd pipeline
  bosh int "$PIPELINE_PATH" -l "$SECRETS_PATH" --var-errs --var-errs-unused
  fly validate-pipeline -c "$PIPELINE_PATH" -l "$SECRETS_PATH"
popd
