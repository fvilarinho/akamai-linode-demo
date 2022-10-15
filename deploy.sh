#!/bin/bash

# Locate Terraform binary.
TERRAFORM_CMD=`which terraform`

# Check if the Terraform was found.
if [ -z "$TERRAFORM_CMD" ]; then
  echo "Terraform is not installed! Please install it first to continue!"

  exit 1
fi

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
if [ -z "$AKAMAI_PROPERTY_ACTIVATION_NOTES" ]; then
  GIT_CMD=`which git`

  if [ -f "$GIT_CMD" ]; then
    AKAMAI_PROPERTY_ACTIVATION_NOTES=$($GIT_CMD log -n 1 --pretty=format:'%s')
  fi
fi

AKAMAI_PROPERTY_LAST_ACTIVATION_NOTES="$($TERRAFORM_CMD state show local_file.akamai_property_activation_notes | grep content | awk -F " = " '{ print $2 }')"
AKAMAI_PROPERTY_LAST_ACTIVATION_NOTES=$(echo "$AKAMAI_PROPERTY_LAST_ACTIVATION_NOTES" | sed 's/"//g')

$TERRAFORM_CMD init --upgrade
$TERRAFORM_CMD plan -var "linode_token=$LINODE_TOKEN" \
                    -var "linode_public_key=$LINODE_PUBLIC_KEY" \
                    -var "linode_private_key=$LINODE_PRIVATE_KEY" \
                    -var "akamai_edgegrid_host=$AKAMAI_EDGEGRID_HOST" \
                    -var "akamai_edgegrid_access_token=$AKAMAI_EDGEGRID_ACCESS_TOKEN" \
                    -var "akamai_edgegrid_client_token=$AKAMAI_EDGEGRID_CLIENT_TOKEN" \
                    -var "akamai_edgegrid_client_secret=$AKAMAI_EDGEGRID_CLIENT_SECRET" \
                    -var "akamai_property_activation_network=$AKAMAI_PROPERTY_ACTIVATION_NETWORK" \
                    -var "akamai_property_activation_notes=$AKAMAI_PROPERTY_ACTIVATION_NOTES" \
                    -var "akamai_property_last_activation_notes=$AKAMAI_PROPERTY_LAST_ACTIVATION_NOTES"
$TERRAFORM_CMD apply -auto-approve \
                     -var "linode_token=$LINODE_TOKEN" \
                     -var "linode_public_key=$LINODE_PUBLIC_KEY" \
                     -var "linode_private_key=$LINODE_PRIVATE_KEY" \
                     -var "akamai_edgegrid_host=$AKAMAI_EDGEGRID_HOST" \
                     -var "akamai_edgegrid_access_token=$AKAMAI_EDGEGRID_ACCESS_TOKEN" \
                     -var "akamai_edgegrid_client_token=$AKAMAI_EDGEGRID_CLIENT_TOKEN" \
                     -var "akamai_edgegrid_client_secret=$AKAMAI_EDGEGRID_CLIENT_SECRET" \
                     -var "akamai_property_activation_network=$AKAMAI_PROPERTY_ACTIVATION_NETWORK" \
                     -var "akamai_property_activation_notes=$AKAMAI_PROPERTY_ACTIVATION_NOTES" \
                     -var "akamai_property_last_activation_notes=$AKAMAI_PROPERTY_LAST_ACTIVATION_NOTES"

cd ..