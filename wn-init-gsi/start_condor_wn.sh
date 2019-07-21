#!/bin/bash

#
# This startup script can be used to start a condor wn in a container
# 
#

provided_collector=$1

echo "Running start_condor_wn.sh ${provided_collector}"

# Add domain to make condor happy
cp /etc/hosts /tmp/hosts && sed "s/`hostname`/`hostname`.optiputer.net `hostname`/" /tmp/hosts > /etc/hosts && rm -f /tmp/hosts


(cd /docker-init/htcondor/downloads/ && ./unpack.sh)
rc=$?
if [ $rc -ne 0 ]; then
  echo "ERROR: Failed to unpack condor"
  exit 1
fi

mkdir -p /etc/grid-security
(cd /etc/grid-security && tar -xzf /docker-init/certificates.tgz)
rc=$?
if [ $rc -ne 0 ]; then
  echo "ERROR: Failed to unpack certificates"
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
       echo "ERROR: Cannot crearte user ${HTCONDOR_USER}. Aborting."
       exit 1
    fi
  fi
  echo "HTCondor daemons launched as root but will run as user ${HTCONDOR_USER}"

  if [ "${SLOT_USER}" == "" ]; then
    export SLOT_USER=slotuser
  fi

  id "${SLOT_USER}"
  if [ $? -ne 0 ]; then
    useradd "${SLOT_USER}"
    if [ $? -ne 0 ]; then
       echo "ERROR: Cannot crearte user ${SLOT_USER}. Aborting."
       exit 1
    fi
  fi

  (cd /opt/htcondor && ./condor_install --type=execute --central-manager=${provided_collector} --owner=${HTCONDOR_USER} --local-dir=/var/lib/htcondor )
  if [ $? -ne 0 ]; then
    echo "ERROR: condor_install failed. Aborting."
    exit 1
  fi

  cp /opt/htcondor/condor.sh /etc/profile.d/

   cat >/var/lib/htcondor/config/11_slot_user.config << EOF

SLOT1_USER = ${SLOT_USER}
DEDICATED_EXECUTE_ACCOUNT_REGEXP = ${SLOT_USER}
STARTER_ALLOW_RUNAS_OWNER = False

EOF

else
  echo "HTCondor daemons running as current user ${myuname}"

  (cd /opt/htcondor && ./condor_install --type=execute --central-manager=${provided_collector} --local-dir=/var/lib/htcondor )
  if [ $? -ne 0 ]; then
    echo "ERROR: condor_install failed. Aborting."
    exit 1
  fi

  echo "source /opt/htcondor/condor.sh" >> ~/.bashrc

fi

# The containers usaully have more CPUs visible than we can use
# Limit to 1 CPU by default
echo "NUM_CPUS=1" > /var/lib/htcondor/config/50_one_cpu.config

#
# GSI security setup
#
cat > /var/lib/htcondor/config/10_gsi.config <<EOF
SEC_DEFAULT_AUTHENTICATION = REQUIRED
SEC_DEFAULT_AUTHENTICATION_METHODS = GSI 

DENY_WRITE = anonymous@*
DENY_ADMINISTRATOR = anonymous@*
DENY_DAEMON = anonymous@*
DENY_NEGOTIATOR = anonymous@*
DENY_OWNER = anonymous@*
DENY_CONFIG = anonymous@*

GSI_DAEMON_PROXY=/etc/grid-security/host.proxy

EOF

# We expect GPUs to be used
echo "use feature : GPUs" > /var/lib/htcondor/config/10_gpu.config

if [ -f "/docker-init/htcondor/condor_init_config.sh" ]; then
  echo "Sourcing /docker-init/htcondor/condor_init_config.sh"
  source /docker-init/htcondor/condor_init_config.sh
fi

echo "Starting HTCondor"

source /opt/htcondor/condor.sh
condor_master -f

