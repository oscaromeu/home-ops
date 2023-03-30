# Flux CD

Flux CD is a GitOps continuous delivery tool that automatically synchronizes Kubernetes manifests with the desired state in Git repositories. This guide covers the most important Flux CD commands and includes a troubleshooting section.


### Checking Flux Components

```sh
flux check
```

### Adding Flux Components

```sh
flux create source git <source-name> --url=<git-url> --branch=<branch> [--interval=<interval>]
flux create kustomization <kustomization-name> --source=<source-name> --path=<path> [--interval=<interval>]
```

### Synchronizing Flux Components

```sh
flux reconcile source git <source-name>
flux reconcile kustomization <kustomization-name>
```

### Suspending/Resuming Flux Components

```sh
flux suspend kustomization <kustomization-name>
flux resume kustomization <kustomization-name>
```

## Troubleshooting Flux CD

### Check the Flux CD components' status:

```sh
flux get sources git
flux get kustomizations
```

### Inspect Flux CD logs:

```sh
flux logs --level=<error|info|debug>
```

### Troubleshoot individual resources:

```sh
kubectl describe <resource-type> <resource-name> -n <namespace>
kubectl logs <pod-name> -n <namespace>
```

**Example**

```
kubectl describe -n flux-system kustomization cluster-apps
...
Events:
  Type    Reason                   Age                From                  Message
  ----    ------                   ----               ----                  -------
  Normal  ReconciliationSucceeded  46m                kustomize-controller  Reconciliation finished in 2.171262291s, next run in 30m0s
  Normal  Progressing              15m (x2 over 46m)  kustomize-controller  Namespace/flux-system configured
Namespace/monitoring configured
  Normal  ReconciliationSucceeded  15m  kustomize-controller  Reconciliation finished in 2.449433766s, next run in 30m0s
➜  home-ops git:(main) ✗ kubectl describe -n flux-system kustomization cluster-apps
```


[FluxCD Multi Tenancy on AKS with GitOps](https://medium.com/@jmasengesho/kubernetes-multi-tenancy-on-aks-with-gitops-fluxcd-v2-part-1-introduction-to-gitops-and-fluxcd-2bde2984bf3e)
