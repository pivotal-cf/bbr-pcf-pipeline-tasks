FROM alpine:3.7
RUN apk --update --no-cache add bash jq python py2-pip curl wget \
    && pip install sshuttle  \
    && apk del py2-pip \
    && curl -s https://api.github.com/repos/pivotal-cf/om/releases/latest \
     | jq -r '.assets[] | select(.name=="om-linux") | .browser_download_url' \
     | wget -qi - -O /bin/om \
    && chmod +x /bin/om
