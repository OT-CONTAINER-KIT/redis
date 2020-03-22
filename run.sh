#!/bin/bash

redis_server_mode() {
    if [[ "${SERVER_MODE}" == "master" ]]; then
        echo "Redis server mode is master"
        if [[ -z "${REDIS_PASSWORD}" ]]; then
             redis-cli --cluster create "${MASTER_LIST}" --cluster-yes
        else
            redis-cli --cluster create ${MASTER_LIST} --cluster-yes -a "${REDIS_PASSWORD}"
        fi 
    elif [[ "${SERVER_MODE}" == "slave" ]]; then
        echo "Redis server mode is slave"
        if [[ -z "${REDIS_PASSWORD}" ]]; then
            redis-cli --cluster add-node ${SLAVE_IP} ${MASTER_IP} --cluster-slave
        else
            redis-cli --cluster add-node ${SLAVE_IP} ${MASTER_IP} --cluster-slave -a "${REDIS_PASSWORD}"
        fi
    else
        echo "Redis server mode is standalone"
    fi
}

redis_server_mode
