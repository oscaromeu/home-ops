variable "authentik_url" {
  description = "Authentik instance URL"
  type        = string
  default     = "https://auth.oscaromeu.io"
}

variable "authentik_token" {
  description = "Authentik admin API token (set via TF_VAR_authentik_token)"
  type        = string
  sensitive   = true
}

variable "grafana_url" {
  description = "Public URL of the Grafana instance"
  type        = string
  default     = "https://grafana.oscaromeu.io"
}
