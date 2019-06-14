#!/bin/bash

#
# This startup script can be used to start a personal condor in a container
# 
#

myuname=`id -un`

if [ "${HTCONDOR_USER}" == "" ]; then
  if [ "${HTCONDOR_USER}" == "root" ]; then
    export HTCONDOR_USER=condor
  else
    export HTCONDOR_USER=$myuname
  fi
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

(cd /opt/htcondor && ./condor_install --make-personal-condor --owner=${HTCONDOR_USER} --local-dir=/var/lib/htcondor )
if [ $? -ne 0 ]; then
   echo "ERROR: condor_install failed. Aborting."
   exit 1
fi

# The containers usaully have more CPUs visible than we can use
# Limit to 1 CPU by default
mkdir /var/lib/htcondor/config
echo "NUM_CPUS=1" > /var/lib/htcondor/config/50_one_cpu.config


if [ "${HTCONDOR_USER}" == "root" ]; then
  cp /opt/htcondor/condor.sh /etc/profile.d/
else
  echo "source /opt/htcondor/condor.sh" >> ~/.bashrc
fi

echo "Starting HTCondor"

source /opt/htcondor/condor.sh
condor_master -f

