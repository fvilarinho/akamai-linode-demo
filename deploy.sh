#!/bin/bash

cd iac

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

cd ..