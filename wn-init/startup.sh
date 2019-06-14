#!/bin/bash

mkdir -p /docker-init/htcondor/downloads

cp /opt/htcondor/downloads/* /docker-init/htcondor/downloads/

cp /opt/htcondor/*.sh /docker-init/htcondor/

if [ -e "${INIT_USER}" ]; then
  chown -R "${INIT_USER}" /docker-init/htcondor
fi
