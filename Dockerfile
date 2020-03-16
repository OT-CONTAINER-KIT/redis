FROM alpine:3.9

MAINTAINER Opstree Solutions

LABEL VERSION=1.0 \
      ARCH=AMD64 \
      DESCRIPTION="A production grade performance tuned docker image created by Opstree Solutions"

ARG REDIS_DOWNLOAD_URL="http://download.redis.io/"

ARG REDIS_VERSION="stable"

COPY redis.conf /etc/redis/redis.conf

COPY entrypoint.sh /usr/bin/entrypoint.sh

RUN addgroup -S -g 1000 redis && adduser -S -G redis -u 999 redis && \
    apk add --no-cache su-exec tzdata make curl build-base linux-headers

RUN curl -fL -Lo /tmp/redis-${REDIS_VERSION}.tar.gz ${REDIS_DOWNLOAD_URL}/redis-${REDIS_VERSION}.tar.gz && \
    cd /tmp && \
    tar xvzf redis-${REDIS_VERSION}.tar.gz && \
    cd redis-${REDIS_VERSION} && \
    make && \
    make install && \
    mkdir -p /etc/redis && \
    cp -f *.conf /etc/redis && \
    rm -rf /tmp/redis-${REDIS_VERSION}*

VOLUME ["/data"]

WORKDIR /data

EXPOSE 6379

ENTRYPOINT ["/usr/bin/entrypoint.sh"]
