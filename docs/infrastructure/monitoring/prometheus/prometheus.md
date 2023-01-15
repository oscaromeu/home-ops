---
title: Monitoring
---
## Service Monitors

A ServiceMonitor is a Kubernetes resource that defines how Prometheus should scrape metrics from a particular service. It specifies the target service(s) to scrape, the endpoint(s) to scrape from, and any required labels or relabelling rules. ServiceMonitors can be created and managed using the Kubernetes API, and are typically used in conjunction with Prometheus Operator, which is an add-on for Prometheus that helps to automate the management of Prometheus instances in a Kubernetes cluster.

The Prometheus Operator uses servicemonitor to automate the process of configuring Prometheus to scrape metrics from specified services, and adapts the configuration according to changes in the services.

## Troubleshooting

### ServiceMonitor not showing up in targets

!!! info
    [Check the oficial troubleshooting guide](https://github.com/coreos/prometheus-operator/blob/master/Documentation/troubleshooting.md#troubleshooting-servicemonitor-changes)

By default, Prometheus instances created with the Helm Kube Prometheus stack have a label `release: <prometheus-installed-namespace>` in their `spec.serviceMonitorSelector.matchLabels` field. This means that Prometheus will only monitor services that have this label. To verify this, you can run the command `kubectl get prom -Ao yaml` and check the `spec.serviceMonitorSelector` field in the output. This means that if a servicemonitor does not have this label, Prometheus created by operator will not monitor it. Check the [values.yaml](https://github.com/prometheus-community/helm-charts/blob/main/charts/kube-prometheus-stack/values.yaml#L2778-L2791) of the kube-prometheus helm chart project.

You have two options to get it work without adding `release` label:

+ Set `serviceMonitorSelectorNilUsesHelmValues` to `false`, the Prometheus will select all the serviceMonitors.

    _before_

    ```
    $ kubectl get prom -Ao yaml | grep -A2 -B2 serviceMonitorSelector
    serviceAccountName: kube-prometheus-stack-prometheus
    serviceMonitorNamespaceSelector: {}
    serviceMonitorSelector:
      matchLabels:
        release: kube-prometheus-stack
    ```

    _after_

    ```
    $ kubectl get prom -Ao yaml | grep -A2 -B2 serviceMonitorSelector
    serviceAccountName: kube-prometheus-stack-prometheus
    serviceMonitorNamespaceSelector: {}
    serviceMonitorSelector: {}
    shards: 1
    version: v2.41.0
    ```

    _moreover_

    ```
    $ kubectl -n monitoring get secret prometheus-kube-prometheus-stack-prometheus -ojson | jq -r '.data["prometheus.yaml.gz"]' | base64 -d | gunzip | grep serviceMoni
    - job_name: serviceMonitor/kube-system/descheduler-servicemonitor/0
    - job_name: serviceMonitor/logging/prometheus-elasticsearch-exporter-monitor/0
    - job_name: serviceMonitor/logging/redis/0
    - job_name: serviceMonitor/monitoring/grafana/0
    - job_name: serviceMonitor/monitoring/kube-prometheus-stack-alertmanager/0
    - job_name: serviceMonitor/monitoring/kube-prometheus-stack-apiserver/0
    - job_name: serviceMonitor/monitoring/kube-prometheus-stack-coredns/0
    - job_name: serviceMonitor/monitoring/kube-prometheus-stack-kube-state-metrics/0
    - job_name: serviceMonitor/monitoring/kube-prometheus-stack-kubelet/0
    - job_name: serviceMonitor/monitoring/kube-prometheus-stack-kubelet/1
    - job_name: serviceMonitor/monitoring/kube-prometheus-stack-kubelet/2
    - job_name: serviceMonitor/monitoring/kube-prometheus-stack-operator/0
    - job_name: serviceMonitor/monitoring/kube-prometheus-stack-prometheus/0
    - job_name: serviceMonitor/monitoring/kube-prometheus-stack-prometheus-node-exporter/0
    ```

+ Set `serviceMonitorSelector`to any label you like. Like this

```yaml
commonLabels:
prometheus: myLabe
prometheus:
  prometheusSpec:
    serviceMonitorSelector:
      matchLabels:
        prometheus: myLabel
```


??? example "Example: The service and service monitor are both in the `default` namespace (click to expand)"
    ```yaml
      ---
      apiVersion: v1
      kind: Service
      metadata:
        name: my-service
        namespace: default
        labels:
          app: my-app

      ---
      apiVersion: monitoring.coreos.com/v1
      kind: ServiceMonitor
      metadata:
        name: my-service-monitor
        namespace: default
        labels:
          app: my-app
      spec:
        selector:
          matchLabels:
            app: my-app
        endpoints:
        - path: /metrics
    ```

??? example "Example: The service is in the `production` namespace and service monitor is in `monitoring` namespace (click to expand)"

    ```yaml
    ---
    apiVersion: v1
    kind: Service
    metadata:
      name: my-service
      namespace: production
      labels:
        app: my-app

    ---
    apiVersion: monitoring.coreos.com/v1
    kind: ServiceMonitor
    metadata:
      name: my-service-monitor
      namespace: monitoring
      labels:
        app: my-app
    spec:
      namespaceSelector:
        matchNames:
          - production
      selector:
        matchLabels:
          app: my-app
      endpoints:
      - path: /metrics
    ```

    And here is an example of how to use a label selector that matches the labels on the service across all namespaces:

    ```yaml
    apiVersion: monitoring.coreos.com/v1
    kind: ServiceMonitor
    metadata:
      name: my-service-monitor
      namespace: monitoring
      labels:
        app: my-app
    spec:
      selector:
        matchLabels:
          app: my-app
      endpoints:
      - path: /metrics
      namespaceSelector:
        any: true
    ```




