#!/bin/sh
#
# Submit an async Kubernetes Job for image mirroring via Kubernetes API
# Uses the pod's service account to create jobs
# No kubectl dependency required

set -euo pipefail

printf "\n"
printf "====== Artifact Registry Webhook - Async Job Submission ======\n"
printf "Webhook received at: $(date)\n"
printf "ACTION: ${ACTION:-not set}\n"
printf "TAG   : ${TAG:-not set}\n"
printf "DIGEST: ${DIGEST:-not set}\n"
printf "DESTINATION_REGISTRY: ${DESTINATION_REGISTRY:-not set}\n"
printf "==============================================================\n\n"

if [[ ${ACTION} != "INSERT" ]]; then
  printf "Error, ACTION is not INSERT (got: ${ACTION}), exiting\n"
  exit 1
fi

# Use TAG if available, otherwise fallback to DIGEST
IMAGE_REF="${TAG:-${DIGEST}}"

if [[ -z ${IMAGE_REF} ]]; then
  printf "Error, neither TAG nor DIGEST is set, exiting\n"
  exit 1
fi

if [[ -z ${DESTINATION_REGISTRY} ]]; then
  printf "Error, DESTINATION_REGISTRY is not set, exiting\n"
  exit 1
fi

# Generate unique job name
JOB_HASH=$(echo "${IMAGE_REF}" | md5sum 2>/dev/null | cut -d' ' -f1 | cut -c1-8)
JOB_NAME="mirror-${JOB_HASH}-$(date +%s)"
NAMESPACE="network"

printf "Creating Kubernetes Job via API...\n"
printf "Job Name: ${JOB_NAME}\n"
printf "Image: ${IMAGE_REF}\n"
printf "Destination: ${DESTINATION_REGISTRY}\n\n"

# Get service account token and API server
SA_TOKEN=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)
API_SERVER="https://${KUBERNETES_SERVICE_HOST}:${KUBERNETES_SERVICE_PORT}"
CA_CERT="/var/run/secrets/kubernetes.io/serviceaccount/ca.crt"

# Create Job manifest
JOB_MANIFEST=$(cat <<EOF
{
  "apiVersion": "batch/v1",
  "kind": "Job",
  "metadata": {
    "name": "${JOB_NAME}",
    "namespace": "${NAMESPACE}",
    "labels": {
      "app.kubernetes.io/name": "webhook-mirror"
    }
  },
  "spec": {
    "backoffLimit": 2,
    "template": {
      "metadata": {
        "labels": {
          "app.kubernetes.io/name": "webhook-mirror"
        }
      },
      "spec": {
        "serviceAccountName": "webhook",
        "restartPolicy": "OnFailure",
        "containers": [
          {
            "name": "mirror",
            "image": "ghcr.io/home-operations/webhook:2.8.2",
            "command": ["/config/image-mirror.sh"],
            "env": [
              {"name": "ACTION", "value": "INSERT"},
              {"name": "TAG", "value": "${IMAGE_REF}"},
              {"name": "DESTINATION_REGISTRY", "value": "${DESTINATION_REGISTRY}"}
            ],
            "volumeMounts": [
              {"name": "config", "mountPath": "/config", "readOnly": true}
            ],
            "resources": {
              "requests": {"cpu": "100m", "memory": "256Mi"},
              "limits": {"cpu": "500m", "memory": "1Gi"}
            }
          }
        ],
        "volumes": [
          {"name": "config", "configMap": {"name": "webhook-configmap", "defaultMode": 493}}
        ]
      }
    }
  }
}
EOF
)

# Submit the Job to Kubernetes API
printf "Submitting job to Kubernetes API...\n"
RESPONSE=$(curl -s -X POST \
  -H "Authorization: Bearer ${SA_TOKEN}" \
  -H "Content-Type: application/json" \
  --cacert "${CA_CERT}" \
  -d "${JOB_MANIFEST}" \
  "${API_SERVER}/apis/batch/v1/namespaces/${NAMESPACE}/jobs" 2>&1)

# Check if job was created successfully
if echo "${RESPONSE}" | grep -q "\"kind\":\"Job\""; then
  printf "✓ Job submitted successfully: ${JOB_NAME}\n"
  printf "Check status with: kubectl logs -n network job/${JOB_NAME} -f\n"
else
  printf "Response: ${RESPONSE}\n"
  printf "Warning: Job submission may have failed, but webhook will continue\n"
fi

