import http from 'k6/http';
import { sleep } from 'k6';
import { Gauge, Trend } from 'k6/metrics';

// Gemelo de vm-push-test / ck-push-test, mismo trabajo simulado y mismas
// fields capturadas. Pushea a kube-prometheus-stack via remote_write (k6 native).
//
// Queries equivalentes (cambiando el datasource en Grafana a Prometheus):
//   k6_cronjob_last_success{job="prom-push-test"}
//   last_over_time(k6_cronjob_last_success{job="prom-push-test"}[15m])
//   time() - last_over_time(k6_cronjob_last_run_timestamp_seconds{job="prom-push-test"}[1h]) > 1200

const last_success = new Gauge('cronjob_last_success');
const last_run_ts = new Gauge('cronjob_last_run_timestamp_seconds');
const last_duration = new Gauge('cronjob_last_duration_seconds');
const runs_total = new Trend('cronjob_runs_total', true);

export const options = {
  vus: 1,
  iterations: 1,
};

export default function () {
  const job = 'prom-push-test';
  const start = Date.now();

  let success = 1;
  let errorMsg = null;
  const targets = [
    'https://httpbin.org/status/200,500',
    'https://httpbin.org/status/200,500',
  ];

  for (const url of targets) {
    const res = http.get(url, { timeout: '5s' });
    if (res.status !== 200) {
      success = 0;
      errorMsg = `target ${url} returned ${res.status}`;
      break;
    }
  }

  sleep(1);

  const end = Date.now();
  const duration_s = (end - start) / 1000;
  const now_s = Math.floor(end / 1000);
  const result = success === 1 ? 'success' : 'failure';

  last_success.add(success, { job });
  last_run_ts.add(now_s, { job });
  last_duration.add(duration_s, { job });
  runs_total.add(1, { job, result });

  console.log(
    `[${job}] result=${result} duration=${duration_s.toFixed(2)}s ts=${now_s} err=${errorMsg ?? ''}`,
  );
}
