#!/bin/bash

set -a

#Redis Configuration needed
MASTER_GROUP_NAME=${MASTER_GROUP_NAME:-"mymaster"}
PORT=${PORT:-6379}
IP=${IP:-0.0.0.0}
QUORUM=${QUORUM:-2}

#Sentinel Config here
EXTERNAL_CONFIG_FILE=${EXTERNAL_CONFIG_FILE:-"/etc/redis/external.conf.d/redis-sentinel-additional.conf"}
DOWN_AFTER_MILLISECONDS=${DOWN_AFTER_MILLISECONDS:-30000}
PARALLEL_SYNCS=${PARALLEL_SYNCS:-1}
FAILOVER_TIMEOUT=${FAILOVER_TIMEOUT:-180000}
RESOLVE_HOSTNAMES=${RESOLVE_HOSTNAMES:-no}
ANNOUNCE_HOSTNAMES=${ANNOUNCE_HOSTNAMES:-no}


sentinel_mode_setup(){
  {
    echo "sentinel monitor ${MASTER_GROUP_NAME} ${IP} ${PORT} ${QUORUM}"
    echo "sentinel down-after-milliseconds ${MASTER_GROUP_NAME} ${DOWN_AFTER_MILLISECONDS}"
    echo "sentinel parallel-syncs ${MASTER_GROUP_NAME} ${PARALLEL_SYNCS}"
    echo "sentinel failover-timeout ${MASTER_GROUP_NAME} ${FAILOVER_TIMEOUT}"
    echo "SENTINEL resolve-hostnames ${RESOLVE_HOSTNAMES}"
    echo "SENTINEL announce-hostnames ${ANNOUNCE_HOSTNAMES}"
    if [[ -n "${MASTER_PASSWORD}" ]];then
      echo "sentinel auth-pass ${MASTER_GROUP_NAME} ${MASTER_PASSWORD}"
    fi
    if [[ -n "${SENTINEL_ID}" ]];then
      (echo -n "sentinel myid "; echo "${SENTINEL_ID}" | sha1sum | awk '{ print $1 }')
    fi
  }>> /etc/redis/sentinel.conf
 
}

external_config() {
  echo "include ${EXTERNAL_CONFIG_FILE}" >> /etc/redis/sentinel.conf
}

set_sentinel_password() {
    if [[ -z "${REDIS_PASSWORD}" ]]; then
        echo "Sentinel is running without password which is not recommended"
        echo "protected-mode no" >> /etc/redis/sentinel.conf
    else
        {
            echo masterauth "${REDIS_PASSWORD}"
            echo requirepass "${REDIS_PASSWORD}"
            echo protected-mode yes
        } >> /etc/redis/sentinel.conf
    fi
}

tls_setup() {
    if [[ "${TLS_MODE}" == "true" ]]; then
        {
            echo port 0
            echo tls-port 26379
            echo tls-cert-file "${REDIS_TLS_CERT}"
            echo tls-key-file "${REDIS_TLS_CERT_KEY}"
            echo tls-ca-cert-file "${REDIS_TLS_CA_KEY}"
            # echo tls-prefer-server-ciphers yes
            echo tls-auth-clients optional
        } >> /etc/redis/sentinel.conf

    else
        echo "Running sentinel without TLS mode"
    fi
}

acl_setup(){
    if [[ "$ACL_MODE" == "true" ]]; then
        {
            echo aclfile /etc/redis/user.acl
            } >> /etc/redis/sentinel.conf

    else
        echo "ACL_MODE is not true, skipping ACL file modification"
    fi
}

port_setup() {
        {
            echo port "${SENTINEL_PORT}"
        } >> /etc/redis/sentinel.conf
}

start_sentinel() {
  echo "Starting  sentinel service ....."
  exec redis-sentinel /etc/redis/sentinel.conf
}

main_function() {
  set_sentinel_password
  sentinel_mode_setup
  port_setup
  acl_setup
  tls_setup
  if [[ -f "${EXTERNAL_CONFIG_FILE}" ]]; then
    external_config
  fi
  start_sentinel
}

main_function
