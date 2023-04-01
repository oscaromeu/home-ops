# Minio


[Install MC](https://min.io/docs/minio/linux/reference/minio-mc-admin.html#installation)

```
brew install minio/stable/mc
```

You can generate the MINIO_PROMETHEUS_TOKEN using a variety of methods, such as a random string generator or password manager. The main goal is to create a secure and unique token that will be used for authentication between MinIO and Prometheus.

Here's an example of how you can generate a secure token using the openssl command on Linux or macOS:

1. Open a terminal.
2. Run the following command:

```
openssl rand -base64 32
```

This command generates a random 32-byte value and encodes it using base64, resulting in a secure token. You can use this token as the value for `MINIO_PROMETHEUS_TOKEN`.

When setting up your MinIO and Prometheus deployments, make sure to use this token in both configurations. In the MinIO deployment, set the `MINIO_PROMETHEUS_TOKEN` environment variable to this token, and in the Prometheus configuration, set the bearer_token to the same token for the scrape_config targeting the MinIO instance.

Remember to store the generated token securely, as it will be used for authentication between MinIO and Prometheus.

```json
{
  "MINIO_ROOT_USER": "admin",
  "MINIO_ROOT_PASSWORD": "admin",
  "MINIO_PROMETHEUS_TOKEN": "***"
}
```
