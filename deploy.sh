#!/bin/bash

# Locate Terraform binary.
TERRAFORM_CMD=`which terraform`

# Check if the Terraform was found.
if [ -z "$TERRAFORM_CMD" ]; then
  echo "Terraform is not installed! Please install it first to continue!"

  exit 1
fi

AKAMAI_PROPERTY_ACTIVATION_NETWORK=$1

# Authenticate in Terraform Cloud to store the states.
if [ ! -d "~/.terraform.d" ]; then
  mkdir -p ~/.terraform.d
fi

cd iac

source .env

cp -f credentials.tfrc.json /tmp
sed -i -e 's|${TERRAFORM_CLOUD_TOKEN}|'"$TERRAFORM_CLOUD_TOKEN"'|g' /tmp/credentials.tfrc.json
cp -f /tmp/credentials.tfrc.json ~/.terraform.d
rm -f /tmp/credentials.tfrc.json

# Execute the provisioning based on the IaC definition file (main.tf).
$TERRAFORM_CMD init --upgrade
$TERRAFORM_CMD plan -var "linode_token=$LINODE_TOKEN" \
                    -var "linode_public_key=$LINODE_PUBLIC_KEY" \
                    -var "linode_private_key=$LINODE_PRIVATE_KEY" \
                    -var "akamai_edgegrid_host=$AKAMAI_EDGEGRID_HOST" \
                    -var "akamai_edgegrid_access_token=$AKAMAI_EDGEGRID_ACCESS_TOKEN" \
                    -var "akamai_edgegrid_client_token=$AKAMAI_EDGEGRID_CLIENT_TOKEN" \
                    -var "akamai_edgegrid_client_secret=$AKAMAI_EDGEGRID_CLIENT_SECRET" \
                    -var "akamai_property_activation_network=$AKAMAI_PROPERTY_ACTIVATION_NETWORK"
$TERRAFORM_CMD apply -auto-approve \
                     -var "linode_token=$LINODE_TOKEN" \
                     -var "linode_public_key=$LINODE_PUBLIC_KEY" \
                     -var "linode_private_key=$LINODE_PRIVATE_KEY" \
                     -var "akamai_edgegrid_host=$AKAMAI_EDGEGRID_HOST" \
                     -var "akamai_edgegrid_access_token=$AKAMAI_EDGEGRID_ACCESS_TOKEN" \
                     -var "akamai_edgegrid_client_token=$AKAMAI_EDGEGRID_CLIENT_TOKEN" \
                     -var "akamai_edgegrid_client_secret=$AKAMAI_EDGEGRID_CLIENT_SECRET" \
                     -var "akamai_property_activation_network=$AKAMAI_PROPERTY_ACTIVATION_NETWORK"

cd ..