#!/bin/bash

#
# Unpack to /opt/condor
# Use the right Linux flavor
#

rm -fr tmpunpack
mkdir -p tmpunpack

if [ -e "/etc/redhat-release" ]; then
 echo "Unpack RedHat version"
 (cd tmpunpack && tar -xzf ../condor-*RedHat*gz && mv condor* condor)
 if [ $? -ne 0 ]; then
   echo "ERROR: Failed to unpack. ABORTING"
   exit 1
 fi
else
 echo "Unpack Debian version"
 (cd tmpunpack && tar -xzf ../condor-*Debian*gz && mv condor* condor)
 if [ $? -ne 0 ]; then
   echo "ERROR: Failed to unpack. ABORTING"
   exit 1
 fi
fi

rm -fr /opt/htcondor
mv tmpunpack/condor /opt/htcondor
