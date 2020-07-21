#!/bin/bash

# This will install k8s clients on Ubuntu 18
# Must be run as root/sudo


#
# Install kubectl
#

# Based on
#  https://kubernetes.io/docs/tasks/tools/install-kubectl/

curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
if [ $? -ne 0 ]; then  echo "ERROR, aborting"; exit 1; fi
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | tee -a /etc/apt/sources.list.d/kubernetes.list
if [ $? -ne 0 ]; then  echo "ERROR, aborting"; exit 1; fi
apt-get update
if [ $? -ne 0 ]; then  echo "ERROR, aborting"; exit 1; fi
apt-get -y install kubectl
if [ $? -ne 0 ]; then  echo "ERROR, aborting"; exit 1; fi

#
# Install helm
#

# Based on
#  https://helm.sh/docs/intro/install/

curl https://helm.baltorepo.com/organization/signing.asc | apt-key add -
apt-get install apt-transport-https --yes
echo "deb https://baltocdn.com/helm/stable/debian/ all main" | tee /etc/apt/sources.list.d/helm-stable-debian.list
apt-get update
apt-get install helm


