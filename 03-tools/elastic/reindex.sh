#!/bin/bash
# poor man debugger
set -x
# cat datastreams.txt | xargs -I{} sh -c "./reindex.sh {}"

# Define the Elasticsearch URL
ES_URL="${ES_URL}"

# Define the Elasticsearch credentials
ES_USER="elastic"
ES_PASS=$(op item get elastic --vault home-ops --fields label=credencial)

# Get the DATASTREAM name from the command-line argument
DATASTREAM_NAME="$1"
NAMESPACE=$(echo "$DATASTREAM_NAME" | sed 's/logs-k3s_prod-//')

# Define the log file
LOG_FILE="script_log.txt"

# Function to log messages
log_message() {
  local message="$1"
  echo "$(date +'%Y-%m-%d %H:%M:%S') - $message"
}

# Check if a DATASTREAM name was provided
if [ -z "$DATASTREAM_NAME" ]; then
  echo "Usage: $0 <datastream_name>"
  exit 1
fi

# Function to ask for confirmation before each curl operation
confirm_operation() {
  local operation_name="$1"
  read -r -p "Are you sure you want to proceed with $operation_name? (yes/no): " confirmation
  if [ "$confirmation" != "yes" ]; then
    log_message "Operation canceled: $operation_name"
    exit 0
  fi
}

# Caution this setting has to be applied per datastream
# Define the PUT request for changing index settings
#SETTINGS_PAYLOAD="{
#  \"index\": {
#    \"refresh_interval\": \"0s\",
#    \"number_of_replicas\": 0
#  }
#}"
#
## Send change settings request
#log_message "Changing settings: $DATASTREAM_NAME"
#change_settings=$(curl -XPOST -sSL "$ES_URL/$DATASTREAM_NAME/_settings" -u "$ES_USER:$ES_PASS" -H "Content-Type: application/json" -d "$SETTINGS_PAYLOAD")
#log_message "message: $change_settings"
#log_message "Reindexed: $DATASTREAM_NAME"

# Define the REINDEX_PAYLOAD
REINDEX_PAYLOAD="{
  \"source\": {
    \"index\": \"$DATASTREAM_NAME\"
  },
  \"dest\": {
    \"index\": \"logs-k3s-prod\",
    \"op_type\": \"create\",
    \"pipeline\": \"reindex_poc\"
  }
}"

# Send the REINDEX request
#confirm_operation "reindexing"
log_message "Reindexing: $DATASTREAM_NAME"
reindexing=$(curl -XPOST -sSL "$ES_URL/_reindex?pretty" -u "$ES_USER:$ES_PASS" -H "Content-Type: application/json" -d "$REINDEX_PAYLOAD")
log_message "message: $reindexing"
log_message "Reindexed: $DATASTREAM_NAME"

# Create an alias
CREATE_ALIAS_REQUEST="_aliases?pretty"
ALIAS_PAYLOAD="{
 \"actions\": [
   {
     \"add\": {
       \"index\": \"logs-k3s-prod\",
       \"alias\": \"$DATASTREAM_NAME\",
       \"filter\": {
         \"term\": {
           \"kubernetes.pod_namespace\": \"$NAMESPACE\"
         }
       }
     }
   }
 ]
}"

# Delete the data stream
DELETE_DATASTREAM_REQUEST="_data_stream/$DATASTREAM_NAME"
#confirm_operation "deleting the data stream $DATASTREAM_NAME"
log_message "Deleting the data stream: $DATASTREAM_NAME"
delete=$(curl -XDELETE -sSL "$ES_URL/$DELETE_DATASTREAM_REQUEST" -u "$ES_USER:$ES_PASS")
log_message "Deleted the data stream: $DATASTREAM_NAME"

# Send the CREATE ALIAS request
#confirm_operation "creating an alias"
log_message "Creating an alias: $DATASTREAM_NAME"
alias=$(curl -XPOST -sSL "$ES_URL/$CREATE_ALIAS_REQUEST" -u "$ES_USER:$ES_PASS" -H "Content-Type: application/json" -d "$ALIAS_PAYLOAD")
log_message "Created an alias: $DATASTREAM_NAME"


