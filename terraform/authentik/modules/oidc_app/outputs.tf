output "client_id" {
  value       = authentik_provider_oauth2.this.client_id
  description = "OIDC client_id"
}

output "client_secret" {
  value       = authentik_provider_oauth2.this.client_secret
  description = "OIDC client_secret"
  sensitive   = true
}

output "endpoints" {
  description = "OIDC endpoints for this application"
  sensitive   = true
  value = {
    issuer        = "${var.authentik_url}/application/o/${authentik_application.this.slug}/"
    authorize_url = "${var.authentik_url}/application/o/authorize/"
    token_url     = "${var.authentik_url}/application/o/token/"
    userinfo_url  = "${var.authentik_url}/application/o/userinfo/"
    logout_url    = "${var.authentik_url}/application/o/${authentik_application.this.slug}/end-session/"
  }
}
