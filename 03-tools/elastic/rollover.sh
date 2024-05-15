#!/bin/bash
# Define the Elasticsearch credentials
ES_USER="${ES_USER}"
ES_PASS=$(gopass show -o personal/homeops/logging/elastic)

# Get the ILM policy name from the command-line argument
DATA_STREAM_NAME="$1"

if [ -z "$ES_URL" ] || [ -z "$ES_USER" ] || [ -z "$ES_PASS" ]; then
    echo "Please provide ES_URL, ES_USER, and ES_PASS environment variables."
    exit 1
fi


# Check if ds argument is provided

if [-z "$DATA_STREAM_NAME"]; then
    echo "I can't rollover a datastream without a target. Please provide a datastream name"
    exit 1
fi

# Make a curl request to Elasticsearch and process the output
curl_output=$(curl -sSL -u "$ES_USER":"$ES_PASS" "$ES_URL/$DATA_STREAM_NAME/_rollover&dry_run=true)


echo "$curl_output"
