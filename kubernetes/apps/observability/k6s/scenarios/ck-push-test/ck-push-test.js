import http from 'k6/http';
import { sleep } from 'k6';

// Gemelo de vm-push-test / prom-push-test pero pusheando a ClickHouse vía HTTP
// INSERT (FORMAT JSONEachRow). Cada run es una fila independiente: event-store
// puro, sin carry-forward, sin staleness window, sin rollup.
//
// Compara en Grafana con datasource ClickHouse:
//   SELECT ts, result, duration_s
//   FROM observability.cronjob_runs
//   WHERE job = 'ck-push-test' AND ts >= now() - INTERVAL 1 HOUR
//   ORDER BY ts
//
//   SELECT toStartOfInterval(ts, INTERVAL 10 MINUTE) AS t,
//          countIf(result = 'failure') AS failures
//   FROM observability.cronjob_runs
//   WHERE job = 'ck-push-test' AND ts >= now() - INTERVAL 1 DAY
//   GROUP BY t ORDER BY t

const CH_URL = __ENV.CLICKHOUSE_URL || 'http://clickhouse-clickhouse-headless.databases.svc.cluster.local:8123';
const CH_USER = __ENV.CLICKHOUSE_USER || 'default';
const CH_PASSWORD = __ENV.CLICKHOUSE_PASSWORD || '';
const INSERT_QUERY = 'INSERT INTO observability.cronjob_runs FORMAT JSONEachRow';

export const options = {
  vus: 1,
  iterations: 1,
};

export default function () {
  const job = 'ck-push-test';
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

  const event = {
    job,
    result,
    duration_s,
    items: 0,
    error_message: errorMsg,
  };

  const headers = {
    'Content-Type': 'application/json',
    'X-ClickHouse-User': CH_USER,
    ...(CH_PASSWORD && { 'X-ClickHouse-Key': CH_PASSWORD }),
  };

  const res = http.post(
    `${CH_URL}/?query=${encodeURIComponent(INSERT_QUERY)}`,
    JSON.stringify(event),
    { headers, timeout: '10s' },
  );

  console.log(
    `[${job}] result=${result} duration=${duration_s.toFixed(2)}s ts=${now_s} err=${errorMsg ?? ''} ch_status=${res.status}`,
  );
}
