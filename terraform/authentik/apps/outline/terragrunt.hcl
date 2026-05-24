include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

terraform {
  source = "../../modules/oidc_app"
}

locals {
  root_locals = include.root.locals
  outline_url = "https://docs.${local.root_locals.domain}"
}

inputs = {
  name        = "Outline"
  slug        = "outline"
  client_id   = local.root_locals.secrets.TF_VAR_outline_client_id
  sub_mode    = "user_username" # preserves existing sub mapping for Outline users
  launch_url  = local.outline_url
  description = "Team knowledge base"

  redirect_uris = [
    {
      matching_mode = "strict"
      url           = "${local.outline_url}/auth/oidc.callback"
    }
  ]
}
