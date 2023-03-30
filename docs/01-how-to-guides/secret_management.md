---
title: Secret Management
---

## Introduction

This guide demonstrates how to manage secrets in Kubernetes using External Secrets and Doppler. External Secrets allows you to sync secrets from external secret management systems into Kubernetes, while Doppler is a secure and easy-to-use secrets management service.

+ [Doppler Secret Provider](https://external-secrets.io/main/provider/doppler/)
+ [Doppler Secrets Operator](https://docs.doppler.com/docs/kubernetes-operator)

## Prerequisites

1. A Kubernetes cluster, fluxcd, kubectl
2. External Secrets operator
3. Doppler CLI installed and configured

## Overview

## Set Up Doppler

1. Sign up for a Doppler account at https://dashboard.doppler.com/signup
2. Follow the documentation for the [doppler provider](https://external-secrets.io/main/provider/doppler/) until "Use Cases".

The Service Token is located under the `kube-system/external-secrets/stores/doppler`


+ `doppler_store.yaml`: Defines a `SecretStore`. A SecretStore is a custom resource provided by the External Secrets Manager that defines the connection and authentication information needed to access an external secret management system. This resource acts as a centralized reference for other resources within the Kubernetes cluster when they need to access the secrets stored in the external system.

    ```yaml
    apiVersion: external-secrets.io/v1beta1
    kind: SecretStore
    metadata:
      name: doppler-auth-api
    spec:
      provider:
        doppler:
          auth:
            secretRef:
              dopplerToken:
                name: doppler-token-auth-api
                key: dopplerToken
    ```

+ `secret.sops.yaml`: The authentication credentials in plain yaml. The contents of the file are similar to :

    ```yaml
    apiVersion: v1
    data:
        dopplerToken: aG91c2Uud29ybGR4eHp3NkZBRzQ2Q3RIN1dXQUlKbTlJZTZOa05Jd1BzV1lqZjNzZ0JKc3oK
    kind: Secret
    metadata:
        name: doppler-token-auth-api
    ```

+ `test.yaml`: Secret to test that the configuration has been done correctly.


2. Create a new project and configure your secrets


## Secret Configuration

### ClusterSecretStore vs SecretStore

There are two types of secret stores provided by the External Secrets Manager:

+ `ClusterSecretStore:` A cluster-wide secret store that can be referenced by ExternalSecret resources across all namespaces in the cluster.
+ `SecretStore:` A namespace-scoped secret store that can only be referenced by ExternalSecret resources within the same namespace.

### ClusterSecretStore

A ClusterSecretStore is suitable for scenarios where a single external secret provider (such as Doppler) is used by multiple applications or services in different namespaces. It provides centralized configuration, consistency, reduced duplication, and access control.

#### Example

```yaml
apiVersion: external-secrets.io/v1beta1
kind: ClusterSecretStore
metadata:
  name: doppler-cluster-wide-secret-store
spec:
  provider:
    doppler:
      auth:
        secretRef:
          dopplerToken:
            name: doppler-token
            key: dopplerToken
            namespace: kube-system
```

### SecretStore

A `SecretStore` is suitable for scenarios where different namespaces need to use different external secret providers or configurations. It provides more granular control over secret provider configurations within each namespace.

#### Example

```yaml
apiVersion: external-secrets.io/v1beta1
kind: SecretStore
metadata:
  name: doppler-namespace-scoped-secret-store
  namespace: my-namespace
spec:
  provider:
    doppler:
      auth:
        secretRef:
          dopplerToken:
            name: doppler-token
            key: dopplerToken
```


### Secret Example

```yaml
---
apiVersion: external-secrets.io/v1beta1
kind: ClusterSecretStore
metadata:
  name: vector-aggregator-elastic
spec:
  provider:
    doppler:
      auth:
        secretRef:
          dopplerToken:
            name: doppler-token-auth-api
            key: dopplerToken
            namespace: kube-system
---
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: auth-api-elasticsearch-ingestion-credentials
spec:
  secretStoreRef:
    kind: ClusterSecretStore
    name: vector-aggregator-elastic

  target:
    name: es-ingestion-credentials

  data:
    - secretKey: ELASTICSEARCH_PASSWORD
      remoteRef:
        key: ELASTICSEARCH_PASSWORD

    - secretKey: ELASTICSEARCH_USERNAME
      remoteRef:
        key: ELASTICSEARCH_USERNAME
```

## Extra: Install Doppler CLI

Follow the installation instructions for your operating system at https://docs.doppler.com/docs/enclave-installation

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
