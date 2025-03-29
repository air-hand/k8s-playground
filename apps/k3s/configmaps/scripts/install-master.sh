#!/bin/bash
set -e

curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION=${K3S_VERSION} sh -s - server \
  --disable traefik \
  --write-kubeconfig-mode 644

# Wait for node-token
while [ ! -f /var/lib/rancher/k3s/server/node-token ]; do
  sleep 1
done

echo "K3s master node installation completed with version ${K3S_VERSION}"
