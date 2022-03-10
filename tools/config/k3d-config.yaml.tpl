kind: Simple
apiVersion: k3d.io/v1alpha3
name: lab
servers: 1
agents: 2
kubeAPI:
  hostIP: 0.0.0.0
  hostPort: "6443"
image: rancher/k3s:v1.22.2-k3s1
volumes:
- volume: $PROJECT_DIR/tools/config/traefik-config.yaml:/var/lib/rancher/k3s/server/manifests/traefik-config.yaml
  nodeFilters:
  - all

#- volume: $PROJECT_DIR/tools/config/sealed-secrets-secrets.yaml:/var/lib/rancher/k3s/server/manifests/sealed-secrets-secrets.yaml
#  nodeFilters:
#  - server:0
#
#- volume: $PROJECT_DIR/tools/config/controller.yaml:/var/lib/rancher/k3s/server/manifests/controller.yaml
#  nodeFilters:
#  - server:0

ports:
- port: 80:80
  nodeFilters:
  - loadbalancer
- port: 0.0.0.0:443:443
  nodeFilters:
  - loadbalancer
options:
  k3d:
    wait: true
    timeout: 6m0s
    disableLoadbalancer: false
    disableImageVolume: false
    disableRollback: false
  k3s:
    extraArgs:
    - arg: --tls-san=127.0.0.1
      nodeFilters:
      - server:*
    - arg: --no-deploy=traefik  
      nodeFilters:
      - server:*
    nodeLabels: []
  kubeconfig:
    updateDefaultKubeconfig: true
    switchCurrentContext: true
  runtime:
    gpuRequest: ""
    serversMemory: ""
    agentsMemory: ""
    labels:
    - label: foo=bar
      nodeFilters:
      - server:0
      - loadbalancer
env:
- envVar: bar=baz
  nodeFilters:
  - all
