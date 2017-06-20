FROM golang:1.8

RUN \
  apt-get update && \
  apt-get install -y jq && \
  rm -rf /var/lib/apt/lists/*

RUN go get github.com/pivotal-cf/om