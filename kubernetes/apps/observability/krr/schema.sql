-- KRR history: what every container asks for vs what it actually uses.
--
-- Ingest path:
--   cronjob  --krr -f json--> /share/krr.json
--            --clickhouse-client--> observability.krr_raw             (one row per scan)
--            --MV------------------> observability.krr_recommendations (one row per container)
--
-- Units follow krr: CPU in cores (0.05 = 50m), memory in bytes.

CREATE DATABASE IF NOT EXISTS observability;

-- ---------------------------------------------------------------------------
-- Raw landing table. Written with FORMAT JSONAsString, so the whole krr report
-- lands in a single column and no parsing happens at ingest time.
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS observability.krr_raw
(
    payload    String,
    scanned_at DateTime DEFAULT now()
)
ENGINE = MergeTree
PARTITION BY toYYYYMM(scanned_at)
ORDER BY scanned_at
TTL scanned_at + INTERVAL 1 YEAR;

-- ---------------------------------------------------------------------------
-- Query table. One row per container per scan.
--
-- `*_current` is what the manifest asks for today, `*_recommended` is what krr
-- would set. Both are Nullable because krr uses three different empty values:
-- null when it says the field should not be set at all (its advice for CPU
-- limits), "?" when it has no data, and absent when the container sets nothing.
-- All three collapse to NULL here; `cpu_info` / `memory_info` carry krr's own
-- explanation when there is one.
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS observability.krr_recommendations
(
    scanned_at                DateTime,
    namespace                 LowCardinality(String),
    kind                      LowCardinality(String),
    name                      String,
    container                 String,
    severity                  LowCardinality(String),   -- worst of the four below
    cpu_request_current       Nullable(Float64),
    cpu_request_recommended   Nullable(Float64),
    cpu_request_severity      LowCardinality(String),
    cpu_limit_current         Nullable(Float64),
    cpu_limit_recommended     Nullable(Float64),
    memory_request_current    Nullable(Float64),
    memory_request_recommended Nullable(Float64),
    memory_request_severity   LowCardinality(String),
    memory_limit_current      Nullable(Float64),
    memory_limit_recommended  Nullable(Float64),
    cpu_info                  String,
    memory_info               String
)
ENGINE = MergeTree
PARTITION BY toYYYYMM(scanned_at)
ORDER BY (namespace, name, container, scanned_at)
TTL scanned_at + INTERVAL 1 YEAR;

-- ---------------------------------------------------------------------------
-- Fan-out: one report carries a scans[] array with one entry per container.
--
-- Values are read with JSONExtractRaw + toFloat64OrNull rather than
-- JSONExtractFloat: krr writes the string "?" where it has no recommendation,
-- and JSONExtractFloat turns that into 0, which reads as "asks for nothing"
-- instead of "unknown". toFloat64OrNull maps "?", null and missing to NULL.
-- ---------------------------------------------------------------------------
CREATE MATERIALIZED VIEW IF NOT EXISTS observability.krr_recommendations_mv
TO observability.krr_recommendations
AS
SELECT
    scanned_at,
    JSONExtractString(scan, 'object', 'namespace')                                  AS namespace,
    JSONExtractString(scan, 'object', 'kind')                                       AS kind,
    JSONExtractString(scan, 'object', 'name')                                       AS name,
    JSONExtractString(scan, 'object', 'container')                                  AS container,
    JSONExtractString(scan, 'severity')                                             AS severity,
    toFloat64OrNull(JSONExtractRaw(scan, 'object', 'allocations', 'requests', 'cpu'))    AS cpu_request_current,
    toFloat64OrNull(JSONExtractRaw(scan, 'recommended', 'requests', 'cpu', 'value'))     AS cpu_request_recommended,
    JSONExtractString(scan, 'recommended', 'requests', 'cpu', 'severity')            AS cpu_request_severity,
    toFloat64OrNull(JSONExtractRaw(scan, 'object', 'allocations', 'limits', 'cpu'))      AS cpu_limit_current,
    toFloat64OrNull(JSONExtractRaw(scan, 'recommended', 'limits', 'cpu', 'value'))       AS cpu_limit_recommended,
    toFloat64OrNull(JSONExtractRaw(scan, 'object', 'allocations', 'requests', 'memory')) AS memory_request_current,
    toFloat64OrNull(JSONExtractRaw(scan, 'recommended', 'requests', 'memory', 'value'))  AS memory_request_recommended,
    JSONExtractString(scan, 'recommended', 'requests', 'memory', 'severity')         AS memory_request_severity,
    toFloat64OrNull(JSONExtractRaw(scan, 'object', 'allocations', 'limits', 'memory'))   AS memory_limit_current,
    toFloat64OrNull(JSONExtractRaw(scan, 'recommended', 'limits', 'memory', 'value'))    AS memory_limit_recommended,
    JSONExtractString(scan, 'recommended', 'info', 'cpu')                            AS cpu_info,
    JSONExtractString(scan, 'recommended', 'info', 'memory')                         AS memory_info
FROM observability.krr_raw
ARRAY JOIN JSONExtractArrayRaw(payload, 'scans') AS scan;
