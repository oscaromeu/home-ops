#!/bin/bash

# Define the Elasticsearch URL
ES_URL="${ES_URL}"

# Define the Elasticsearch credentials
ES_USER="elastic"
ES_PASS="QW5vA1bjf38O355DmC1Q1n5k"
METRIC=$1

# Define the Elasticsearch API endpoint
ES_ENDPOINT="${ES_URL}/_nodes/stats"

# Make the GET request using curl with authentication
curl -sSL -u "$ES_USER:$ES_PASS" "$ES_ENDPOINT"
