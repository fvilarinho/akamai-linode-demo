#!/bin/bash

cd iac

KUBECTL_CMD=`which kubectl`

if [ ! -f "$KUBECTL_CMD" ]; then
  echo "Kubectl is not installed! Please install it first to continue!"

  exit 1
fi

TERRAFORM_CMD=`which terraform`

if [ -z "$TERRAFORM_CMD" ]; then
  echo "Terraform is not installed! Please install it first to continue!"

  exit 1
fi

# Execute the provisioning based on the IaC definition file (main.tf).
$TERRAFORM_CMD init --upgrade
$TERRAFORM_CMD plan -var "linode_token=$LINODE_TOKEN"
$TERRAFORM_CMD apply -auto-approve \
                     -var "linode_token=$LINODE_TOKEN"

# Get the IP of the cluster manager used to deploy the application.
#export CLUSTER_MANAGER_IP=$($TERRAFORM_CMD output -raw cluster-manager-ip)

# Get and set the kubernetes settings used to orchestrate the deploy the application.
#echo "$LINODE_SSH_KEY" > /tmp/.id_rsa
#chmod og-rwx /tmp/.id_rsa
#scp -i /tmp/.id_rsa -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@$CLUSTER_MANAGER_IP:/etc/rancher/k3s/k3s.yaml /tmp/.kubeconfig
#sed -i -e 's|127.0.0.1|'"$CLUSTER_MANAGER_IP"'|g' /tmp/.kubeconfig

# Define the version to be deployed.
#DATABASE_BUILD_VERSION=$(md5sum -b /tmp/demo-database.tar | awk '{print $1}')
#BACKEND_BUILD_VERSION=$(md5sum -b /tmp/demo-backend.tar | awk '{print $1}')
#FRONTEND_BUILD_VERSION=$(md5sum -b /tmp/demo-frontend.tar | awk '{print $1}')

#cp ./kubernetes.yml /tmp/kubernetes.yml
#sed -i -e 's|${DOCKER_REGISTRY_URL}|'"$DOCKER_REGISTRY_URL"'|g' /tmp/kubernetes.yml
#sed -i -e 's|${DOCKER_REGISTRY_ID}|'"$DOCKER_REGISTRY_ID"'|g' /tmp/kubernetes.yml
#sed -i -e 's|${DATABASE_BUILD_VERSION}|'"$DATABASE_BUILD_VERSION"'|g' /tmp/kubernetes.yml
#sed -i -e 's|${BACKEND_BUILD_VERSION}|'"$BACKEND_BUILD_VERSION"'|g' /tmp/kubernetes.yml
#sed -i -e 's|${FRONTEND_BUILD_VERSION}|'"$FRONTEND_BUILD_VERSION"'|g' /tmp/kubernetes.yml

# Deploy the application.
#$KUBECTL_CMD --kubeconfig=/tmp/.kubeconfig apply -f /tmp/kubernetes.yml

# Clear temporary files.
#rm -f /tmp/kubernetes.yml*
#rm -f /tmp/.kubeconfig*
#rm -f /tmp/.id_rsa*

cd ..