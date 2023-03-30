
## k3s documentation references

```
extra_server_args: "--disable servicelb --disable traefik --etcd-expose-metrics=true --kube-controller-manager-arg=bind-address=0.0.0.0 --kube-proxy-arg=metrics-bind-address=0.0.0.0 --kube-scheduler-arg=bind-address=0.0.0.0"
extra_agent_args: ""
```

https://docs.k3s.io/cli/server

## k3s components monitoring

By default, K3S components (Scheduler, Controller Manager, and Proxy) do not expose their endpoints for metric collection. Their /metrics endpoints are bound to 127.0.0.1, making them accessible only to localhost and preventing remote queries.

To modify this behavior, you must provide the following installation arguments for K3S:

```
--kube-controller-manager-arg 'bind-address=0.0.0.0'
--kube-proxy-arg 'metrics-bind-address=0.0.0.0'
--kube-scheduler-arg 'bind-address=0.0.0.0
```


