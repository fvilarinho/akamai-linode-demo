#!/bin/bash

SNYK_CMD=`which snyk`

if [ ! -f "$SNYK_CMD" ]; then
  echo "Snyk is not installed! Please install it first to continue!"

  exit 1
fi

# Execute the libraries analysis with Snyk. Check only high severities.
$SNYK_CMD test ./backend --severity-threshold=high