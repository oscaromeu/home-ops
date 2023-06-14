
## Vector pipeline with double sink is stucked

A pipeline with double sink may be get stucked if one of the sinks is failing. For example,
in `k3s` aggregator pipeline with double output as shown below:

```yaml
sinks:
  elasticsearch:
    type: elasticsearch
    #batch:
    #  max_bytes: 2049000
    inputs:
      - kubernetes_remap
    auth:
      strategy: "basic"
      user: "${ELASTICSEARCH_PASSWORD:-ingestion}"
      password: "${ELASTICSEARCH_PASSWORD:-monitor}"
    data_stream:
      # {data_stream.type}-{data_stream.dataset}-{data_stream.namespace}
      # https://www.elastic.co/guide/en/ecs/master/ecs-data_stream.html
      type: logs
      dataset: "k3s_prod"
      namespace: "{{ .kubernetes.pod_namespace }}"
    mode: "data_stream"
    bulk:
      action: "create"
    endpoints:
      - "https://elk-es-master.logging.svc.cluster.local:9200"
    tls:
      verify_certificate: false
    encoding:
      except_fields: ["pod_labels"]

  loki:
    type: loki
    #batch:
    #  max_bytes: 2049000
    encoding:
      codec: json
    endpoint: http://loki.logging.svc.cluster.local:3100
    inputs:
      - kubernetes_remap
    out_of_order_action: accept
    remove_label_fields: true
    remove_timestamp: true
    labels:
      app: '{{ custom_app_name }}'
      namespace: '{{ kubernetes.pod_namespace }}'
      node: '{{ kubernetes.pod_node_name }}'
```

If the connection to loki fails
