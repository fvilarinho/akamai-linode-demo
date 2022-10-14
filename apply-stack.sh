#!/bin/bash

KUBECTL_CMD=`which kubectl`

if [ ! -f "$KUBECTL_CMD" ]; then
  echo "Kubectl is not installed! Please install it first to continue!"

  exit 1
fi

source ./iac/.env

cp ./iac/kubernetes.yml /tmp/kubernetes.yml
sed -i -e 's|${DOCKER_REGISTRY_URL}|'"$DOCKER_REGISTRY_URL"'|g' /tmp/kubernetes.yml
sed -i -e 's|${DOCKER_REGISTRY_ID}|'"$DOCKER_REGISTRY_ID"'|g' /tmp/kubernetes.yml
sed -i -e 's|${BUILD_VERSION}|'"$BUILD_VERSION"'|g' /tmp/kubernetes.yml
cp /tmp/kubernetes.yml ./iac/kubernetes.yml
rm /tmp/kubernetes.yml
rm -rf ./iac

$KUBECTL_CMD apply -f ./iac/kubernetes.yml