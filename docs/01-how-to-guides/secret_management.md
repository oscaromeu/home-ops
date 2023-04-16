---
title: Secret Management
---

## Overview

This guide demonstrates the different ways to utilize Kubernetes secrets when using [Flux](https://fluxcd.io/), [SOPS](https://github.com/mozilla/sops) and External Secrets with Doppler provider.

_Check the following [document](https://fluxcd.io/docs/guides/mozilla-sops/) on how to integrate SOPS into Flux_

All the examples will use the following secret


```yaml
apiVersion: v1
kind: Secret
metadata:
  name: application-secret
  namespace: default
stringData:
  AWESOME_SECRET: "SUPER SECRET VALUE"
```

## Create the Secret

1. Create in Doppler the `AWESOME_SECRET` variable with the desired value
2. Create an external secret resource

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
    name: application-secret

  data:
    - secretKey: AWESOME_SECRET
      remoteRef:
        key: AWESOME_SECRET
```

## Method 1: `envFrom`

Use `envFrom` in a deployment or a Helm chart that supports the setting, this will pass all secret items from the secret into the containers environment.

```yaml
envFrom:
  - secretRef:
      name: application-secret
```

Add an example

## Method 2: `env.valueFrom`

Similar to the above but it's possible with `env` to pick an item from a secret.

```yaml
env:
  - name: WAY_COOLER_ENV_VARIABLE
    valueFrom:
      secretKeyRef:
        name: application-secret
        key: AWESOME_SECRET
```

Add an example

## Method 3: `spec.valuesFrom`

The Flux HelmRelease option `valuesFrom` can inject a secret item into the Helm values of a `HelmRelease`
 * _Does not work with merging array values
 * _Care needed with keys that contain dot notation in the name

```yaml
valuesFrom:
  - targetPath: config."admin\.password"
    kind: Secret
    name: application-secret
    valuesKey: AWESOME_SECRET
```

Add an example

## Method 4: Variable Substitution with Flux

Flux variable substitution can inject secrets into any YAML manifest. This requires the [Flux Kustomization](https://fluxcd.io/docs/components/kustomize/kustomization/) configured to enable [variable substitution](https://fluxcd.io/docs/components/kustomize/kustomization/#variable-substitution). Correctly configured this allows you to use `${GLOBAL_AWESOME_SECRET}` in any YAML manifest.

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: cluster-secrets
  namespace: flux-system
stringData:
  GLOBAL_AWESOME_SECRET: "GLOBAL SUPER SECRET VALUE"
```

```yaml
apiVersion: kustomize.toolkit.fluxcd.io/v1
kind: Kustomization
# ...
spec:
# ...
  decryption:
    provider: sops
    secretRef:
      name: sops-age
  postBuild:
    substituteFrom:
      - kind: Secret
        name: cluster-secrets
```

Add an example


* For the first **three methods** consider using a tool like [stakater/reloader](https://github.com/stakater/Reloader) to restart the pod when the secret changes.

* Using reloader on a pod using a secret provided by Flux Variable Substitution will lead to pods being restarted during any change to the secret while related to the pod or not.

* The last method should be used when all other methods are not an option, or used when you have a “global” secret used by a bunch of YAML manifests.
