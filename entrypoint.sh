#!/bin/bash

set -ex

set_redis_password() {
    if [[ -z "${REDIS_PASSWORD}" ]]; then
        echo "Redis is running without password which is not recommended"
    else
        {
            echo masterauth "${REDIS_PASSWORD}"
            echo requirepass "${REDIS_PASSWORD}"
        } >> /etc/redis/redis.conf
    fi
}

redis_mode_setup() {
    if [[ "${SETUP_MODE}" == "cluster" ]]; then
        {
            echo cluster-enabled yes
            echo cluster-config-file nodes.conf
            echo cluster-node-timeout 5000
        } >> /etc/redis/redis.conf
    else
        echo "Setting up redis in standalone mode"
    fi
}

start_redis() {
    echo "Starting redis service....."
    redis-server /etc/redis/redis.conf
}

main_function() {
    set_redis_password
    redis_mode_setup
    start_redis
}

main_function
