############################
# CUSTOM PROPERTY MAPPINGS
############################

resource "authentik_property_mapping_provider_scope" "grafana_groups" {
  name       = "Grafana groups"
  scope_name = "groups"

  expression = <<-EOT
    return [group.name for group in user.groups.all()]
  EOT
}

resource "authentik_property_mapping_provider_scope" "grafana_identity" {
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

############################
# APPLICATION
############################

module "grafana" {
  source = "../modules/oidc_app"

  authentik_url = var.authentik_url
  name          = "Grafana"
  slug          = "grafana"
  launch_url    = var.grafana_url
  description   = "Observability dashboards"

  redirect_uris = [
    {
      matching_mode = "strict"
      url           = "${var.grafana_url}/login/generic_oauth"
    }
  ]

  extra_property_mappings = [
    authentik_property_mapping_provider_scope.grafana_groups.id,
    authentik_property_mapping_provider_scope.grafana_identity.id,
  ]
}
