
## Introduction

When deploying applications in a cluster, it is essential to manage secrets (API keys, passwords, tokens, etc.) securely. This ensures that sensitive data is protected from unauthorized access and minimizes the potential for security breaches.

### Challenges of Secret Management

There are several challenges associated with secret management in a clustered environment:

+ __Security:__ Storing sensitive data in plaintext or hardcoding it within applications can lead to security vulnerabilities.

+ __Scalability:__ As the number of services and applications increases, managing secrets becomes complex.

+ __Versioning and Synchronization:__ Ensuring that secrets are updated and synchronized across all instances of a service can be difficult.

### What is the External Secrets resource?

The External Secrets Operator provides the translation layer between Kubernetes native secrets and external secrets. By utilizing external secrets, applications can easily retrieve the required secrets without exposing them in plaintext or hardcoding them within the application

### What about Doppler?

Doppler provides an easy-to-use interface and API for managing secrets, and supports a wide range of integrations with different platforms.


By using Doppler as the centralized secrets provider, you can store and manage secrets in one place, while allowing applications to securely access them through the External Secrets API.

## Set Up Doppler

1. Sign up for a Doppler account at https://dashboard.doppler.com/signup
2. Follow the documentation for the [doppler provider](https://external-secrets.io/main/provider/doppler/) until "Use Cases". The Service Token is located under the `kube-system/external-secrets/stores/doppler`. Instead of using a SecretStore a ClusterSecretStore is used because we want to retrieve secrets from all namespaces.

+ `doppler_cluster_store.yaml`: Defines a `ClusterSecretStore`. A `ClusterSecretStore` is a custom resource provided by the External Secrets Manager that defines the connection and authentication information needed to access an external secret management system i.e, Doppler API in this case. This resource acts as a centralized reference for other resources within the Kubernetes cluster when they need to access the secrets stored in the external system.

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

## Install Doppler CLI

Follow the installation instructions for your operating system at https://docs.doppler.com/docs/enclave-installation

## List of secrets

```
$ doppler secrets --only-names
```
