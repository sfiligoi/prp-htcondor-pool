#!/bin/bash

# Copy over the HTCondor binaries and the related files
mkdir -p /docker-init/htcondor/downloads

cp /opt/htcondor/downloads/* /docker-init/htcondor/downloads/

cp /opt/htcondor/*.sh /docker-init/htcondor/
echo "HTCondor init files in /docker-init/htcondor"

# Copy over the CA certs
yum update -y osg-ca-certs cilogon-openid-ca-cert
(cd /etc/grid-security && tar -czf /docker-init/certificates.tgz certificates)
echo "Certificates in /docker-init/certificates.tgz"

