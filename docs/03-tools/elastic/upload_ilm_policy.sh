#!/bin/bash

# Define the Elasticsearch URL
ES_URL="${ES_URL}"

# Define the Elasticsearch credentials
ES_USER="${ES_USER}"
ES_PASS="${ES_PASS}"

# Get the JSON file path from the command-line argument
JSON_FILE="$1"

# Check if a JSON file was provided
if [ -z "$JSON_FILE" ]; then
  echo "Usage: $0 <path_to_json_file>"
  exit 1
fi

# Read the JSON content from the provided file
JSON_CONTENT=$(cat "$JSON_FILE")

# Extract the ILM policy name from the filename
ILM_POLICY_NAME=$(basename "$JSON_FILE" .json)

# Construct the full URL for the ILM policy
ILM_POLICY_URL="$ES_URL/_ilm/policy/$ILM_POLICY_NAME"

# Send the JSON using curl to create/update the ILM policy
curl -X PUT "$ILM_POLICY_URL" -H "Content-Type: application/json" -u "$ES_USER:$ES_PASS" -d "$JSON_CONTENT"
