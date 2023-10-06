#!/bin/bash

PODS="$1"

yes yes | redis-cli --cluster create "${PODS}"
