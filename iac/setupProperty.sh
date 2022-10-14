#!/bin/bash

JQ_CMD=`which jq`

if [ ! -f "$JQ_CMD" ]; then
  echo "Jq tool is not installed! Please install it first to continue!"

  exit 1
fi

if [ -z "$1" ]; then
  echo "The Origin Hostname must be specified!"

  exit 1
fi

cd ./property-snippets

$JQ_CMD '.rules.behaviors[0].options.hostname = "'$1'"' main.json > /tmp/main.json.modified
cp /tmp/main.json.modified ./main.json
rm /tmp/main.json.modified

cd ..