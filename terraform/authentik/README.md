# Authentik Terraform

Provisions Authentik OIDC application for Grafana (and future apps).

## Setup

1. Copy and edit secrets:
   ```sh
   cp secrets.sops.yaml.example secrets.sops.yaml
   # fill in AWS_SECRET_ACCESS_KEY (Garage), TF_VAR_authentik_token
   task terraform:encrypt-secrets
   ```

2. Init + apply (the task loads SOPS secrets into env automatically):
   ```sh
   task terraform:init
   task terraform:apply
   ```

3. Wire Grafana with the outputs:
   ```sh
   task terraform:output -- -raw grafana_client_secret
   task terraform:output -- grafana_oidc_endpoints
   ```

## Available tasks

All accept `MODULE=<name>` (defaults to `authentik`):

```sh
task terraform:init
task terraform:plan
task terraform:apply
task terraform:destroy
task terraform:output
task terraform:edit-secrets       # opens sops editor
task terraform:encrypt-secrets    # sops -e -i
```

## State backend

Garage S3-compatible bucket `home-ops-tfstate` at `https://s3.{SECRET_DOMAIN}`.
