---
title: Elastisearch
---

## Introduction

The ELK stack (Elasticsearch, Logstash, and Kibana) is a popular open-source solution for storing, searching, and visualizing log data.

## Architecture

The hot/warm architecture is a common design pattern for storing and managing data in Elasticsearch. In this architecture, data is divided into two tiers: a hot tier for actively used data and a warm tier for less frequently used data.

Here's how it works:

+ __Hot tier:__ The hot tier consists of Elasticsearch indices that store data that is actively used and updated on a regular basis. This data is usually indexed on fast storage, such as solid-state drives (SSDs), and it is queried and analyzed frequently.
+ __Warm tier:__ The warm tier consists of Elasticsearch indices that store data that is less frequently used and updated. This data is usually indexed on slower storage, such as hard disk drives (HDDs), and it is queried and analyzed less frequently than the data in the hot tier.

The hot/warm architecture allows you to store and manage large amounts of data in Elasticsearch while minimizing the cost and maintenance overhead of the cluster. It is particularly useful for applications that generate large amounts of data and need to retain it for long periods of time.

To implement the hot/warm architecture in Elasticsearch, is used

+ __index lifecycle management (ILM)__ to automatically move indices between the hot and warm tiers based on their age or usage patterns.
+ __index templates__ to define the settings and mapping of indices in the hot and warm tiers, and use search templates to route queries to the appropriate tier based on the data being accessed.

Also the nodes that store data in the hot tier has the role of "master" and the nodes that store data in the warm tier has the "data tier".

This setup can provide better performance and efficiency for the cluster, as the master nodes can focus on managing the cluster and processing requests for actively used data, while the data nodes can focus on storing and processing less frequently used data. This setup can provide better availability and fault tolerance, as the master nodes can continue to operate even if one or more data nodes fail.

## Infrastructure

+ TBD Hot and Warm nodes


## Index Management

[Elasticsearch ILM policies](https://www.elastic.co/guide/en/elasticsearch/reference/current/overview-index-lifecycle-management.html) are used to automatically manage the [data streams](https://www.elastic.co/guide/en/elasticsearch/reference/current/data-streams.html) according the performance, resiliency, and retention requirements.

### Index Lifecycle Policy

The following policies have been created.

| Policy Name  | Rollover Policy | Warm Phase | Delete | Index Template |
|--------------|-----------------|------------|--------| -------------- |
| logs-k3s     | 1 Gb/5d     | 10d    | 15d| logs |

### Index and Component templates

The logs is composed by the following [Component Templates](https://www.elastic.co/guide/en/elasticsearch/reference/current/index-templates.html):

+ logs-mappings
+ data-streams-mappings
+ logs-settings

## Snapshot and restore

## Monitoring

+ Search and indexing performance
+ Memory and garbage collection
+ Host-level system and network metrics
+ Cluster health and node availability
+ Resource saturation and errors

### __1. Cluster health__

| METRIC DESCRIPTION | ELASTICSEARCH EXPORTER METRIC NAME  |
|----------------|--------------------------------------------|
| Cluster status | `elasticsearch_cluster_health_status` |
| Number of unasigned shards | `elasticsearch_cluster_health_unassigned_shards`|


### __2. Search Performance__

| **Metric description**  | **Name** | **Metric type** |
| ------------ | ----------- | ------------------- |
| Total number of queries     | `elasticsearch_indices_search_query_total` | Work: Throughput |
| Total time spent on queries    | `elasticsearch_indices_search_query_time_seconds`  | Work: Performance               |
| _Number of queries currently in progress_ **   | `indices.search.query_current`    | Work: Throughput |
| Total number of fetches     | `elasticsearch_indices_search_fetch_total`  | Work: Throughput |
| Total time spent on fetches     | `elasticsearch_indices_search_fetch_time_seconds`  | Work: Performance |
| _Number of fetches currently in progress_  **  | `indices.search.fetch_current`    | Work: Throughput |

** TBD

## References
[Elasticsearch documentation](https://www.elastic.co/guide/en/elasticsearch/reference/current/index.html)
[Top 10 Elasticsearch Metrics to Watch](https://sematext.com/blog/top-10-elasticsearch-metrics-to-watch/)
