#!/bin/bash

# Define the terraform client used to provision the infrastructure.
TERRAFORM_CMD=`which terraform`

if [ -z "$TERRAFORM_CMD" ]; then
  echo "Terraform is not installed! Please install it first to continue!"

  exit 1
fi

cd iac

source .env

# Execute the de-provisioning based on the IaC definition file (main.tf).
$TERRAFORM_CMD destroy -auto-approve \
                       -var "linode_token=$LINODE_TOKEN" \
                       -var "akamai_property_activation_network=$AKAMAI_PROPERTY_ACTIVATION_NETWORK" \
                       -var "akamai_property_activation_notes=$AKAMAI_PROPERTY_ACTIVATION_NOTES"

cd ..