#!/bin/bash
set -e

# Get token from master node
TOKEN=$(ssh pi@rasp-111 "sudo cat /var/lib/rancher/k3s/server/node-token")

curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION=${K3S_VERSION} \
  K3S_URL=https://192.168.0.111:6443 \
  K3S_TOKEN=${TOKEN} \
  sh -

echo "K3s worker node installation completed with version ${K3S_VERSION}"
