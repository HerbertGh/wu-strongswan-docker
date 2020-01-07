#!/bin/bash

SCRIPT_DIR="$(dirname "$(realpath "$0")")"
source "${SCRIPT_DIR}/.env"
mkdir -pv "${SCRIPT_DIR}/config"
mkdir -pv "${SCRIPT_DIR}/config/ipsec.d"
echo $USER
docker run -it --rm=true -v ${SCRIPT_DIR}/config:/config -v ${SCRIPT_DIR}/config/ipsec.d:/etc/ipsec.d -v ${SCRIPT_DIR}/__gs.sh:/__gs.sh  -v ${SCRIPT_DIR}/.env:/.env alpine sh /__gs.sh
