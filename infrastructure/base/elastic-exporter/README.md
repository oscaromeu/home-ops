NOTES:
1. Get the application URL by running these commands:
  export POD_NAME=$(kubectl get pods --namespace default -l "app=prometheus-elasticsearch-exporter-1647583902" -o jsonpath="{.items[0].metadata.name}")
  echo "Visit http://127.0.0.1:9108/metrics to use your application"
  kubectl port-forward $POD_NAME 9108:9108 --namespace default


see https://github.com/prometheus-community/elasticsearch_exporter/blob/master/main.go#L126