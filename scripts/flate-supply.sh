#!/usr/bin/env bash
set -euo pipefail

cluster="${1:-home}"
root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
secrets="$root/kubernetes/clusters/$cluster/config/secrets/cluster-secrets.sops.yaml"

[[ -f "$secrets" ]] || { echo "error: no cluster-secrets for '$cluster'" >&2; exit 2; }

exec cue export "$root/scripts/flate-supply.cue" "$secrets" -e out --out yaml
