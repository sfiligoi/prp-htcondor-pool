#!/bin/bash

#
# This startup script can be used to start a condor submit in a container
# 
#

provided_collector=$1

echo "Running start_condor_submit.sh ${provided_collector}"

# Add domain to make condor happy
cp /etc/hosts /tmp/hosts && sed "s/`hostname`/`hostname`.optiputer.net `hostname`/" /tmp/hosts > /etc/hosts && rm -f /tmp/hosts


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

  if [ "${HTCONDOR_USER}" == "" ]; then
    export HTCONDOR_USER=condor
  fi

  echo "HTCondor daemons will run as user ${HTCONDOR_USER}"

  id "${HTCONDOR_USER}"
  if [ $? -ne 0 ]; then
    useradd "${HTCONDOR_USER}"
    if [ $? -ne 0 ]; then
       echo "ERROR: Cannot create user ${HTCONDOR_USER}. Aborting."
       exit 1
    fi
  fi
  echo "HTCondor daemons launched as root but will run as user ${HTCONDOR_USER}"

  (cd /opt/htcondor && ./condor_install --type=submit --central-manager=${provided_collector} --owner=${HTCONDOR_USER} --local-dir=/var/lib/htcondor )
  if [ $? -ne 0 ]; then
    echo "ERROR: condor_install failed. Aborting."
    exit 1
  fi

  cp /opt/htcondor/condor.sh /etc/profile.d/

else
  echo "HTCondor daemons running as current user ${myuname}"

  (cd /opt/htcondor && ./condor_install --type=submit --central-manager=${provided_collector} --local-dir=/var/lib/htcondor )
  if [ $? -ne 0 ]; then
    echo "ERROR: condor_install failed. Aborting."
    exit 1
  fi

  echo "source /opt/htcondor/condor.sh" >> ~/.bashrc

fi

#
# Security setup
#
cat > /var/lib/htcondor/config/10_sec.config <<EOF
#
# Condor Security Config
#

#
# Define a common UID domain
#

UID_DOMAIN = prp
TRUST_UID_DOMAIN = True

# But the file system is not shared
FILESYSTEM_DOMAIN=$(FULL_HOSTNAME)

#
# Force pool password authentication
# (shared secret between head and worker nodes)
#

SEC_PASSWORD_FILE = /var/lib/htcondor/pool_password

SEC_DEFAULT_INTEGRITY = REQUIRED
SEC_READ_INTEGRITY = OPTIONAL
SEC_CLIENT_INTEGRITY = OPTIONAL

SEC_DEFAULT_AUTHENTICATION = REQUIRED
SEC_DEFAULT_AUTHENTICATION_METHODS = FS,PASSWORD
SEC_READ_AUTHENTICATION = OPTIONAL
SEC_CLIENT_AUTHENTICATION = OPTIONAL

# With strong security, do not use IP based controls
ALLOW_WRITE = *

# But must explicity deny unauthenticated access 
DENY_WRITE = anonymous@*
DENY_ADMINISTRATOR = anonymous@*
DENY_DAEMON = anonymous@*
DENY_NEGOTIATOR = anonymous@*
DENY_CLIENT = anonymous@*
DENY_OWNER = anonymous@*

EOF

if [ -f "/docker-init/htcondor/condor_init_config.sh" ]; then
  echo "Sourcing /docker-init/htcondor/condor_init_config.sh"
  source /docker-init/htcondor/condor_init_config.sh
fi

echo "Starting HTCondor"

source /opt/htcondor/condor.sh
condor_store_cred -p `cat /etc/wn-init/poolpasswd` -f /var/lib/htcondor/pool_password
condor_master -f

