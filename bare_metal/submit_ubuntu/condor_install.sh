#!/bin/bash

# This will install and configure HTCondor 8.8 on Ubuntu 18
# Must be run as root/sudo


#
# First install HTCondor binaries
#

# Based on
#  https://research.cs.wisc.edu/htcondor/instructions/ubuntu/18/stable/

wget -qO - https://research.cs.wisc.edu/htcondor/ubuntu/HTCondor-Release.gpg.key | sudo apt-key add -
echo "deb http://research.cs.wisc.edu/htcondor/ubuntu/8.8/bionic bionic contrib" >> /etc/apt/sources.list
echo "deb-src http://research.cs.wisc.edu/htcondor/ubuntu/8.8/bionic bionic contrib" >> /etc/apt/sources.list
apt-get update
apt-get -y install htcondor

#
# Add configuration files
#

cp condor_config.d/* /etc/condor/config.d/

#
# Create a unique pool password
#

condor_store_cred -f /etc/condor/POOL

#
# We are ready to start condor
#

systemctl enable condor
systemctl start condor

