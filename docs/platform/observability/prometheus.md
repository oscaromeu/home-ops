---
title: Prometheus
---

## Overview

## Ingest Prometheus Metrics

### Service Monitors

A ServiceMonitor is a Kubernetes resource that defines how Prometheus should scrape metrics from a particular service. It specifies the target service(s) to scrape, the endpoint(s) to scrape from, and any required labels or relabelling rules. ServiceMonitors can be created and managed using the Kubernetes API, and are typically used in conjunction with Prometheus Operator, which is an add-on for Prometheus that helps to automate the management of Prometheus instances in a Kubernetes cluster.

The Prometheus Operator uses servicemonitor to automate the process of configuring Prometheus to scrape metrics from specified services, and adapts the configuration according to changes in the services.

#### Examples

??? example "The service and service monitor are both in the `default` namespace (click to expand)"
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

??? example "The service is in the `production` namespace and service monitor is in `monitoring` namespace (click to expand)"

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

### Used Exporters

## Query the Prometheus metrics

## Rule evaluation and alerting

## Set up horizontal pod autoscaling (HPA)

## Storage

## Alerting and monitoring

### Default Prometheus metrics configuration

This entry list the default targets, dashboards, and recording rules available when deploying the cluster.

#### Scrape frequency

The default scrape frequency for all defult targets and scrapes is 30 seconds.

#### Default targets scrapped

+ `cadvisor` (`job=kubelet`) cAdvisor (short for "Container Advisor") is a tool that provides container-level metrics and resource usage statistics for Docker and other container systems. In Kubernetes, cAdvisor is usually run as a part of the kubelet on each node and collects metrics about the containers running on that node.

+ `nodeexporter` (`job=node-exporter`)  Prometheus exporter that collects various system-level metrics from a node in a Kubernetes cluster, including CPU usage, memory usage, disk usage, network usage, and more. It is typically run as a separate process on each node, and its metrics can be used to monitor the health and performance of the nodes themselves.

+ `kubelet` (`job=kubelet`) Metrics about kubelet which is the primary "node agent" in a Kubernetes cluster, responsible for managing the containers and pods that are scheduled to run on a given node. Among other things, kubelet communicates with the API server to retrieve information about which pods it should be running, and then starts and stops containers as necessary to keep the desired state of the system.

+ `kube-state-metrics` (`job=kube-state-metrics`) kube-state-metrics is a tool that provides detailed metrics about the state of various Kubernetes objects, such as pods, deployments, services, and more. It runs as a separate process and exposes its metrics in a Prometheus-compatible format, allowing users to monitor the state of their Kubernetes cluster and troubleshoot any issues that arise.

By default k3s exposes all metrics combined (apiserver, kubelet, kube-proxy, kube-scheduler, kube-controller). The kube-prometheus stack has two jobs that
pulls this metrics, to avoid duplicates the following configuration is set

```
    kubeApiServer:
      metricRelabelings:
        # remove duplicates
        - action: drop
          sourceLabels: ["__name__"]
          regex: '(aggregator_|apiextensions_|etcd_|scheduler_|workqueue).*'
```

And in order to have standard names the following is applied

```
kubelet:
  serviceMonitor:
    metricRelabelings:
      # k3s exposes all metrics on all endpoints, relabel jobs that belong to other components
      - sourceLabels: [__name__]
        regex: "scheduler_(.+)"
        targetLabel: "job"
        replacement: "kube-scheduler"
      - sourceLabels: [__name__]
        regex: "kubeproxy_(.+)"
        targetLabel: "job"
        replacement: "kube-proxy"
```


#### Metrics collected from default targets

The following metrics are collected by default from each default target. All other metrics are dropped through relabeling rules.

??? cAdvisor List of metrics

    + `container_cpu_cfs_periods_total`
    + `container_cpu_cfs_throttled_periods_total`
    + `container_cpu_cfs_throttled_seconds_total`
    + `container_cpu_usage_seconds_total`
    + `container_memory_rss`
    + `container_memory_usage_bytes`
    + `container_memory_working_set_bytes`
    + `container_network_receive_bytes_total`
    + `container_network_transmit_bytes_total`
    + `container_network_receive_packets_total`
    + `container_network_transmit_packets_total`
    + `container_network_receive_packets_dropped_total`
    + `container_network_transmit_packets_dropped_total`
    + `container_oom_events_total`
    + `container_fs_reads_total`
    + `container_fs_writes_total`
    + `container_fs_reads_bytes_total`
    + `container_fs_writes_bytes_total`


    Check the following table in the [cAdvisor documentation](https://github.com/google/cadvisor/blob/master/docs/storage/prometheus.md) in case there is any doubt regards the type of the metric, what it is his purpose or the units

??? kubelet List of metrics

    + `kubelet_node_name`
    + `kubelet_running_pods`
    + `kubelet_running_pod_count`
    + `kubelet_running_sum_containers`
    + `kubelet_running_container_count`
    + `volume_manager_total_volumes`
    + `kubelet_node_config_error`
    + `kubelet_runtime_operations_total`
    + `kubelet_runtime_operations_errors_total`
    + `kubelet_runtime_operations_duration_seconds_bucket`
    + `kubelet_runtime_operations_duration_seconds_sum`
    + `kubelet_runtime_operations_duration_seconds_count`
    + `kubelet_pod_start_duration_seconds_bucket`
    + `kubelet_pod_start_duration_seconds_sum`
    + `kubelet_pod_start_duration_seconds_count`
    + `kubelet_pod_worker_duration_seconds_bucket`
    + `kubelet_pod_worker_duration_seconds_sum`
    + `kubelet_pod_worker_duration_seconds_count`
    + `storage_operation_duration_seconds_bucket`
    + `storage_operation_duration_seconds_sum`
    + `storage_operation_duration_seconds_count`
    + `storage_operation_errors_total`
    + `kubelet_cgroup_manager_duration_seconds_bucket`
    + `kubelet_cgroup_manager_duration_seconds_sum`
    + `kubelet_cgroup_manager_duration_seconds_count`
    + `kubelet_pleg_relist_interval_seconds_bucket`
    + `kubelet_pleg_relist_interval_seconds_count`
    + `kubelet_pleg_relist_interval_seconds_sum`
    + `kubelet_pleg_relist_duration_seconds_bucket`
    + `kubelet_pleg_relist_duration_seconds_count`
    + `kubelet_pleg_relist_duration_seconds_sum`
    + `rest_client_requests_total`
    + `rest_client_request_duration_seconds_bucket`
    + `rest_client_request_duration_seconds_sum`
    + `rest_client_request_duration_seconds_count`
    + `process_resident_memory_bytes`
    + `process_cpu_seconds_total`
    + `go_goroutines`
    + `kubernetes_build_info`



??? "node-exporter"

    + `node_memory_MemTotal_bytes`
    + `node_cpu_seconds_total`
    + `node_memory_MemAvailable_bytes`
    + `node_memory_Buffers_bytes`
    + `node_memory_Cached_bytes`
    + `node_memory_MemFree_bytes`
    + `node_memory_Slab_bytes`
    + `node_filesystem_avail_bytes`
    + `node_filesystem_size_bytes`
    + `node_time_seconds`
    + `node_exporter_build_info`
    + `node_load1`
    + `node_vmstat_pgmajfault`
    + `node_network_receive_bytes_total`
    + `node_network_transmit_bytes_total`
    + `node_network_receive_drop_total`
    + `node_network_transmit_drop_total`
    + `node_disk_io_time_seconds_total`
    + `node_disk_io_time_weighted_seconds_total`
    + `node_load5`
    + `node_load15`
    + `node_disk_read_bytes_total`
    + `node_disk_written_bytes_total`
    + `node_uname_info`


    Check the following documentation of [prometheus node exporter in splunk](https://docs.splunk.com/Observability/gdi/prometheus-node/prometheus-node.html#metrics)

??? "kube-state-metrics"

    + `kube_pod_owner`
    + `kube_pod_container_resource_requests`
    + `kube_pod_status_phase`
    + `kube_pod_container_resource_limits`
    + `kube_pod_info`
    + `kube_pod_labels`
    + `kube_pod_container_info`
    + `kube_pod_container_status_waiting`
    + `kube_pod_container_status_waiting_reason`
    + `kube_pod_container_status_running`
    + `kube_pod_container_status_terminated`
    + `kube_pod_container_status_terminated_reason`
    + `kube_pod_container_status_restarts_total`
    + `kube_replicaset_owner`
    + `kube_resourcequota`
    + `kube_namespace_status_phase`
    + `kube_node_spec_unschedulable`
    + `kube_node_status_allocatable`
    + `kube_node_status_capacity`
    + `kube_node_info`
    + `kube_node_status_condition`
    + `kube_node_spec_taint`
    + `kube_daemonset_created`
    + `kube_daemonset_status_current_number_scheduled`
    + `kube_daemonset_status_desired_number_scheduled`
    + `kube_daemonset_status_number_available`
    + `kube_daemonset_status_number_ready`
    + `kube_daemonset_status_number_unavailable`
    + `kube_daemonset_labels`
    + `kube_deployment_labels`
    + `kube_deployment_spec_replicas`
    + `kube_deployment_status_replicas_available`
    + `kube_deployment_status_replicas_unavailable`
    + `kube_deployment_status_replicas_updated`
    + `kube_statefulset_labels`
    + `kube_statefulset_status_replicas_available`
    + `kube_statefulset_status_replicas`
    + `kube_statefulset_status_replicas_current`
    + `kube_job_status_start_time`
    + `kube_job_status_active`
    + `kube_job_failed`
    + `kube_horizontalpodautoscaler_status_desired_replicas`
    + `kube_horizontalpodautoscaler_status_current_replicas`
    + `kube_horizontalpodautoscaler_spec_min_replicas`
    + `kube_horizontalpodautoscaler_spec_max_replicas`
    + `kubernetes_build_info`


# Troubleshooting

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

## Best Practices and reference diagrams

## References

+ [Prevent metrics explosion](https://tanmay-bhat.github.io/posts/how-to-prevent-metrics-explosion-in-prometheus/)

+ [kube-prometheus-runbooks](https://runbooks.prometheus-operator.dev)

+ [Amazon Managed Prometheus](https://docs.aws.amazon.com/prometheus/latest/userguide/AMP-onboard-amg.html)
