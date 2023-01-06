#!/bin/bash

# Locate Kubectl binary.
KUBECTL_CMD=`which kubectl`
SCP_CMD=`which scp`

# Check if the Kubectl was found.
if [ ! -f "$KUBECTL_CMD" ]; then
  echo "Kubectl is not installed! Please install it first to continue!"

  exit 1
fi

# Check if the Openssh client was found.
if [ ! -f "$SCP_CMD" ]; then
  echo "Openssh client is not installed! Please install it first to continue!"

  exit 1
fi

NODE_MANAGER_IP=$1

# Check if the manager node IP is defined.
if [ -z "$NODE_MANAGER_IP" ]; then
  echo "Please specify the manager node IP!"

  exit 1
fi

source .env

# Download kubeconfig to be able to connect in the cluster.
rm -rf ./kubeconfig*
$SCP_CMD -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@$NODE_MANAGER_IP:/etc/rancher/k3s/k3s.yaml /tmp/kubeconfig
sed -i -e 's|127.0.0.1|'"$NODE_MANAGER_IP"'|g' /tmp/kubeconfig
cp /tmp/kubeconfig ./kubeconfig

export KUBECONFIG=./kubeconfig

# Prepare the stack manifest.
cp ./kubernetes.yml /tmp/kubernetes.yml
sed -i -e 's|${DOCKER_REGISTRY_URL}|'"$DOCKER_REGISTRY_URL"'|g' /tmp/kubernetes.yml
sed -i -e 's|${DOCKER_REGISTRY_ID}|'"$DOCKER_REGISTRY_ID"'|g' /tmp/kubernetes.yml
sed -i -e 's|${BUILD_VERSION}|'"$BUILD_VERSION"'|g' /tmp/kubernetes.yml

# Apply the stack.
$KUBECTL_CMD apply -f /tmp/kubernetes.yml

rm -f /tmp/kubernetes.yml
rm -rf ./kubeconfig*

cd ..