# Platform

## Data Platform

### Streaming

Streaming logs platforms are systems that collect, process, and analyze log data
from various sources in near real-time. They are designed to handle large volumes of log
data and provide insights into systems and application performance.

Here there is an overview of the phases and components:

![Streaming Logs Architecture](../../img/stream_logs_arch_w.pdf)

#### __Data Collection__

Collection of log data from sources such as containers running inside kubernetes or logs from JournalD. Vector from datadog is used to do this job. Other valid options are filebeat of fluentd.

#### __Message Queuing__

Log data is first buffered in [Redis]() before being picked up by [Vector]() for further processing. Message queuing is used to efficiently handle high volumes of log data, and provide reliable and fault-tolerant delivery to downstream components. Other typical option is Kafka but due to the operational overhead it was not considered.

In order to support that critical data is processed in near real time there are two different hot and cold ingestion paths.

!!! info

    Hot paths typically involve real-time processing and analysis of streaming data, such as logs, events, or telemetry data. Hot paths are used to identify critical issues or opportunities that require immediate attention, such as system failures, security breaches, or performance bottlenecks.

    On the other hand, cold paths refer to the processing of data that is less urgen or can be deferred, such as batch processing of historical data, long-term storage, or offline analysis. Cold paths are used to provide insights into long-term trends, patterns, and anomalies, or to support reporting, compliance, and auditing requirements.

    Overall, the hot and cold path concepts are used to balance the need for real-time insights and immediate action with the need for long-term analysis and planning. By designing a data analytics platform that supports both hot and cold paths, organizations can maximize the value of their data and optimize their operations.

#### Aggregation

In this step log data is processed and routed the final destination using vector working as an aggregator.

#### Log Indexing / Storage

- Elasticsearch

#### Analytics and visualization

- Kibana

### Datascience and ML

- TBD

## Observability

- Prometheus
- Thanos
- Loki


## Storage

- Rook
