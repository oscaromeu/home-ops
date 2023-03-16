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

#### Targets scrapped

+ `cadvisor` (`job=kubelet`)
+ `nodeexporter` (`job=node-exporter`)
+ `kubelet` (`job=kubelet`)
+ `kube-state-metrics` (`job=kube-state-metrics`)

#### Metrics collected from default targets

The following metrics are collected by default from each default target. All other metrics are dropped through relabeling rules.

##### cadvisor

| Name                                        | Metric Description                          | Metric Type   |
|---------------------------------------------|---------------------------------------------|---------------|
| container_memory_rss                  | Measures the amount of memory a container is currently using in RAM.   | Performance   |
| container_network_receive_bytes_total     | Measures the total number of bytes received over the network by a container        | Throughput    |
| container_network_transmit_bytes_total    | Measures the total number of bytes transmitted over the network by a container     | Throughput    |
| container_network_receive_packets_total   | Measures the total number of network packets received by a container               | Throughput    |
| container_network_transmit_packets_total  | Measures the total number of network packets transmitted by a container            | Throughput    |
| container_network_receive_packets_dropped_total | Measures the total number of network packets dropped while being received by a container  | Throughput    |
| container_network_transmit_packets_dropped_total | Measures the total number of network packets dropped while being transmitted by a container | Throughput    |
| container_fs_reads_total                  | Measures the total number of filesystem reads performed by a container            | Throughput    |
| container_fs_writes_total                 | Measures the total number of filesystem writes performed by a container           | Throughput    |
| container_fs_reads_bytes_total            | Measures the total number of bytes read from the filesystem by a container        | Throughput    |
| container_fs_writes_bytes_total           | Measures the total number of bytes written to the filesystem by a container       | Throughput    |
| container_cpu_usage_seconds_total         | Measures the cumulative CPU time consumed by a container in seconds               | Performance   |

##### kubelet

| Metric Name | Metric Description | Metric Type |
|-------------|--------------------|-------------|
| kubelet_node_name | The name of the Kubernetes node that the kubelet is running on | None |
| kubelet_running_pods | The number of pods that are currently running on the node | Performance |
| kubelet_running_pod_count | The number of running pods on the node | Performance |
| kubelet_running_sum_containers | The total number of containers that are currently running on the node | Performance |
| kubelet_running_container_count | The number of running containers on the node | Performance |
| volume_manager_total_volumes | The total number of volumes managed by the kubelet's volume manager | Performance |
| kubelet_node_config_error | The number of times the kubelet failed to load node configuration due to errors | Throughput |
| kubelet_runtime_operations_total | The total number of runtime operations performed by the kubelet | Performance |
| kubelet_runtime_operations_errors_total | The total number of runtime operation errors encountered by the kubelet | Performance |
| kubelet_runtime_operations_duration_seconds_bucket | The bucketed histogram of durations for runtime operations performed by the kubelet | Performance |
| kubelet_runtime_operations_duration_seconds_sum | The total time taken to perform all runtime operations, in seconds | Performance |
| kubelet_runtime_operations_duration_seconds_count | The total number of runtime operations performed by the kubelet, summed across all buckets | Performance |
| kubelet_pod_start_duration_seconds_bucket | The bucketed histogram of durations for pod start operations performed by the kubelet | Performance |
| kubelet_pod_start_duration_seconds_sum | The total time taken to start all pods, in seconds | Performance |
| kubelet_pod_start_duration_seconds_count | The total number of pod start operations performed by the kubelet, summed across all buckets | Performance |
| kubelet_pod_worker_duration_seconds_bucket | The bucketed histogram of durations for pod worker operations performed by the kubelet | Performance |
| kubelet_pod_worker_duration_seconds_sum | The total time taken to perform all pod worker operations, in seconds | Performance |
| kubelet_pod_worker_duration_seconds_count | The total number of pod worker operations performed by the kubelet, summed across all buckets | Performance |
| storage_operation_duration_seconds_bucket | The bucketed histogram of durations for storage operations performed by the kubelet | Performance |
| storage_operation_duration_seconds_sum | The total time taken to perform all storage operations, in seconds | Performance |
| storage_operation_duration_seconds_count | The total number of storage operations performed by the kubelet, summed across all buckets | Performance |
| storage_operation_errors_total | The total number of errors encountered during storage operations performed by the kubelet | Performance |
| kubelet_cgroup_manager_duration_seconds_bucket | The bucketed histogram of durations for cgroup manager operations performed by the kubelet | Performance |
| kubelet_cgroup_manager_duration_seconds_sum | The total time taken to perform all cgroup manager operations, in seconds | Performance |
| kubelet_cgroup_manager_duration_seconds_count | The total number of cgroup manager operations performed by the kubelet, summed across all buckets | Performance |
| kubelet_pleg_relist_interval_seconds_bucket | The bucketed histogram of intervals at which kubelet pod lifecycle event generator (PLEG) performs relisting operations | Performance |
| kubelet_pleg_relist_interval_seconds_count | The total number of PLEG relisting operations performed by the kubelet, summed across all buckets | Performance |
| kubelet_pleg_relist_interval_seconds_sum | The total time taken to perform all PLEG relisting operations, in seconds | Performance |
| kubelet_pleg_relist_duration_seconds_bucket | The

| Metric Name                            | Metric Description                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       | Metric Type     |
|----------------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|-----------------|
| node_memory_MemTotal_bytes             | Total physical memory available on the node in bytes. This metric includes all types of memory (RAM, swap, etc.)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          | Performance     |
| node_cpu_seconds_total                 | Total CPU time consumed by the node in seconds. This metric represents the total amount of CPU time that the node has used since it was last rebooted.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               | Performance     |
| node_memory_MemAvailable_bytes         | Memory available for new processes in bytes. This metric represents the amount of memory that is currently available for new processes to use. It takes into account the amount of memory that is being used by the kernel, as well as the amount of memory that is being used by other processes.| Performance     |
| node_memory_Buffers_bytes              | Memory used by the kernel for buffering I/O operations in bytes. This metric represents the amount of memory that the kernel is using to buffer I/O operations. This is used to improve the performance of disk and network I/O. | Performance     |
| node_memory_Cached_bytes               | Memory used by the kernel for caching file system data in bytes. This metric represents the amount of memory that the kernel is using to cache file system data. This is used to improve the performance of file system operations.  | Performance     |
| node_memory_MemFree_bytes              | Total free memory available on the node in bytes. This metric represents the amount of memory that is currently not being used by the system. It takes into account the amount of memory that is being used by the kernel, as well as the amount of memory that is being used by other processes.  | Performance     |
| node_memory_Slab_bytes                 | Memory used by the kernel to cache data structures in bytes. This metric represents the amount of memory that the kernel is using to cache data structures. This is used to improve the performance of certain kernel operations. | Performance     |
| node_filesystem_avail_bytes            | Available disk space on the node's filesystem in bytes. This metric represents the amount of disk space that is currently available on the node's filesystem. | Performance     |
| node_filesystem_size_bytes             | Total size of the node's filesystem in bytes. This metric represents the total amount of disk space that is available on the node's filesystem. | Performance     |
| node_time_seconds                      | The current system time in seconds. This metric represents the current system time on the node.  | Performance     |
| node_exporter_build_info               | Information about the Node Exporter build, including the version, revision, and build date.  | Throughput      |
| node_load1                             | The load average over the last 1 minute. The load average represents the average number of processes that are either in a runnable or uninterruptable state. | Performance     |
| node_vmstat_pgmajfault                | The number of major page faults that have occurred on the node. A major page fault occurs when a process requests a page that is not currently in memory and the page has to be read in from disk. | Performance     |
| node_network_receive_bytes_total       | The total number of bytes received by the node's network interfaces.


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

## Best Practices and reference diagrams

## References

+ [Prevent metrics explosion](https://tanmay-bhat.github.io/posts/how-to-prevent-metrics-explosion-in-prometheus/)

+ [kube-prometheus-runbooks](https://runbooks.prometheus-operator.dev)

+ [Amazon Managed Prometheus](https://docs.aws.amazon.com/prometheus/latest/userguide/AMP-onboard-amg.html)
