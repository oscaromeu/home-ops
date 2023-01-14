---
title: Loki
---

Grafana Loki is a horizontally-scalable, highly-available, multi-tenant log aggregation system inspired by Prometheus. It is designed to be cost-effective and easy to operate. It is an alternative to the more common log aggregation systems like Elasticsearch, Splunk and Logstash.

Loki is built on top of the Prometheus ecosystem and works seamlessly with it. It uses the same labels and metric data model as Prometheus, making it easy to correlate logs with metrics. It also has a similar query language and API, so it is easy to switch between metrics and logs.

Loki consists of three main components:

+ __Loki:__ the log data store and indexer. It is responsible for receiving, parsing, and indexing log data.

+ __Promtail:__ the log data scraper. It is responsible for collecting log data from various sources and sending it to Loki.

+ __Grafana:__ the visualization and alerting tool. Grafana can be used to query and visualize logs stored in Loki.
With Grafana Loki, you can aggregate logs from different sources, such as Kubernetes pods, system logs, and application logs, in one place. You can then use Grafana to create powerful visualizations and alerts to gain insights into your system.

Please note that Grafana Loki is a relatively new tool, and it may not be as mature or feature-rich as some of the more established log aggregation systems. It is important to consider your specific use case and requirements when deciding whether to use Grafana Loki or another log aggregation system.

## Requirements

+ Kubernetes >= `1.21.0`
+ Kustomize >= `v3.5.3`
+ prometheus-operator
+ grafana

!!! note

    Prometheus Operator is necessary since we configure a `ServiceMonitor` to make some metrics available from Loki on Prometheus.


## Configuration

Loki is deployed in Monolithic mode; it runs all of Loki's microservice components inside a single process as a single binary or Docker image.

!!! note

    Monolithic mode is useful for getting started quickly to experiment with Loki, as well as for small read/write volumes of up to approximately 100GB per day.

+ Single node
+ Listens on port `3100` for client connections and metrics scrapping
+ Resource limits are `512Mi` for memory, there are no limits for CPU.
+ Requires `10Gi` storage


## Development

To develop the Locki stack we can follow this steps

+ Download the helm chart to a choosen folder, for example: `/tmp/loki`

```
helm repo add grafana https://grafana.github.io/helm-charts
# this command will download the chart in /tmp/loki
helm pull grafana/loki --version 2.6.4 --untar --untardir /tmp
```

+ Create the configuration file `values.yaml`

```yaml
loki:
  commonConfig:
    replication_factor: 1
  storage:
    type: 'filesystem'
```

+ Run the following command to get the entire deployment:

```
helm template loki /tmp/loki --set grafana.enabled=false --set loki.serviceMonitor.enabled=true -n logging --values values.yaml > loki-stack-built.yaml
```

