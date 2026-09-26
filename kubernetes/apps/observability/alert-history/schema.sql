-- Alert history: long-term archive of every Alertmanager notification.
--
-- Ingest path:
--   alertmanager --webhook--> fluent-bit aggregator (in_http :8888)
--                --http-----> clickhouse  observability.alerts_raw   (one row per webhook)
--                --MV-------> clickhouse  observability.alert_events (one row per alert)
--
-- alerts_raw keeps the untouched payload on purpose: if alert_events ever needs
-- a new column, it can be backfilled by replaying this table instead of being
-- lost. Cheap to keep — a few thousand rows a month.

CREATE DATABASE IF NOT EXISTS observability;

-- ---------------------------------------------------------------------------
-- Raw landing table. Written with FORMAT JSONAsString, so the whole webhook
-- body lands in a single column and no parsing happens at ingest time.
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS observability.alerts_raw
(
    payload     String,
    received_at DateTime64(3) DEFAULT now64(3)
)
ENGINE = MergeTree
PARTITION BY toYYYYMM(received_at)
ORDER BY received_at
TTL toDateTime(received_at) + INTERVAL 1 YEAR;

-- ---------------------------------------------------------------------------
-- Query table. One row per alert per state change (firing / resolved).
--
-- ORDER BY leads with alertname because every analytical query filters or
-- groups by it; fingerprint then groups the lifecycle of a single alert
-- instance together on disk.
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS observability.alert_events
(
    received_at   DateTime64(3),
    status        LowCardinality(String),          -- firing | resolved
    alertname     LowCardinality(String),
    severity      LowCardinality(String),
    namespace     LowCardinality(String),
    service       LowCardinality(String),
    instance      String,
    fingerprint   String,                          -- stable id of the alert instance
    starts_at     DateTime64(3),
    ends_at       Nullable(DateTime64(3)),         -- NULL while firing
    generator_url String,
    summary       String,
    description   String,
    runbook_url   String,
    labels        Map(LowCardinality(String), String),
    annotations   Map(LowCardinality(String), String),
    receiver      LowCardinality(String),
    group_key     String
)
ENGINE = MergeTree
PARTITION BY toYYYYMM(starts_at)
ORDER BY (alertname, fingerprint, starts_at)
TTL toDateTime(starts_at) + INTERVAL 3 YEAR;

-- ---------------------------------------------------------------------------
-- Fan-out: one webhook carries an alerts[] array of N alerts. arrayJoin turns
-- it into N rows. This is the step Fluent Bit cannot do on its own, and the
-- reason no Vector/Lua transform is needed.
-- ---------------------------------------------------------------------------
CREATE MATERIALIZED VIEW IF NOT EXISTS observability.alert_events_mv
TO observability.alert_events
AS
SELECT
    received_at,
    JSONExtractString(alert, 'status')                                AS status,
    JSONExtractString(alert, 'labels', 'alertname')                   AS alertname,
    JSONExtractString(alert, 'labels', 'severity')                    AS severity,
    JSONExtractString(alert, 'labels', 'namespace')                   AS namespace,
    JSONExtractString(alert, 'labels', 'service')                     AS service,
    JSONExtractString(alert, 'labels', 'instance')                    AS instance,
    JSONExtractString(alert, 'fingerprint')                           AS fingerprint,
    parseDateTime64BestEffortOrNull(JSONExtractString(alert, 'startsAt'), 3) AS starts_at,
    -- Alertmanager sends 0001-01-01T00:00:00Z while an alert is still firing.
    -- That is below the DateTime64 range, and the parser SATURATES it to
    -- 1900-01-01 instead of returning NULL — so the sentinel has to be caught
    -- on the raw string, before parsing. Getting this wrong makes every
    -- duration computed against a firing alert nonsense.
    if(
        startsWith(JSONExtractString(alert, 'endsAt'), '0001-01-01'),
        NULL,
        parseDateTime64BestEffortOrNull(JSONExtractString(alert, 'endsAt'), 3)
    )                                                                 AS ends_at,
    JSONExtractString(alert, 'generatorURL')                          AS generator_url,
    JSONExtractString(alert, 'annotations', 'summary')                AS summary,
    JSONExtractString(alert, 'annotations', 'description')            AS description,
    JSONExtractString(alert, 'annotations', 'runbook_url')            AS runbook_url,
    JSONExtract(alert, 'labels', 'Map(String, String)')               AS labels,
    JSONExtract(alert, 'annotations', 'Map(String, String)')          AS annotations,
    JSONExtractString(payload, 'receiver')                            AS receiver,
    JSONExtractString(payload, 'groupKey')                            AS group_key
FROM observability.alerts_raw
ARRAY JOIN JSONExtractArrayRaw(payload, 'alerts') AS alert;
