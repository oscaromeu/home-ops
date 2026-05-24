############################
# ROOT TERRAGRUNT CONFIG
#
# Everything below is inherited by every leaf via `include "root"`.
# Each leaf gets its own remote state, the provider config generated,
# and a baseline set of inputs.
############################

locals {
  secrets       = yamldecode(sops_decrypt_file(find_in_parent_folders("secrets.sops.yaml")))
  domain        = local.secrets.TF_VAR_domain
  authentik_url = "https://auth.${local.domain}"
}

############################
# REMOTE STATE
# One state file per leaf at:
#   s3://home-ops-tfstate/authentik/<leaf path>/terraform.tfstate
############################

remote_state {
  backend = "s3"

  generate = {
    path      = "backend_gen.tf"
    if_exists = "overwrite"
  }

  config = {
    bucket = "home-ops-tfstate"
    key    = "authentik/${path_relative_to_include()}/terraform.tfstate"
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
# PROVIDER (generated into each leaf's working directory)
############################

generate "provider" {
  path      = "provider_gen.tf"
  if_exists = "overwrite"
  contents  = <<-EOF
    provider "authentik" {
      url   = "${local.authentik_url}"
      token = var.authentik_token
    }

    variable "authentik_token" {
      type      = string
      sensitive = true
    }
  EOF
}

############################
# COMMON INPUTS
# Leaves can override or extend.
############################

inputs = {
  authentik_token = local.secrets.TF_VAR_authentik_token
  authentik_url   = local.authentik_url
}
