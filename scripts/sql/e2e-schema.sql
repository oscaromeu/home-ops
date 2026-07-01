-- e2e probe observability schema. Apply with:
--   kubectl -n databases exec -i clickhouse-clickhouse-0-0-0 -c clickhouse-server -- \
--     clickhouse-client --multiquery < e2e-schema.sql
-- Tables: runs (per run), steps (per test.step), net_timing (per request, from HAR).

CREATE DATABASE IF NOT EXISTS e2e;

CREATE TABLE IF NOT EXISTS e2e.runs (
  run_id String,
  probe LowCardinality(String),
  env LowCardinality(String) DEFAULT 'dev',
  started_at DateTime64(3),
  duration_ms UInt32,
  status Enum8('pass' = 2, 'flaky' = 1, 'fail' = 0),
  tests_total UInt16,
  tests_failed UInt16,
  report_url String DEFAULT '',
  video_url String DEFAULT '',
  trace_url String DEFAULT '',
  error String DEFAULT '',
  git_sha String DEFAULT ''
) ENGINE = ReplacingMergeTree
ORDER BY (probe, started_at, run_id)
TTL toDateTime(started_at) + INTERVAL 90 DAY;

CREATE TABLE IF NOT EXISTS e2e.steps (
  run_id String,
  probe LowCardinality(String),
  test String,
  step String,
  started_at DateTime64(3),
  duration_ms UInt32,
  status Enum8('pass' = 2, 'flaky' = 1, 'fail' = 0),
  error String DEFAULT ''
) ENGINE = MergeTree
ORDER BY (probe, started_at, run_id)
TTL toDateTime(started_at) + INTERVAL 90 DAY;

-- One row per captured request, parsed from the per-test HAR.
-- httpstat phases (HAR `connect` includes TLS, so tcp = connect - ssl) plus
-- status/method/size/protocol and a failed flag (failed requests included).
CREATE TABLE IF NOT EXISTS e2e.net_timing (
  run_id String,
  probe LowCardinality(String),
  test String,
  step String DEFAULT '',
  url String,
  type LowCardinality(String),
  method LowCardinality(String) DEFAULT '',
  status_code UInt16 DEFAULT 0,
  protocol LowCardinality(String) DEFAULT '',
  dns_ms UInt32,
  tcp_ms UInt32,
  tls_ms UInt32,
  server_ms UInt32,
  transfer_ms UInt32,
  total_ms UInt32,
  response_bytes UInt32 DEFAULT 0,
  failed UInt8 DEFAULT 0,
  error_text String DEFAULT '',
  ts DateTime64(3)
) ENGINE = MergeTree
ORDER BY (probe, ts, run_id)
TTL toDateTime(ts) + INTERVAL 90 DAY;

-- One row per page test: Core Web Vitals + the full PerformanceNavigationTiming
-- breakdown of the main-document navigation (redirect/DNS/TCP/TLS/request/
-- response/DOM phases + sizes). DNS/TCP/TLS are 0 on warm (reused) connections.
-- (INP is 0 unless the test interacts and the web-vitals lib is added.)
CREATE TABLE IF NOT EXISTS e2e.web_vitals (
  run_id String,
  probe LowCardinality(String),
  test String,
  started_at DateTime64(3),
  lcp_ms UInt32 DEFAULT 0,
  fcp_ms UInt32 DEFAULT 0,
  ttfb_ms UInt32 DEFAULT 0,
  inp_ms UInt32 DEFAULT 0,
  cls Float32 DEFAULT 0,
  dom_content_loaded_ms UInt32 DEFAULT 0,
  load_ms UInt32 DEFAULT 0,
  -- PerformanceNavigationTiming phase durations (ms) for the main document.
  redirect_ms UInt32 DEFAULT 0,
  dns_ms UInt32 DEFAULT 0,
  tcp_ms UInt32 DEFAULT 0,
  tls_ms UInt32 DEFAULT 0,
  request_ms UInt32 DEFAULT 0,
  response_ms UInt32 DEFAULT 0,
  dom_processing_ms UInt32 DEFAULT 0,
  dom_interactive_ms UInt32 DEFAULT 0,
  transfer_bytes UInt32 DEFAULT 0,
  encoded_body_bytes UInt32 DEFAULT 0,
  decoded_body_bytes UInt32 DEFAULT 0,
  redirect_count UInt8 DEFAULT 0,
  response_status UInt16 DEFAULT 0,
  nav_type LowCardinality(String) DEFAULT ''
) ENGINE = MergeTree
ORDER BY (probe, started_at, run_id)
TTL toDateTime(started_at) + INTERVAL 90 DAY;

-- Migration for an already-deployed web_vitals (idempotent; no-op on fresh installs).
ALTER TABLE e2e.web_vitals
  ADD COLUMN IF NOT EXISTS redirect_ms UInt32 DEFAULT 0,
  ADD COLUMN IF NOT EXISTS dns_ms UInt32 DEFAULT 0,
  ADD COLUMN IF NOT EXISTS tcp_ms UInt32 DEFAULT 0,
  ADD COLUMN IF NOT EXISTS tls_ms UInt32 DEFAULT 0,
  ADD COLUMN IF NOT EXISTS request_ms UInt32 DEFAULT 0,
  ADD COLUMN IF NOT EXISTS response_ms UInt32 DEFAULT 0,
  ADD COLUMN IF NOT EXISTS dom_processing_ms UInt32 DEFAULT 0,
  ADD COLUMN IF NOT EXISTS dom_interactive_ms UInt32 DEFAULT 0,
  ADD COLUMN IF NOT EXISTS transfer_bytes UInt32 DEFAULT 0,
  ADD COLUMN IF NOT EXISTS encoded_body_bytes UInt32 DEFAULT 0,
  ADD COLUMN IF NOT EXISTS decoded_body_bytes UInt32 DEFAULT 0,
  ADD COLUMN IF NOT EXISTS redirect_count UInt8 DEFAULT 0,
  ADD COLUMN IF NOT EXISTS response_status UInt16 DEFAULT 0,
  ADD COLUMN IF NOT EXISTS nav_type LowCardinality(String) DEFAULT '';

-- Per-probe thresholds (SLO target + runtime SLA tiers). Written by the reporter
-- from the probe's CronJob env (PROBE_SLO_TARGET / PROBE_HIGH_MS / PROBE_CRITICAL_MS
-- / PROBE_FATAL_MS) on every run, with sane defaults — so a new probe gets usable
-- thresholds for free and overrides them just by setting env. Dashboards JOIN this
-- to classify each probe against its own thresholds instead of global constants.
-- ReplacingMergeTree(updated_at): one latest row per probe (query with FINAL).
CREATE TABLE IF NOT EXISTS e2e.probe_config (
  probe LowCardinality(String),
  slo_target Float32 DEFAULT 99.0,
  high_ms UInt32 DEFAULT 2000,
  critical_ms UInt32 DEFAULT 4000,
  fatal_ms UInt32 DEFAULT 8000,
  updated_at DateTime64(3)
) ENGINE = ReplacingMergeTree(updated_at)
ORDER BY probe;
