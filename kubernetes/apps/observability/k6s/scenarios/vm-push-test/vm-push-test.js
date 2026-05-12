import http from 'k6/http';
import { sleep } from 'k6';
import { Gauge, Trend } from 'k6/metrics';

// Patrón "batch job": ejecuta una serie de operaciones y al final pushea
// las métricas del run. Valida el modelo push de VictoriaMetrics.
//
// Queries para dashboards y alertas (resuelven la sensación "event-like"
// sin tocar -search.maxStalenessInterval global):
//   last_over_time(cronjob_last_success[1h])
//   time() - last_over_time(cronjob_last_run_timestamp_seconds[1h]) > 600
//   last_over_time(cronjob_last_duration_seconds[1h])

const last_success = new Gauge('cronjob_last_success');
const last_run_ts = new Gauge('cronjob_last_run_timestamp_seconds');
const last_duration = new Gauge('cronjob_last_duration_seconds');
const runs_total = new Trend('cronjob_runs_total', true);

export const options = {
  vus: 1,
  iterations: 1,
};

export default function () {
  const job = 'vm-push-test';
  const start = Date.now();

  // Simulamos "operaciones del cronjob": un par de HTTP requests a un endpoint
  // de control. Si todas pasan -> success, si alguna falla -> failure.
  let success = 1;
  const targets = [
    'https://httpbin.org/status/200',
    'https://httpbin.org/status/200',
  ];

  for (const url of targets) {
    const res = http.get(url, { timeout: '5s' });
    if (res.status !== 200) {
      success = 0;
      break;
    }
  }

  // Simulamos algo de trabajo extra para que duration sea > 0
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
    `[${job}] result=${result} duration=${duration_s.toFixed(2)}s ts=${now_s}`,
  );
}
