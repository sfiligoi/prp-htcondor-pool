This directory contains the files needed to setup a bare-metal Ubuntu-based submit node

Assuming you have a clean Ubuntu18 installation,
just run
sudo ./condor_install.sh
and you should be good to go.

Note that port 9618 must allow incoming TCP traffic.

Running in the Clouds or reverse-NAT setups:
============================================

If the node can only be reached through a reverse-NAT setup (e.g. in the clouds), add
echo "TCP_FORWARDING_HOST = ${EXTERNAL_IP}" > /etc/condor/config.d/90_nat.config
and restart the condor service.
