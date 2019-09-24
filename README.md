# BBR PCF Pipeline Tasks

This is a collection of [Concourse](https://concourse.ci) tasks for backing up a [Pivotal Cloud Foundry](https://pivotal.io/platform) installation using [bbr](https://github.com/cloudfoundry-incubator/bosh-backup-and-restore).

### All Foundations
- [export-om-installation](tasks/export-om-installation/task.yml): Export Ops Manager installation settings
- [bbr-backup-director](tasks/bbr-backup-director/task.yml): Run `bbr director backup`
- [bbr-cleanup-director](tasks/bbr-cleanup-director/task.yml): Run `bbr director backup-cleanup`
- [check-opsman-status](tasks/check-opsman-status/task.yml): Check `Apply changes` is not inflight before taking a backup. If it is, the task fails. This should prevent a backup from taking place. Please refer to the [example](examples/) pipelines to see how the task is used.


### PAS
- [bbr-backup-pas](tasks/bbr-backup-pas/task.yml): Run `bbr deployment backup` for PAS
- [bbr-cleanup-pas](tasks/bbr-cleanup-pas/task.yml): Run `bbr deployment backup-cleanup` for PAS

### PKS
- [bbr-backup-pks](tasks/bbr-backup-pks/task.yml): Run `bbr deployment backup` for PKS control plane
- [bbr-cleanup-pks](tasks/bbr-cleanup-pks/task.yml): Run `bbr deployment backup-cleanup` for PKS control plane
- [bbr-backup-pks-clusters](tasks/bbr-backup-pks-clusters/task.yml): Run `bbr deployment --all-deployments backup` for all PKS clusters
- [bbr-cleanup-pks-clusters](tasks/bbr-cleanup-pks-clusters/task.yml): Run `bbr deployment --all-deployments backup-cleanup` for all PKS clusters
- [lock-pks](tasks/lock-pks/task.yml): Lock PKS control plane
- [unlock-pks](tasks/unlock-pks/task.yml): Unlock PKS control plane

### Helper
- [extract-bbr-binary](tasks/extract-bbr-binary/task.yml): Extracts the linux bbr binary from tarfile

---

## Requirements

### GitHub Account

For Concourse to pull the tasks it needs to reach out to GitHub. We use the SSH method to download the tasks from GitHub in the example pipelines and we strongly recommend that the HTTPS method is not used. Concourse typically polls GitHub for any changes to the target Git repo and the HTTPS method is subject to rate limits. The SSH method is not subject to the same rate limits as it authenticates the client against a GitHub user which has much higher limits.

Please [create](https://help.github.com/en/articles/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent#generating-a-new-ssh-key) and [add](https://help.github.com/en/articles/adding-a-new-ssh-key-to-your-github-account) and SSH key to your GitHub account as this will needs to be used in the [pipeline secrets](https://github.com/pivotal-cf/bbr-pcf-pipeline-tasks/blob/master/examples/pks-secrets.yml#L2).

### Networking

To use any of these tasks, apart from `export-om-installation`, you will need either:
- a Concourse worker with access to your Ops Manager private networks. You can find an example template for deploying an external worker in a different network to your Concourse deployment [here](https://github.com/concourse/concourse-bosh-deployment/blob/master/cluster/external-worker.yml)
- or, provide the `OPSMAN_PRIVATE_KEY` to use a SSH tunnel via the Ops Manager VM. This key **is not required** if your concourse worker **has access** to the Ops Manager **private networks**. Please note, using a SSH tunnel may increase the time taken to drain backup artifacts. Backup artifacts can be very large and using a SSH tunnel will be a significant overhead on network performance.

### Disk space

The backup tasks will run `bbr` commands on your Concourse worker. Ensure that your Concourse workers have enough disk space to accommodate your backup artifacts.

---

## Example pipelines

Example pipelines and secrets are provided to show how to use these tasks to back up PAS or PKS.

### Triggers

Running regular backups (at least every 24 hours) and storing multiple copies of backup artifacts in different datacenters is highly recommended. The [time](https://github.com/concourse/time-resource) Concourse resource can be added to the pipeline to trigger backups regularly.

### Backup artifact storage

There are a variety of storage resources such as [S3](https://github.com/concourse/s3-resource) that can be used to move backups to storage. A list of Concourse resources can be found [here](https://concourse.ci/resource-types.html).

### HTTP Proxies

BBR tasks for backing up deployments use the BOSH API and will result in HTTP requests to the director.

Setting the `SET_NO_PROXY` parameter on the tasks will result in a `NO_PROXY` environment variable being exported that contains the BOSH Director IP.

```yaml
- task: bbr-backup-pas
  file: bbr-pipeline-tasks-repo/tasks/bbr-backup-pas/task.yml
  params:
    SKIP_SSL_VALIDATION: ((skip-ssl-validation))
    OPSMAN_URL: ((opsman-url))
    OPSMAN_USERNAME: ((opsman-username))
    OPSMAN_PASSWORD: ((opsman-password))
    OPSMAN_PRIVATE_KEY: ((opsman-private-key))    
    SET_NO_PROXY: true
```

---

## Semantic Versioning

The inputs, outputs, params, filename, and filepath of all task files in this repo are part of a semantically versioned API.
See our documentation for a detailed discussion of our semver API. See www.semver.org for an explanation of semantic versioning.

### Pinning to a version

This repository has git tags that can be used to pin to a specific version. For example, here is how to pin to v1.0.0 using `tag_filter`:

```yaml
resources:
- name: bbr-pipeline-tasks-repo
  type: git
  source:
    uri: https://github.com/pivotal-cf/bbr-pcf-pipeline-tasks.git
    branch: master
    tag_filter: v1.0.0
```
