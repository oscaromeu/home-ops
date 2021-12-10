# Live-Infra

TODO

Repostitory of application definitions, configurations and environments in a declarative and versioned control fashion. Live Infra uses [Flux V2](https://fluxcd.io/) to keep Kubernetes clusters in sync and updated. 

Infrastructure services and applications are installed and updated automatically when changes in the repository are detected. This mechanism is done with controllers in the clusters which detects change in the source code.

## Prerequisites

You will need to meet the following in order to spin up Live Infra

- Kubernetes cluster version 1.16 or newer.
- kubectl version 1.8 or newer.
- Flux V2 version 0.17.2 or newer.

## Repository structure

+ Tools
+ Services
+ Testing

## Testing

Any change to the Kubernetes manifests or to the repository structure should be validated in CI before a pull requests is merged into themaster branch and synced on the cluster.

This repository contains the following Github CI workflows:

* the [test](./.github/workflows/test.yaml) workflow validates the Kubernetes manifests and Kustomize overlays with kubeval
* the [e2e](./.github/workflows/e2e.yaml) workflow starts a Kubernetes cluster in CI and tests the staging setup by running Flux in Kubernetes Kind

