```bash
#!/usr/bin/env bash
set -euo pipefail
```

## Setting Pipelines
```bash
fly --target=concourse                      \
    login                                   \
    --concourse-url="${CONCOURSE_URL}"      \
    --team-name="${CONCOURSE_TEAM}"

fly --target=concourse sync

fly --target=concourse                      \
    set-pipeline                            \
    --non-interactive                       \
    --pipeline=pas-pipeline-tasks           \
    --config="${PROJECT_ROOT}/ci/pipelines/pas-pipeline-tasks/pipeline.yml"
```