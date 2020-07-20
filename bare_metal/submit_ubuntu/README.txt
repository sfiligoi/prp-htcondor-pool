This directory contains the files needed to setup a bare-metal Ubuntu-based submit node

Assuming you have a clean Ubuntu18 installation,
just run
sudo ./condor_install.sh
and you should be good to go.

You will be asked to provide a pool password;
choose something random, hard to guess. You will not need to insert it again.

Note that port 9618 must allow incoming TCP traffic.

Running in the Clouds or reverse-NAT setups:
============================================

If the node can only be reached through a reverse-NAT setup (e.g. in the clouds), add
sudo echo "TCP_FORWARDING_HOST = ${EXTERNAL_IP}" > /etc/condor/config.d/90_nat.config
and restart the condor service:
sudo systemctl restart condor


Adding kubernetes client
========================

Since you will probably add resources through Kuberrnetes, you may want to install kubectl, too.
The provided support script will do that for you
sudo ./kubectl_install.sh


Note that you will need to manually add the needed configuration/authorization file for each user in their
~/.kube/config

