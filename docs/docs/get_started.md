---
sidebar_position: 2
title: Get started
---

# Get Started with Live Infra

This doc shows how to boostrap the platform in a Kubernetes cluster in a GitOps manner.

## Before you begin

What we will need

+ Flux CLI
+ Kubernetes Cluster
+ A GitHub personal access token with repo permissions.

## Objectives

+ Boostrap Live Infra
+ Deploy a sample application using Flux


### Bootstrap Production

Secrets - Age

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


