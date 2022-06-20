# Live-Infra

Repository of application definitions, configurations and environments in a declarative and versioned control fashion that provides a cluster monitoring stack for x86-64/arm64 platform. Live Infra uses [Flux V2](https://fluxcd.io/) to keep k3s clusters sync and updated. 

Infrastructure services and applications are installed and updated automatically when changes in the repository are detected. This mechanism is done with controllers in the clusters which detects change in the source code.

The components that are included are explained below.

## Prerequisites

You will need to meet the following in order to spin up Live Infra

- Kubernetes cluster version 1.16 or newer.
- kubectl version 1.8 or newer.
- Flux V2 version 0.17.2 or newer.


## Repository structure

The Git repository contains the following top directories:

+ __apps__ dir contains app releases with a custom configuration per cluster
+ __infrastructure__ dir contains common infra tools such as Prometheus or Elasticsearch
+ __clusters__ dir contains the Flux configuration per cluster
+ __tools__ dir contains scripts to spin up a local k3d cluster to test the staging cluster

```
├── apps
│   ├── base
│   ├── production 
│   └── staging
├── infrastructure
│   ├── base
│   ├── production
│   └── staging
|   └── dev
└── clusters
    ├── production
    └── staging
```

The apps configuration is structured into:

+ __apps/base/__ dir contains namespaces and Helm release definitions
+ __apps/production/__ dir contains the production Helm release values
+ __apps/staging/__ dir contains the staging values

## Components

TODO

<details><summary> <b>Infrastructure</b> </summary>
<p>

 * [Flux](https://github.com/fluxcd/flux2) Tool for keeping Kubernetes clusters in sync with sources of configuration like git repositories, and automating updates to configuration when there is new code to deploy.
 * [Sealed Secrets](https://github.com/bitnami-labs/sealed-secrets) Kubernetes controller to encrypt secrets which are safe to store - even to a public repository. 
</p>
</details>



<details><summary> <b>Metrics</b> </summary>
<p>

 * [Kube-Prometheus](https://github.com/prometheus-operator/kube-prometheus#kube-prometheus) the Kubernetes monitoring stack
    * [Prometheus](https://github.com/prometheus/prometheus) to collect metrics
    * [AlertManager](https://github.com/prometheus/alertmanager#alertmanager-) to fire the alerts
    * [Grafana](https://github.com/grafana/grafana) to visualize what's going on
    * [Node-Exporter](https://github.com/prometheus/node_exporter) to export metrics from the nodes
    * [Kube-State-Metrics](https://github.com/kubernetes/kube-state-metrics) to get metrics from kubernetes api-server
    * [Prometheus-Operator](https://github.com/prometheus-operator/prometheus-operator#prometheus-operator) to manage the life-cycle of Prometheus and AlertManager custom resource definitions (CRDs)
 * [Promlens](https://promlens.com/) tool to build and analyse promql queries with ease.

To provide HA and long term storage capabilities to the metrics platform two options are available:

 * (TODO) [Thanos](https://thanos.io/)
 * (TODO) [VictoriaMetrics](https://victoriametrics.com/) 

</p>
</details>

<details><summary> <b>Logging</b> </summary>
<p>

* [Filebeat](https://www.elastic.co/beats/filebeat) collect logs and forward them to Redis
* [Redis](https://redis.io/) to brokers the data flow and queue it
* [Logstash](https://www.elastic.co/logstash/) to subscribe to Redis, process the data and ship it to Elasticsearch
* [Elasticsearch](https://www.elastic.co/) to index and store the data
* [Kibana](https://www.elastic.co/kibana/) to visualize and analyze the data
* (TODO) [Metricbeat](https://www.elastic.co/beats/metricbeat)
* (TODO) [Minio](https://min.io/)

![logging-infra](./.img/logging-infra.png)

</p>
</details>
<details><summary> <b>Tracing</b> </summary>
<p>

</p>
</details>

## Bootstrap Production

Fork this repository on your personal Github account and export your Github access token, username and repo name:

```bash
export GITHUB_TOKEN=<your-token>
export GITHUB_USER=<your-username>
export GITHUB_REPO=<repository-name>
```

Verify that your staging cluster satisfies the prerequisites with:

```bash
flux check --pre
```

If everything worked fine bootstrap Tools:

```bash
flux bootstrap github \
    --owner=${GITHUB_USER} \
    --repository=${GITHUB_REPO} \
    --branch=master   
    --path=./clusters/production
    --personal
```

The bootstrap command commits the manifests for the Flux components in `Tools/` dir and creates a deploy key with read-only access on GitHub, so it can pull changes inside the cluster. 

Flux components can be customized before or after running bootstrap in order to do edit`flux-system/gotk-patches.yaml` an example can be found in this repo under `Tools/flux-system`. For more information about the bootstrap command [see](https://fluxcd.io/docs/cmd/flux_bootstrap_github/#synopsis). 


## Secrets

TODO

## Testing

Any change to the Kubernetes manifests or to the repository structure should be validated in CI before a pull requests is merged into the master branch and synced on the cluster.

This repository contains the following Github CI workflows:

+ The [test](./.github/workflows/test.yaml) workflow validates the Kubernetes manifests and Kustomize overlays with kubeval


## Roadmap

TODO

## Acknowledgements

Not all of the code here is my original work, but has been collated from and inspired by some fantastic contributors. Thank you all!

