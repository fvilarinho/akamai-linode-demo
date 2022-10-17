#!/bin/bash

# Locate Docker installation.
DOCKER_CMD=`which docker`
JQ_CMD=`which jq`

# Check if the Docker is installed.
if [ ! -f "$DOCKER_CMD" ]; then
  echo "Docker is not installed! Please install it first to continue!"

  exit 1
fi

# Check if the Jq is installed.
if [ ! -f "$DOCKER_CMD" ]; then
  echo "Jq tool is not installed! Please install it first to continue!"

  exit 1
fi

cd iac

# Check if the purge content definition exists.
if [ -f "purgeContent.json" ]; then
  HOSTNAME=`cat purgeContent.json | $JQ_CMD -r '.hostname'`
  URLS_TO_PURGE=`cat purgeContent.json | $JQ_CMD -r '.urls[]'`
  CPCODES_TO_PURGE=`cat purgeContent.json | $JQ_CMD -r '.cpCodes[]'`

  # Check if the hostname is defined.
  if [ ! -z "$HOSTNAME" ]; then
    # Create the Akamai EdgeGrid credentials file.
    echo "[ccu]" > /tmp/.edgerc
    echo "host = $AKAMAI_EDGEGRID_HOST" >> /tmp/.edgerc
    echo "client_secret = $AKAMAI_EDGEGRID_CLIENT_SECRET" >> /tmp/.edgerc
    echo "client_token = $AKAMAI_EDGEGRID_CLIENT_TOKEN" >> /tmp/.edgerc
    echo "access_token = $AKAMAI_EDGEGRID_ACCESS_TOKEN" >> /tmp/.edgerc

    # Check if there are URLs to purge.
    if [ ! -z "$URLS_TO_PURGE" ]; then
      for URL_TO_PURGE in $URLS_TO_PURGE
      do
        $DOCKER_CMD run --name purge -it -v /tmp/.edgerc:/root/.edgerc akamai/purge:latest akamai purge invalidate --staging $HOSTNAME/$URL_TO_PURGE
        $DOCKER_CMD rm purge
      done
    fi

    # Check if there are CP Codes to purge.
    if [ ! -z "$CPCODES_TO_PURGE" ]; then
      for CPCODE_TO_PURGE in $CPCODES_TO_PURGE
      do
        $DOCKER_CMD run --name purge -it -v /tmp/.edgerc:/root/.edgerc akamai/purge:latest akamai purge invalidate --staging --cpcode $CPCODE_TO_PURGE
        $DOCKER_CMD rm purge
      done
    fi

    # Remove temporary files.
    rm /tmp/.edgerc
  fi
fi

cd ..