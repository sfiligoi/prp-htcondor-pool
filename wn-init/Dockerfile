FROM sfiligoi/prp-htcondor-pool:htcondor-bins

# The startup script will copy out of /opt/htcondor/downloads/
ADD unpack.sh /opt/htcondor/downloads/

ADD start_personal_condor.sh /opt/htcondor/


# Note: This container assumes there is a shared /docker-init available
ADD startup.sh /usr/bin/wn-init-startup.sh

CMD ["/usr/bin/wn-init-startup.sh"] 

