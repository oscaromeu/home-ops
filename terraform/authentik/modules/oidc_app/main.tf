data "authentik_flow" "authorization" {
  slug = "default-provider-authorization-implicit-consent"
}

data "authentik_flow" "invalidation" {
  slug = "default-provider-invalidation-flow"
}

data "authentik_property_mapping_provider_scope" "openid" {
  name = "authentik default OAuth Mapping: OpenID 'openid'"
}

data "authentik_property_mapping_provider_scope" "email" {
  name = "authentik default OAuth Mapping: OpenID 'email'"
}

data "authentik_property_mapping_provider_scope" "profile" {
  name = "authentik default OAuth Mapping: OpenID 'profile'"
}

data "authentik_certificate_key_pair" "default" {
  name = "authentik Self-signed Certificate"
}

resource "authentik_provider_oauth2" "this" {
  name        = var.name
  client_id   = coalesce(var.client_id, var.slug)
  client_type = "confidential"

  authorization_flow = data.authentik_flow.authorization.id
  invalidation_flow  = data.authentik_flow.invalidation.id

  signing_key = data.authentik_certificate_key_pair.default.id

  access_code_validity  = var.access_code_validity
  access_token_validity = var.access_token_validity
  sub_mode              = var.sub_mode

  allowed_redirect_uris = var.redirect_uris

  property_mappings = concat(
    [
      data.authentik_property_mapping_provider_scope.openid.id,
      data.authentik_property_mapping_provider_scope.email.id,
      data.authentik_property_mapping_provider_scope.profile.id,
    ],
    var.extra_property_mappings,
  )
}

resource "authentik_application" "this" {
  name              = var.name
  slug              = var.slug
  protocol_provider = authentik_provider_oauth2.this.id

  meta_launch_url  = var.launch_url
  meta_description = var.description
  open_in_new_tab  = var.open_in_new_tab
}
