locals {
  bot_keys_local_path = "${path.module}/bot-keys.local.yaml"
  use_local_bot_keys  = fileexists(local.bot_keys_local_path)
}

# SOPS-encrypted file (committed). Skipped when a plain local override exists.
data "sops_file" "bot_keys" {
  count       = local.use_local_bot_keys ? 0 : 1
  source_file = "${path.module}/bot-keys.sops.yaml"
}

locals {
  # Plain-YAML local override (gitignored). Same schema as bot-keys.sops.yaml:
  #   <bot_name_with_underscores>_private_key: |
  #     -----BEGIN RSA PRIVATE KEY-----
  #     ...
  bot_keys_data = (
    local.use_local_bot_keys
    ? yamldecode(file(local.bot_keys_local_path))
    : data.sops_file.bot_keys[0].data
  )

  # Flatten bot × repo into one entry per (bot, repo) pair so we can use for_each
  # with a stable string key for plan stability.
  bot_repo_pairs = flatten([
    for bot in var.bots : [
      for repo in bot.repos : {
        key             = "${bot.name}--${repo}"
        bot_name        = bot.name
        repo            = repo
        app_id          = bot.app_id
        installation_id = bot.installation_id
        secret_prefix   = upper(replace(bot.name, "-", "_"))
        sops_key        = "${replace(bot.name, "-", "_")}_private_key"
      }
    ]
  ])

  by_key = { for pair in local.bot_repo_pairs : pair.key => pair }
}

# Note: managing the App's repository installation list (`github_app_installation_repository`)
# was removed because the underlying API endpoint
# `GET /user/installations/{id}/repositories` rejects classic PATs in practice
# despite what the docs say — only fine-grained PATs with very specific
# permissions or App user-access tokens work, neither of which are easy to
# obtain. Install the App on each repo manually via
# https://github.com/settings/installations → click app → "Repository access"
# before running `terraform apply`. Terraform here only seeds the per-repo
# Actions secrets that the workflows consume.

resource "github_actions_secret" "app_id" {
  for_each = local.by_key

  repository      = each.value.repo
  secret_name     = "${each.value.secret_prefix}_APP_ID"
  plaintext_value = each.value.app_id
}

resource "github_actions_secret" "app_private_key" {
  for_each = local.by_key

  repository      = each.value.repo
  secret_name     = "${each.value.secret_prefix}_APP_PRIVATE_KEY"
  plaintext_value = local.bot_keys_data[each.value.sops_key]
}

output "managed" {
  description = "Map of bot name to the list of repos with secrets seeded. App installation must be done manually in the GitHub UI."
  value = {
    for bot in var.bots : bot.name => bot.repos
  }
}
