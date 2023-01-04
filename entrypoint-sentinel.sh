#!/bin/bash

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


sentinel_mode_setup(){
  {
    echo "sentinel monitor ${MASTER_GROUP_NAME} ${IP} ${PORT} ${QUORUM}"
    echo "sentinel down-after-milliseconds ${MASTER_GROUP_NAME} ${DOWN_AFTER_MILLISECONDS}"
    echo "sentinel parallel-syncs ${MASTER_GROUP_NAME} ${PARALLEL_SYNCS}"
    echo "sentinel failover-timeout ${MASTER_GROUP_NAME} ${FAILOVER_TIMEOUT}"
  }>> /etc/redis/sentinel.conf
 
}

external_config() {
  echo "include ${EXTERNAL_CONFIG_FILE}" >> /etc/redis/sentinel.conf
}

start_sentinel() {

  echo "Starting  sentinel service ....."
    redis-sentinel /etc/redis/sentinel.conf
  
}

main_function() {

  sentinel_mode_setup

  if [[ -f "${EXTERNAL_CONFIG_FILE}" ]]; then
    external_config
  fi
  start_sentinel
}

main_function