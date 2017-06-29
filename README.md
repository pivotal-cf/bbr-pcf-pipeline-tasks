# BBR PCF Pipeline Tasks

This is a collection of [Concourse](https://concourse.ci) tasks for backing up and restoring a [Pivotal Cloud Foundry](https://pivotal.io/platform) installation using [bbr](https://github.com/pivotal-cf/bosh-backup-and-restore).

## Tasks

### export-om-installation

#### Inputs

* `bbr-pipeline-tasks-repo`: this repository

#### Outputs

* `om-installation`: a directory containing a installation.zip generated by exporting the Operations Manager installation. 

#### Params

* `SKIP_SSL_VALIDATION`: if true, ssl validation will be skipped. Defaults to false 
* `OPSMAN_URL`: The OpsManager URL
* `OPSMAN_USERNAME`: The OpsManager username
* `OPSMAN_PASSWORD`: The OpsManager password

### bbr-backup-ert

N.B.: the pipeline assumes you have a tagged concourse worker deployed on the same network as ERT, i.e., the pipeline will use the concourse worker as the jumpbox. Ensure that this worker has enough disk space to accomodate the ERT backup files.

#### Inputs:

* `bbr-pipeline-tasks-repo`: this repository
* `binary`: a directory containing a executable `bbr` file

#### Outputs

* `ert-backup-artifact`: a directory containing ert-backup.tar generated by backing up ERT.

#### Params

* `SKIP_SSL_VALIDATION`: if true, ssl validation will be skipped. Defaults to false 
* `OPSMAN_URL`: The OpsManager URL
* `OPSMAN_USERNAME`: The OpsManager username
* `OPSMAN_PASSWORD`: The OpsManager password

## Example pipeline

You can set the example pipeline with [fly](https://concourse.ci/fly-cli.html):

```bash
cp secrets.sample.yml secrets.yml
# update secrets.yml with real secrets
fly --target <target> \
    set-pipeline \
    --pipeline bbr-pipeline \
    --config pipeline.sample.yml \
    --load-vars-from secret.yml 
```