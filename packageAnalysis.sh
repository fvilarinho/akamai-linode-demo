#!/bin/bash

# Locate Snyk binary.
SNYK_CMD=`which snyk`

# Check if the Snyk was found.
if [ ! -f "$SNYK_CMD" ]; then
  echo "Snyk is not installed! Please install it first to continue!"

  exit 1
fi

# Execute packaging analysis for the database image.
$SNYK_CMD container test --severity-threshold=high docker-archive:/tmp/demo-database.tar --file=./database/Dockerfile

status=`echo $?`

# Check if there is any vulnerability.
if [ $status -eq 0 ]; then
  # Execute packaging analysis for the backend image.
	$SNYK_CMD container test --severity-threshold=high docker-archive:/tmp/demo-backend.tar --file=./backend/Dockerfile

	status=`echo $?`

  # Check if there is any vulnerability.
	if [ $status -eq 0 ]; then
    # Execute packaging analysis for the frontend image.
		$SNYK_CMD container test --severity-threshold=high docker-archive:/tmp/demo-frontend.tar --file=./frontend/Dockerfile

		status=`echo $?`
	fi
fi

# Return if there is any vulnerability.
exit $status