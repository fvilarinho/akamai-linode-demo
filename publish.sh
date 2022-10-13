#!/bin/bash

DOCKER_CMD=`which docker`
DOCKER_COMPOSE_CMD=`which docker-compose`

if [ ! -f "$DOCKER_CMD" ]; then
  echo "Docker is not installed! Please install it first to continue!"

  exit 1
fi

if [ ! -f "$DOCKER_COMPOSE_CMD" ]; then
  echo "Docker Compose is not installed! Please install it first to continue!"

  exit 1
fi

# Authenticate in the packaging repository.
source ./iac/.env
echo $DOCKER_REGISTRY_PASSWORD | $DOCKER_CMD login -u $DOCKER_REGISTRY_ID $DOCKER_REGISTRY_URL --password-stdin

# Push images.
$DOCKER_COMPOSE_CMD -f ./iac/docker-compose.yml push