# BBR PCF Pipeline Tasks

This is a collection of [Concourse](https://concourse.ci) tasks for backing up a [Pivotal Cloud Foundry](https://pivotal.io/platform) installation using [bbr](https://github.com/cloudfoundry-incubator/bosh-backup-and-restore).

### All Foundations
- [export-om-installation](tasks/export-om-installation/task.yml): Export Ops Manager installation settings
- [bbr-backup-director](tasks/bbr-backup-director/task.yml): Run `bbr director backup`
- [bbr-cleanup-director](tasks/bbr-cleanup-director/task.yml): Run `bbr director backup-cleanup`

### PAS/ERT
- [bbr-backup-ert](tasks/bbr-backup-ert/task.yml): Run `bbr deployment backup` for PAS/ERT
- [bbr-cleanup-ert](tasks/bbr-cleanup-ert/task.yml): Run `bbr deployment backup-cleanup` for PAS/ERT

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

### Networking

To use any of these tasks, apart from `export-om-installation`, you will need either:
- a Concourse worker with access to your Ops Manager private networks. You can find an example template for deploying an external worker in a different network to your Concourse deployment [here](https://github.com/concourse/concourse-bosh-deployment/blob/master/cluster/external-worker.yml)
- or, provide the `OPSMAN_PRIVATE_KEY` to use a SSH tunnel via the Ops Manager VM. Please note, using a SSH tunnel may increase the time taken to drain backup artifacts. Backup artifacts can be very large and using a SSH tunnel will be a significant overhead on network performance.

### Disk space

The backup tasks will run `bbr` commands on your Concourse worker. Ensure that your Concourse workers have enough disk space to accommodate your backup artifacts.

---

## Sample pipelines

Sample pipelines and secrets are provided as examples of how to run the tasks to back up PAS or PKS.

### Triggers

Running regular backups (at least every 24 hours) and storing multiple copies of backup artifacts in different datacenters is highly recommended. The [time](https://github.com/concourse/time-resource) Concourse resource can be added to the pipeline to trigger backups regularly.

### Backup artifact storage

There are a variety of storage resources such as [S3](https://github.com/concourse/s3-resource) that can be used to move backups to storage. A list of Concourse resources can be found [here](https://concourse.ci/resource-types.html).
