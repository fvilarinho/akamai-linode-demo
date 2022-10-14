#!/bin/bash

# Locate Terraform binary.
TERRAFORM_CMD=`which terraform`

# Check if the Terraform was found.
if [ -z "$TERRAFORM_CMD" ]; then
  echo "Terraform is not installed! Please install it first to continue!"

  exit 1
fi

AKAMAI_PROPERTY_ACTIVATION_NETWORK=$1

# Check if the Akamai activation network is defined. If it isn't set the default value.
if [ -z "$AKAMAI_PROPERTY_ACTIVATION_NETWORK" ]; then
  AKAMAI_PROPERTY_ACTIVATION_NETWORK=staging
fi

AKAMAI_PROPERTY_ACTIVATION_NOTES=$2

# Check if the Akamai activation notes is defined. If it isn't set the default value.
if [ -z "$AKAMAI_PROPERTY_ACTIVATION_NOTES" ]; then
  AKAMAI_PROPERTY_ACTIVATION_NOTES="General changes."
fi

# Authenticate in Terraform Cloud to store the states.
if [ ! -d "~/.terraform.d" ]; then
  mkdir -p ~/.terraform.d
fi

cd iac

cp -f credentials.tfrc.json /tmp
sed -i -e 's|${TERRAFORM_CLOUD_TOKEN}|'"$TERRAFORM_CLOUD_TOKEN"'|g' /tmp/credentials.tfrc.json
cp -f /tmp/credentials.tfrc.json ~/.terraform.d
rm -f /tmp/credentials.tfrc.json

source .env

echo $AKAMAI_PROPERTY_ACTIVATION_NOTES

# Execute the provisioning based on the IaC definition file (main.tf).
$TERRAFORM_CMD init --upgrade
$TERRAFORM_CMD plan -var "linode_token=$LINODE_TOKEN" \
                    -var "linode_public_key=$LINODE_PUBLIC_KEY" \
                    -var "linode_private_key=$LINODE_PRIVATE_KEY" \
                    -var "akamai_edgegrid_host=$AKAMAI_EDGEGRID_HOST" \
                    -var "akamai_edgegrid_access_token=$AKAMAI_EDGEGRID_ACCESS_TOKEN" \
                    -var "akamai_edgegrid_client_token=$AKAMAI_EDGEGRID_CLIENT_TOKEN" \
                    -var "akamai_edgegrid_client_secret=$AKAMAI_EDGEGRID_CLIENT_SECRET" \
                    -var "akamai_property_activation_network=$AKAMAI_PROPERTY_ACTIVATION_NETWORK" \
                    -var "akamai_property_activation_notes=$AKAMAI_PROPERTY_ACTIVATION_NOTES"
$TERRAFORM_CMD apply -auto-approve \
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