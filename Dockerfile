FROM alpine:3.15 as builder

MAINTAINER Opstree Solutions

ARG TARGETARCH

LABEL VERSION=1.0 \
      ARCH=$TARGETARCH \
      DESCRIPTION="A production grade performance tuned redis docker image created by Opstree Solutions"

ARG REDIS_DOWNLOAD_URL="http://download.redis.io/"

ARG REDIS_VERSION="stable"

RUN apk add --no-cache su-exec tzdata make curl build-base linux-headers bash openssl-dev

RUN curl -fL -Lo /tmp/redis-${REDIS_VERSION}.tar.gz ${REDIS_DOWNLOAD_URL}/redis-${REDIS_VERSION}.tar.gz && \
    cd /tmp && \
    tar xvzf redis-${REDIS_VERSION}.tar.gz && \
    cd redis-${REDIS_VERSION} && \
    make && \
    make install BUILD_TLS=yes

FROM alpine:3.15

MAINTAINER Opstree Solutions

ARG TARGETARCH

LABEL VERSION=1.0 \
      ARCH=$TARGETARCH \
      DESCRIPTION="A production grade performance tuned redis docker image created by Opstree Solutions"

COPY --from=builder /usr/local/bin/redis-server /usr/local/bin/redis-server
COPY --from=builder /usr/local/bin/redis-cli /usr/local/bin/redis-cli

RUN addgroup -S -g 1000 redis && adduser -S -G redis -u 1000 redis && \
    apk add --no-cache bash

COPY redis.conf /etc/redis/redis.conf

COPY entrypoint.sh /usr/bin/entrypoint.sh

COPY setupMasterSlave.sh /usr/bin/setupMasterSlave.sh

COPY healthcheck.sh /usr/bin/healthcheck.sh

RUN chown -R 1000:0 /etc/redis && \
    chmod -R g+rw /etc/redis && \
    mkdir /data && \
    chown -R 1000:0 /data && \
    chmod -R g+rw /data && \
    mkdir /node-conf && \
    chown -R 1000:0 /node-conf && \
    chmod -R g+rw /node-conf

VOLUME ["/data"]
VOLUME ["/node-conf"]

WORKDIR /data

EXPOSE 6379

USER 1000

ENTRYPOINT ["/usr/bin/entrypoint.sh"]
