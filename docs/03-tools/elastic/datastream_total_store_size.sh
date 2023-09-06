#!/bin/bash

# Define Elasticsearch credentials
ES_USER="${ES_USER}"
ES_PASS=$(gopass show -o personal/homeops/logging/elastic)

# Define Elasticsearch URL
ES_URL="${ES_URL}"

# Fetch the data_stream_stats using _data_stream/_stats
DATA_STREAM_STATS=$(curl -sSL -u "$ES_USER:$ES_PASS" "$ES_URL/_data_stream/_stats")

# Extract the relevant information from the response
STORE_SIZE_BYTES=$(echo "$DATA_STREAM_STATS" | jq -r '.total_store_size_bytes')
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%S.000Z")
MESSAGE='{"@timestamp":"'"$TIMESTAMP"'","message":'"$DATA_STREAM_STATS"'}'

# Ingest the JSON message into the index
curl -sSL -u "$ES_USER:$ES_PASS" -X POST "$ES_URL/logs-data-stream-test/_doc/" -H 'Content-Type: application/json' -d "$MESSAGE"
