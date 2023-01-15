---
title: Monitoring
---
## Service Monitors

A ServiceMonitor is a Kubernetes resource that defines how Prometheus should scrape metrics from a particular service. It specifies the target service(s) to scrape, the endpoint(s) to scrape from, and any required labels or relabelling rules. ServiceMonitors can be created and managed using the Kubernetes API, and are typically used in conjunction with Prometheus Operator, which is an add-on for Prometheus that helps to automate the management of Prometheus instances in a Kubernetes cluster.

The Prometheus Operator uses servicemonitor to automate the process of configuring Prometheus to scrape metrics from specified services, and adapts the configuration according to changes in the services.


!!! note

    By default, Prometheus instances created with the Prometheus Operator have a label `release: <prometheus-installed-namespace>` in their `spec.serviceMonitorSelector.matchLabels` field. This means that Prometheus will only monitor services that have this label. To verify this, you can run the command `kubectl get prom -Ao yaml` and check the `spec.serviceMonitorSelector` field in the output. This means that if a servicemonitor does not have this label, Prometheus created by operator will not monitor it. Check the [values.yaml](https://github.com/prometheus-community/helm-charts/blob/main/charts/kube-prometheus-stack/values.yaml#L2778-L2791) of the kube-prometheus helm chart project.

    You have two options to get it work without adding `release` label

    1. Set `serviceMonitorSelectorNilUsesHelmValues` to `false`, the Prometheus will select all the serviceMonitors.
    2. Set `serviceMonitorSelector`to any label you like. Like this
    ```yaml
    commonLabels:
    prometheus: myLabel

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


## Troubleshooting

### ServiceMonitor not showing up in targets

Have you gone through our troubleshooting docs? https://github.com/coreos/prometheus-operator/blob/master/Documentation/troubleshooting.md#troubleshooting-servicemonitor-changes

