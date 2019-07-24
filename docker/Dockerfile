FROM ubuntu:xenial

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
