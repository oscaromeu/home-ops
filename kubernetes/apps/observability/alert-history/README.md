# alert-history

Long-term archive of every Alertmanager notification, in ClickHouse.

Alertmanager is stateless by design: it knows which alerts are firing *now* and
nothing about last quarter. This app keeps the history so questions like "which
alert wakes me up most and never means anything?" can be answered with data
instead of memory.

## Path

```
alertmanager  ──webhook──→  fluent-bit aggregator (in_http :8888)
                            observability/fluentbit/aggregator/pipelines/alertmanager.yaml
                   ──http──→  clickhouse  observability.alerts_raw     one row per webhook
                   ────MV───→  clickhouse  observability.alert_events  one row per alert
```

One webhook carries an `alerts[]` array of N alerts. Fluent Bit cannot split one
record into many, so it does not try: the body is stored verbatim with
`FORMAT JSONAsString` and the materialized view does the `arrayJoin`. ClickHouse
is the transform engine, which is why no Vector deployment or Lua filter exists
here.

`alerts_raw` is kept for a year on purpose. If `alert_events` needs a new column
later, it can be backfilled by replaying the raw payloads rather than being
lost.

The `ch-archive` receiver is `continue: true` in the Alertmanager route, so this
archive runs alongside Pushover and the VictoriaLogs archive without swallowing
notifications.

## Schema

[`app/schema.sql`](app/schema.sql). Applied by a Job; every statement is
`IF NOT EXISTS`, so it is safe to re-run. The parent Flux Kustomization sets
`force: true` because Job specs are immutable — editing `schema.sql` rolls the
ConfigMap hash and Flux recreates the Job.

One detail worth not re-learning the hard way: Alertmanager sends
`endsAt: 0001-01-01T00:00:00Z` while an alert is still firing. That is below the
`DateTime64` range and the parser **saturates it to 1900-01-01 rather than
returning NULL**, so the sentinel is caught on the raw string before parsing.
Miss this and every duration computed against a firing alert is garbage.

## Dashboard queries

The Grafana dashboard sidecar is disabled in this cluster (`allowUiUpdates:
true`), so dashboards are built in the UI. Use the `ClickHouse` datasource.

**Noise ranking — the tuning worklist**

```sql
SELECT alertname,
       countIf(status = 'firing') AS fires,
       uniq(fingerprint)          AS instances
FROM observability.alert_events
WHERE $__timeFilter(starts_at)
GROUP BY alertname
ORDER BY fires DESC
LIMIT 20
```

**MTTR distribution by severity** — look at p95, not the average

```sql
SELECT severity,
       count()                                                  AS resolved,
       avg(dateDiff('second', starts_at, ends_at))              AS mttr_avg_s,
       quantile(0.95)(dateDiff('second', starts_at, ends_at))   AS mttr_p95_s
FROM observability.alert_events
WHERE status = 'resolved' AND ends_at IS NOT NULL
  AND $__timeFilter(starts_at)
GROUP BY severity
ORDER BY resolved DESC
```

**Flapping — cycles shorter than five minutes**

```sql
SELECT alertname,
       countIf(dateDiff('second', starts_at, ends_at) < 300) AS short_cycles,
       count()                                               AS total
FROM observability.alert_events
WHERE status = 'resolved' AND ends_at IS NOT NULL
  AND $__timeFilter(starts_at)
GROUP BY alertname
HAVING short_cycles > 0
ORDER BY short_cycles DESC
```

Usually means a threshold is wrong or `for:` is too short.

**Out-of-hours load — what actually costs sleep**

```sql
SELECT toHour(starts_at) AS hour,
       countIf(severity = 'critical') AS critical,
       count()                        AS total
FROM observability.alert_events
WHERE status = 'firing' AND $__timeFilter(starts_at)
GROUP BY hour
ORDER BY hour
```

**Currently firing, oldest first**

```sql
SELECT alertname, namespace, service, severity, starts_at, summary
FROM observability.alert_events
WHERE ends_at IS NULL
ORDER BY starts_at
```

**Filtering on an arbitrary label** — no schema change needed

```sql
SELECT * FROM observability.alert_events
WHERE labels['pod'] LIKE 'jellyfin-%'
```

## Verified

Schema, fan-out and the `endsAt` sentinel were tested against
`clickhouse-server:26.3` with a real two-alert webhook payload (one firing, one
resolved): 1 raw row produced 2 `alert_events` rows, labels and annotations
landed as `Map`, and re-applying `schema.sql` was a no-op.

Not yet verified on-cluster: the Job's ClickHouse connection and the Alertmanager
→ Fluent Bit hop. See the checks in the PR description.
