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

# Build docker images.
cd iac
source ./.env
$DOCKER_COMPOSE_CMD build

# Save images locally.
rm -f /tmp/demo-*.tar

$DOCKER_CMD save $DOCKER_REGISTRY_URL/$DOCKER_REGISTRY_ID/demo-database:$BUILD_VERSION -o /tmp/demo-database.tar
$DOCKER_CMD save $DOCKER_REGISTRY_URL/$DOCKER_REGISTRY_ID/demo-backend:$BUILD_VERSION -o /tmp/demo-backend.tar
$DOCKER_CMD save $DOCKER_REGISTRY_URL/$DOCKER_REGISTRY_ID/demo-frontend:$BUILD_VERSION -o /tmp/demo-frontend.tar

cd ..