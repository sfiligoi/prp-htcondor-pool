#!/bin/bash

#
# This startup script can be used to start a condor wn in a container
# 
#

provided_collector=$1

echo "Running start_condor_wn.sh ${provided_collector}"

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
ALLOW_NEGOTIATOR = *
ALLOW_ADMINISTRATOR = *
ALLOW_READ = *
ALLOW_CLIENT = *

# But must explicity deny unauthenticated access 
DENY_WRITE = anonymous@*
DENY_ADMINISTRATOR = anonymous@*
DENY_DAEMON = anonymous@*
DENY_NEGOTIATOR = anonymous@*
DENY_CLIENT = anonymous@*
DENY_OWNER = anonymous@*

EOF

if [ "${OS_IMAGE}" != "" ]; then
   cat > /var/lib/htcondor/config/80_os_image.config <<EOF
#
# Adverise image name
#

OS_Image = "${OS_IMAGE}"

# Publish this info
MASTER_ATTRS = \$(MASTER_ATTRS),OS_Image
STARTD_ATTRS = \$(STARTD_ATTRS),OS_Image

EOF

fi

# We expect GPUs to be used
echo "use feature : GPUs" > /var/lib/htcondor/config/10_gpu.config

#
# Set up auto shutdown
# Set to 0 if you want to disable it
#
if [ "${HTCONDOR_AUTO_SHUTDOWN}" == "" ]; then
   export HTCONDOR_AUTO_SHUTDOWN=1200
fi
if [ "${HTCONDOR_AUTO_SHUTDOWN}" -gt 0 ]; then
   cat > /var/lib/htcondor/config/20_autoshutdown.config <<EOF
#
# Condor Auto-shutdown Config
#

# How long will it wait in an unclaimed state before exiting
# i.e. Auto-cleanup
STARTD_NOCLAIM_SHUTDOWN = ${HTCONDOR_AUTO_SHUTDOWN}
GLIDEIN_Max_Idle = ${HTCONDOR_AUTO_SHUTDOWN}

# Publish this info
MASTER_ATTRS = \$(MASTER_ATTRS),GLIDEIN_Max_Idle
STARTD_ATTRS = \$(STARTD_ATTRS),GLIDEIN_Max_Idle

EOF

fi

if [ -f "/docker-init/htcondor/condor_init_config.sh" ]; then
  echo "Sourcing /docker-init/htcondor/condor_init_config.sh"
  source /docker-init/htcondor/condor_init_config.sh
fi

echo "Starting HTCondor"

source /opt/htcondor/condor.sh
condor_store_cred -p `cat /etc/wn-init/poolpasswd` -f /var/lib/htcondor/pool_password
condor_master -f

