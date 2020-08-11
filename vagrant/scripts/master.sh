#!/bin/bash

set -euo pipefail

export MASTER_IP=$(ip a | grep global | grep -v '10.0.2.15' | awk '{print $2}' | cut -f1 -d '/')

curl -sfL https://get.k3s.io | \
	K3S_KUBECONFIG_MODE="644" \
	INSTALL_K3S_EXEC="--node-ip=${MASTER_IP} --node-external-ip=${MASTER_IP} --bind-address=${MASTER_IP}" \
	sh -

echo $MASTER_IP > /vagrant/master-ip

sudo cp /var/lib/rancher/k3s/server/node-token /vagrant/node-token
sudo cp /etc/rancher/k3s/k3s.yaml /vagrant/k3s.yaml

echo $MASTER_IP
sudo sed -i -e "s/127.0.0.1/${MASTER_IP}/g" /vagrant/k3s.yaml
