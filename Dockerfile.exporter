FROM alpine:3.15 as builder

ARG EXPORTER_URL="https://github.com/oliver006/redis_exporter/releases/download"

ARG REDIS_EXPORTER_VERSION="1.44.0"

RUN  apk add --no-cache curl ca-certificates && \
      curl -fL -Lo /tmp/redis_exporter-v${REDIS_EXPORTER_VERSION}.linux-amd64.tar.gz \
      ${EXPORTER_URL}/v${REDIS_EXPORTER_VERSION}/redis_exporter-v${REDIS_EXPORTER_VERSION}.linux-amd64.tar.gz && \
      cd /tmp && tar -xvzf redis_exporter-v${REDIS_EXPORTER_VERSION}.linux-amd64.tar.gz && \
      mv redis_exporter-v${REDIS_EXPORTER_VERSION}.linux-amd64 redis_exporter

FROM scratch

MAINTAINER Opstree Solutions

LABEL VERSION=1.0 \
      ARCH=AMD64 \
      DESCRIPTION="A production grade redis exporter docker image created by Opstree Solutions"

COPY --from=builder /etc/ssl/certs /etc/ssl/certs
COPY --from=builder /tmp/redis_exporter/redis_exporter /usr/local/bin/redis_exporter

EXPOSE 9121

ENTRYPOINT ["/usr/local/bin/redis_exporter"]
