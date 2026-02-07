#!/bin/sh
#
# script triggered by a webhook call coming from ACR hook
# pull the new image with skopeo to fee the local harbor cache

set -euo pipefail

#defaults
[[ -z ${SRC_TLS} ]] && SRC_TLS=true
[[ -z ${SCRIPT_DEBUG} ]] && SCRIPT_DEBUG=false

if [[ ${SCRIPT_DEBUG} == "true" ]]; then
  printf "\n"
  printf "DEBUG Request ENV dump:\n"
  printf "DEBUG  ACTION: ${ACTION}\n"
  printf "DEBUG  REPO  : ${REPO}\n"
  printf "DEBUG  TAG   : ${TAG}\n"
  printf "DEBUG  DIGEST: ${DIGEST}\n"
  #printf "DEBUG  ACRTOKEN: ${ACRTOKEN}\n"
fi

#Store script start time
start_time=$(date +%s)

if [[ ${ACTION} != "push" ]]; then
  printf "Error, ACTION is not push, exiting\n"
  exit 1
else
  TARGETDIR=$(mktemp -d)
  if [[ ${SCRIPT_DEBUG} == "true" ]]; then
    printf "DEBUG: executing command - skopeo copy --src-tls-verify=${SRC_TLS} docker://${HARBOR_URL}/${REPO}:${TAG} dir:${TARGETDIR}\n"
  fi
  printf "Pulling the image to feed the cache...........\n"
  skopeo copy --src-tls-verify=${SRC_TLS} docker://${HARBOR_URL}/$REPO:$TAG dir:$TARGETDIR
  if [[ ${SCRIPT_DEBUG} == "true" ]]; then
    printf "DEBUG: executing command - rm -rf ${TARGETDIR}\n"
  fi
  rm -rf ${TARGETDIR}
fi
# calculate and print elapsed time since start
end_time=$(date +%s)
elapsed=$(( end_time - start_time ))
eval "echo Elapsed time : $(date -ud "@$elapsed" +'$((%s/3600/24)) days %H hr %M min %S sec')"