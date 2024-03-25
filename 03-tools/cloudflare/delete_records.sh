#!/bin/bash

ZONE_ID="${ZONE_ID}"
AUTH_EMAIL="${AUTH_EMAIL}"
AUTH_KEY="${AUTH_KEY}"

# Get the DNS record IDs
record_ids=$(curl -s --request GET \
  --url "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records" \
  --header "Content-Type: application/json" \
  --header "X-Auth-Email: $AUTH_EMAIL" \
  --header "X-Auth-Key: $AUTH_KEY" | jq -r '.result[].id')

# Loop through the IDs and fetch details for each DNS record
for id in $record_ids; do
  curl -s --request DELETE \
    --url "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records/$id" \
    --header "Content-Type: application/json" \
    --header "X-Auth-Email: $AUTH_EMAIL" \
    --header "X-Auth-Key: $AUTH_KEY"
  echo ""  # Add an empty line for separation between records
done

