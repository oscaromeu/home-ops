---
title: Secret Management
---

## Introduction

This guide demonstrates how to manage secrets in Kubernetes using External Secrets and Doppler. External Secrets allows you to sync secrets from external secret management systems into Kubernetes, while Doppler is a secure and easy-to-use secrets management service.

## Prerequisites

1. A Kubernetes cluster
2. `kubectl` command-line tool installed and configured
3. Doppler CLI installed and configured

## Step 1: Set Up Doppler

1. Sign up for a Doppler account at https://dashboard.doppler.com/signup
2. Create a new project and configure your secrets

## Step 2: Install Doppler CLI

Follow the installation instructions for your operating system at https://docs.doppler.com/docs/enclave-installation

## Step 3: Install External Secrets in Your Kubernetes Cluster

Once the doppler account is configured and the secrets are in place we can proceed. The next step will be installing the external secrets resource in our cluster. This is done using fluxcd same as other applications. Note that before the kustomization `cluster-apps`

## Doppler Store

### Example

```
apiVersion: v1
data:
    dopplerToken: aG91c2Uud29ybGR4eHp3NkZBRzQ2Q3RIN1dXQUlKbTlJZTZOa05Jd1BzV1lqZjNzZ0JKc3oK
kind: Secret
metadata:
    name: doppler-token-auth-api
```

Define a `DB_URL` variable in your doppler project to test if everything is working using the following. Note that

```yaml
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: auth-api-db-url
spec:
  secretStoreRef:
    kind: SecretStore
    name: doppler-auth-api

  target:
    name: home-ops-db-url

  data:
    - secretKey: DB_URL
      remoteRef:
        key: DB_URL
```

## List of secrets

```
$ doppler secrets --only-names

NAME
-----------------------
CLICKHOUSE_PASSWORD
CLICKHOUSE_USERNAME
CLOUDFLARE_APIKEY
CLOUDFLARE_TOKEN
ELASTICSEARCH_PASSWORD
ELASTICSEARCH_USERNAME

```

```
./kubernetes/apps/monitoring/kube-prometheus-stack/app/secret.sops.yaml
./kubernetes/apps/monitoring/kube-prometheus-stack/app/grafana-secret.sops.yaml
./kubernetes/apps/monitoring/botkube/app/secret.sops.yaml
./kubernetes/apps/monitoring/botkube/app/helmrelease.yaml
./kubernetes/apps/monitoring/botkube/app/values.yml.key
./kubernetes/apps/monitoring/botkube/app/com_config.sops.yaml
./kubernetes/apps/monitoring/thanos/app/secret.sops.yaml
./kubernetes/apps/logging/loki/app/secret_loki.sops.yaml
```
