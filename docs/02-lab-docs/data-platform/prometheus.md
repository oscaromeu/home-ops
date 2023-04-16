---
title: Prometheus
---

## Introduction

Monitoring a Kubernetes cluster is essential to ensure the stability, performance, and security of applications running on it. One popular solution for monitoring Kubernetes is Prometheus, an open-source monitoring and alerting toolkit. The Prometheus Operator simplifies the process of managing Prometheus instances in Kubernetes clusters. This document explains how to ingest metrics in a Kubernetes cluster using the Prometheus Operator and its related custom resources, ServiceMonitors and PodMonitors.

## Metrics Ingestion


### Scrape frequency

The default scrape frequency for all default targets and scrapes is 60s

### Default Targets scraped

These jobs involve scraping metrics from the core components of the k3s cluster. There are additional jobs that haven't been listed here, as they aren't deemed critical to the cluster's overall functionality.

To retrieve the available jobs in the cluster, you can use the following query:

```sql
sum by (job) (up)
```

+ `apiserver` (`{job="apiserver"}`)

+ `kube-controller-manager` (`{job="kube-controller-manager"}`)

+ `kube-scheduler` (`{job="kube-scheduler"}`)

+ `kubelet` (`{job="kubelet"}`)

+ `kube-state-metrics` (`{job="kube-state-metrics"}`)

+ `coredns` (`{job="coredns"}`)

+ `prometheus-alertmanager` (`{job="prometheus-alertmanager"}`)

+ `prometheus-operator` (`{job="prometheus-operator"}`)

+ `prometheus` (`{job="prometheus-prometheus"}`)


### Metrics collected from targets

The metrics gathered by default from each standard target are listed here, while all other metrics are discarded using relabeling rules. To obtain the metrics from these standard targets, for example, `job="kubelet"` you can execute the following:

```sql
group by (__name__) ({job="kubelet"})
```

??? "apiserver (click to expand)"

    + `apiserver_admission_controller_admission_duration_seconds_bucket`
    + `apiserver_admission_controller_admission_duration_seconds_count`
    + `apiserver_admission_controller_admission_duration_seconds_sum`
    + `apiserver_admission_step_admission_duration_seconds_bucket`
    + `apiserver_admission_step_admission_duration_seconds_count`
    + `apiserver_admission_step_admission_duration_seconds_sum`
    + `apiserver_admission_step_admission_duration_seconds_summary`
    + `apiserver_admission_step_admission_duration_seconds_summary_count`
    + `apiserver_admission_step_admission_duration_seconds_summary_sum`
    + `apiserver_admission_webhook_admission_duration_seconds_bucket`
    + `apiserver_admission_webhook_admission_duration_seconds_count`
    + `apiserver_admission_webhook_admission_duration_seconds_sum`
    + `apiserver_admission_webhook_fail_open_count`
    + `apiserver_admission_webhook_rejection_count`
    + `apiserver_admission_webhook_request_total`
    + `apiserver_audit_event_total`
    + `apiserver_audit_requests_rejected_total`
    + `apiserver_current_inflight_requests`
    + `apiserver_current_inqueue_requests`
    + `apiserver_delegated_authn_request_duration_seconds_bucket`
    + `apiserver_delegated_authn_request_duration_seconds_count`
    + `apiserver_delegated_authn_request_duration_seconds_sum`
    + `apiserver_delegated_authn_request_total`
    + `apiserver_delegated_authz_request_duration_seconds_bucket`
    + `apiserver_delegated_authz_request_duration_seconds_count`
    + `apiserver_delegated_authz_request_duration_seconds_sum`
    + `apiserver_delegated_authz_request_total`
    + `apiserver_init_events_total`
    + `apiserver_longrunning_requests`
    + `apiserver_request_aborts_total`
    + `apiserver_request_duration_seconds_count`
    + `apiserver_request_duration_seconds_sum`
    + `apiserver_request_filter_duration_seconds_bucket`
    + `apiserver_request_filter_duration_seconds_count`
    + `apiserver_request_filter_duration_seconds_sum`
    + `apiserver_request_post_timeout_total`
    + `apiserver_request_sli_duration_seconds_count`
    + `apiserver_request_sli_duration_seconds_sum`
    + `apiserver_request_slo_duration_seconds_count`
    + `apiserver_request_slo_duration_seconds_sum`
    + `apiserver_request_terminations_total`
    + `apiserver_request_timestamp_comparison_time_bucket`
    + `apiserver_request_timestamp_comparison_time_count`
    + `apiserver_request_timestamp_comparison_time_sum`
    + `apiserver_request_total`
    + `apiserver_requested_deprecated_apis`
    + `apiserver_response_sizes_count`
    + `apiserver_response_sizes_sum`
    + `apiserver_selfrequest_total`
    + `apiserver_storage_db_total_size_in_bytes`
    + `apiserver_storage_list_evaluated_objects_total`
    + `apiserver_storage_list_fetched_objects_total`
    + `apiserver_storage_list_returned_objects_total`
    + `apiserver_storage_list_total`
    + `apiserver_storage_objects`
    + `apiserver_tls_handshake_errors_total`
    + `apiserver_watch_events_sizes_count`
    + `apiserver_watch_events_sizes_sum`
    + `apiserver_watch_events_total`
    + `count:up`
    + `scrape_duration_seconds`
    + `scrape_samples_post_metric_relabeling`
    + `scrape_samples_scraped`
    + `scrape_series_added`
    + `up`

??? "kube-controller-manager" (click to expand)"

    + `apiserver_audit_event_total`
    + `apiserver_audit_requests_rejected_total`
    + `apiserver_client_certificate_expiration_seconds_bucket`
    + `apiserver_client_certificate_expiration_seconds_count`
    + `apiserver_client_certificate_expiration_seconds_sum`
    + `apiserver_delegated_authn_request_duration_seconds_bucket`
    + `apiserver_delegated_authn_request_duration_seconds_count`
    + `apiserver_delegated_authn_request_duration_seconds_sum`
    + `apiserver_delegated_authn_request_total`
    + `apiserver_delegated_authz_request_duration_seconds_bucket`
    + `apiserver_delegated_authz_request_duration_seconds_count`
    + `apiserver_delegated_authz_request_duration_seconds_sum`
    + `apiserver_delegated_authz_request_total`
    + `apiserver_envelope_encryption_dek_cache_fill_percent`
    + `apiserver_storage_data_key_generation_duration_seconds_bucket`
    + `apiserver_storage_data_key_generation_duration_seconds_count`
    + `apiserver_storage_data_key_generation_duration_seconds_sum`
    + `apiserver_storage_data_key_generation_failures_total`
    + `apiserver_storage_db_total_size_in_bytes`
    + `apiserver_storage_envelope_transformation_cache_misses_total`
    + `apiserver_storage_list_evaluated_objects_total`
    + `apiserver_storage_list_fetched_objects_total`
    + `apiserver_storage_list_returned_objects_total`
    + `apiserver_storage_list_total`
    + `apiserver_storage_objects`
    + `apiserver_webhooks_x509_insecure_sha_total`
    + `apiserver_webhooks_x509_missing_san_total`
    + `attachdetach_controller_forced_detaches`
    + `attachdetach_controller_total_volumes`
    + `authenticated_user_requests`
    + `authentication_attempts`
    + `authentication_duration_seconds_bucket`
    + `authentication_duration_seconds_count`
    + `authentication_duration_seconds_sum`
    + `authentication_token_cache_active_fetch_count`
    + `authentication_token_cache_fetch_total`
    + `authentication_token_cache_request_duration_seconds_bucket`
    + `authentication_token_cache_request_duration_seconds_count`
    + `authentication_token_cache_request_duration_seconds_sum`
    + `authentication_token_cache_request_total`
    + `count:up`
    + `cronjob_controller_job_creation_skew_duration_seconds_bucket`
    + `cronjob_controller_job_creation_skew_duration_seconds_count`
    + `cronjob_controller_job_creation_skew_duration_seconds_sum`
    + `disabled_metric_total`
    + `endpoint_slice_controller_changes`
    + `endpoint_slice_controller_desired_endpoint_slices`
    + `endpoint_slice_controller_endpoints_added_per_sync_bucket`
    + `endpoint_slice_controller_endpoints_added_per_sync_count`
    + `endpoint_slice_controller_endpoints_added_per_sync_sum`
    + `endpoint_slice_controller_endpoints_desired`
    + `endpoint_slice_controller_endpoints_removed_per_sync_bucket`
    + `endpoint_slice_controller_endpoints_removed_per_sync_count`
    + `endpoint_slice_controller_endpoints_removed_per_sync_sum`
    + `endpoint_slice_controller_endpointslices_changed_per_sync_bucket`
    + `endpoint_slice_controller_endpointslices_changed_per_sync_count`
    + `endpoint_slice_controller_endpointslices_changed_per_sync_sum`
    + `endpoint_slice_controller_num_endpoint_slices`
    + `endpoint_slice_controller_syncs`
    + `endpoint_slice_mirroring_controller_addresses_skipped_per_sync_bucket`
    + `endpoint_slice_mirroring_controller_addresses_skipped_per_sync_count`
    + `endpoint_slice_mirroring_controller_addresses_skipped_per_sync_sum`
    + `endpoint_slice_mirroring_controller_changes`
    + `endpoint_slice_mirroring_controller_desired_endpoint_slices`
    + `endpoint_slice_mirroring_controller_endpoints_added_per_sync_bucket`
    + `endpoint_slice_mirroring_controller_endpoints_added_per_sync_count`
    + `endpoint_slice_mirroring_controller_endpoints_added_per_sync_sum`
    + `endpoint_slice_mirroring_controller_endpoints_desired`
    + `endpoint_slice_mirroring_controller_endpoints_removed_per_sync_bucket`
    + `endpoint_slice_mirroring_controller_endpoints_removed_per_sync_count`
    + `endpoint_slice_mirroring_controller_endpoints_removed_per_sync_sum`
    + `endpoint_slice_mirroring_controller_endpoints_sync_duration_bucket`
    + `endpoint_slice_mirroring_controller_endpoints_sync_duration_count`
    + `endpoint_slice_mirroring_controller_endpoints_sync_duration_sum`
    + `endpoint_slice_mirroring_controller_endpoints_updated_per_sync_bucket`
    + `endpoint_slice_mirroring_controller_endpoints_updated_per_sync_count`
    + `endpoint_slice_mirroring_controller_endpoints_updated_per_sync_sum`
    + `endpoint_slice_mirroring_controller_num_endpoint_slices`
    + `ephemeral_volume_controller_create_failures_total`
    + `ephemeral_volume_controller_create_total`
    + `garbagecollector_controller_resources_sync_error_total`
    + `go_cgo_go_to_c_calls_calls_total`
    + `go_gc_cycles_automatic_gc_cycles_total`
    + `go_gc_cycles_forced_gc_cycles_total`
    + `go_gc_cycles_total_gc_cycles_total`
    + `go_gc_duration_seconds`
    + `go_gc_duration_seconds_count`
    + `go_gc_duration_seconds_sum`
    + `go_gc_heap_allocs_by_size_bytes_bucket`
    + `go_gc_heap_allocs_by_size_bytes_count`
    + `go_gc_heap_allocs_by_size_bytes_sum`
    + `go_gc_heap_allocs_bytes_total`
    + `go_gc_heap_allocs_objects_total`
    + `go_gc_heap_frees_by_size_bytes_bucket`
    + `go_gc_heap_frees_by_size_bytes_count`
    + `go_gc_heap_frees_by_size_bytes_sum`
    + `go_gc_heap_frees_bytes_total`
    + `go_gc_heap_frees_objects_total`
    + `go_gc_heap_goal_bytes`
    + `go_gc_heap_objects_objects`
    + `go_gc_heap_tiny_allocs_objects_total`
    + `go_gc_limiter_last_enabled_gc_cycle`
    + `go_gc_pauses_seconds_bucket`
    + `go_gc_pauses_seconds_count`
    + `go_gc_pauses_seconds_sum`
    + `go_gc_stack_starting_size_bytes`
    + `go_goroutines`
    + `go_info`
    + `go_memory_classes_heap_free_bytes`
    + `go_memory_classes_heap_objects_bytes`
    + `go_memory_classes_heap_released_bytes`
    + `go_memory_classes_heap_stacks_bytes`
    + `go_memory_classes_heap_unused_bytes`
    + `go_memory_classes_metadata_mcache_free_bytes`
    + `go_memory_classes_metadata_mcache_inuse_bytes`
    + `go_memory_classes_metadata_mspan_free_bytes`
    + `go_memory_classes_metadata_mspan_inuse_bytes`
    + `go_memory_classes_metadata_other_bytes`
    + `go_memory_classes_os_stacks_bytes`
    + `go_memory_classes_other_bytes`
    + `go_memory_classes_profiling_buckets_bytes`
    + `go_memory_classes_total_bytes`
    + `go_memstats_alloc_bytes`
    + `go_memstats_alloc_bytes_total`
    + `go_memstats_buck_hash_sys_bytes`
    + `go_memstats_frees_total`
    + `go_memstats_gc_sys_bytes`
    + `go_memstats_heap_alloc_bytes`
    + `go_memstats_heap_idle_bytes`
    + `go_memstats_heap_inuse_bytes`
    + `go_memstats_heap_objects`
    + `go_memstats_heap_released_bytes`
    + `go_memstats_heap_sys_bytes`
    + `go_memstats_last_gc_time_seconds`
    + `go_memstats_lookups_total`
    + `go_memstats_mallocs_total`
    + `go_memstats_mcache_inuse_bytes`
    + `go_memstats_mcache_sys_bytes`
    + `go_memstats_mspan_inuse_bytes`
    + `go_memstats_mspan_sys_bytes`
    + `go_memstats_next_gc_bytes`
    + `go_memstats_other_sys_bytes`
    + `go_memstats_stack_inuse_bytes`
    + `go_memstats_stack_sys_bytes`
    + `go_memstats_sys_bytes`
    + `go_sched_gomaxprocs_threads`
    + `go_sched_goroutines_goroutines`
    + `go_sched_latencies_seconds_bucket`
    + `go_sched_latencies_seconds_count`
    + `go_sched_latencies_seconds_sum`
    + `go_threads`
    + `hidden_metric_total`
    + `job_controller_job_pods_finished_total`
    + `job_controller_job_sync_duration_seconds_bucket`
    + `job_controller_job_sync_duration_seconds_count`
    + `job_controller_job_sync_duration_seconds_sum`
    + `job_controller_job_syncs_total`
    + `job_controller_jobs_finished_total`
    + `job_controller_terminated_pods_tracking_finalizer_total`
    + `kubernetes_build_info`
    + `kubernetes_feature_enabled`
    + `node_collector_evictions_total`
    + `node_collector_unhealthy_nodes_in_zone`
    + `node_collector_zone_health`
    + `node_collector_zone_size`
    + `node_ipam_controller_cidrset_allocation_tries_per_request_bucket`
    + `node_ipam_controller_cidrset_allocation_tries_per_request_count`
    + `node_ipam_controller_cidrset_allocation_tries_per_request_sum`
    + `node_ipam_controller_cidrset_cidrs_allocations_total`
    + `node_ipam_controller_cidrset_usage_cidrs`
    + `process_cpu_seconds_total`
    + `process_max_fds`
    + `process_open_fds`
    + `process_resident_memory_bytes`
    + `process_start_time_seconds`
    + `process_virtual_memory_bytes`
    + `process_virtual_memory_max_bytes`
    + `pv_collector_bound_pv_count`
    + `pv_collector_bound_pvc_count`
    + `pv_collector_total_pv_count`
    + `registered_metric_total`
    + `replicaset_controller_sorting_deletion_age_ratio_bucket`
    + `replicaset_controller_sorting_deletion_age_ratio_count`
    + `replicaset_controller_sorting_deletion_age_ratio_sum`
    + `rest_client_exec_plugin_certificate_rotation_age_bucket`
    + `rest_client_exec_plugin_certificate_rotation_age_count`
    + `rest_client_exec_plugin_certificate_rotation_age_sum`
    + `rest_client_exec_plugin_ttl_seconds`
    + `rest_client_rate_limiter_duration_seconds_bucket`
    + `rest_client_rate_limiter_duration_seconds_count`
    + `rest_client_rate_limiter_duration_seconds_sum`
    + `rest_client_request_duration_seconds_count`
    + `rest_client_request_duration_seconds_sum`
    + `rest_client_request_size_bytes_bucket`
    + `rest_client_request_size_bytes_count`
    + `rest_client_request_size_bytes_sum`
    + `rest_client_requests_total`
    + `rest_client_response_size_bytes_bucket`
    + `rest_client_response_size_bytes_count`
    + `rest_client_response_size_bytes_sum`
    + `retroactive_storageclass_errors_total`
    + `retroactive_storageclass_total`
    + `root_ca_cert_publisher_sync_duration_seconds_bucket`
    + `root_ca_cert_publisher_sync_duration_seconds_count`
    + `root_ca_cert_publisher_sync_duration_seconds_sum`
    + `root_ca_cert_publisher_sync_total`
    + `running_managed_controllers`
    + `scrape_duration_seconds`
    + `scrape_samples_post_metric_relabeling`
    + `scrape_samples_scraped`
    + `scrape_series_added`
    + `storage_count_attachable_volumes_in_use`
    + `storage_operation_duration_seconds_bucket`
    + `storage_operation_duration_seconds_count`
    + `storage_operation_duration_seconds_sum`
    + `ttl_after_finished_controller_job_deletion_duration_seconds_bucket`
    + `ttl_after_finished_controller_job_deletion_duration_seconds_count`
    + `ttl_after_finished_controller_job_deletion_duration_seconds_sum`
    + `up`
    + `volume_operation_total_seconds_bucket`
    + `volume_operation_total_seconds_count`
    + `volume_operation_total_seconds_sum`
    + `workqueue_adds_total`
    + `workqueue_depth`
    + `workqueue_longest_running_processor_seconds`
    + `workqueue_queue_duration_seconds_bucket`
    + `workqueue_queue_duration_seconds_count`
    + `workqueue_queue_duration_seconds_sum`
    + `workqueue_retries_total`
    + `workqueue_unfinished_work_seconds`
    + `workqueue_work_duration_seconds_bucket`
    + `workqueue_work_duration_seconds_count`
    + `workqueue_work_duration_seconds_sum`

??? "cAdvisor (click to expand)"

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

??? "kubelet (click to expand)"

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
    + `kube_namespace_created`
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

### Adding Targets

#### Service Monitor

+ [Service Monitor API Docs](https://prometheus-operator.dev/docs/operator/api/#monitoring.coreos.com/v1.ServiceMonitor)

+ Retrieve all service monitor available

  ```sql
  group by (scrape_job) ({scrape_job!=""})
  ```

##### Examples

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

#### Pod Monitor

+ [Pod Monitor API Doc](https://prometheus-operator.dev/docs/operator/api/#monitoring.coreos.com/v1.PodMonitor)

#### Exporters and integrations

+ [Third Party Exporters](https://prometheus.io/docs/instrumenting/exporters/#third-party-exporters)
+ [Understanding and Building exporters](https://promlabs-training-platform.firebaseapp.com/training/understanding-and-building-exporters)

## k3s services monitoring

The [kubernetes Documentation on System Metrics](https://kubernetes.io/docs/concepts/cluster-administration/system-metrics/) outlines the components that expose metrics in Prometheus format:

- kube-controller-manager (TCP 10257 metrics endpoint)
- kube-proxy (TCP 10249 /metrics endpoint)
- kube-apiserver (TCP 6443 /metrics at Kubernetes API port)
- kube-scheduler (TCP 10259 /metrics endpoint)
- kubelet (TCP 10250 /metrics, /metrics/cadvisor, /metrics/resource, and /metrics/probes endpoints)

!!! info
    TCP port numbers for kube-scheduler and kube-controller-manager changed in Kubernetes release 1.22 (from 10251/10252 to 10257/10259). Additionally, an HTTPS authenticated connection is now required, so a Kubernetes authorized service account is needed to access the metrics service. Only the kube-proxy endpoint still uses HTTP; the rest now use HTTPS.

!!! tip
    By default, K3S components (Scheduler, Controller Manager, and Proxy) do not expose their endpoints for metric collection. Their /metrics endpoints are bound to 127.0.0.1, only exposing them to localhost and preventing remote queries. To change this behavior, provide the following K3S installation arguments:

    ```
    --kube-controller-manager-arg 'bind-address=0.0.0.0'
    --kube-proxy-arg 'metrics-bind-address=0.0.0.0'
    --kube-scheduler-arg 'bind-address=0.0.0.0'
    ```

kube-prometheus-stack creates the kubernetes resources needed to scrape metrics from all k8S components in a standard Kubernetes distribution, but these objects are not valid for a K3S cluster. K3S has a unique behavior related to metrics exposure. It deploys one process on each cluster node: `k3s-server` on master nodes or `k3s-agent` on worker nodes.

All Kubernetes components running on a node share the same memory, and k3s emits the same metrics at all `/metrics` endpoints available on a node: `api-server`, `kubelet` (`TCP 10250`), `kube-proxy` (`TCP 10249`), `kube-scheduler` (`TCP 10251`), and `kube-controller-manager` (`TCP 10257`). When polling a Kubernetes component's metrics endpoint, metrics from other components are not filtered out.

A k3s master running all Kubernetes components, emits the same metrics on all ports. On the other hand, k3s workers running only `kubelet` and `kube-proxy`, emit the same metrics on `TCP 10250` and `10249` ports.

Enabling scraping of all different metrics TCP ports (`10249`, `10250`, `10251`, `10257`, and `apiserver`) causes ingestion of duplicate metrics. To reduce memory and CPU consumption, Prometheus should avoid duplicate metrics. On the other hand, kubelet's additional metrics endpoints (`/metrics/cadvisor`, `/metrics/resource`, and `/metrics/probes`) are only available at `TCP 10250`.

Therefore, the solution is to scrape only the metrics endpoints available on the kubelet port (`TCP 10250`): `/metrics`, `/metrics/cadvisor`, `/metrics/resource`, and `/metrics/probes`.

To avoid duplicates, reduce memory consumption and minimize costs the following configuration are applied:

+ [`apiserver` (`{job="apiserver"}`)](https://github.com/oscaromeu/home-ops/blob/main/kubernetes/apps/monitoring/kube-prometheus-stack/app/helmrelease.yaml#L57-L82)

+ [`kube-controller-manager` (`{job="kube-controller-manager"}`)](https://github.com/oscaromeu/home-ops/blob/main/kubernetes/apps/monitoring/kube-prometheus-stack/app/helmrelease.yaml#L107-L120)

+ [`kube-scheduler` (`{job="kube-scheduler"}`)](https://github.com/oscaromeu/home-ops/blob/main/kubernetes/apps/monitoring/kube-prometheus-stack/app/helmrelease.yaml#L123-L131)

+ [`kubelet` (`{job="kubelet"}`)](https://github.com/oscaromeu/home-ops/blob/main/kubernetes/apps/monitoring/kube-prometheus-stack/app/helmrelease.yaml#L84-L104)

+ [`kube-state-metrics` (`{job="kube-state-metrics"}`)](https://github.com/oscaromeu/home-ops/blob/main/kubernetes/apps/monitoring/kube-prometheus-stack/app/helmrelease.yaml#L145-L154)


+ [`kube-proxy` (`{job="kube-proxy"}`)](https://github.com/oscaromeu/home-ops/blob/main/kubernetes/apps/monitoring/kube-prometheus-stack/app/helmrelease.yaml#L133-L141)


## Rule evaluation and alerting

```
kubectl get prometheusrules -n monitoring --no-headers=true |\
awk '{print $1}' |\
xargs -I{} kubectl get prometheusrule {} -n monitoring -ojson |\
jq '.spec.groups[].rules[]'
```

## Storage

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

## References

+ [Prevent metrics explosion](https://tanmay-bhat.github.io/posts/how-to-prevent-metrics-explosion-in-prometheus/)

+ [kube-prometheus-runbooks](https://runbooks.prometheus-operator.dev)

+ [Amazon Managed Prometheus](https://docs.aws.amazon.com/prometheus/latest/userguide/AMP-onboard-amg.html)

+ [Kubernetes API server metrics](https://docs.datadoghq.com/integrations/kube_apiserver_metrics/)

+ [Kubernetes Metrics reference](https://kubernetes.io/docs/reference/instrumentation/metrics/)

+ [PromQL Queries for Exploring Your Metrics](https://promlabs.com/blog/2020/12/17/promql-queries-for-exploring-your-metrics/)

+ [My Prometheus is overwhelmed](https://hackernoon.com/my-prometheus-is-overwhelmed-help-qi1937xj)
