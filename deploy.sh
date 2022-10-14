#!/bin/bash

cd iac

TERRAFORM_CMD=`which terraform`

if [ -z "$TERRAFORM_CMD" ]; then
  echo "Terraform is not installed! Please install it first to continue!"

  exit 1
fi

AKAMAI_PROPERTY_ACTIVATION_NETWORK=$1

if [ -z "$AKAMAI_PROPERTY_ACTIVATION_NETWORK" ]; then
  AKAMAI_PROPERTY_ACTIVATION_NETWORK=staging
fi

AKAMAI_PROPERTY_ACTIVATION_NOTES=$2

if [ -z "$AKAMAI_PROPERTY_ACTIVATION_NOTES" ]; then
  AKAMAI_PROPERTY_ACTIVATION_NOTES="General changes."
fi

$TERRAFORM_CMD init --upgrade
$TERRAFORM_CMD plan -var "linode_token=$LINODE_TOKEN" \
                    -var "akamai_property_activation_network=$AKAMAI_PROPERTY_ACTIVATION_NETWORK" \
                    -var "akamai_property_activation_notes=$AKAMAI_PROPERTY_ACTIVATION_NOTES"

$TERRAFORM_CMD apply -auto-approve \
                     -var "linode_token=$LINODE_TOKEN" \
                     -var "akamai_property_activation_network=$AKAMAI_PROPERTY_ACTIVATION_NETWORK" \
                     -var "akamai_property_activation_notes=$AKAMAI_PROPERTY_ACTIVATION_NOTES"

cd ..