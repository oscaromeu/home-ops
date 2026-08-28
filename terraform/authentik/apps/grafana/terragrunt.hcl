include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

terraform {
  source = "../../modules/oidc_app"
}

locals {
  root_locals = include.root.locals
  grafana_url = "https://grafana.${local.root_locals.domain}"
}

inputs = {
  name        = "Grafana"
  slug        = "grafana"
  sub_mode    = "user_username" # preserves existing sub mapping for Grafana users
  launch_url  = local.grafana_url
  description = "Observability dashboards"

  redirect_uris = [
    {
      matching_mode = "strict"
      url           = "${local.grafana_url}/login/generic_oauth"
    }
  ]

  custom_scope_mappings = []
}
