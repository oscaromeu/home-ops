variable "domain" {
  description = "Base domain (set via TF_VAR_domain). All app URLs are derived from this."
  type        = string
  sensitive   = true
}

variable "authentik_token" {
  description = "Authentik admin API token (set via TF_VAR_authentik_token)"
  type        = string
  sensitive   = true
}

variable "outline_client_id" {
  description = "Existing OAuth client_id for Outline (preserved on import to avoid breaking the app)"
  type        = string
  sensitive   = true
}

locals {
  authentik_url = "https://auth.${var.domain}"
  grafana_url   = "https://grafana.${var.domain}"
  outline_url   = "https://docs.${var.domain}"
}
