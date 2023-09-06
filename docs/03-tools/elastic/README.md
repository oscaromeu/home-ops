Elasticsearch cheatsheet

# Shortlinks:

- [Cluster Health](#cluster-health)
  - [Index Level](#cluster-health-index-level)
  - [Shard Level](#cluster-health-shard-level)
- [Nodes Overview](#nodes-overview)
- [Indices Overview](#indices-overview)
- [Cluster Maintenance](#cluster-maintenance)
- [Settings]()
  - [Cluster Settings](#cluster-settings)
- [Ingest](#ingest-documents-into-elasticsearch)
- [Mapping](#mapping)
  - [Check Fields in Mappings](#check-fields-in-mappings)
- [Close API](#open--close-api)
- [Search](#searching)
  - [Using the Search API](#using-the-search-api)
- [Query](#query)
  - [Query by Match](#query-by-match)
  - [Query with Bool](#query-with-bool)
  - [Other Examples with Query](#other-examples-of-query)
- [Sort](#sort)
- [Aggregate]()
- [Delete](#delete)
- [Snapshots](#snapshots)
  - [Create Snapshot Repository on S3](#elasticsearch-s3-snapshot-repo)
  - [Create a Snapshot](#elasticsearch-snapshots)
  - [Restore from a Snapshot](#elasticsearch-restore)

# Resources
- https://www.elastic.co/guide/en/elasticsearch/reference/current/index.html
- https://www.elastic.co/guide/en/elasticsearch/reference/current/docs.html
- https://www.elastic.co/blog/managing-time-based-indices-efficiently
- http://joelabrahamsson.com/elasticsearch-101/
- https://www.elastic.co/guide/en/elasticsearch/reference/current/getting-started.html
- https://chatbots.network/logstash-exclude-bots-from-result/

# Overview

## Cluster Health:

Resource:
- https://www.elastic.co/guide/en/elasticsearch/guide/current/_cluster_health.html

```
$ curl -sSL -u "$ES_USER":"$ES_PASS" "$ES_URL/_cluster/health?pretty
{
  "cluster_name" : "docker-cluster",
  "status" : "green",
  "timed_out" : false,
  "number_of_nodes" : 5,
  "number_of_data_nodes" : 5,
  "active_primary_shards" : 11,
  "active_shards" : 22,
  "relocating_shards" : 0,
  "initializing_shards" : 0,
  "unassigned_shards" : 0,
  "delayed_unassigned_shards" : 0,
  "number_of_pending_tasks" : 0,
  "number_of_in_flight_fetch" : 0,
  "task_max_waiting_in_queue_millis" : 0,
  "active_shards_percent_as_number" : 100.0
}
```

## Cluster Health: Index Level:

```
$ curl -sSL -u "$ES_USER":"$ES_PASS" "$ES_URL/_cluster/health?level=indices&pretty'
{
  "cluster_name" : "swarm-elasticsearch",
  "status" : "red",
  "timed_out" : false,
  "number_of_nodes" : 5,
  "number_of_data_nodes" : 5,
  "active_primary_shards" : 44,
  "active_shards" : 44,
  "relocating_shards" : 0,
  "initializing_shards" : 0,
  "unassigned_shards" : 64,
  "delayed_unassigned_shards" : 0,
  "number_of_pending_tasks" : 0,
  "number_of_in_flight_fetch" : 0,
  "task_max_waiting_in_queue_millis" : 0,
  "active_shards_percent_as_number" : 40.74074074074074,
  "indices" : {
    "test" : {
      "status" : "yellow",
      "number_of_shards" : 5,
      "number_of_replicas" : 1,
      "active_primary_shards" : 5,
      "active_shards" : 5,
      "relocating_shards" : 0,
      "initializing_shards" : 0,
      "unassigned_shards" : 5
    }
  }
}
```

## Cluster Health: Shard Level:

```
curl -sSL -u "$ES_USER":"$ES_PASS" "$ES_URL/_cluster/health?level=shards&pretty'
{
  "cluster_name" : "swarm-elasticsearch",
  "status" : "red",
  "timed_out" : false,
  "number_of_nodes" : 5,
  "number_of_data_nodes" : 5,
  "active_primary_shards" : 44,
  "active_shards" : 44,
  "relocating_shards" : 0,
  "initializing_shards" : 0,
  "unassigned_shards" : 64,
  "delayed_unassigned_shards" : 0,
  "number_of_pending_tasks" : 0,
  "number_of_in_flight_fetch" : 0,
  "task_max_waiting_in_queue_millis" : 0,
  "active_shards_percent_as_number" : 40.74074074074074,
  "indices" : {
    "test" : {
      "status" : "yellow",
      "number_of_shards" : 5,
      "number_of_replicas" : 1,
      "active_primary_shards" : 5,
      "active_shards" : 5,
      "relocating_shards" : 0,
      "initializing_shards" : 0,
      "unassigned_shards" : 5,
      "shards" : {
        "0" : {
          "status" : "yellow",
          "primary_active" : true,
          "active_shards" : 1,
          "relocating_shards" : 0,
          "initializing_shards" : 0,
          "unassigned_shards" : 1
        },
        "1" : {
          "status" : "yellow",
          "primary_active" : true,
          "active_shards" : 1,
          "relocating_shards" : 0,
          "initializing_shards" : 0,
          "unassigned_shards" : 1
        },
        "2" : {
          "status" : "yellow",
          "primary_active" : true,
          "active_shards" : 1,
          "relocating_shards" : 0,
          "initializing_shards" : 0,
          "unassigned_shards" : 1
        },
        "3" : {
          "status" : "yellow",
          "primary_active" : true,
          "active_shards" : 1,
          "relocating_shards" : 0,
          "initializing_shards" : 0,
          "unassigned_shards" : 1
        },
        "4" : {
          "status" : "yellow",
          "primary_active" : true,
          "active_shards" : 1,
          "relocating_shards" : 0,
          "initializing_shards" : 0,
          "unassigned_shards" : 1
        }
      }
    }
  }
}
```

## Nodes Overview:

```
$ curl -sSL -u "$ES_USER":"$ES_PASS" "$ES_URL/_cat/nodes?v
ip        heap.percent ram.percent cpu load_1m load_5m load_15m node.role master name
10.0.2.28           21          92   2    0.55    0.45     0.38 mdi       -      ea1q921
10.0.2.24           27          95   5    0.17    0.24     0.22 mdi       -      rNDYCtL
10.0.2.27           20          93  12    0.18    0.20     0.24 mdi       -      bDWFHuw
10.0.2.18           12          93  12    0.18    0.20     0.24 mdi       *      mstWlao
10.0.2.22           27          92   2    0.55    0.45     0.38 mdi       -      ifgr6ym
```

## Who is Master:

```
$ curl -sSL -u "$ES_USER":"$ES_PASS" "$ES_URL/_cat/master?v
id                     host      ip        node
mstWlaoyTM69xhSt-_rZAA 10.0.2.18 10.0.2.18 mstWlao
```

## Indices Overview:

View all your indices in your cluster:

```
$ curl -sSL -u "$ES_USER":"$ES_PASS" "$ES_URL/_cat/indices?v
health status index                         uuid                   pri rep docs.count docs.deleted store.size pri.store.size
green  open   ruan-test                     CrQZB2L4SaaYCkvYPx5vUA   5   1         38            0    131.9kb         78.6kb
```

View one index:

```
$ curl -XGET 'http://127.0.0.1:9200/_cat/indices/index-name-2018.01.01?v'
health status index                   uuid                   pri rep docs.count docs.deleted store.size pri.store.size
green  open   index-name-2018.01.01 Nk8SMQvRSIaNm854bc3Zjg   5   1     395552            0    755.6mb        377.8mb
```

View a range of indices:

```
$ curl -XGET 'https://http://127.0.0.1:9200/_cat/indices/index-name-2018.01*?v'
health status index                   uuid                   pri rep docs.count docs.deleted store.size pri.store.size
green  open   index-name-2018.01.19 Vp1EBoeMQkS-a_upLzedhQ   5   1       1220            0      2.6mb          1.3mb
green  open   index-name-2018.01.17 hSJMzFJIQrePifCfgb1rOA   5   1       2875            0      3.8mb          1.9mb
```

View only the index name header:

```
$ curl -XGET 'http://127.0.0.1:9200/_cat/indices/*2018.03.*?v&h=index'
index
index-name-2018.03.01
index-name-2018.03.02
```

## How Many Documents in the ES Cluster (Across all Indices):

```
$ curl -sSL -u "$ES_USER":"$ES_PASS" "$ES_URL/_cat/count?v
epoch      timestamp count
1502288579 14:22:59  38
```

## Shards Info per Index:

```
$ curl -sSL -u "$ES_USER":"$ES_PASS" "$ES_URL/_cat/shards/ruan-test?v
index     shard prirep state   docs  store ip        node
ruan-test 3     r      STARTED   10  6.9kb 10.0.2.28 ea1q921
ruan-test 3     p      STARTED   10  6.9kb 10.0.2.24 rNDYCtL
ruan-test 1     r      STARTED    9 22.7kb 10.0.2.28 ea1q921
ruan-test 1     p      STARTED    9 22.7kb 10.0.2.18 mstWlao
ruan-test 4     r      STARTED    3  6.6kb 10.0.2.22 ifgr6ym
ruan-test 4     p      STARTED    3  6.6kb 10.0.2.18 mstWlao
ruan-test 2     p      STARTED   12 29.2kb 10.0.2.27 bDWFHuw
ruan-test 2     r      STARTED   12  3.9kb 10.0.2.24 rNDYCtL
ruan-test 0     p      STARTED    4 12.9kb 10.0.2.22 ifgr6ym
ruan-test 0     r      STARTED    4 12.9kb 10.0.2.27 bDWFHuw
```

## Shard Allocation per Node:

```
$ curl -sSL -u "$ES_USER":"$ES_PASS" "$ES_URL/_cat/allocation?v
shards disk.indices disk.used disk.avail disk.total disk.percent host      ip        node
     4       60.6mb    15.7gb     29.9gb     45.7gb           34 10.0.2.24 10.0.2.24 rNDYCtL
     4       48.3kb    16.7gb     28.9gb     45.7gb           36 10.0.2.18 10.0.2.18 mstWlao
     4      248.8kb    15.5gb     30.1gb     45.7gb           34 10.0.2.28 10.0.2.28 ea1q921
     5       54.6mb    16.7gb     28.9gb     45.7gb           36 10.0.2.27 10.0.2.27 bDWFHuw
     5        3.1mb    15.5gb     30.1gb     45.7gb           34 10.0.2.22 10.0.2.22 ifgr6ym
```

# Cluster Maintenance:

## Decomission Node from Shard Allocation

This will move shards from the mentioned node

```
$ curl -XPUT 'localhost:9200/_cluster/settings?pretty' -d'
{
  "transient" : {
    "cluster.routing.allocation.exclude._ip" : "10.0.0.1"
  }
}
'
```

## Recovery Resources:
- https://www.elastic.co/guide/en/elasticsearch/reference/current/indices-recovery.html

## Recovering from Node Failure:

At the moment one of the nodes were down, and up again:

```
$ curl -XGET http://127.0.0.1:9200/_cat/allocation?v
shards disk.indices disk.used disk.avail disk.total disk.percent host        ip          node
   290       54.1mb       1gb       20mb        1gb           98 10.79.2.193 10.79.2.193 es01
   151       43.5mb       1gb     11.9gb       13gb            8 10.79.3.171 10.79.3.171 es02
   139                                                                                   UNASSIGNED
```

## Recovery API:

```
$ curl -XGET http://127.0.0.1:9200/_cat/recovery?v
index                     shard time   type       stage source_host target_host repository snapshot files files_percent bytes  bytes_percent total_files total_bytes translog translog_percent total_translog
sysadmins-2017.06.19      0     1512   replica    done  10.79.2.193 10.79.3.171 n/a        n/a      31    100.0%        340020 100.0%        31          340020      0        100.0%           0
sysadmins-2017.06.19      0     7739   store      done  10.79.2.193 10.79.2.193 n/a        n/a      0     100.0%        0      100.0%        31          340020      0        100.0%           0
sysadmins-2017.06.19      1     2592   relocation done  10.79.2.193 10.79.3.171 n/a        n/a      13    100.0%        246229 100.0%        13          246229      0        100.0%           0
sysadmins-2017.06.19      1     613    replica    done  10.79.3.171 10.79.2.193 n/a        n/a      0     0.0%          0      0.0%          0           0           0        100.0%           0

```

## Pending Tasks:

```
$ curl -XGET http://127.0.0.1:9200/_cat/pending_tasks?v
insertOrder timeInQueue priority source
       1736        1.8s URGENT   shard-started ([sysadmins-2017.06.02][2], node[WR3y31g1TnuufpNyrJnQtg], [R], v[91], s[INITIALIZING], a[id=wVTDn4nFSKKxvi07cU0uCg], unassigned_info[[reason=CLUSTER_RECOVERED], at[2017-08-11T07:50:56.550Z]]), reason [after recovery (replica) from node [{es01}{6ND8sZ_rTqaL42VdlxyW7Q}{10.79.2.193}{10.79.2.193:9300}]]
       1737        1.3s URGENT   shard-started ([sysadmins-2017.06.02][3], node[WR3y31g1TnuufpNyrJnQtg], [R], v[91], s[INITIALIZING], a[id=JmrtwtYURMyQF6LspeJXLg], unassigned_info[[reason=CLUSTER_RECOVERED], at[2017-08-11T07:50:56.550Z]]), reason [after recovery (replica) from node [{es01}{6ND8sZ_rTqaL42VdlxyW7Q}{10.79.2.193}{10.79.2.193:9300}]]
```

## Clear Cache:

```
$  curl -XGET http://127.0.0.1:9200/_cache/clear
{"_shards":{"total":21,"successful":15,"failed":0}}
```

# Settings

## Cluster Settings

Search Timeout:

Global Search Timeout, that applies to all search queries across the entire cluster -> search.default_search_timeout:

```
PUT /_cluster/settings
{
    "persistent" : {
        "search.default_search_timeout" : "50"
    }
}
```

# Index Info (Shards, Replicas, Allocation):

## Create Index:

When you create an Index, 5 Primary Shards and 1 Replica Shard will assigned to the Index by Default.

```
$ curl -XPUT http://elasticsearch:9200/my2ndindex
{"acknowledged":true,"shards_acknowledged":true}
```

To verify the behavior:

```
curl -XGET -u http://elasticsearch:9200/_cat/indices?v
health status index                         uuid                   pri rep docs.count docs.deleted store.size pri.store.size
green  open   my2ndindex                    V32G9IOoTF6uq0DuNUIAMA   5   1          0            0      1.2kb           650b
green  open   ruan-test                     CrQZB2L4SaaYCkvYPx5vUA   5   1         38            0    131.9kb         78.6kb
```

From here on, we can increase the number of replica shards, but NOT the primary shards.
You can ONLY set the number primary shards on index creation.

## Shard info on our new index:

While having 5 prmary shards and 1 replica shard, let's have a look at it:

```
$ curl -sSL -u "$ES_USER":"$ES_PASS" "$ES_URL/_cat/shards/my2ndindex?v
index      shard prirep state   docs store ip        node
my2ndindex 3     p      STARTED    0  130b 10.0.2.22 ifgr6ym
my2ndindex 3     r      STARTED    0  130b 10.0.2.27 bDWFHuw
my2ndindex 1     r      STARTED    0  130b 10.0.2.22 ifgr6ym
my2ndindex 1     p      STARTED    0  130b 10.0.2.18 mstWlao
my2ndindex 4     r      STARTED    0  130b 10.0.2.18 mstWlao
my2ndindex 4     p      STARTED    0  130b 10.0.2.27 bDWFHuw
my2ndindex 2     r      STARTED    0  130b 10.0.2.28 ea1q921
my2ndindex 2     p      STARTED    0  130b 10.0.2.24 rNDYCtL
my2ndindex 0     p      STARTED    0  130b 10.0.2.28 ea1q921
my2ndindex 0     r      STARTED    0  130b 10.0.2.24 rNDYCtL
```

## Increase the Replica Shard Number:

Let's change the replica shard number to 2, meaning each primary shard will have 2 replica shards:

```
$ curl -XPUT http://elasticsearch:9200/my2ndindex/_settings -d '{"settings": {"index": {"number_of_replicas": 2}}}'
{"acknowledged":true}
```

Let's have a look at the shard info after we have increased the replica shard number:

```
$ curl -sSL -u "$ES_USER":"$ES_PASS" "$ES_URL/_cat/shards/my2ndindex?v
index      shard prirep state   docs store ip        node
my2ndindex 3     r      STARTED    0  130b 10.0.2.28 ea1q921
my2ndindex 3     p      STARTED    0  130b 10.0.2.22 ifgr6ym
my2ndindex 3     r      STARTED    0  130b 10.0.2.27 bDWFHuw
my2ndindex 2     r      STARTED    0  130b 10.0.2.28 ea1q921
my2ndindex 2     r      STARTED    0  130b 10.0.2.22 ifgr6ym
my2ndindex 2     p      STARTED    0  130b 10.0.2.24 rNDYCtL
my2ndindex 4     r      STARTED    0  130b 10.0.2.28 ea1q921
my2ndindex 4     r      STARTED    0  130b 10.0.2.18 mstWlao
my2ndindex 4     p      STARTED    0  130b 10.0.2.27 bDWFHuw
my2ndindex 1     r      STARTED    0  130b 10.0.2.22 ifgr6ym
my2ndindex 1     p      STARTED    0  130b 10.0.2.18 mstWlao
my2ndindex 1     r      STARTED    0  130b 10.0.2.24 rNDYCtL
my2ndindex 0     r      STARTED    0  130b 10.0.2.18 mstWlao
my2ndindex 0     p      STARTED    0  130b 10.0.2.27 bDWFHuw
my2ndindex 0     r      STARTED    0  130b 10.0.2.24 rNDYCtL
```

## Create a Index:

Create a Index with Default Settings:

```
$ curl -XPUT -H 'Content-Type: application/json' 'http://127.0.0.1:9200/ruan-test-2018.03.12'
```

View the settings of the created index:

```
$ curl -XGET 'http://127.0.0.1:9200/ruan-test-2018.03.12/_settings?pretty'
{
  "ruan-test-2018.03.12" : {
    "settings" : {
      "index" : {
        "creation_date" : "1520929659349",
        "number_of_shards" : "5",
        "number_of_replicas" : "1",
        "uuid" : "EwGz6y7XQkK0ZI08u8qdrQ",
        "version" : {
          "created" : "6000199"
        },
        "provided_name" : "ruan-test-2018.03.12"
      }
    }
  }
}
```

Remember that primary shard number can only be set on index creation. Change the settings of the index, let's update the index to: 2 replica shards, and the total_fields limit to: 2000

```
$ curl -XPUT -H 'Content-Type: application/json' 'http://127.0.0.1:9200/ruan-test-2018.03.12/_settings' -d '{"number_of_replicas": 0, "index.mapping.total_fields.limit": 2000}'
```

View the changes:

```
$ curl -XGET 'http://127.0.0.1:9200/ruan-test-2018.03.12/_settings?pretty'
{
  "ruan-test-2018.03.12" : {
    "settings" : {
      "index" : {
        "mapping" : {
          "total_fields" : {
            "limit" : "2000"
          }
        },
        "number_of_shards" : "5",
        "provided_name" : "ruan-test-2018.03.12",
        "creation_date" : "1520929659349",
        "number_of_replicas" : "0",
        "uuid" : "EwGz6y7XQkK0ZI08u8qdrQ",
        "version" : {
          "created" : "6000199"
        }
      }
    }
  }
}
```

Now, to set the settings on Index Creation:


```
$ curl -XPUT -H 'Content-Type: application/json' 'http://127.0.0.1:9200/ruan-test-2018.03.13' -d '{"settings": {"number_of_replicas": 1, "number_of_shards": 2, "index.mapping.total_fields.limit": 2000}}'
```

Verifying our settings:

```
$ curl -XGET 'http://127.0.0.1:9200/ruan-test-2018.03.13/_settings?pretty'
{
  "ruan-test-2018.03.13" : {
    "settings" : {
      "index" : {
        "mapping" : {
          "total_fields" : {
            "limit" : "2000"
          }
        },
        "number_of_shards" : "2",
        "provided_name" : "ruan-test-2018.03.13",
        "creation_date" : "1520929638792",
        "number_of_replicas" : "1",
        "uuid" : "hEY8HrlRTFuiYLwKVDAraQ",
        "version" : {
          "created" : "6000199"
        }
      }
    }
  }
}
```

Viewing our indexes:

```
$ curl -XGET 'http://127.0.0.1:9200/_cat/indices/ruan-test-*?v'
health status index                uuid                   pri rep docs.count docs.deleted store.size pri.store.size
green  open   ruan-test-2018.03.12 EwGz6y7XQkK0ZI08u8qdrQ   5   1          2            0     15.7kb          7.8kb
green  open   ruan-test-2018.03.13 hEY8HrlRTFuiYLwKVDAraQ   2   1          0            0       932b           466b
```

## Ingest Document into Elasticsearch:

Let's ingest one docuemnt into Elasticsearch, and in this case we will specify the document id as `1`

```
$ curl -XPUT http://elasticsearch:9200/my2ndindex/docs/1 -d '{"identity": {"name": "ruan", "surname": "bekker"}}'
{"_index":"my2ndindex","_type":"docs","_id":"1","_version":1,"result":"created","_shards":{"total":3,"successful":3,"failed":0},"created":true}
```

View the index info:

```
$ curl -sSL -u "$ES_USER":"$ES_PASS" "$ES_URL/_cat/indices/my*?v'
health status index      uuid                   pri rep docs.count docs.deleted store.size pri.store.size
green  open   my2ndindex V32G9IOoTF6uq0DuNUIAMA   5   2          1            0       13kb          4.3kb
```

View the Shard information on our Index:

```
$ curl -sSL -u "$ES_USER":"$ES_PASS" "$ES_URL/_cat/shards/my2ndindex?v
index      shard prirep state   docs store ip        node
my2ndindex 3     r      STARTED    1 3.9kb 10.0.2.28 ea1q921
my2ndindex 3     p      STARTED    1 3.9kb 10.0.2.22 ifgr6ym
my2ndindex 3     r      STARTED    1 3.9kb 10.0.2.27 bDWFHuw
my2ndindex 1     r      STARTED    0  130b 10.0.2.22 ifgr6ym
my2ndindex 1     p      STARTED    0  130b 10.0.2.18 mstWlao
my2ndindex 1     r      STARTED    0  130b 10.0.2.24 rNDYCtL
my2ndindex 4     r      STARTED    0  130b 10.0.2.28 ea1q921
my2ndindex 4     r      STARTED    0  130b 10.0.2.18 mstWlao
my2ndindex 4     p      STARTED    0  130b 10.0.2.27 bDWFHuw
my2ndindex 2     r      STARTED    0  130b 10.0.2.28 ea1q921
my2ndindex 2     r      STARTED    0  130b 10.0.2.22 ifgr6ym
my2ndindex 2     p      STARTED    0  130b 10.0.2.24 rNDYCtL
my2ndindex 0     r      STARTED    0  130b 10.0.2.18 mstWlao
my2ndindex 0     p      STARTED    0  130b 10.0.2.27 bDWFHuw
my2ndindex 0     r      STARTED    0  130b 10.0.2.24 rNDYCtL
```

## Some info on Yellow Status:

In elasticsearch, a replica shard of its primary shard, will never appear on the same node as the other shards.

As we have 5 nodes in our cluster, meaning if we create 5 replica shards, our index will consist of 5 primary shards,
each primary shard having 5 replica shards, as a result in a yellow status es cluster.

The reasoning for this is that if we take `primary shard id 0`:

- primary shard   - node 1
- replica shard 1 - node 2
- replica shard 2 - node 3
- replica shard 3 - node 4
- replica shard 4 - node 5
- replica shard 5 - UNASSIGNED

The 5th replica shard for the mentioned primary shard will be unassigned, as there is no node available where the
primary shard's replicas already reside on.

To get the status back to green:

- add a data node
- reduce the replica number

## Let's see the YELLOW Status in action:

Increase the replica shards to `5`:

```
$ curl -XPUT http://elasticsearch:9200/my2ndindex/_settings -d '{"settings": {"number_of_replicas": 5}}'
{"acknowledged":true}
```

Verify the Indices Overview:

```
$ curl -sSL -u "$ES_USER":"$ES_PASS" "$ES_URL/_cat/indices/my*?v'
health status index      uuid                   pri rep docs.count docs.deleted store.size pri.store.size
yellow open   my2ndindex V32G9IOoTF6uq0DuNUIAMA   5   5          1            0     22.2kb          4.4kb
```

We can see that we have a YELLOW status, for more info let's have a look at the shards overview:

```
$ curl -sSL -u "$ES_USER":"$ES_PASS" "$ES_URL/_cat/shards/my2ndindex?v
index      shard prirep state      docs store ip        node
my2ndindex 3     r      STARTED       1 3.9kb 10.0.2.28 ea1q921
my2ndindex 3     p      STARTED       1 3.9kb 10.0.2.22 ifgr6ym
my2ndindex 3     r      STARTED       1 3.9kb 10.0.2.18 mstWlao
my2ndindex 3     r      STARTED       1 3.9kb 10.0.2.27 bDWFHuw
my2ndindex 3     r      STARTED       1 3.9kb 10.0.2.24 rNDYCtL
my2ndindex 3     r      UNASSIGNED
my2ndindex 2     r      STARTED       0  130b 10.0.2.28 ea1q921
my2ndindex 2     r      STARTED       0  130b 10.0.2.22 ifgr6ym
my2ndindex 2     r      STARTED       0  130b 10.0.2.18 mstWlao
my2ndindex 2     r      STARTED       0  130b 10.0.2.27 bDWFHuw
my2ndindex 2     p      STARTED       0  130b 10.0.2.24 rNDYCtL
my2ndindex 2     r      UNASSIGNED
my2ndindex 4     r      STARTED       0  130b 10.0.2.28 ea1q921
my2ndindex 4     r      STARTED       0  130b 10.0.2.22 ifgr6ym
my2ndindex 4     r      STARTED       0  130b 10.0.2.18 mstWlao
my2ndindex 4     p      STARTED       0  130b 10.0.2.27 bDWFHuw
my2ndindex 4     r      STARTED       0  130b 10.0.2.24 rNDYCtL
my2ndindex 4     r      UNASSIGNED
my2ndindex 1     r      STARTED       0  130b 10.0.2.28 ea1q921
my2ndindex 1     r      STARTED       0  130b 10.0.2.22 ifgr6ym
my2ndindex 1     p      STARTED       0  130b 10.0.2.18 mstWlao
my2ndindex 1     r      STARTED       0  130b 10.0.2.27 bDWFHuw
my2ndindex 1     r      STARTED       0  130b 10.0.2.24 rNDYCtL
my2ndindex 1     r      UNASSIGNED
my2ndindex 0     p      STARTED       0  130b 10.0.2.28 ea1q921
my2ndindex 0     r      STARTED       0  130b 10.0.2.22 ifgr6ym
my2ndindex 0     r      STARTED       0  130b 10.0.2.18 mstWlao
my2ndindex 0     r      STARTED       0  130b 10.0.2.27 bDWFHuw
my2ndindex 0     r      STARTED       0  130b 10.0.2.24 rNDYCtL
my2ndindex 0     r      UNASSIGNED
```

Also, when we look at the allocation api, we can see that we have 5 shards that is unassigned:

```
$ curl -sSL -u "$ES_USER":"$ES_PASS" "$ES_URL/_cat/allocation?v
shards disk.indices disk.used disk.avail disk.total disk.percent host      ip        node
     9       59.2kb    16.8gb     28.8gb     45.7gb           36 10.0.2.18 10.0.2.18 mstWlao
    10       61.2mb    16.8gb     28.8gb     45.7gb           36 10.0.2.27 10.0.2.27 bDWFHuw
     9      275.5kb    15.6gb     30.1gb     45.7gb           34 10.0.2.28 10.0.2.28 ea1q921
     9       64.2mb    15.7gb     29.9gb     45.7gb           34 10.0.2.24 10.0.2.24 rNDYCtL
    10        3.4mb    15.6gb     30.1gb     45.7gb           34 10.0.2.22 10.0.2.22 ifgr6ym
     5                                                                               UNASSIGNED
```

## Create Index with 10 Primary Shards:

Let's create an index with 10 primary shards and a replica count of 2:

```
$ curl -XPUT http://elasticsearch:9200/my3rdindex -d '{"settings": {"index": {"number_of_shards": 10, "number_of_replicas": 2}}}'
{"acknowledged":true,"shards_acknowledged":true}/ #
```

Verify:

```
$ curl -sSL -u "$ES_USER":"$ES_PASS" "$ES_URL/_cat/indices/my*?v'
health status index      uuid                   pri rep docs.count docs.deleted store.size pri.store.size
green  open   my3rdindex ljovpse0RzCB5INxUBLBYg  10   2          0            0      2.4kb           650b
green  open   my2ndindex V32G9IOoTF6uq0DuNUIAMA   5   2          1            0     13.3kb          4.4kb
```

View the shard info on our index:

```
$ curl -sSL -u "$ES_USER":"$ES_PASS" "$ES_URL/_cat/shards/my3rdindex?v
index      shard prirep state   docs store ip        node
my3rdindex 8     r      STARTED    0  130b 10.0.2.28 ea1q921
my3rdindex 8     p      STARTED    0  130b 10.0.2.22 ifgr6ym
my3rdindex 8     r      STARTED    0  130b 10.0.2.24 rNDYCtL
my3rdindex 7     r      STARTED    0  130b 10.0.2.18 mstWlao
my3rdindex 7     r      STARTED    0  130b 10.0.2.27 bDWFHuw
my3rdindex 7     p      STARTED    0  130b 10.0.2.24 rNDYCtL
my3rdindex 4     r      STARTED    0  130b 10.0.2.28 ea1q921
my3rdindex 4     r      STARTED    0  130b 10.0.2.22 ifgr6ym
my3rdindex 4     p      STARTED    0  130b 10.0.2.27 bDWFHuw
my3rdindex 2     r      STARTED    0  130b 10.0.2.18 mstWlao
my3rdindex 2     r      STARTED    0  130b 10.0.2.27 bDWFHuw
my3rdindex 2     p      STARTED    0  130b 10.0.2.24 rNDYCtL
my3rdindex 5     p      STARTED    0  130b 10.0.2.28 ea1q921
my3rdindex 5     r      STARTED    0  130b 10.0.2.22 ifgr6ym
my3rdindex 5     r      STARTED    0  130b 10.0.2.27 bDWFHuw
my3rdindex 6     r      STARTED    0  130b 10.0.2.28 ea1q921
my3rdindex 6     p      STARTED    0  130b 10.0.2.18 mstWlao
my3rdindex 6     r      STARTED    0  130b 10.0.2.27 bDWFHuw
my3rdindex 1     r      STARTED    0  130b 10.0.2.28 ea1q921
my3rdindex 1     r      STARTED    0  130b 10.0.2.22 ifgr6ym
my3rdindex 1     p      STARTED    0  130b 10.0.2.18 mstWlao
my3rdindex 3     p      STARTED    0  130b 10.0.2.22 ifgr6ym
my3rdindex 3     r      STARTED    0  130b 10.0.2.18 mstWlao
my3rdindex 3     r      STARTED    0  130b 10.0.2.24 rNDYCtL
my3rdindex 9     r      STARTED    0  130b 10.0.2.22 ifgr6ym
my3rdindex 9     p      STARTED    0  130b 10.0.2.27 bDWFHuw
my3rdindex 9     r      STARTED    0  130b 10.0.2.24 rNDYCtL
my3rdindex 0     p      STARTED    0  130b 10.0.2.28 ea1q921
my3rdindex 0     r      STARTED    0  130b 10.0.2.18 mstWlao
my3rdindex 0     r      STARTED    0  130b 10.0.2.24 rNDYCtL
```

Take note, with the configuration as above your index that you created will have 30 shards in your cluster:

```
$ curl -s -XGET 'http://elasticsearch:9200/_cat/shards/my3rdindex?v'  | grep -v 'node' | wc -l
30
```

Number of Primary Shards per Node:

```
$ curl -s -XGET 'http://elasticsearch:9200/_cat/shards/my3rdindex?v' | grep 'p      STARTED' | awk '{print $7}' | sort | uniq -c
      2 10.0.2.18
      3 10.0.2.22
      1 10.0.2.24
      1 10.0.2.27
      3 10.0.2.28
```

# Ingest Documents into Elasticsearch:

## Structure:

In Elasticsearch we have `Indices`, 'Types`, and `Documents`. In a Relational Database you can think of it like, Database, Tables, Records:

- Indices => Databases
- Types => Tables
- Documents => Records

## Ingest a Document and Specify the ID:

When you do a `PUT` request, you need to specify the `id` of the document:

- "_id": 1
- "_id": "james"

Let's ingest a simple document with a random string as the document id:

```
$ curl -XPUT http://elasticsearch:9200/people/users/abcd -d '{"name", "james", "age": 28}'
{"_index":"people","_type":"users","_id":"abcd","_version":1,"result":"created","_shards":{"total":2,"successful":2,"failed":0},"created":true}
```

If we have to repeat the same request with the same `id`, the docuement will be overwritten, ES will create a new document if
the `id` is not present.

```
$ curl -XPUT http://elasticsearch:9200/people/users/abcd -d '{"name": "james", "age": 28}'
{"_index":"people","_type":"users","_id":"abcd","_version":2,"result":"updated","_shards":{"total":2,"successful":2,"failed":0},"created":false}
```

## Ingeest a Document and Let ES generate a ID:

When you do a `POST` request, the service will automatically assign a `id` for your docuemt:

```
$ curl -XPOST http://elasticsearch:9200/people/users/ -d '{"name": "susan", "age: 30}'
{"_index":"people","_type":"users","_id":"AV3H_9q6AH1phg1wCfDW","_version":1,"result":"created","_shards":{"total":2,"successful":2,"failed":0},"created":true}
```

## Bulk Ingest

Our Sample Data: `info.json`:

```
{"index":{"_index":"info","_type":"feed","_id":1}}
{"user_id":james4,"handle_name":"james","category":"sport","socialmedia_src":"twitter","text":"manchester united lost","country":"south africa"}
{"index":{"_index":"info","_type":"feed","_id":2}}
{"user_id":pete09,"handle_name":"pete","category":"politics","socialmedia_src":"facebook","text":"new mayor selected","country":"new zealand"}
```

Ingest using the Bulk Api:

```
curl -XPOST 'http://elasticsearch:9200/info/_bulk?pretty' --data-binary @info.json
```

# Mapping

## Create Mapping
## View Mappings

## Check Fields in Mappings:

Check if a field exisists in your mapping:

```
$ curl -XGET 'http://127.0.0.1:9200/index-name-2018.03.01/_mapping/docs/field/company?pretty'
{
  "index-name-2018.03.01" : {
    "mappings" : {
      "docs" : {
        "company" : {
          "full_name" : "company",
          "mapping" : {
            "company" : {
              "type" : "text",
              "fields" : {
                "keyword" : {
                  "type" : "keyword",
                  "ignore_above" : 256
                }
              }
            }
          }
        }
      }
    }
  }
}
```

# Open / Close API:
- https://www.elastic.co/guide/en/elasticsearch/reference/current/indices-open-close.html

## Close Index:

```
$ curl -XPOST http://elasticsearch:9200/people/_close
{"acknowledged":true}
```

Trying to ingest while the index is closed:

```
$ curl -XPOST http://elasticsearch:9200/people/users/ -d '{"name": "susan", "age": 30}'
{"error":{"root_cause":[{"type":"index_closed_exception","reason":"closed","index_uuid":"Yt31-EAwTOa-a6duElYRsQ","index":"people"}],"type":"index_closed_exception","reason":"closed","index_uuid":"Yt31-EAwTOa-a6duElYRsQ","index":"people"},"status":403}
```

## Open Index:

```
$ curl -XPOST http://elasticsearch:9200/people/_open
```

# Searching

## Get a Document by ID:

We can get the document by passing the document `id`:

```
$ curl -sSL -u "$ES_USER":"$ES_PASS" "$ES_URL/people/users/abcd?pretty
{
  "_index" : "people",
  "_type" : "users",
  "_id" : "abcd",
  "_version" : 2,
  "found" : true,
  "_source" : {
    "name" : "james",
    "age" : 28
  }
}
```

## Determine which Shard a Document Reside on:

```
$ curl -sSL -u "$ES_USER":"$ES_PASS" "$ES_URL/people/users/_search?q=age:28&explain&pretty'
{
  "took" : 73,
  "timed_out" : false,
  "_shards" : {
    "total" : 5,
    "successful" : 5,
    "failed" : 0
  },
  "hits" : {
    "total" : 1,
    "max_score" : 1.0,
    "hits" : [
      {
        "_shard" : "[people][2]",
        "_node" : "ea1q921TQWyNiyiRXzfXZQ",
        "_index" : "people",
        "_type" : "users",
        "_id" : "abcd",
        "_score" : 1.0,
        "_source" : {
          "name" : "james",
          "age" : 28
        },
        "_explanation" : {
          "value" : 1.0,
          "description" : "age:[28 TO 28], product of:",
          "details" : [
            {
              "value" : 1.0,
              "description" : "boost",
              "details" : [ ]
            },
            {
              "value" : 1.0,
              "description" : "
              Norm",
              "details" : [ ]
            }
          ]
        }
      }
    ]
  }
}
```

## Search API:
- https://www.elastic.co/guide/en/elasticsearch/reference/current/search.html

Lets do a search on our index:

```
$ curl -sSL -u "$ES_USER":"$ES_PASS" "$ES_URL/people/_search?pretty
{
  "took" : 29,
  "timed_out" : false,
  "_shards" : {
    "total" : 5,
    "successful" : 5,
    "failed" : 0
  },
  "hits" : {
    "total" : 2,
    "max_score" : 1.0,
    "hits" : [
      {
        "_index" : "people",
        "_type" : "users",
        "_id" : "abcd",
        "_score" : 1.0,
        "_source" : {
          "name" : "james",
          "age" : 28
        }
      },
      {
        "_index" : "people",
        "_type" : "users",
        "_id" : "AV3H_9q6AH1phg1wCfDW",
        "_score" : 1.0,
        "_source" : {
          "name" : "susan",
          "age" : 30
        }
      }
    ]
  }
}
```

By default the Search API returns 10 items, which can be changed using `size`

```
curl -sSL -u "$ES_USER":"$ES_PASS" "$ES_URL/shakespeare/_search?size=3&pretty'
{
  "took" : 25,
  "timed_out" : false,
  "_shards" : {
    "total" : 5,
    "successful" : 5,
    "failed" : 0
  },
  "hits" : {
    "total" : 111396,
    "max_score" : 1.0,
    "hits" : [
      {
        "_index" : "shakespeare",
        "_type" : "act",
        "_id" : "0",
        "_score" : 1.0,
        "_source" : {
          "line_id" : 1,
          "play_name" : "Henry IV",
          "speech_number" : "",
          "line_number" : "",
          "speaker" : "",
          "text_entry" : "ACT I"
        }
      },
      {
        "_index" : "shakespeare",
        "_type" : "line",
        "_id" : "14",
        "_score" : 1.0,
        "_source" : {
          "line_id" : 15,
          "play_name" : "Henry IV",
          "speech_number" : 1,
          "line_number" : "1.1.12",
          "speaker" : "KING HENRY IV",
          "text_entry" : "Did lately meet in the intestine shock"
        }
      },
      {
        "_index" : "shakespeare",
        "_type" : "line",
        "_id" : "19",
        "_score" : 1.0,
        "_source" : {
          "line_id" : 20,
          "play_name" : "Henry IV",
          "speech_number" : 1,
          "line_number" : "1.1.17",
          "speaker" : "KING HENRY IV",
          "text_entry" : "The edge of war, like an ill-sheathed knife,"
        }
      }
    ]
  }
}
```

View the latest indexed document (this will only work if theres a @timestmap field):

```
curl -H 'content-type: application/json' -XPOST http://elasticsearch:9200/<timestamped-index>/_search?pretty -d '{"size": 1, "sort": { "@timestamp": "desc"}, "query": {"match_all": {} }}'
 ```

## Query

Query our index for people with the age of 28:

```
curl -sSL -u "$ES_USER":"$ES_PASS" "$ES_URL/people/_search?q=age:30&pretty'
{
  "took" : 25,
  "timed_out" : false,
  "_shards" : {
    "total" : 5,
    "successful" : 5,
    "failed" : 0
  },
  "hits" : {
    "total" : 1,
    "max_score" : 1.0,
    "hits" : [
      {
        "_index" : "people",
        "_type" : "users",
        "_id" : "AV3H_9q6AH1phg1wCfDW",
        "_score" : 1.0,
        "_source" : {
          "name" : "susan",
          "age" : 30
        }
      }
    ]
  }
}
```

#### Query by Term and limit results by 2:

```
$ curl -XGET http://127.0.0.1:9200/scrape-sysadmins/_search?pretty -d '
{
  "query": {
    "term": {
      "title": "traefik"
    }
  },
  "size": 2
}
'
```

#### Query by Match:

```
$ curl -XGET http://127.0.0.1:9200/scrape-sysadmins/_search?pretty -d '
{
  "query": {
    "match": {
      "title": "traefik"
    }
  },
  "size": 10
}
'
```

#### Query with Bool:

- Check if field exists in index:

```
$ curl http://127.0.0.1:9200/test4/_search?pretty -d '
{
  "query": {
    "bool": {
      "must": [{
        "exists": {
	  "field": "name"
	}
      }]
    }
  }
}'

{
  "took" : 7,
  "timed_out" : false,
  "_shards" : {
    "total" : 5,
    "successful" : 5,
    "failed" : 0
  },
  "hits" : {
    "total" : 1,
    "max_score" : 1.0,
    "hits" : [
      {
        "_index" : "test4",
        "_type" : "docs",
        "_id" : "2",
        "_score" : 1.0,
        "_source" : {
          "id" : "2",
          "name" : "ruan"
        }
      }
    ]
  }
}
```

#### Other Examples of Query:

Match:

```
{
  "query": {
    "match": {
      "title": "something"
    }
  }
}
```

Multi match with boost on title:

```
# ^ boosts the score 4 times on title
{
  "query": {
    "multi_match": {
      "query": "something",
      "fields": ["title^4", "plot"]
    }
  }
}
```

Match phrase:

```
{
  "query": {
    "match_phrase": {
      "title": "somethings got to give"
    }
  }
}
```

Common terms:

```
{
  "query": {
    "common": {
      "title": {
        "query": "the something word"
      }
    }
  }
}
```

Query string:

```
{
  "query": {
    "query_string": {
      "query": "the something AND (gives OR gave)"
    }
  }
}
```

Simple query string:

```
{
  "query": {
    "simple_query_string": {
      "query": "\"give got to\"~4 | *thing~2",
      "fields": ["title"]
    }
  }
}
```

More info on above:

```
+    -> Acts as the AND operator
|    -> Acts as the OR operator
*    -> Acts as a wildcard.
""   -> Wraps several terms into a phrase.
()   -> Wraps a clause for precedence.
~n   -> When used after a term (e.g. thign~3), sets fuzziness. When used after a phrase, sets slop. See Options.
-    -> Negates the term.
```

Match all:

```
{
  "query": {
    "match_all": {}
  }
}
```

Match none:

```
{
  "query": {
    "match_none": {}
  }
}
```

- https://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl-match-query.html

## Sort
- https://www.elastic.co/guide/en/elasticsearch/reference/current/search-request-sort.html

Sort Per Field:

Ingest a couple of example documents:

```
$ curl -XPUT http://elasticsearch:9200/products/items/1 -d '{"product": "chocolate", "price": [20, 4]}'
$ curl -XPUT http://elasticsearch:9200/products/items/2 -d '{"product": "apples", "price": [28, 6]}'
$ curl -XPUT http://elasticsearch:9200/products/items/3 -d '{"product": "bananas", "price": [28, 22, 23, 20]}'
$ curl -XPUT http://elasticsearch:9200/products/items/4 -d '{"product": "chips", "price": [14, 24, 22, 12]}'
```

Run a Sort Query on the term `bananas`, and show the `average` price. We can also use `min, max, avg, sum`:

```
$ curl -XPOST http://elasticsearch:9200/products/_search?pretty -d '
{
  "query" : {
    "term" : {
      "product" : "bananas"
    }
  },
  "sort" : [{
    "price" : {
      "order" : "asc",
      "mode" : "avg"
    }
  }]
}'

{
  "took" : 9,
  "timed_out" : false,
  "_shards" : {
    "total" : 5,
    "successful" : 5,
    "failed" : 0
  },
  "hits" : {
    "total" : 1,
    "max_score" : null,
    "hits" : [
      {
        "_index" : "products",
        "_type" : "items",
        "_id" : "3",
        "_score" : null,
        "_source" : {
          "product" : "bananas",
          "price" : [
            28,
            22,
            23,
            20
          ]
        },
        "sort" : [
          23
        ]
      }
    ]
  }
}
```

Running the same, but wanting to see the sum of all the prices:

```
$ curl -XPOST http://elasticsearch:9200/products/_search?pretty -d '
{
  "query" : {
    "term" : {
      "product" : "bananas"
    }
  },
  "sort" : [{
    "price" : {
      "order" : "asc",
      "mode" : "sum"
    }
  }]
}'

{
  "took" : 34,
  "timed_out" : false,
  "_shards" : {
    "total" : 5,
    "successful" : 5,
    "failed" : 0
  },
  "hits" : {
    "total" : 1,
    "max_score" : null,
    "hits" : [
      {
        "_index" : "products",
        "_type" : "items",
        "_id" : "3",
        "_score" : null,
        "_source" : {
          "product" : "bananas",
          "price" : [
            28,
            22,
            23,
            20
          ]
        },
        "sort" : [
          93
        ]
      }
    ]
  }
}
```

# Delete

References:

- [Delete API](https://www.elastic.co/guide/en/elasticsearch/reference/current/docs-delete.html)
- [Delete by Query](https://www.elastic.co/guide/en/elasticsearch/reference/5.6/docs-delete-by-query.html)

## Delete Index:

```
$ curl -XDELETE http://elasticsearch:9200/myindex
```

## Delete Documents on Query:

We would like to delete all documents that has `"os_name": "Windows 10"`

```
curl -XPOST 'http://elasticsearch:9200/weblogs/_delete_by_query?pretty' -d '
{
  "query": {
    "match": {
      "os_name": "Windows 10"
    }
  }
}'

{
  "took" : 1217,
  "timed_out" : false,
  "total" : 48,
  "deleted" : 48,
  "batches" : 1,
  "version_conflicts" : 0,
  "noops" : 0,
  "retries" : {
    "bulk" : 0,
    "search" : 0
  },
  "throttled_millis" : 0,
  "requests_per_second" : -1.0,
  "throttled_until_millis" : 0,
  "failures" : [ ]
}
```

If routing is provided, then the routing is copied to the scroll query, limiting the process to the shards that match that routing value:

```
$ curl -XPOST 'http://elasticsearch:9200/people/_delete_by_query?routing=1
{
  "query": {
    "range" : {
        "age" : {
           "gte" : 10
        }
    }
  }
}
```

By default _delete_by_query uses scroll batches of 1000. You can change the batch size with the scroll_size URL parameter:

```
$ curl -XPOST 'http://elasticsearch:9200/weblogs/_delete_by_query?scroll_size=5000
{
  "query": {
    "term": {
      "category": "docker"
    }
  }
}
```

## Delete Stats:

```
$ curl -XGET 'elasticsearch:9200/_tasks?detailed=true&actions=*/delete/byquery&pretty'
{
  "nodes" : {
    "s5A2CoRWrwKf512z6NEscF" : {
      "name" : "r4A5VoT",
      "transport_address" : "127.0.0.1:9300",
      "host" : "127.0.0.1",
      "ip" : "127.0.0.1:9300",
      "attributes" : {
        "testattr" : "test",
        "portsfile" : "true"
      },
      "tasks" : {
        "s5A2CoRWrwKf512z6NEscF" : {
          "node" : "s5A2CoRWrwKf512z6NEscF",
          "id" : 36619,
          "type" : "transport",
          "action" : "indices:data/write/delete/byquery",
          "status" : {
            "total" : 6154,
            "updated" : 0,
            "created" : 0,
            "deleted" : 3500,
            "batches" : 36,
            "version_conflicts" : 0,
            "noops" : 0,
            "retries": 0,
            "throttled_millis": 0
          },
          "description" : ""
        }
      }
    }
  }
}
```

# Snapshots

## Elasticsearch S3 Snapshot Repo

Setup the [S3 Snapshot Repository](https://sysadmins.co.za/aws-elasticsearch-register-s3-repository-for-snapshots-using-the-cli/?rbas_source=gist.github.com?rbas_sourcepage=cheatsheet-elasticsearch.md)

List the Snapshot Repositories:

```
$ curl -XGET 'http://127.0.0.1:9200/_cat/repositories?v'
id            type
foo-bacups    s3
bar-backups   s3
```

View the Snapshot Repository:

```
$ curl -sSL -u "$ES_USER":"$ES_PASS" "$ES_URL/_snapshot/bar-backups?pretty'
{
  "bar-backups" : {
    "type" : "s3",
    "settings" : {
      "bucket" : "my-es-snapshot-bucket",
      "region" : "eu-west-1",
      "role_arn" : "arn:aws:iam::0123456789012:role/elasticsearch-snapshot-role"
    }
  }
}
```

## Elasticsearch Snapshots

Create a Snapshot named `mysnapshot_ruan-test-2018-05-24_1` of the index: `ruan-test-2018-05-24` and return the exit when the snapshot is done:

```
$ curl -XPUT -H 'Content-Type: application/json' \
  'http://elasticsearch:9200/_snapshot/bar-backups/mysnapshot_ruan-test-2018-05-24_1?wait_for_completion=true&pretty=true' -d '
{
	"indices": "ruan-test-2018-05-24",
	"ignore_unavailable": true,
	"include_global_state": false
}
'

{
  "snapshot" : {
    "snapshot" : "mysnapshot_ruan-test-2018-05-24_1",
    "uuid" : "YRTE5922QCeqyEaMxPqb1A",
    "version_id" : 6000199,
    "version" : "6.0.1",
    "indices" : [ "ruan-test-2018-05-24" ],
    "state" : "SUCCESS",
    "start_time" : "2018-05-25T13:20:11.497Z",
    "start_time_in_millis" : 1527254411497,
    "end_time" : "2018-05-25T13:20:11.886Z",
    "end_time_in_millis" : 1527254411886,
    "duration_in_millis" : 389,
    "failures" : [ ],
    "shards" : {
      "total" : 5,
      "failed" : 0,
      "successful" : 5
    }
  }
}
```

Verify the Snapshot:

```
$ curl -sSL -u "$ES_USER":"$ES_PASS" "$ES_URL/_cat/snapshots/bar-backups?v&s=id'
id                                      status start_epoch start_time end_epoch  end_time duration indices successful_shards failed_shards total_shards
mysnapshot_ruan-test-2018-05-24_1      SUCCESS 1527254411  06:20:11   1527254411 06:20:11    389ms       1                 5             0            5
```

## Elasticsearch Restore

Get the Metadata of the Snapshot:

```
$ curl -sSL -u "$ES_USER":"$ES_PASS" "$ES_URL/_snapshot/bar-backups/mysnapshot_ruan-test-2018-05-24_1?pretty'
{
  "snapshots" : [ {
    "snapshot" : "mysnapshot_ruan-test-2018-05-24_1",
    "uuid" : "YRTE5922QCeqyEaMxPqb1A",
    "version_id" : 6000199,
    "version" : "6.0.1",
    "indices" : [ "ruan-test-2018-05-24" ],
    "state" : "SUCCESS",
    "start_time" : "2018-05-25T13:20:11.497Z",
    "start_time_in_millis" : 1527254411497,
    "end_time" : "2018-05-25T13:20:11.886Z",
    "end_time_in_millis" : 1527254411886,
    "duration_in_millis" : 389,
    "failures" : [ ],
    "shards" : {
      "total" : 5,
      "failed" : 0,
      "successful" : 5
    }
  } ]
}
```

Inspect the Snapshot on S3:

```
$ aws s3 --profile es ls s3://my-es-snapshot-bucket/ | grep VRTF2942QCeqyEaMxPgb1B
2018-05-25 15:20:12         90 meta-VRTF2942QCeqyEaMxPgb1B.dat
2018-05-25 15:20:12        258 snap-VRTF2942QCeqyEaMxPgb1B.dat
```

Execute the Restore:

```
$ curl -XPOST -H 'Content-Type: application/json' 'http://elasticsearch:9200/_snapshot/bar-backups/mysnapshot_ruan-test-2018-05-24_1/_restore -d '
{
  "indices": "ruan-test-2018-05-24",
  "ignore_unavailable": true,
  "include_global_state": false,
  "rename_pattern": "index_(.+)",
  "rename_replacement": "restored_index_$1"
}
'
```

or leave out the body for normal restore

## Elasticsearch Snapshot Resources:

- https://www.elastic.co/guide/en/elasticsearch/reference/current/modules-snapshots.html
- https://www.youtube.com/watch?v=Otl-IcmbiDE
- https://recology.info/2015/02/elasticsearch-backup-restore/
- https://medium.com/@rcdexta/periodic-snapshotting-of-elasticsearch-indices-f6b6ca221a0c
