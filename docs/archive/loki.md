Assume you have the following JSON log data:

```
{
  "timestamp": "2023-03-23T10:00:00Z",
  "level": "ERROR",
  "message": "An error occurred while processing the request",
  "app": "my-app",
  "environment": "production",
  "status_code": 500,
  "latency": 2.5
}
```

Now, let's explore some LogQL queries using this JSON log example:

## Log Filtering

Filter logs based on labels or search terms.

```
// Show logs with the label app="my-app"
{app="my-app"}

// Show logs containing the string "error" from the "my-app" app
{app="my-app"} |= "error"

// Show logs with status_code 500 from the "my-app" app in the "production" environment
{app="my-app", environment="production"} |= "500"
```

## Log Parsing

Loki supports parsing logs with various parsers. For JSON logs, use the json parser.

```
// Parse JSON log fields
{app="my-app"} | json
```

## Log Filtering with Parsed Fields

After parsing log lines, you can filter based on the parsed fields.

```
// Filter logs with a specific status code (e.g., 500)
{app="my-app"} | json | status_code == 500

// Filter logs with latency greater than 1 second
{app="my-app"} | json | latency > 1s
```

## Aggregations and Metrics

Generate metrics from logs using various aggregation functions.

```
// Calculate the 99th percentile latency for each unique label set in the last 10 minutes
quantile_over_time(0.99, {app="my-app"} | json | unwrap latency [10m])

// Count log lines with errors per stream over the last 5 minutes
sum by (app) (count_over_time({app="my-app"} | json | level == "ERROR" [5m]))

// Calculate the average latency for each unique label set in the last 10 minutes
avg_over_time({app="my-app"} | json | unwrap latency [10m])
```
