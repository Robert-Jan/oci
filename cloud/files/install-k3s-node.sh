#!/bin/bash

wait_for_master() {
    while [ true ]
    do
        curl --output /dev/null --silent -k https://${k3s_url}:6443
        if [[ "$?" -eq 0 ]]; then
            break
        fi
        sleep 5
        echo "Wait for Master"
    done
}

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
DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y  python3 python3-pip open-iscsi curl util-linux
pip install oci-cli

# Gather network data
local_ip=$(curl -s -H "Authorization: Bearer Oracle" -L http://169.254.169.254/opc/v2/vnics/ | jq -r '.[0].privateIp')
flannel_iface=$(ip -4 route ls | grep default | grep -Po '(?<=dev )(\S+)')

wait_for_master

echo "Installing K3S and joining cluster ${k3s_url}"

until (curl -sfL https://get.k3s.io | K3S_TOKEN=${k3s_token} K3S_URL=https://${k3s_url}:6443 sh -s - --node-ip $local_ip --flannel-iface $flannel_iface); do
    echo 'K3S did not install correctly'
    sleep 2
done

echo "Done"