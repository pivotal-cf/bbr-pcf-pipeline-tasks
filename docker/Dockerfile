FROM ubuntu:16.04
RUN \
  apt-get update && \
  apt-get install -y jq sshuttle curl wget ca-certificates && \
  rm -rf /var/lib/apt/lists/*
RUN \
  curl -s https://api.github.com/repos/pivotal-cf/om/releases/latest \
   | jq -r '.assets[] | select(.name=="om-linux") | .browser_download_url' \
   | wget -qi - -O /bin/om \
  && chmod +x /bin/om
