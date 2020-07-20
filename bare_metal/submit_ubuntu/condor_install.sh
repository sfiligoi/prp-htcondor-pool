#!/bin/bash

# This will install and configure HTCondor 8.8 on Ubuntu 18
# Must be run as root/sudo


#
# First install HTCondor binaries
#

# Based on
#  https://research.cs.wisc.edu/htcondor/instructions/ubuntu/18/stable/

wget -qO - https://research.cs.wisc.edu/htcondor/ubuntu/HTCondor-Release.gpg.key | sudo apt-key add -
if [ $? -ne 0 ]; then  echo "ERROR, aborting"; exit 1; fi
echo "deb http://research.cs.wisc.edu/htcondor/ubuntu/8.8/bionic bionic contrib" >> /etc/apt/sources.list
if [ $? -ne 0 ]; then  echo "ERROR, aborting"; exit 1; fi
echo "deb-src http://research.cs.wisc.edu/htcondor/ubuntu/8.8/bionic bionic contrib" >> /etc/apt/sources.list
if [ $? -ne 0 ]; then  echo "ERROR, aborting"; exit 1; fi
apt-get update
if [ $? -ne 0 ]; then  echo "ERROR, aborting"; exit 1; fi
apt-get -y install htcondor
if [ $? -ne 0 ]; then  echo "ERROR, aborting"; exit 1; fi

#
# Add configuration files
#

cp condor_config.d/* /etc/condor/config.d/
if [ $? -ne 0 ]; then  echo "ERROR, aborting"; exit 1; fi

#
# Create a unique pool password
#

echo "=============================================="
echo "Please provide a random HTCondor pool password"

condor_store_cred -f /etc/condor/POOL
if [ $? -ne 0 ]; then  echo "ERROR, aborting"; exit 1; fi

#
# We are ready to start condor
#

systemctl enable condor
systemctl start condor

