#!/bin/bash

# Define Grafana API URL and API Key
GRAFANA_URL="https://grafana.oscaromeu.io"
API_KEY="glsa_35731F5zTsra7FmtyTQOEtR9I89eD5xg_45a98d02"

# Define the Elasticsearch data source configuration
DATASOURCE_NAME="Test"
DATASOURCE_TYPE="elasticsearch"
DATASOURCE_URL="http://elasticsearch.oscaromeu.io:9200"  # Elasticsearch endpoint URL
DATASOURCE_ACCESS="proxy"  # Change to "direct" if needed
DATASOURCE_BASIC_AUTH="false"  # Set to "true" if your Elasticsearch requires basic auth
DATASOURCE_USER="elastic"  # Elasticsearch username if basic auth is enabled
DATASOURCE_PASSWORD="$(op item get elastic-api --vault home-ops --fields label=password)"  # Elasticsearch password if basic auth is enabled

# Create the JSON payload for the data source
DATA_SOURCE_JSON=$(cat <<EOF
{
  "name": "$DATASOURCE_NAME",
  "type": "$DATASOURCE_TYPE",
  "url": "$DATASOURCE_URL",
  "access": "$DATASOURCE_ACCESS",
  "basicAuth": $DATASOURCE_BASIC_AUTH,
  "basicAuthUser": "$DATASOURCE_USER",
  "basicAuthPassword": "$DATASOURCE_PASSWORD"
}
EOF
)

# Create the data source in Grafana using the API
RESPONSE=$(curl -s -X POST -H "Authorization: Bearer $API_KEY" \
  -H "Content-Type: application/json" \
  -H "CF-Access-Client-Id: 459e68d0c7fb875509b31d104566f142.access" \
  -H "CF-Access-Client-Secret: dc7183c7d473d534dbd92e5a39e5695717a032dd02036a36d88383e298b4a0e1" \
  --data "$DATA_SOURCE_JSON" \
  "$GRAFANA_URL/api/datasources")

# Check the response for success or failure
if [[ "$RESPONSE" == *"datasource created"* ]]; then
  echo "Elasticsearch data source created successfully."
else
  echo "Error creating Elasticsearch data source: $RESPONSE"
fi
