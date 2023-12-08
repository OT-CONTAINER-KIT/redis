#!/bin/bash

check_redis_health() {
    if [[ -n "${REDIS_PASSWORD}" ]]; then
        export REDISCLI_AUTH="${REDIS_PASSWORD}"
    fi
    if [[ "${TLS_MODE}" == "true" ]]; then
        redis-cli --tls --cert "${REDIS_TLS_CERT}" --key "${REDIS_TLS_CERT_KEY}" --cacert "${REDIS_TLS_CA_KEY}" -h "$(hostname)" -p "${REDIS_PORT}" ping
    else
        redis-cli -h "$(hostname)" -p "${REDIS_PORT}" ping
    fi
}

check_redis_health
