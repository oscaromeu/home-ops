# Metrics Server

Metrics Server is a cluster-wide aggregator of resource usage metrics for pods
and nodes.  These are the same metrics that you can access by using `kubectl
top`. The metrics server collects metrics from the Summary API, exposed by Kubelet
on each node.

## Requirements

- Kubernetes >= `1.20.0`
- Kustomize >= `3.3.x`
- [cert-manager][cert] >= `1.0.0`


## Configuration

Fury distribution Metrics Server is deployed with the following configuration:

- Replica number: `1`
- Metrics are scraped from Kubelets every `30s`
- Skips verifying Kubelet CA certificates


<!-- Links -->

[cert]: https://github.com/sighupio/fury-kubernetes-ingress/tree/master/katalog/cert-manager
[ms-gh]: https://github.com/kubernetes/kubernetes/tree/master/cluster/addons/metrics-server
[ms-doc]: https://kubernetes.io/docs/tasks/debug-application-cluster/core-metrics-pipeline/

<!-- </KFD-DOCS> -->

## License

For license details please see [LICENSE](../../LICENSE)
