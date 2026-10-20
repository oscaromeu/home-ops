#!/usr/bin/env bash
set -Eeuo pipefail

source "$(dirname "${0}")/lib/common.sh"

export LOG_LEVEL="debug"
export ROOT_DIR="$(git rev-parse --show-toplevel)"
export CLUSTER="${CLUSTER:-home}"

case "${CLUSTER}" in
    home) KUBE_CONTEXT="admin@kubernetes" ;;
    test) KUBE_CONTEXT="test" ;;
    *) log fatal "Unknown cluster" "cluster" "${CLUSTER}" ;;
esac

# Talos requires the nodes to be 'Ready=False' before applying resources
function wait_for_nodes() {
    log debug "Waiting for nodes to be available"

    # Skip waiting if all nodes are 'Ready=True'
    if kubectl --context "${KUBE_CONTEXT}" wait nodes --for=condition=Ready=True --all --timeout=10s &>/dev/null; then
        log info "Nodes are available and ready, skipping wait for nodes"
        return
    fi

    # Wait for all nodes to be 'Ready=False'
    until kubectl --context "${KUBE_CONTEXT}" wait nodes --for=condition=Ready=False --all --timeout=10s &>/dev/null; do
        log info "Nodes are not available, waiting for nodes to be available. Retrying in 10 seconds..."
        sleep 10
    done
}

# Namespaces to be applied before the SOPS secrets are installed
function apply_namespaces() {
    log debug "Applying namespaces"

    local -r apps_dir="${ROOT_DIR}/kubernetes/clusters/${CLUSTER}/apps"

    if [[ ! -d "${apps_dir}" ]]; then
        log error "Directory does not exist" "directory=${apps_dir}"
    fi

    for app in "${apps_dir}"/*/; do
        namespace=$(basename "${app}")

        # Check if the namespace resources are up-to-date
        if kubectl --context "${KUBE_CONTEXT}" get namespace "${namespace}" &>/dev/null; then
            log info "Namespace resource is up-to-date" "resource=${namespace}"
            continue
        fi

        # Apply the namespace resources
        if kubectl --context "${KUBE_CONTEXT}" create namespace "${namespace}" --dry-run=client --output=yaml \
            | kubectl --context "${KUBE_CONTEXT}" apply --server-side --filename - &>/dev/null;
        then
            log info "Namespace resource applied" "resource=${namespace}"
        else
            log error "Failed to apply namespace resource" "resource=${namespace}"
        fi
    done
}

# SOPS secrets to be applied before the helmfile charts are installed
function apply_sops_secrets() {
    log debug "Applying secrets"

    local -r secrets=(
        "${ROOT_DIR}/bootstrap/github-deploy-key.sops.yaml"
        "${ROOT_DIR}/bootstrap/sops-age.sops.yaml"
        "${ROOT_DIR}/kubernetes/clusters/${CLUSTER}/config/secrets/cluster-secrets.sops.yaml"
    )

    for secret in "${secrets[@]}"; do
        if [ ! -f "${secret}" ]; then
            log warn "File does not exist" "file=${secret}"
            continue
        fi

        # Check if the secret resources are up-to-date
        if sops exec-file "${secret}" "kubectl --context ${KUBE_CONTEXT} --namespace flux-system diff --filename {}" &>/dev/null; then
            log info "Secret resource is up-to-date" "resource=$(basename "${secret}" ".sops.yaml")"
            continue
        fi

        # Apply secret resources
        if sops exec-file "${secret}" "kubectl --context ${KUBE_CONTEXT} --namespace flux-system apply --server-side --filename {}" &>/dev/null; then
            log info "Secret resource applied successfully" "resource=$(basename "${secret}" ".sops.yaml")"
        else
            log error "Failed to apply secret resource" "resource=$(basename "${secret}" ".sops.yaml")"
        fi
    done
}

# The HelmRelease values carry Flux substitution vars; helmfile expands them from the environment
function export_cluster_secrets() {
    local -r secret="${ROOT_DIR}/kubernetes/clusters/${CLUSTER}/config/secrets/cluster-secrets.sops.yaml"

    if ! sops --decrypt "${secret}" &>/dev/null; then
        log fatal "Failed to decrypt cluster secrets" "file" "${secret}"
    fi

    while IFS=$'\t' read -r key value; do
        export "${key}=${value}"
    done < <(sops --decrypt "${secret}" | yq '.stringData | to_entries[] | [.key, .value] | @tsv')
}

# CRDs to be applied before the helmfile charts are installed
function apply_crds() {
    log debug "Applying CRDs"

    local -r helmfile_file="${ROOT_DIR}/bootstrap/helmfile.d/00-crds.yaml"

    if [[ ! -f "${helmfile_file}" ]]; then
        log fatal "File does not exist" "file" "${helmfile_file}"
    fi

    if ! crds=$(helmfile --file "${helmfile_file}" template --quiet) || [[ -z "${crds}" ]]; then
        log fatal "Failed to render CRDs from Helmfile" "file" "${helmfile_file}"
    fi

    if echo "${crds}" | kubectl --context "${KUBE_CONTEXT}" diff --filename - &>/dev/null; then
        log info "CRDs are up-to-date"
        return
    fi

    if ! echo "${crds}" | kubectl --context "${KUBE_CONTEXT}" apply --server-side --filename - &>/dev/null; then
        log fatal "Failed to apply crds from Helmfile" "file" "${helmfile_file}"
    fi

    log info "CRDs applied successfully"
}

# Sync Helm releases
function sync_helm_releases() {
    log debug "Syncing Helm releases"

    local -r helmfile_file="${ROOT_DIR}/bootstrap/helmfile.d/01-apps.yaml.gotmpl"

    if [[ ! -f "${helmfile_file}" ]]; then
        log error "File does not exist" "file=${helmfile_file}"
    fi

    if ! helmfile --file "${helmfile_file}" --environment "${CLUSTER}" --kube-context "${KUBE_CONTEXT}" sync --hide-notes; then
        log error "Failed to sync Helm releases"
    fi

    log info "Helm releases synced successfully"
}

# FluxInstance applied after the flux-operator install (its CRD must exist)
function apply_flux_instance() {
    log debug "Applying FluxInstance"

    local -r manifest="${ROOT_DIR}/kubernetes/clusters/${CLUSTER}/entrypoint/fluxinstance.yaml"

    if [[ ! -f "${manifest}" ]]; then
        log fatal "File does not exist" "file" "${manifest}"
    fi

    if kubectl --context "${KUBE_CONTEXT}" diff --filename "${manifest}" &>/dev/null; then
        log info "FluxInstance is up-to-date"
        return
    fi

    # Same field manager Flux uses, so kustomize-controller can take it over
    if ! kubectl --context "${KUBE_CONTEXT}" apply --server-side --force-conflicts \
        --field-manager=kustomize-controller --filename "${manifest}" &>/dev/null; then
        log fatal "Failed to apply FluxInstance" "file" "${manifest}"
    fi

    log info "FluxInstance applied successfully"
}

function main() {
    check_env KUBECONFIG
    check_cli helmfile kubectl kustomize sops yq

    # Apply resources and Helm releases
    wait_for_nodes
    apply_namespaces
    export_cluster_secrets
    apply_sops_secrets
    apply_crds
    sync_helm_releases
    apply_flux_instance

    log info "Congrats! The cluster is bootstrapped and Flux is syncing the Git repository"
}

main "$@"
