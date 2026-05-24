variable "authentik_url" {
  description = "Base URL of the Authentik instance (used to build endpoint outputs)"
  type        = string
}

variable "name" {
  description = "Human-readable name of the application"
  type        = string
}

variable "slug" {
  description = "URL-safe slug. Used as Authentik application slug and (by default) as client_id."
  type        = string
}

variable "client_id" {
  description = "OAuth client_id. Defaults to slug."
  type        = string
  default     = null
}

variable "launch_url" {
  description = "Public URL of the app (shown in the Authentik launcher)"
  type        = string
}

variable "redirect_uris" {
  description = "Allowed OAuth redirect URIs"
  type = list(object({
    matching_mode = optional(string, "strict")
    url           = string
  }))
}

variable "extra_property_mappings" {
  description = "Additional property mapping IDs to attach to the provider (e.g. custom scopes)"
  type        = list(string)
  default     = []
}

variable "description" {
  description = "Optional metadata description shown in the launcher"
  type        = string
  default     = ""
}

variable "open_in_new_tab" {
  description = "Whether the launcher opens the app in a new tab"
  type        = bool
  default     = true
}

variable "access_code_validity" {
  description = "Authorization code validity (Authentik duration string)"
  type        = string
  default     = "minutes=1"
}

variable "access_token_validity" {
  description = "Access token validity (Authentik duration string)"
  type        = string
  default     = "minutes=10"
}

variable "sub_mode" {
  description = "How the `sub` claim is generated (e.g. hashed_user_id, user_username, user_email)"
  type        = string
  default     = "hashed_user_id"
}
