#!/bin/sh
#
# script triggered by a webhook call coming from GCR push event
# sync image from production GCR to pre-production GCR using skopeo

set -euo pipefail

# defaults
[[ -z ${SCRIPT_DEBUG} ]] && SCRIPT_DEBUG=true

printf "\n"
printf "====== GCR Webhook Trigger ======\n"
printf "ACTION: ${ACTION:-not set}\n"
printf "REPO  : ${REPO:-not set}\n"
printf "TAG   : ${TAG:-not set}\n"
printf "DIGEST: ${DIGEST:-not set}\n"
printf "\nAll environment variables:\n"
env | grep -E "^(ACTION|REPO|TAG|DIGEST|SRC_GCR|DST_GCR)" || true
printf "================================\n\n"

# Store script start time
start_time=$(date +%s)

if [[ ${ACTION} != "push" ]]; then
  printf "Error, ACTION is not push, exiting\n"
  exit 1
else
  printf "Syncing image from production to pre-production GCR...........\n"
  skopeo copy --src-tls-verify=false "docker://${SRC_GCR}/${REPO}:${TAG}" "docker://${DST_GCR}/${REPO}:${TAG}"
  printf "Image synced successfully: ${REPO}:${TAG}\n"
fi
# calculate and print elapsed time since start
end_time=$(date +%s)
elapsed=$(( end_time - start_time ))
eval "echo Elapsed time : $(date -ud "@$elapsed" +'$((%s/3600/24)) days %H hr %M min %S sec')"