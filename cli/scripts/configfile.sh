#!/bin/bash
#set -x
NAMESPACE=monitoring

CURR_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )";
[ -d "$CURR_DIR" ] || { echo "FATAL: no current dir (maybe running in zsh?)";  exit 1; }

tempfile=cli/config/k3d-config.yaml.tpl
configfile=cli/config/k3d-config.yaml

export PROJECT_DIR=$PWD
envsubst < $tempfile > $configfile

# shellcheck source=./common.sh
source "$CURR_DIR/common.sh";



section "Create a Cluster purely from a config file"
printf "${CYA}********************${END}\n$(cat $configfile)\n${CYA}********************${END}\n"
info_pause_exec "Create a cluster" "k3d cluster create --config $configfile"



section "Access the Cluster"

info_pause_exec "List clusters" "k3d cluster list"

info_pause_exec "Use kubectl to checkout the nodes" "kubectl get nodes"

section "Deploy manifest"

info_pause_exec "Use kubectl to create namespace $NAMESPACE" "kubectl create namespace $NAMESPACE"

info_pause_exec_options "Would you like to deploy sealed secrets controller" "kubectl apply -f cli/config/controller.yaml"

info_pause_exec_options "Would you like to deploy prometheus?" "cd manifests/kube-prometheus;kubectl apply -f manifests/setup;sleep 10s;kustomize build | kubectl apply -f -;"

info_pause_exec_options "Would you like to deploy grafana?" "cd ../grafana;kustomize build | kubectl apply -f -;"

section "Cleanup Clusters"

info_pause_exec "Delete all Clusters" "k3d cluster rm -a"

info_pause_exec "Deleting temporary configuration files" "rm -f $configfile"



