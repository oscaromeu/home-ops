---
title: Operations 
---


## Helm 

Download the latest tgz for chart

```
helm repo add grafana https://grafana.github.io/helm-charts
helm pull grafana/loki-stack --version 2.6.4 --untar --untardir /tmp # this command will download the chart in /tmp/loki-stack
```

Run the following command

```
helm template loki-stack /tmp/loki-stack --set grafana.enabled=false --set loki.serviceMonitor.enabled=true -n logging > loki-stack-built.yaml
```

