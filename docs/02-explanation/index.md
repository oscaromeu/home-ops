# Observability

Observability is the ability to understand the internal state of a system by examining its external outputs. It plays a crucial role in managing complex systems and applications by enabling efficient monitoring, debugging, and performance optimization.

In this documentation, we will cover a general overview of the tools and technologies used in my observability stack for log data streaming, metrics, and analytics.


## Metrics

Prometheus metrics are collected from Kubernetes clusters and use industry standard tools for analyzing and alerting such as PromQL and Grafana

![Metrics ecosystem](./img/ecosystem.jpg){ width="1600"}
_Source:_ [Prometheus Stack Review](https://clux.dev/post/2022-01-11-prometheus-ecosystem/)

## Streaming

Log streaming platforms are systems that efficiently gather, process, and analyze log data from a wide range of sources in near real-time. These platforms are specifically engineered to manage high volumes of log data, offering valuable insights into system and application performance.

Below is an overview of the key phases and components involved in a log streaming platform:

![Streaming Logs Architecture](./img/stream_logs_arch_w.pdf)

### __Data Collection__

The platform collects log data from various sources such as containers running inside K8s or logs from JournalD. [Vector](https://vector.dev) from datadog is used, serving as both an agent for collecting logs and metrics and an aggregator for processing and forwarding data. Other valid options are filebeat of fluentd.

### __Message Queuing__

To ensure efficient and reliable log data transfer, we use a message queueing system. This approach decouples data producers and consumers, allowing for scalability, fault tolerance, and improved data processing.

#### Hot Path and Cold Path

The log data collection process is divided into two paths: hot path and cold path.

- **Hot Path**: Involves real-time data processing, analysis, and alerting. This path is designed for low-latency data access and quick response to potential issues.

- **Cold Path**: Deals with long-term storage, indexing, and batch processing of log data. It allows for historical analysis and trend identification, often used for optimization and capacity planning.

### Log Data Storage and Analysis

+ **Elasticsearch:** A distributed, RESTful search and analytics engine for storing, searching, and analyzing log data.

+ **Loki:** A horizontally scalable, highly available log aggregation system designed for simplicity and cost-efficiency, providing a streamlined querying and visualization experience in Grafana.


### Visualization

+ **Kibana:** A data visualization and exploration tool that integrates with Elasticsearch, providing an intuitive interface for exploring, visualizing, and managing the log data.

+ **Grafana:** A powerful visualization for creating dashboards, allowing you to explore and analyze different data sources.
