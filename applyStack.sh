#!/bin/bash

# Locate Kubectl binary.
KUBECTL_CMD=`which kubectl`

# Check if the Kubectl was found.
if [ ! -f "$KUBECTL_CMD" ]; then
  echo "Kubectl is not installed! Please install it first to continue!"

  exit 1
fi

NODE_MANAGER_ID=$1

# Check if the manager node identifier is defined.
if [ -z "$NODE_MANAGER_ID" ]; then
  echo "Please specify the manager node name!"

  exit 1
fi

NODE_WORKER_ID=$1

# Check if the worker node identifier is defined.
if [ -z "$NODE_WORKER_ID" ]; then
  echo "Please specify the worker node name!"

  exit 1
fi

# Apply cluster nodes labels.
$KUBECTL_CMD label node $NODE_MANAGER_ID kubernetes.io/role=manager --overwrite
$KUBECTL_CMD label node $NODE_WORKER_ID kubernetes.io/role=worker --overwrite

cd iac

source .env

# Prepare the stack manifest.
cp ./kubernetes.yml /tmp/kubernetes.yml
sed -i -e 's|${DOCKER_REGISTRY_URL}|'"$DOCKER_REGISTRY_URL"'|g' /tmp/kubernetes.yml
sed -i -e 's|${DOCKER_REGISTRY_ID}|'"$DOCKER_REGISTRY_ID"'|g' /tmp/kubernetes.yml
sed -i -e 's|${BUILD_VERSION}|'"$BUILD_VERSION"'|g' /tmp/kubernetes.yml
cp /tmp/kubernetes.yml ./kubernetes.yaml
rm -f /tmp/kubernetes.yml

# Apply the stack.
$KUBECTL_CMD apply -f ./kubernetes.yaml

cd ..