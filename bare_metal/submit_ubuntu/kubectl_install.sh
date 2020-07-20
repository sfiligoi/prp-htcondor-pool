#!/bin/bash

# This will install kubectl on Ubuntu 18
# Must be run as root/sudo


# Based on
#  https://kubernetes.io/docs/tasks/tools/install-kubectl/

curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
if [ $? -ne 0 ]; then  echo "ERROR, aborting"; exit 1; fi
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee -a /etc/apt/sources.list.d/kubernetes.list
if [ $? -ne 0 ]; then  echo "ERROR, aborting"; exit 1; fi
apt-get update
if [ $? -ne 0 ]; then  echo "ERROR, aborting"; exit 1; fi
apt-get -y install kubectl
if [ $? -ne 0 ]; then  echo "ERROR, aborting"; exit 1; fi

