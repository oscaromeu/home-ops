#!/bin/bash

# Define the Elasticsearch URL
ES_URL="${ES_URL}"

# Define the Elasticsearch credentials
ES_USER="${ES_USER}"
ES_PASS=$(gopass show -o personal/homeops/logging/elastic)

# Make a GET request to the ILM policy endpoint and extract policy names without "managed" field using jq
POLICY_NAMES=$(curl -sSL -u "$ES_USER:$ES_PASS" "$ES_URL/_ilm/policy" | jq -r '. | to_entries[] | select(.value.policy._meta.managed == null) | .key')

# Iterate through the policy names
for POLICY_NAME in $POLICY_NAMES; do
  echo "Processing policy: $POLICY_NAME"

  # Perform any desired action with each policy name here
  # For example, you could call another script or perform some operation
done
