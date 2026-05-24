variable "authentik_url" {
  description = "Base URL of the Authentik instance"
  type        = string
}

variable "grafana_url" {
  description = "Public URL of the Grafana instance"
  type        = string
}

variable "outline_url" {
  description = "Public URL of the Outline instance"
  type        = string
}

variable "outline_client_id" {
  description = "Existing OAuth client_id for Outline (preserved from pre-TF state)"
  type        = string
  sensitive   = true
}
