variable "github_owner" {
  description = "GitHub user or organization that owns the target repos."
  type        = string
  default     = "oscaromeu"
}

variable "bots" {
  description = <<-EOT
    List of GitHub App bots managed by this module. For each bot, the module:

      1. Adds every repo in `repos` to the App's installation repository list
         (i.e. installs the App on those repos).
      2. Creates two repo-scoped Actions secrets in each repo:
         <SECRET_PREFIX>_APP_ID and <SECRET_PREFIX>_APP_PRIVATE_KEY.

    Where <SECRET_PREFIX> is the bot `name` upper-cased with hyphens replaced by
    underscores (e.g. `bot-oscaromeu` → `BOT_OSCAROMEU`).

    The private key for each bot must exist in bot-keys.sops.yaml under the key
    `<bot_name_with_underscores>_private_key` (e.g. `bot_oscaromeu_private_key`).
  EOT
  type = list(object({
    name            = string       # Bot lowercase name, used to derive secret prefix and SOPS key.
    app_id          = string       # GitHub App ID. Find at https://github.com/settings/apps/<app-slug>.
    installation_id = number       # Installation ID. Find at https://github.com/settings/installations → click app → URL.
    repos           = list(string) # Repository names (slug, not full owner/repo).
  }))
}
