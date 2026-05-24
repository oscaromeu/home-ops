output "grafana_client_id" {
  value = module.grafana.client_id
}

output "grafana_client_secret" {
  value     = module.grafana.client_secret
  sensitive = true
}

output "grafana_oidc_endpoints" {
  value     = module.grafana.endpoints
  sensitive = true
}

output "outline_client_id" {
  value     = module.outline.client_id
  sensitive = true
}

output "outline_client_secret" {
  value     = module.outline.client_secret
  sensitive = true
}

output "outline_oidc_endpoints" {
  value     = module.outline.endpoints
  sensitive = true
}
