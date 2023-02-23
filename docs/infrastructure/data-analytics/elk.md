---
title: Elastisearch
---

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


## ILM

### Create new policy

```
PUT _ilm/policy/logs-home-ops
{
  "policy": {
    "phases": {
      "hot": {
        "actions": {
          "rollover": {
            "max_age": "5d",
            "max_primary_shard_size": "1gb"
          },
          "set_priority": {
            "priority": 100
          },
          "shrink": {
            "number_of_shards": 1
          }
        },
        "min_age": "0ms"
      },
      "warm": {
        "min_age": "10d",
        "actions": {
          "set_priority": {
            "priority": 50
          }
        }
      },
      "delete": {
        "min_age": "20d",
        "actions": {
          "delete": {}
        }
      }
    }
  }
}
```

## Monitoring

+ Search and indexing performance
+ Memory and garbage collection
+ Host-level system and network metrics
+ Cluster health and node availability
+ Resource saturation and errors

### Cluster health

| METRIC DESCRIPTION | ELASTICSEARCH EXPORTER METRIC NAME  |
|----------------|--------------------------------------------|
| Cluster status | `elasticsearch_cluster_health_status` |
| Number of unasigned shards | `elasticsearch_cluster_health_unassigned_shards`|


### Search Performance

| **Metric description**  | **Name** | **Metric type** |
| ------------ | ----------- | ------------------- |
| Total number of queries     | `indices.search.query_total`          | Work: Throughput |
| Total time spent on queries    | `indices.search.query_time_in_millis`      | Work: Performance               |
| Number of queries currently in progress    | `indices.search.query_current`          | Work: Throughput |
| Total number of fetches     | `indices.search.fetch_total`  | Work: Throughput |
| Total time spent on fetches     | `indices.search.fetch_time_in_millis`  | Work: Performance |
| Number of fetches currently in progress    | `indices.search.fetch_current`          | Work: Throughput |
