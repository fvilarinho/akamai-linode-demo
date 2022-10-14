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
$TERRAFORM_CMD init --upgrade
$TERRAFORM_CMD destroy -auto-approve \
                       -var "linode_token=$LINODE_TOKEN" \
                       -var "linode_public_key=$LINODE_PUBLIC_KEY" \
                       -var "linode_private_key=$LINODE_PRIVATE_KEY" \
                       -var "akamai_edgegrid_host=$AKAMAI_EDGEGRID_HOST" \
                       -var "akamai_edgegrid_access_token=$AKAMAI_EDGEGRID_ACCESS_TOKEN" \
                       -var "akamai_edgegrid_client_token=$AKAMAI_EDGEGRID_CLIENT_TOKEN" \
                       -var "akamai_edgegrid_client_secret=$AKAMAI_EDGEGRID_CLIENT_SECRET" \
                       -var "akamai_property_activation_network=$AKAMAI_PROPERTY_ACTIVATION_NETWORK" \
                       -var "akamai_property_activation_notes=$AKAMAI_PROPERTY_ACTIVATION_NOTES"

cd ..