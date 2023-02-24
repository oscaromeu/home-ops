---
title: Elasticsearch
---

## Configure a lifecycle policy

### Create lifecycle policy

```json
PUT _ilm/policy/logs-k3s
{
  "policy": {
    "phases": {
      "hot": {
        "actions": {
          "rollover": {
            "max_age": "5d",
            "max_primary_shard_size": "200mb"
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

## Apply lifecycle policy with an index template


```json
PUT _index_template/logs-k3s
{
  "priority": 101,
  "template": {
    "settings": {
      "index": {
        "lifecycle": {
          "name": "logs-k3s"
        },
        "number_of_shards": "1",
        "number_of_replicas": "0"
      }
    }
  },
  "index_patterns": [
    "logs-k3s_*"
  ],
  "data_stream": {},
  "composed_of": [
    "logs-mappings",
    "data-streams-mappings",
    "logs-settings"
  ]
}
```

1. Use this template for all new indices whose names begin with test-
1. Apply my_policy to new indices created with this template
1. Define an index alias for referencing indices managed by my_policy
