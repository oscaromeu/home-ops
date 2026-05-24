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
  launch_url  = local.grafana_url
  description = "Observability dashboards"

  redirect_uris = [
    {
      matching_mode = "strict"
      url           = "${local.grafana_url}/login/generic_oauth"
    }
  ]

  custom_scope_mappings = [
    {
      name       = "Grafana groups"
      scope_name = "groups"
      expression = "return [group.name for group in user.groups.all()]"
    },
    {
      name       = "Grafana identity"
      scope_name = "grafana_identity"
      expression = <<-EOT
        return {
          "email": user.email,
          "preferred_username": user.username,
          "name": user.name
        }
      EOT
    }
  ]
}
