# Grafana

## Overview

## Data sources

### Add new datasource

You can also create a ConfigMap or Secret in your namespace that contains the definition of a Grafana data source. Then, you can label it with the key `grafana-homeops-datasource` and any desired value. Once labeled, the k8s-sidecar will automatically inject it into a shared volume and send a reload signal to Grafana, so it can access and use the new data source. An example of this can be found in the datasources folder in the `kustomization.yaml` file.

## Dashboards

### Add new dashboards

You can create a ConfigMap or Secret in your namespace that contains a JSON file of a Grafana dashboard. Then, you can label it with the key `grafana-homeops-dashboard` and any desired value. Once labeled, the k8s-sidecar will automatically inject it into a shared volume, where Grafana will then be able to detect and display it. For an example, you can refer to the dashboards folder in the `kustomization.yaml` file.

## Alerting

## Logging and monitoring


