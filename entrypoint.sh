#!/bin/bash

set -eu

generate_common_config() {
    {
        echo "bind 0.0.0.0"
        echo protected-mode yes
        echo tcp-backlog 511
        echo timeout 0
        echo tcp-keepalive 300
        echo daemonize no
        echo supervised no
        echo pidfile /var/run/redis.pid
    } > /etc/redis/redis.conf
}

set_redis_password() {
    if [ -z "${REDIS_PASSWORD}" ]; then
        echo "Redis is running without password which is not recommended"
    else
        {
            echo masterauth "${REDIS_PASSWORD}"
            echo requirepass "${REDIS_PASSWORD}"
        } >> /etc/redis/redis.conf
    fi
}

redis_mode_setup() {
    if [ "${SETUP_MODE}" = "cluster" ]; then
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
    echo "Starting redis service "
    redis-server /etc/redis/redis.conf
}

main_function() {
    generate_common_config
    set_redis_password
    redis_mode_setup
    start_redis
}

main_function
