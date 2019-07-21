#!/bin/bash


cat > /var/lib/htcondor/config/50_glidein_stop.config <<EOF

# Shutdown the master if the startd exits.  Note that if
# STARTD_StartTime is zero, that the startd is not currently running.
#
MASTER.DAEMON_SHUTDOWN = (STARTD_StartTime =?= 0)

# Start auto-shutdown after 2 days
GLIDEIN_ToDie = ( `date +%s` + 48*3600) 
STARTD.DAEMON_SHUTDOWN = (CurrentTime > ( `date +%s` + 48*3600) )

# Allow jobs up to 2 days
SHUTDOWN_GRACEFUL_TIMEOUT= (48 * 3600)


# How long will it wait in an unclaimed state before exiting
# i.e. Auto-cleanup
STARTD_NOCLAIM_SHUTDOWN = 1200
GLIDEIN_Max_Idle = 1200

EOF

#
# Limit which jobs can run here
#
if [ -z "${OS_IMAGE}" ]; then
  OS_IMAGE=UNKNOWN
fi

cat > /var/lib/htcondor/config/20_uaf_start.config <<EOF

START = stringListMember("${OS_IMAGE}",DESIRED_Images,",") && stringListMember("PRP-k8s",DESIRED_Sites,",")

GLIDEIN_Image = "${OS_IMAGE}"
GLIDEIN_Site = "PRP-k8s"

EOF

cat > /var/lib/htcondor/config/90_uaf_publish.config <<EOF

MASTER_ATTRS = GLIDEIN_ToDie,DaemonStopTime,GLIDEIN_Image,GLIDEIN_Site,GLIDEIN_Max_Idle
STARTD_ATTRS = GLIDEIN_ToDie,START,DaemonStopTime,GLIDEIN_Image,GLIDEIN_Site,GLIDEIN_Graceful_Shutdown,GLIDEIN_Max_Idle

EOF


cat  > /var/lib/htcondor/config/10_ccb_setup.config << EOF

CCB_ADDRESS = $(COLLECTOR_HOST)
PRIVATE_NETWORK_NAME = optiputer.net

# no CCB for the master, will not try to talk to it from remote
MASTER.CCB_ADDRESS =

EOF

