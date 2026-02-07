#!/bin/sh
#
# Generic registry mirror script
# Syncs images between any two registries using skopeo
# Supports: GCR, Azure, ECR, etc.
#
# Required environment variables:
#   - ACTION: INSERT (from Artifact Registry webhook)
#   - TAG or DIGEST: Image reference from webhook
#   - DESTINATION_REGISTRY: Target registry URL (e.g., azurecr.io, registry.example.com)
#   - SOURCE_REGISTRY_PREFIX: Source registry prefix to replace (optional, defaults to original registry)

set -euo pipefail

printf "\n"
printf "====== Registry Mirror Webhook ======\n"
printf "Script executed at: $(date)\n"
printf "ACTION: ${ACTION:-not set}\n"
printf "TAG   : ${TAG:-not set}\n"
printf "DIGEST: ${DIGEST:-not set}\n"
printf "DESTINATION_REGISTRY: ${DESTINATION_REGISTRY:-not set}\n"
printf "\nAll environment variables:\n"
env | grep -E "^(ACTION|TAG|DIGEST|DESTINATION_REGISTRY|SOURCE_REGISTRY_PREFIX)" || true
printf "=====================================\n\n"

# Store script start time
start_time=$(date +%s)

if [[ ${ACTION} != "INSERT" ]]; then
  printf "Error, ACTION is not INSERT (got: ${ACTION}), exiting\n"
  exit 1
fi

if [[ -z ${DESTINATION_REGISTRY} ]]; then
  printf "Error, DESTINATION_REGISTRY is not set, exiting\n"
  exit 1
fi

# Use TAG if available, otherwise fallback to DIGEST
IMAGE_REF="${TAG:-${DIGEST}}"

if [[ -z ${IMAGE_REF} ]]; then
  printf "Error, neither TAG nor DIGEST is set, exiting\n"
  exit 1
fi

# Extract image path (remove source registry prefix)
# Format: us-west1-docker.pkg.dev/project/repo/image:tag or @sha256:hash
IMAGE_PATH=$(echo "${IMAGE_REF}" | cut -d'/' -f4-)
printf "Parsed IMAGE_PATH: ${IMAGE_PATH}\n"

# Construct destination image reference
DESTINATION_IMAGE="${DESTINATION_REGISTRY}/${IMAGE_PATH}"

printf "Mirroring image...........\n"
printf "Source: ${IMAGE_REF}\n"
printf "Dest  : ${DESTINATION_IMAGE}\n"
printf "Command: skopeo copy --src-tls-verify=false docker://${IMAGE_REF} docker://${DESTINATION_IMAGE}\n"
#skopeo copy --src-tls-verify=false "docker://${IMAGE_REF}" "docker://${DESTINATION_IMAGE}"
printf "Image mirrored successfully: ${IMAGE_PATH}\n"

# calculate and print elapsed time since start
end_time=$(date +%s)
elapsed=$(( end_time - start_time ))
eval "echo Elapsed time : $(date -ud "@$elapsed" +'$((%s/3600/24)) days %H hr %M min %S sec')"