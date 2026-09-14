FROM alpine:3.23 AS builder

LABEL maintainer="Opstree Solutions"

ARG TARGETARCH

LABEL version=1.0 \
      arch=$TARGETARCH \
      description="A production grade performance tuned redis docker image created by Opstree Solutions"

ARG REDIS_VERSION="stable"
ARG BUILD_WITH_MODULES=no
ENV BUILD_WITH_MODULES=$BUILD_WITH_MODULES

RUN apk add --no-cache su-exec tzdata make curl build-base linux-headers bash openssl-dev
RUN <<EOF
if [ "$BUILD_WITH_MODULES" == "yes" ]; then
 apk add autoconf automake bsd-compat-headers cmake cargo python3 py-virtualenv py3-pip git llvm-dev clang-dev clang-static ncurses-dev automake autoconf libtool
 apk add clang clang-libclang g++ libffi-dev libgcc openssh openssl py3-cryptography py3-virtualenv python3-dev rsync tar unzip xsimd xz;
fi
EOF

WORKDIR /tmp

SHELL   ["bash", "-xe", "-c"]

RUN <<EOF
# if llvm-config isn't found, it's probably at `/usr/bin/llvm-config-${llvm_version}`
# see https://gitlab.alpinelinux.org/alpine/aports/-/work_items/17773 and remove once that hits the repositories
if ! command -v llvm-config &> /dev/null; then
    LLVM_CONFIG=$(find /usr/bin -name "llvm-config*" | head -n 1)
    if [ -n "$LLVM_CONFIG" ]; then
        export LLVM_CONFIG_PATH="$LLVM_CONFIG"
    fi
fi

VERSION=$(echo ${REDIS_VERSION} | sed -e "s/^v//g");
case "${VERSION}" in
   latest | stable) REDIS_DOWNLOAD_URL="http://download.redis.io/redis-stable.tar.gz" && VERSION="stable";;
   *) REDIS_DOWNLOAD_URL="http://download.redis.io/releases/redis-${VERSION}.tar.gz";;
esac;
curl -fL -Lo redis-${VERSION}.tar.gz ${REDIS_DOWNLOAD_URL};
tar xvzf redis-${VERSION}.tar.gz;

arch="$(uname -m)";
extraJemallocConfigureFlags="--with-lg-page=16";
if [ "$arch" = "aarch64" ] || [ "$arch" = "arm64" ]; then
    sed -ri 's!cd jemalloc && ./configure !&'"$extraJemallocConfigureFlags"' !' /tmp/redis-${VERSION}/deps/Makefile;
fi;
export BUILD_TLS=yes;
make -C redis-${VERSION} all;
make -C redis-${VERSION} install;

EOF

FROM alpine:3.22

LABEL maintainer="Opstree Solutions"

ARG TARGETARCH
ARG REDIS_VERSION="stable"

ENV REDIS_PORT=6379

LABEL version=1.0 \
      arch=$TARGETARCH \
      description="A production grade performance tuned redis docker image created by Opstree Solutions"

RUN apk upgrade --no-cache

COPY --from=builder /usr/local/bin/redis-server /usr/local/bin/redis-server
COPY --from=builder /usr/local/bin/redis-cli /usr/local/bin/redis-cli
COPY --from=builder /tmp/redis-*/modules/*/*.so /modules/

RUN addgroup -S -g 1000 redis && adduser -S -G redis -u 1000 redis && \
    apk add --no-cache bash libstdc++ libssl3 libcrypto3

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
