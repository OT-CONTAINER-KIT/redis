#!/bin/bash

check_redis_health() {
    if [[ -z "${REDIS_PASSWORD}" ]]; then
        redis-cli ping
    else
        redis-cli -a ${REDIS_PASSWORD} ping
    fi
}

check_redis_health
