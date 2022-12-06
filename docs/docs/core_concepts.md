---
sidebar_position: 1
title: Core Concepts
---


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


