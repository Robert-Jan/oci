#!/bin/bash

# Disable firewall 
/usr/sbin/netfilter-persistent stop
/usr/sbin/netfilter-persistent flush
systemctl stop netfilter-persistent.service
systemctl disable netfilter-persistent.service

# Start services
systemctl enable iscsid.service
systemctl start iscsid.service

# Install dependencies 
apt-get update
apt-get install -y software-properties-common jq
DEBIAN_FRONTEND=noninteractive apt-get upgrade -y
DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y python3 python3-pip open-iscsi curl util-linux
pip install oci-cli

# Gather network data
local_ip= $(curl -s -H "Authorization: Bearer Oracle" -L http://169.254.169.254/opc/v2/vnics/ | jq -r '.[0].privateIp')
flannel_iface=$(ip -4 route ls | grep default | grep -Po '(?<=dev )(\S+)')

echo "Initializing cluster"
until (curl -sfL https://get.k3s.io | K3S_TOKEN=${k3s_token} sh -s - server --disable traefik --node-ip $local_ip --advertise-address $local_ip --flannel-iface $flannel_iface --tls-san ${k3s_url} --write-kubeconfig-mode 644); do
    echo 'K3S did not install correctly'
    sleep 2
done

echo "Done"