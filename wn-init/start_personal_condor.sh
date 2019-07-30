#!/bin/bash

#
# This startup script can be used to start a personal condor in a container
# 
#

(cd /docker-init/htcondor/downloads/ && ./unpack.sh)
rc=$?
if [ $rc -ne 0 ]; then
  echo "ERROR: Failed to unpack condor"
  exit 1
fi

mkdir -p /var/lib/htcondor/config
rc=$?
if [ $rc -ne 0 ]; then
  echo "ERROR: Failed to create /var/lib/htcondor/config"
  exit 1
fi

myuname=`id -un`

if [ "${myuname}" == "root" ]; then

  if [ "${NODE_DOMAIN}" == "" ]; then
    export NODE_DOMAIN=cluster.local
  fi

  # Add domain to make condor happy
  cp /etc/hosts /tmp/hosts && sed "s/`hostname`/`hostname`.${NODE_DOMAIN} `hostname`/" /tmp/hosts > /etc/hosts && rm -f /tmp/hosts

  if [ "${HTCONDOR_USER}" == "" ]; then
    export HTCONDOR_USER=condor
  fi

  echo "HTCondor daemons will run as user ${HTCONDOR_USER}"

  id "${HTCONDOR_USER}"
  if [ $? -ne 0 ]; then
    useradd "${HTCONDOR_USER}"
    if [ $? -ne 0 ]; then
       echo "ERROR: Cannot crearte user ${HTCONDOR_USER}. Aborting."
       exit 1
    fi
  fi
  echo "HTCondor daemons launched as root but will run as user ${HTCONDOR_USER}"

  (cd /opt/htcondor && ./condor_install --make-personal-condor --owner=${HTCONDOR_USER} --local-dir=/var/lib/htcondor )
  if [ $? -ne 0 ]; then
    echo "ERROR: condor_install failed. Aborting."
    exit 1
  fi

  cp /opt/htcondor/condor.sh /etc/profile.d/

else
  echo "HTCondor daemons running as current user ${myuname}"

  (cd /opt/htcondor && ./condor_install --make-personal-condor --local-dir=/var/lib/htcondor )
  if [ $? -ne 0 ]; then
    echo "ERROR: condor_install failed. Aborting."
    exit 1
  fi

  echo "source /opt/htcondor/condor.sh" >> ~/.bashrc

fi

# The containers usaully have more CPUs visible than we can use
# Limit to 1 CPU by default
echo "NUM_CPUS=1" > /var/lib/htcondor/config/50_one_cpu.config

echo "Starting HTCondor"

source /opt/htcondor/condor.sh
condor_master -f

