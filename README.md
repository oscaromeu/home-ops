# Live-Infra

(TODO!!!)

Repository of application definitions, configurations and environments in a declarative and versioned control fashion that provides a cluster monitoring stack for ARM64 platform. Live Infra uses [Flux V2](https://fluxcd.io/) to keep k3s clusters sync and updated. 

Infrastructure services and applications are installed and updated automatically when changes in the repository are detected. This mechanism is done with controllers in the clusters which detects change in the source code.

The components that are included are explained below.

## Prerequisites

You will need to meet the following in order to spin up Live Infra

- Kubernetes cluster version 1.16 or newer.
- kubectl version 1.8 or newer.
- Flux V2 version 0.17.2 or newer.
- A bunch of raspberry pi's

## Repository structure

The repository is structured with three folders which maps onto a different purpose 

```
Tools
  ├── production    => Code running in the cluster
  │   └── ...
  ├── staging       => Same code as production but tested locally before applying changes
  │   └── ...
  └── testing       => Let's have some fun!
      └── ...
```

The staging and testing area can be tested locally (TODO)

## Bootstrap Live Infra

(TODO)

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
    --path=./Tools 
    --personal
```

The bootstrap command commits the manifests for the Flux components in Tools/ dir and creates a deploy key with read-only access on GitHub, so it can pull changes inside the cluster. 

Note that the bootstrap github command creates the Github repository if it doesn't exist and commits the toolkit components manifests to the main branch. Then it configures the target cluster to synchronize with the repository. If the toolkit components are present on the cluster, the bootstrap command will perform an upgrade if needed. Flux components can be customized before or after running bootstrap in order to do edit `flux-system/gotk-patches.yaml` an example can be found in this repo under `Tools/flux-system`.


## Testing

TODO!!!

Any change to the Kubernetes manifests or to the repository structure should be validated in CI before a pull requests is merged into themaster branch and synced on the cluster.

This repository contains the following Github CI workflows:
* Add CI job to encypt sensitive data in the manifest files
* the [test](./.github/workflows/test.yaml) workflow validates the Kubernetes manifests and Kustomize overlays with kubeval
* the [e2e](./.github/workflows/e2e.yaml) workflow starts a Kubernetes cluster in CI and tests the staging setup by running Flux in Kubernetes Kind

## Acknowledgements

Not all of the code here is my original work, but has been collated from and inspired by some fantastic contributors.

