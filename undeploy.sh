#!/bin/bash

# Define the terraform client used to provision the infrastructure.
TERRAFORM_CMD=`which terraform`

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

echo "[terraform]" > .edgerc
echo "host = $AKAMAI_APIS_HOST" >> .edgerc
echo "access_token = $AKAMAI_APIS_ACCESS_TOKEN" >> .edgerc
echo "client_token = $AKAMAI_APIS_CLIENT_TOKEN" >> .edgerc
echo "client_secret = $AKAMAI_APIS_CLIENT_SECRET" >> .edgerc
echo "account_key = $AKAMAI_APIS_ACCOUNT_KEY" >> .edgerc

cp -f credentials.tfrc.json /tmp
sed -i -e 's|${TERRAFORM_CLOUD_TOKEN}|'"$TERRAFORM_CLOUD_TOKEN"'|g' /tmp/credentials.tfrc.json
cp -f /tmp/credentials.tfrc.json ~/.terraform.d
rm -f /tmp/credentials.tfrc.json

# Execute the de-provisioning based on the IaC definition file (main.tf).
$TERRAFORM_CMD init --upgrade
$TERRAFORM_CMD destroy -auto-approve \
                       -var "linode_token=$LINODE_TOKEN" \
                       -var "linode_public_key=$LINODE_PUBLIC_KEY" \
                       -var "linode_private_key=$LINODE_PRIVATE_KEY"

cd ..