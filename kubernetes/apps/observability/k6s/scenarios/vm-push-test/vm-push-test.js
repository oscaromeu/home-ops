import http from 'k6/http';
import { sleep } from 'k6';
import { Counter, Trend } from 'k6/metrics';

// Gemelo de prom-push-test / ck-push-test, mismo trabajo simulado y mismas
// fields capturadas. Pushea a VictoriaMetrics via remote_write (k6 native).
//
// Importante: k6 Counter no acumula entre runs (cada TestRun es proceso fresco
// pusheando v=1). rate()/increase() devolverán 0. Usar count_over_time/sum_over_time.
//
// Queries:
//   count_over_time(k6_cronjob_runs_total{job="vm-push-test"}[1h])
//   count_over_time(k6_cronjob_runs_total{job="vm-push-test",result="failure"}[1h])
//   k6_cronjob_duration_seconds_p95{job="vm-push-test"}
//   k6_cronjob_duration_seconds_avg{job="vm-push-test"}

const runs_total = new Counter('cronjob_runs_total');
const duration = new Trend('cronjob_duration_seconds');

export const options = {
  vus: 1,
  iterations: 1,
};

export default function () {
  const job = 'vm-push-test';
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

  const duration_s = (Date.now() - start) / 1000;
  const result = success === 1 ? 'success' : 'failure';

  runs_total.add(1, { job, result });
  duration.add(duration_s, { job, result });

  console.log(
    `[${job}] result=${result} duration=${duration_s.toFixed(2)}s err=${errorMsg ?? ''}`,
  );
}
