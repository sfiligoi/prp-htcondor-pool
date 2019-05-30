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

 # base centos image does not have these two packages, and they are needed by condor
 if [ -n "/usr/bin/perl" ]; then
   yum install -y perl 
 fi

 if [ -n "/usr/lib64/libgomp.so.1" ]; then
   yum install -y libgomp
 fi
elif [ -e "/etc/os-release" ]; then
   grep -q 'ubuntu' /etc/os-release
   rc=$?

   if [ $rc -eq 0 ]; then
     grep -q 'VERSION_ID="16' /etc/os-release
     rc=$?
     if [ $rc -eq 0 ]; then
       echo "Unpack Ubuntu16 version"
       (cd tmpunpack && tar -xzf ../condor-*Ubuntu16*gz && mv condor* condor)
       if [ $? -ne 0 ]; then
         echo "ERROR: Failed to unpack. ABORTING"
         exit 1
       fi
     else
       echo "Unpack Ubuntu18 version"
       (cd tmpunpack && tar -xzf ../condor-*Ubuntu18*gz && mv condor* condor)
       if [ $? -ne 0 ]; then
         echo "ERROR: Failed to unpack. ABORTING"
         exit 1
       fi
     fi

   else
      echo "ERROR: Unknown Linux release. ABORTING"
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
