#!/bin/bash

cd iac

# Define the terraform client used to provision the infrastructure.
TERRAFORM_CMD=`which terraform`

if [ -z "$TERRAFORM_CMD" ]; then
  echo "Terraform is not installed! Please install it first to continue!"

  exit 1
fi

# Execute the de-provisioning based on the IaC definition file (main.tf).
$TERRAFORM_CMD destroy -auto-approve \
                       -var "linode_token=$LINODE_TOKEN"

cd ..