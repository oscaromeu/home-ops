############################
# 1Password items — single state.
#
# Adding a secret    = añade un bloque al fichero del vault en vaults/.
# Adding a new vault = añade vaults/<slug>.sops.yaml (crea el vault en 1P
#                      manualmente primero y dale acceso al Service Account).
############################

locals {
  shared = yamldecode(sops_decrypt_file("${get_terragrunt_dir()}/secrets.sops.yaml"))
  domain = local.shared.TF_VAR_domain

  # One file per vault under vaults/. Each file is encrypted and contains both
  # the metadata (category, url, tags...) and the secret values for that vault.
  # Exclude sops' .decrypted~* cache files (created transiently while editing).
  vault_files = [
    for f in fileset("${get_terragrunt_dir()}/vaults", "*.sops.yaml") :
    f if !startswith(f, ".decrypted~")
  ]
  vaults = [
    for f in local.vault_files :
    yamldecode(sops_decrypt_file("${get_terragrunt_dir()}/vaults/${f}"))
  ]

  # Flatten { vault, items: { title: spec } } files into a single list of items
  # ready to feed terraform's for_each.
  items = flatten([
    for v in local.vaults : [
      for title, spec in v.items : merge(spec, {
        title = title
        vault = v.vault
      })
    ]
  ])
}

############################
# REMOTE STATE
############################

remote_state {
  backend = "s3"

  generate = {
    path      = "backend_gen.tf"
    if_exists = "overwrite"
  }

  config = {
    bucket = "home-ops-tfstate"
    key    = "onepassword/terraform.tfstate"
    region = "us-east-1"

    endpoints = {
      s3 = "https://s3.${local.domain}"
    }

    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    skip_requesting_account_id  = true
    skip_s3_checksum            = true
    use_path_style              = true
  }
}

############################
# PROVIDER
# Reads OP_SERVICE_ACCOUNT_TOKEN from the environment (loaded by the Taskfile
# from secrets.sops.yaml).
############################

generate "provider" {
  path      = "provider_gen.tf"
  if_exists = "overwrite"
  contents  = <<-EOF
    provider "onepassword" {}
  EOF
}

inputs = {
  items = local.items
}
