---
title: Secret Management
---

## Overview

This guide demonstrates how to make secrets available on a Kubernetes cluster using [Flux](https://fluxcd.io/), [SOPS](https://github.com/mozilla/sops), and External Secrets with the Doppler provider.

If you're new to Flux or SOPS, be sure to check out the Flux documentation and the SOPS GitHub repository for more information.

_Check the following [document](https://fluxcd.io/docs/guides/mozilla-sops/) on how to integrate SOPS into Flux_

### Generate Secrets from Doppler through External Secrets

#### Example 1

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
    - secretKey: ELASTICSEARCH_PASSWORD   # key to be created
      remoteRef:
        key: ELASTICSEARCH_PASSWORD       # remote secret name

    - secretKey: ELASTICSEARCH_USERNAME   # key to be created
      remoteRef:
        key: ELASTICSEARCH_USERNAME       # remote secret name
```

This YAML snippet shows an example of creating an ExternalSecret with different keys. The `secretStoreRef` field specifies the name of the `ClusterSecretStore` to use for retrieving secrets, note that this is necessary in order to retrieve the data (secrets) stored in Doppler. The target field specifies the name of the Kubernetes Secret that should be created or updated with the retrieved secrets. Finally, the data field specifies the keys of the secrets to retrieve and the remote reference to use for retrieving each secret. In this concrete example in Doppler there is:

```
ELASTICSEARCH_USERNAME: MY_USERNAME
ELASTICSEARCH_PASSWORD: MY_PASSWORD
```

Note that `secretKey` has not to be the same as `remoteRef.key`

### Example 2

This YAML snippet shows an example of creating an ExternalSecret that retrieves all of its secrets from a single remote reference using the `dataFrom` field. The extract field specifies the key of the secret to retrieve, and the retrieved secret is assumed to be a JSON object containing key-value pairs.

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

The keys in the JSON object are used to populate the data field of the Kubernetes Secret, while the values are rendered using Go templates. The Go templates can be used to substitute environment variables or other values at runtime.
