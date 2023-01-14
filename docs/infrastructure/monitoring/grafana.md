# Grafana

Grafana is an open-source data visualization and monitoring tool that allows users to create and share dashboards composed of panels representing specific metrics over time. It supports a variety of data sources, including Prometheus, InfluxDB, and Elasticsearch, and can be used to monitor and analyze metrics from various systems and applications. Grafana is commonly used for monitoring and troubleshooting in DevOps and IT operations.


## Image repository and tag

- Grafana image: `grafana/grafana:9.1.7`
- Grafana repository: [https://github.com/grafana/grafana](https://github.com/grafana/grafana)
- Grafana documentation: [https://docs.grafana.org](https://docs.grafana.org)
- k8s-sidecar image: `kiwigrid/k8s-sidecar`
- k8s-sidecar repository: <https://github.com/kiwigrid/k8s-sidecar>
- k8s-sidecar documentation: <https://github.com/kiwigrid/k8s-sidecar/blob/master/README.md>

## Requirements

- Kubernetes >= `1.21.0`
- Kustomize = `v3.5.3`

## Configuration

Grafana is deployed with the following configuration:

- Replica number: `1`
- Anonymous authentication enabled
- `Admin` role for unauthenticated users
- Resource limits for memory `200Mi`
- Listens on port `3000`
- Prometheus configured as the data source

## Add new dashboards

You can create a ConfigMap or Secret in your namespace that contains a JSON file of a Grafana dashboard. Then, you can label it with the key `grafana-homeops-dashboard` and any desired value. Once labeled, the k8s-sidecar will automatically inject it into a shared volume, where Grafana will then be able to detect and display it. For an example, you can refer to the dashboards folder in the `kustomization.yaml` file.

## Dashboarding

### Add new datasource

You can also create a ConfigMap or Secret in your namespace that contains the definition of a Grafana data source. Then, you can label it with the key `grafana-homeops-datasource` and any desired value. Once labeled, the k8s-sidecar will automatically inject it into a shared volume and send a reload signal to Grafana, so it can access and use the new data source. An example of this can be found in the datasources folder in the `kustomization.yaml` file.



### Provisioning Dashboards



