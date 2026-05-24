provider "authentik" {
  url   = local.authentik_url
  token = var.authentik_token
}
