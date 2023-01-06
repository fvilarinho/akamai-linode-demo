#!/bin/bash

# Locate Terraform binary.
TERRAFORM_CMD=`which terraform`

# Check if the Terraform was found.
if [ -z "$TERRAFORM_CMD" ]; then
  echo "Terraform is not installed! Please install it first to continue!"

  exit 1
fi

cd iac

source .env

# Create Akamai credentials file.
echo "[default]" > .edgerc
echo "host = $AKAMAI_EDGEGRID_HOST" >> .edgerc
echo "access_token = $AKAMAI_EDGEGRID_ACCESS_TOKEN" >> .edgerc
echo "client_token = $AKAMAI_EDGEGRID_CLIENT_TOKEN" >> .edgerc
echo "client_secret = $AKAMAI_EDGEGRID_CLIENT_SECRET" >> .edgerc
echo "account_key = $(cat variables.tf | grep account | cut -d '=' -f2 | awk '{print $2}' | tr -d \")" >> .edgerc

# Create Terraform state persistence in Linode.
if [ -d "~/.aws" ]; then
  mv ~/.aws ~/.aws.old
fi

mkdir -p ~/.aws

echo "[default]" > ~/.aws/config
echo "output = json" >> ~/.aws/config
echo "region = us-east-1" > ~/.aws/config

echo "[default]" > ~/.aws/credentials
echo "aws_access_key_id=$LINODE_OBJECT_STORAGE_ACCESS_KEY" >> ~/.aws/credentials
echo "aws_secret_access_key=$LINODE_OBJECT_STORAGE_SECRET_KEY" >> ~/.aws/credentials

# Execute the provisioning based on the IaC definition file (main.tf).
$TERRAFORM_CMD init --upgrade

status=`echo $?`

if [ $status -eq 0 ]; then
  $TERRAFORM_CMD plan -var "linode_token=$LINODE_TOKEN" \
                      -var "linode_public_key=$LINODE_PUBLIC_KEY" \
                      -var "linode_private_key=$LINODE_PRIVATE_KEY"

  status=`echo $?`

  if [ $status -eq 0 ]; then
    $TERRAFORM_CMD apply -auto-approve \
                         -var "linode_token=$LINODE_TOKEN" \
                         -var "linode_public_key=$LINODE_PUBLIC_KEY" \
                         -var "linode_private_key=$LINODE_PRIVATE_KEY"

    status=`echo $?`
  fi
fi

rm -rf .edgerc
rm -rf ~/.aws

if [ -d "~/.aws.old" ]; then
  mv ~/.aws.old ~/.aws
fi

cd ..

exit $status