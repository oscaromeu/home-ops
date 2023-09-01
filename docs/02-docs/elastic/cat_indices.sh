#!/bin/bash
# Define the Elasticsearch credentials
ES_USER="${ES_USER}"
ES_PASS=$(gopass show -o personal/homeops/logging/elastic)

if [ -z "$ES_URL" ] || [ -z "$ES_USER" ] || [ -z "$ES_PASS" ]; then
    echo "Please provide ES_URL, ES_USER, and ES_PASS environment variables."
    exit 1
fi

# Make a curl request to Elasticsearch and process the output
curl_output=$(curl -sSL -u "$ES_USER":"$ES_PASS" "$ES_URL/_cat/indices/?v&s=index&bytes=b")
indices=$(echo "$curl_output" )

echo "$indices"
