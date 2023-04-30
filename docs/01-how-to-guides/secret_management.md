---
title: Secret Management
---

## Overview

This guide demonstrates the different ways that secrets can be made available onto the cluster  when using [Flux](https://fluxcd.io/), [SOPS](https://github.com/mozilla/sops) and External Secrets with Doppler provider.

_Check the following [document](https://fluxcd.io/docs/guides/mozilla-sops/) on how to integrate SOPS into Flux_

## Generate secret with different keys

```yaml
---
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: auth-api-elasticsearch-ingestion-credentials
spec:
  secretStoreRef:
    kind: ClusterSecretStore
    name: doppler-auth-api
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


## All keys, one secret

Use dataFrom field to get multiple key-values from an external secret.

```yaml
---
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: gitea
  namespace: default
spec:
  secretStoreRef:
    kind: ClusterSecretStore
    name: doppler-auth-api
  target:
    name: gitea-config
    creationPolicy: Owner
    deletionPolicy: "Delete"
    template:
      engineVersion: v2
      data:
        adminEmail: "{{ .ADMIN_EMAIL }}"
        adminPassword: "{{ .ADMIN_PASSWORD }}"
        dbUser: "{{ .DB_USER }}"
        dbPassword: "{{ .DB_PASSWORD }}"
        deploymentRsaPrivKey: "{{ .DEPLOYMENT_RSA_PRIV_KEY }}"
        host: "{{ .GITEA_POSTGRES_HOST }}"

  dataFrom:
    - extract:
        key: GITEA
```

The contents of the GITEA field are a json with the key value pairs

```json
{
  "ADMIN_EMAIL": "admin@localhost",
  "ADMIN_PASSWORD": "CHANGEME",
  "DB_USER": "gitea",
  "DB_PASSWORD": "CHANGEME",
  "GITEA_POSTGRES_HOST_PORT": "postgres-rw.default.svc.cluster.local:5432",
  "GITEA_POSTGRES_HOST": "postgres-rw.default.svc.cluster.local",
  "POSTGRES_SUPER_USER": "admin",
  "POSTGRES_SUPER_PASS": "CHANGEME",
  "DEPLOYMENT_RSA_PRIV_KEY": "MY PRIVATE KEY"
}
```
