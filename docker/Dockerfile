ARG REGISTRY=docker.io
ARG BASE_IMAGE=ubuntu:latest
# as of 2024/03/28, comment taken from https://hub.docker.com/_/ubuntu h1: "What's in this image?"
# The ubuntu:latest tag points to the "latest LTS", since that's the version recommended for general use. The ubuntu:rolling tag points to the latest release (regardless of LTS status).
# additionally the FROM is parametrized so we can provide the base image layer without the implicit docker pull at build time.This avoid docker rate limitation in CI
FROM ${REGISTRY}/${BASE_IMAGE}

RUN apt-get update && apt-get install -y \
  openssh-client \
  curl \
  wget \
  jq \
  netcat-openbsd \
  && rm -rf /var/lib/apt/lists/*

RUN ["/bin/bash", "-c", "set -o pipefail && curl -s https://api.github.com/repos/pivotal-cf/om/releases/latest \
     | jq -e -r '.assets[] | select(.name | contains(\"om-linux\")) | select(.name | contains(\"tar.gz\") | not) | .browser_download_url' \
     | wget -qi - -O /bin/om && chmod +x /bin/om"]

RUN ["/bin/bash", "-c", "set -o pipefail && curl -s https://api.github.com/repos/cloudfoundry/bosh-cli/releases/latest \
    | jq -e -r '.assets[] | .browser_download_url' \
    | grep linux \
    | wget -qi - -O /bin/bosh && chmod +x /bin/bosh"]

RUN ["/bin/bash", "-c", "set -o pipefail && curl -s https://api.github.com/repos/concourse/concourse/releases/latest \
    | jq -e -r '.assets[] | select(.name | contains(\"linux-amd64.tgz\")) | select(.name | contains(\"fly\")) | select(.name | contains(\"sha\") | not) | .browser_download_url' \
    | wget -qi - -O fly.tar.gz && tar xvf fly.tar.gz -C /bin && rm fly.tar.gz && chmod +x /bin/fly"]
