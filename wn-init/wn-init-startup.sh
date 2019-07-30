#!/bin/bash

mkdir -p /docker-init/htcondor/downloads

cp /opt/htcondor/downloads/* /docker-init/htcondor/downloads/

cp /opt/htcondor/*.sh /docker-init/htcondor/
echo "HTCOndor init files in /docker-init/htcondor"

if [ -e "${INIT_USER}" ]; then
  chown -R "${INIT_USER}" /docker-init/htcondor
  echo "Change ownership of /docker-init/htcondor to ${INIT_USER}"
fi
