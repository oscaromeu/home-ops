# GitHub Bot Terraform

Manages GitHub App installations and bot Actions secrets across personal repos.

For each `(bot, repo)` pair this module:

1. Adds the repo to the bot's GitHub App installation (same as ticking it in `https://github.com/settings/installations` → App → Repository access).
2. Sets two repo-scoped Actions secrets: `<BOT>_APP_ID` and `<BOT>_APP_PRIVATE_KEY`.

Mirrors the pattern from `flanks-infra/terraform/shared/github/bot-secrets/`, adapted for personal repos (no GitHub org → repo secrets instead of org secrets) and for the home-ops style (plain Terraform, no Terragrunt, S3-Garage backend, SOPS).

## Setup

1. **Find the App credentials.**

   ```sh
   # App ID is shown at the top of the App settings page:
   open https://github.com/settings/apps

   # Installation ID — open the installation, the URL ends with /installations/<ID>:
   open https://github.com/settings/installations
   ```

2. **Configure the bots list.**

   ```sh
   cp terraform.tfvars.example terraform.tfvars
   # edit: name, app_id, installation_id, repos
   ```

   To match the existing renovate workflow in `fastapi-observability` (which references `BOT_APP_ID` / `BOT_APP_PRIVATE_KEY`), use `name = "bot"` so the secret prefix is `BOT`. If you prefer a different bot name, also update the secret refs in `.github/workflows/renovate.yaml`.

3. **Encrypt the private key.**

   ```sh
   cp bot-keys.sops.yaml.example bot-keys.sops.yaml
   # paste the bot's private key under bot_private_key (multi-line is fine)
   sops -e -i bot-keys.sops.yaml
   ```

4. **Configure secrets for the providers.**

   ```sh
   cp secrets.sops.yaml.example secrets.sops.yaml
   # fill GITHUB_TOKEN (classic PAT with `repo`) and AWS_* for Garage backend
   sops -e -i secrets.sops.yaml
   ```

5. **Init and apply.** The Taskfile loads `secrets.sops.yaml` as env vars automatically.

   ```sh
   task terraform:init MODULE=github-bot
   task terraform:plan MODULE=github-bot
   task terraform:apply MODULE=github-bot
   ```

## Adding a new repo

Edit `terraform.tfvars`, append the repo to the relevant bot's `repos` list, then `task terraform:apply MODULE=github-bot`. Terraform will install the App on the new repo and seed both secrets in one apply.

## Adding a new bot

1. Create the GitHub App, generate its private key.
2. Add a new entry to `bots` in `terraform.tfvars` with a unique `name`.
3. Add `<name_with_underscores>_private_key` to `bot-keys.sops.yaml` and re-encrypt.
4. `task terraform:apply MODULE=github-bot`.

## Files

| File | Purpose |
|------|---------|
| `versions.tf` | Terraform + provider pins, S3 backend (Garage). |
| `providers.tf` | `github` provider config (token via env). |
| `variables.tf` | `bots` schema. |
| `main.tf` | SOPS data source, App installation + secret resources, output. |
| `terraform.tfvars` | Per-deployment config (gitignored). |
| `bot-keys.sops.yaml` | SOPS-encrypted YAML with bot private keys. Read directly by Terraform via the `carlpett/sops` provider. Committed. |
| `secrets.sops.yaml` | SOPS-encrypted YAML with `GITHUB_TOKEN` and `AWS_*`. Loaded by the Taskfile via `sops -d --output-type dotenv` and exported as env vars. Committed. |

> **Format note:** both files are **YAML internally** — the `.sops.yaml` extension requires it (SOPS auto-detects format by extension). `secrets.sops.yaml` only contains flat `KEY: value` pairs because SOPS converts them to dotenv at decrypt time; nested structures would not survive that conversion.

## State

Garage S3-compatible bucket `home-ops-tfstate` at `https://s3.oscaromeu.io`, key `github-bot/terraform.tfstate`.
