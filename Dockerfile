FROM alpine:3.15 as builder

LABEL maintainer="Opstree Solutions"

ARG TARGETARCH

LABEL version=1.0 \
      arch=$TARGETARCH \
      description="A production grade performance tuned redis docker image created by Opstree Solutions"

ARG REDIS_VERSION="stable"

RUN apk add --no-cache su-exec tzdata make curl build-base linux-headers bash openssl-dev

WORKDIR /tmp

RUN VERSION=$(echo ${REDIS_VERSION} | sed -e "s/^v//g"); \
    case "${VERSION}" in \
       latest | stable) REDIS_DOWNLOAD_URL="http://download.redis.io/redis-stable.tar.gz" && VERSION="stable";; \
       *) REDIS_DOWNLOAD_URL="http://download.redis.io/releases/redis-${VERSION}.tar.gz";; \
    esac; \
    curl -fL -Lo redis-${VERSION}.tar.gz ${REDIS_DOWNLOAD_URL}; \
    tar xvzf redis-${VERSION}.tar.gz; \
    \
    arch="$(uname -m)"; \
    extraJemallocConfigureFlags="--with-lg-page=16"; \
    if [ "$arch" = "aarch64" ] || [ "$arch" = "arm64" ]; then \
        sed -ri 's!cd jemalloc && ./configure !&'"$extraJemallocConfigureFlags"' !' /tmp/redis-${VERSION}/deps/Makefile; \
    fi; \
    export BUILD_TLS=yes; \
    make -C redis-${VERSION} all; \
    make -C redis-${VERSION} install

FROM alpine:3.15

LABEL maintainer="Opstree Solutions"

ARG TARGETARCH

ENV REDIS_PORT=6379

LABEL version=1.0 \
      arch=$TARGETARCH \
      description="A production grade performance tuned redis docker image created by Opstree Solutions"

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
    chmod -R g+rw /node-conf && \
    chmod -R g+rw /var/run

VOLUME ["/data"]
VOLUME ["/node-conf"]

WORKDIR /data

EXPOSE ${REDIS_PORT}

USER 1000

ENTRYPOINT ["/usr/bin/entrypoint.sh"]
