#!/bin/bash

# Define the Elasticsearch URL
ES_URL="${ES_URL}"

# Define the Elasticsearch credentials
ES_USER="${ES_USER}"
ES_PASS=$(gopass show -o personal/homeops/logging/elastic)

# Get the ILM policy name from the command-line argument
POLICY_NAME="$1"

# Check if an ILM policy name was provided
if [ -z "$POLICY_NAME" ]; then
  echo "Usage: $0 <ilm_policy_name>"
  exit 1
fi

# Make a GET request to the specific ILM policy endpoint and save the JSON response
POLICY_JSON=$(curl -sSL -u "$ES_USER:$ES_PASS" "$ES_URL/_ilm/policy/$POLICY_NAME")

# Extract and format the desired portion of the JSON response using jq
FORMATTED_POLICY_JSON=$(echo "$POLICY_JSON" | jq '.[].policy | { _meta, phases }')

# Create a JSON file with the formatted policy content
SAVE_DIR="ilm_policy"
JSON_FILE="$SAVE_DIR/$POLICY_NAME.json"

# Add the "policy" object to the beginning of the formatted JSON content
echo "{\"policy\": $FORMATTED_POLICY_JSON}" | jq '.' > "$JSON_FILE"

echo "ILM policy JSON saved to $JSON_FILE"
