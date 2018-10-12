FROM alpine:3.7
RUN apk --update --no-cache add bash openssh jq curl wget
RUN curl -s https://api.github.com/repos/pivotal-cf/om/releases/latest \
     | jq -r '.assets[] | select(.name=="om-linux") | .browser_download_url' \
     | wget -qi - -O /bin/om && chmod +x /bin/om
RUN curl -s https://api.github.com/repos/cloudfoundry/bosh-cli/releases/latest \
    | jq -r '.assets[] | .browser_download_url' \
    | grep linux \
    | wget -qi - -O /bin/bosh && chmod +x /bin/bosh

