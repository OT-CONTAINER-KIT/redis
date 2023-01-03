#!/bin/bash

EXTERNAL_CONFIG_FILE=${EXTERNAL_CONFIG_FILE:-"/etc/redis/external.conf.d/redis-sentinel-additional.conf"}

external_config() {
  echo "include ${EXTERNAL_CONFIG_FILE}" >> /etc/redis/sentinel.conf
}

start_sentinel() {

  echo "Starting redis sentinel service in standalone mode....."
    redis-sentinel /etc/redis/sentinel.conf
  
}

main_function() {

  if [[ -f "${EXTERNAL_CONFIG_FILE}" ]]; then
    external_config
  fi
  start_sentinel
}

main_function