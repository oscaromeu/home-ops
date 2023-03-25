
## k3s documentation references
https://docs.k3s.io/cli/server

## k3s components monitoring

By default, K3S components (Scheduler, Controller Manager and Proxy) do not expose their endpoints to be able to collect metrics. Their /metrics endpoints are bind to 127.0.0.1, exposing them only to localhost, not allowing the remote query.

The following K3S intallation arguments need to be provided, to change this behaviour.

```
--kube-controller-manager-arg 'bind-address=0.0.0.0'
--kube-proxy-arg 'metrics-bind-address=0.0.0.0'
--kube-scheduler-arg 'bind-address=0.0.0.0
```
