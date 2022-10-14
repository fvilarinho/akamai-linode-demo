#!/bin/bash

# Locate Snyk binary.
SNYK_CMD=`which snyk`

# Check if the Snyk was found.
if [ ! -f "$SNYK_CMD" ]; then
  echo "Snyk is not installed! Please install it first to continue!"

  exit 1
fi

# Execute the libraries analysis with Snyk. Check only high severities.
$SNYK_CMD test ./backend --severity-threshold=high