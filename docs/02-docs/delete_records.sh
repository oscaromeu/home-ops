#!/bin/bash

ZONE_ID="25ccc3c437cf8f7e516110cf942c2b10"
AUTH_EMAIL="oscaromeu@gmail.com"
AUTH_KEY="b1b66a7f16f17cde4d3eefa18e42c8e825c55"

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

