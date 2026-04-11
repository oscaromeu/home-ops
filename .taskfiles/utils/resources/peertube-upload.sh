#!/bin/bash

# ==============================
# Configuration
# ==============================

INSTANCE="${INSTANCE:-https://peertube.oscaromeu.io}"
CHANNEL_ID="${CHANNEL_ID:-7}"
USERNAME="${PT_USER}"
PASSWORD="${PT_PASS}"
PRIVACY="${PRIVACY:-1}"            # 1 = public, 2 = unlisted, 3 = private

VIDEO_FILE="$1"
VIDEO_NAME="$2"

# ==============================
# Checks
# ==============================

if ! command -v curl &> /dev/null; then
    echo "Error: curl is not installed."
    exit 1
fi

if ! command -v jq &> /dev/null; then
    echo "Error: jq is not installed."
    exit 1
fi

if [[ -z "$VIDEO_FILE" || -z "$VIDEO_NAME" ]]; then
    echo "Usage: $0 <video_file> \"video title\""
    exit 1
fi

if [[ ! -f "$VIDEO_FILE" ]]; then
    echo "Error: file '$VIDEO_FILE' does not exist."
    exit 1
fi

if [[ -z "$USERNAME" || -z "$PASSWORD" ]]; then
    echo "Error: PT_USER and PT_PASS must be set."
    exit 1
fi

# ==============================
# Authentication
# ==============================

echo "Obtaining client credentials..."

CLIENT_RESPONSE=$(curl -s "$INSTANCE/api/v1/oauth-clients/local")
CLIENT_ID=$(echo "$CLIENT_RESPONSE" | jq -r '.client_id')
CLIENT_SECRET=$(echo "$CLIENT_RESPONSE" | jq -r '.client_secret')

if [[ "$CLIENT_ID" == "null" || -z "$CLIENT_ID" ]]; then
    echo "Error: failed to obtain client_id."
    exit 1
fi

echo "Obtaining access token..."

TOKEN_RESPONSE=$(curl -s -X POST "$INSTANCE/api/v1/users/token" \
    -H "Content-Type: application/x-www-form-urlencoded" \
    -d "client_id=$CLIENT_ID" \
    -d "client_secret=$CLIENT_SECRET" \
    -d "grant_type=password" \
    -d "username=$USERNAME" \
    -d "password=$PASSWORD")

ACCESS_TOKEN=$(echo "$TOKEN_RESPONSE" | jq -r '.access_token')

if [[ "$ACCESS_TOKEN" == "null" || -z "$ACCESS_TOKEN" ]]; then
    echo "Error: failed to obtain access token."
    echo "$TOKEN_RESPONSE" | jq
    exit 1
fi

# ==============================
# Upload
# ==============================

echo "Uploading '$VIDEO_NAME' to channel $CHANNEL_ID..."

UPLOAD_RESPONSE=$(curl -s -X POST "$INSTANCE/api/v1/videos/upload" \
    -H "Authorization: Bearer $ACCESS_TOKEN" \
    -F "videofile=@$VIDEO_FILE" \
    -F "name=$VIDEO_NAME" \
    -F "channelId=$CHANNEL_ID" \
    -F "privacy=$PRIVACY")

if echo "$UPLOAD_RESPONSE" | jq -e '.video.uuid' > /dev/null 2>&1; then
    VIDEO_UUID=$(echo "$UPLOAD_RESPONSE" | jq -r '.video.uuid')
    echo "OK: $INSTANCE/w/$VIDEO_UUID"
else
    echo "Error uploading video."
    echo "$UPLOAD_RESPONSE" | jq
    exit 1
fi
