import { Gauge, Counter } from 'k6/metrics';

const last_success = new Gauge('uptime_check_last_success_timestamp_seconds');
const last_failure = new Gauge('uptime_check_last_failure_timestamp_seconds');
const runs_total = new Counter('uptime_check_runs_total');

export default function () {
  const now = Math.floor(Date.now() / 1000);
  const shouldPass = Math.random() < 0.5;

  runs_total.add(1, {
    result: shouldPass ? 'success' : 'failure',
  });

  if (shouldPass) {
    last_success.add(now);
  } else {
    last_failure.add(now);
  }
}
