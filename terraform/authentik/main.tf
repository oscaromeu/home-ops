############################
# MODULES
############################

module "identity" {
  source = "./identity"
}

module "apps" {
  source = "./apps"

  authentik_url     = local.authentik_url
  grafana_url       = local.grafana_url
  outline_url       = local.outline_url
  outline_client_id = var.outline_client_id
}

############################
# STATE MIGRATION
# (these blocks tell Terraform "the resource you have at the
#  old address is the same one now declared at the new address",
#  so refactoring file layout doesn't trigger destroy+create)
############################

# identity: groups moved from root to module.identity
moved {
  from = authentik_group.admins
  to   = module.identity.authentik_group.admins
}

moved {
  from = authentik_group.viewers
  to   = module.identity.authentik_group.viewers
}

# apps: custom property mappings moved from root to module.apps
moved {
  from = authentik_property_mapping_provider_scope.grafana_groups
  to   = module.apps.authentik_property_mapping_provider_scope.grafana_groups
}

moved {
  from = authentik_property_mapping_provider_scope.grafana_identity
  to   = module.apps.authentik_property_mapping_provider_scope.grafana_identity
}

# apps: grafana provider/application (originally at root, then to module.grafana,
#  now nested under module.apps.module.grafana)
moved {
  from = authentik_provider_oauth2.grafana
  to   = module.apps.module.grafana.authentik_provider_oauth2.this
}

moved {
  from = authentik_application.grafana
  to   = module.apps.module.grafana.authentik_application.this
}

# apps: outline provider/application (currently at module.outline after import)
moved {
  from = module.outline.authentik_provider_oauth2.this
  to   = module.apps.module.outline.authentik_provider_oauth2.this
}

moved {
  from = module.outline.authentik_application.this
  to   = module.apps.module.outline.authentik_application.this
}

############################
# OUTPUTS (pass-through from apps module)
############################

output "grafana_client_id" {
  value = module.apps.grafana_client_id
}

output "grafana_client_secret" {
  value     = module.apps.grafana_client_secret
  sensitive = true
}

output "grafana_oidc_endpoints" {
  value     = module.apps.grafana_oidc_endpoints
  sensitive = true
}

output "outline_client_id" {
  value     = module.apps.outline_client_id
  sensitive = true
}

output "outline_client_secret" {
  value     = module.apps.outline_client_secret
  sensitive = true
}

output "outline_oidc_endpoints" {
  value     = module.apps.outline_oidc_endpoints
  sensitive = true
}
