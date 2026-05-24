############################
# FLOWS
############################

data "authentik_flow" "default_authorization_flow" {
  slug = "default-provider-authorization-implicit-consent"
}

data "authentik_flow" "default_invalidation_flow" {
  slug = "default-provider-invalidation-flow"
}

############################
# STANDARD SCOPES
############################

data "authentik_property_mapping_provider_scope" "scope_openid" {
  name = "authentik default OAuth Mapping: OpenID 'openid'"
}

data "authentik_property_mapping_provider_scope" "scope_email" {
  name = "authentik default OAuth Mapping: OpenID 'email'"
}

data "authentik_property_mapping_provider_scope" "scope_profile" {
  name = "authentik default OAuth Mapping: OpenID 'profile'"
}

############################
# GROUPS CLAIM
############################

resource "authentik_property_mapping_provider_scope" "grafana_groups" {
  name       = "Grafana groups"
  scope_name = "groups"

  expression = <<-EOT
    return [group.name for group in user.groups.all()]
  EOT
}

############################
# IDENTITY CLAIMS
############################

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
# CERTIFICATE
############################

data "authentik_certificate_key_pair" "default" {
  name = "authentik Self-signed Certificate"
}

############################
# OAUTH PROVIDER (GRAFANA)
############################

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
    }
  ]

  property_mappings = [
    data.authentik_property_mapping_provider_scope.scope_openid.id,
    data.authentik_property_mapping_provider_scope.scope_email.id,
    data.authentik_property_mapping_provider_scope.scope_profile.id,

    authentik_property_mapping_provider_scope.grafana_groups.id,
    authentik_property_mapping_provider_scope.grafana_identity.id,
  ]
}

############################
# APPLICATION
############################

resource "authentik_application" "grafana" {
  name              = "Grafana"
  slug              = "grafana"
  protocol_provider = authentik_provider_oauth2.grafana.id

  meta_launch_url   = var.grafana_url
  meta_description  = "Observability dashboards"
  open_in_new_tab   = true
}

############################
# OUTPUTS
############################

output "grafana_client_id" {
  value       = authentik_provider_oauth2.grafana.client_id
  description = "OIDC client_id for Grafana"
}

output "grafana_client_secret" {
  value       = authentik_provider_oauth2.grafana.client_secret
  description = "OIDC client_secret for Grafana"
  sensitive   = true
}

output "grafana_oidc_endpoints" {
  value = {
    issuer        = "${var.authentik_url}/application/o/${authentik_application.grafana.slug}/"
    authorize_url = "${var.authentik_url}/application/o/authorize/"
    token_url     = "${var.authentik_url}/application/o/token/"
    userinfo_url  = "${var.authentik_url}/application/o/userinfo/"
  }
}