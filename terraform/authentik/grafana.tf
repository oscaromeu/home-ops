data "authentik_flow" "default_authorization_flow" {
  slug = "default-provider-authorization-implicit-consent"
}

data "authentik_flow" "default_invalidation_flow" {
  slug = "default-provider-invalidation-flow"
}

data "authentik_property_mapping_provider_scope" "scope_email" {
  name = "authentik default OAuth Mapping: OpenID 'email'"
}

data "authentik_property_mapping_provider_scope" "scope_profile" {
  name = "authentik default OAuth Mapping: OpenID 'profile'"
}

data "authentik_property_mapping_provider_scope" "scope_openid" {
  name = "authentik default OAuth Mapping: OpenID 'openid'"
}

# Custom mapping that exposes group names in the `groups` claim,
# so Grafana's role_attribute_path can map IdP groups to roles.
resource "authentik_property_mapping_provider_scope" "grafana_groups" {
  name       = "Grafana groups"
  scope_name = "groups"
  expression = <<-EOT
    return {
      "groups": [group.name for group in user.ak_groups.all()],
    }
  EOT
}

data "authentik_certificate_key_pair" "default" {
  name = "authentik Self-signed Certificate"
}

resource "authentik_provider_oauth2" "grafana" {
  name                  = "grafana"
  client_id             = "grafana"
  client_type           = "confidential"
  authorization_flow    = data.authentik_flow.default_authorization_flow.id
  invalidation_flow     = data.authentik_flow.default_invalidation_flow.id
  signing_key           = data.authentik_certificate_key_pair.default.id
  access_code_validity  = "minutes=1"
  access_token_validity = "minutes=10"

  allowed_redirect_uris = [
    {
      matching_mode = "strict"
      url           = "${var.grafana_url}/login/generic_oauth"
    },
  ]

  property_mappings = [
    data.authentik_property_mapping_provider_scope.scope_openid.id,
    data.authentik_property_mapping_provider_scope.scope_email.id,
    data.authentik_property_mapping_provider_scope.scope_profile.id,
    authentik_property_mapping_provider_scope.grafana_groups.id,
  ]
}

resource "authentik_application" "grafana" {
  name              = "Grafana"
  slug              = "grafana"
  protocol_provider = authentik_provider_oauth2.grafana.id
  meta_launch_url   = var.grafana_url
  meta_description  = "Observability dashboards"
  open_in_new_tab   = true
}

output "grafana_client_id" {
  description = "OIDC client_id for Grafana"
  value       = authentik_provider_oauth2.grafana.client_id
}

output "grafana_client_secret" {
  description = "OIDC client_secret for Grafana (use in Grafana env)"
  value       = authentik_provider_oauth2.grafana.client_secret
  sensitive   = true
}

output "grafana_oidc_endpoints" {
  description = "OIDC endpoints to wire into Grafana"
  value = {
    issuer        = "${var.authentik_url}/application/o/${authentik_application.grafana.slug}/"
    authorize_url = "${var.authentik_url}/application/o/authorize/"
    token_url     = "${var.authentik_url}/application/o/token/"
    userinfo_url  = "${var.authentik_url}/application/o/userinfo/"
  }
}
