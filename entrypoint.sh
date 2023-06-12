#!/bin/bash

set -a

PERSISTENCE_ENABLED=${PERSISTENCE_ENABLED:-"false"}
DATA_DIR=${DATA_DIR:-"/data"}
NODE_CONF_DIR=${NODE_CONF_DIR:-"/node-conf"}
EXTERNAL_CONFIG_FILE=${EXTERNAL_CONFIG_FILE:-"/etc/redis/external.conf.d/redis-additional.conf"}
REDIS_MAJOR_VERSION=${REDIS_MAJOR_VERSION:-"v7"}

apply_permissions() {
    chgrp -R 1000 /etc/redis
    chmod -R g=u /etc/redis
}

common_operation() {
    mkdir -p "${DATA_DIR}"
    mkdir -p "${NODE_CONF_DIR}"
}

set_redis_password() {
    if [[ -z "${REDIS_PASSWORD}" ]]; then
        echo "Redis is running without password which is not recommended"
        echo "protected-mode no" >> /etc/redis/redis.conf
    else
        {
            echo masterauth "${REDIS_PASSWORD}"
            echo requirepass "${REDIS_PASSWORD}"
            echo protected-mode yes
        } >> /etc/redis/redis.conf
    fi
}

redis_mode_setup() {
    if [[ "${SETUP_MODE}" == "cluster" ]]; then
        {
            echo cluster-enabled yes
            echo cluster-node-timeout 5000
            echo cluster-require-full-coverage no
            echo cluster-migration-barrier 1
            echo cluster-config-file "${NODE_CONF_DIR}/nodes.conf"
        } >> /etc/redis/redis.conf

        POD_HOSTNAME=$(hostname)
        POD_IP=$(hostname -i)
        sed -i -e "/myself/ s/[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}/${POD_IP}/" "${NODE_CONF_DIR}/nodes.conf"
    else
        echo "Setting up redis in standalone mode"
    fi
}

tls_setup() {
    if [[ "${TLS_MODE}" == "true" ]]; then
        {
            echo port 0
            echo tls-port 6379
            echo tls-cert-file "${REDIS_TLS_CERT}"
            echo tls-key-file "${REDIS_TLS_CERT_KEY}"
            echo tls-ca-cert-file "${REDIS_TLS_CA_KEY}"
            # echo tls-prefer-server-ciphers yes
            echo tls-auth-clients optional
        } >> /etc/redis/redis.conf

        if [[ "${SETUP_MODE}" == "cluster" ]]; then
            {
                echo tls-replication yes
                echo tls-cluster yes
                echo cluster-preferred-endpoint-type hostname
            } >> /etc/redis/redis.conf
        fi
    else
        echo "Running without TLS mode"
    fi
}

persistence_setup() {
    if [[ "${PERSISTENCE_ENABLED}" == "true" ]]; then
        {
            echo save 900 1
            echo save 300 10
            echo save 60 10000
            echo appendonly yes
            echo appendfilename \"appendonly.aof\"
            echo dir "${DATA_DIR}"
        } >> /etc/redis/redis.conf
    else
        echo "Running without persistence mode"
    fi
}

external_config() {
    echo "include ${EXTERNAL_CONFIG_FILE}" >> /etc/redis/redis.conf
}

start_redis() {
    if [[ "${SETUP_MODE}" == "cluster" ]]; then
        echo "Starting redis service in cluster mode....."
        if [[ "${REDIS_MAJOR_VERSION}" != "v7" ]]; then
          redis-server /etc/redis/redis.conf \
          --cluster-announce-ip "${POD_IP}" \
          --cluster-announce-hostname "${POD_HOSTNAME}"
        else
          redis-server /etc/redis/redis.conf
        fi
    else
        echo "Starting redis service in standalone mode....."
        redis-server /etc/redis/redis.conf
    fi
}

main_function() {
    common_operation
    set_redis_password
    redis_mode_setup
    persistence_setup
    tls_setup
    if [[ -f "${EXTERNAL_CONFIG_FILE}" ]]; then
        external_config
    fi
    start_redis
}

main_function
