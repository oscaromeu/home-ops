import { check } from 'k6';
import http from 'k6/http';

export default function () {
  const res = http.get('http://kube-prometheus-stack-prometheus.observability.svc.custer.local:9090/metrics');
  check(res, {
    'is status 200': (r) => r.status === 200,
  });
}