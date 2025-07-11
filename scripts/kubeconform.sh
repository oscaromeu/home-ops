#!/usr/bin/env bash
set -o errexit
set -o pipefail

KUBERNETES_DIR=$1

[[ -z "${KUBERNETES_DIR}" ]] && echo "Kubernetes location not specified" && exit 1

kustomize_args=("--load-restrictor=LoadRestrictionsNone")
kustomize_config="kustomization.yaml"
kubeconform_args=(
    "-strict"
    "-ignore-missing-schemas"
    "-skip"
    "Secret"
    "-schema-location"
    "default"
    "-schema-location"
    "https://kubernetes-schemas.pages.dev/{{.Group}}/{{.ResourceKind}}_{{.ResourceAPIVersion}}.json"
    "-verbose"
)

echo "=== Validating standalone manifests in ${KUBERNETES_DIR}/clusters/ ==="
find "${KUBERNETES_DIR}/clusters/" -maxdepth 1 -type f -name '*.yaml' -print0 | while IFS= read -r -d $'\0' file;
  do
    kubeconform "${kubeconform_args[@]}" "${file}"
    if [[ ${PIPESTATUS[0]} != 0 ]]; then
      exit 1
    fi
done
