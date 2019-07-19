FROM sfiligoi/prp-htcondor-pool:htcondor-bins

# Get CA certs from OSG
RUN yum -y install https://repo.opensciencegrid.org/osg/3.4/osg-3.4-el7-release-latest.rpm && \
    yum -y install epel-release \
                   yum-plugin-priorities && \
    yum -y install  \
                   osg-ca-certs \
                   cilogon-openid-ca-cert && \


# The startup script will copy out of /opt/htcondor/downloads/
ADD unpack.sh /opt/htcondor/downloads/

ADD start_condor_wn.sh /opt/htcondor/


# Note: This container assumes there is a shared /docker-init available
ADD startup.sh /usr/bin/wn-init-startup.sh

CMD ["/usr/bin/wn-init-startup.sh"] 

