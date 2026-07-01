variable "items" {
  description = <<-EOT
    List of 1Password items to manage. Each entry is assembled by terragrunt.hcl
    from vaults/*.sops.yaml — you should not need to write to this variable by
    hand.

    Schema per item:
      title    Item title. Unique within (vault).
      vault    Vault display name (resolved to UUID via the provider).
      category login | password | database | secure_note | api_credential.
      tags     Optional list of tags.
      url      Optional URL (login / password categories).
      username Optional (login / database).
      password Optional (login / password / database).
      note     Optional note body (secure_note); also notes on other categories.
      fields   Optional map of <label> -> <value>; rendered as STRING fields
               inside a single "Custom" section. For CONCEALED data put it on
               `password` / `note` instead.
  EOT
  type = list(object({
    title    = string
    vault    = string
    category = optional(string, "password")
    tags     = optional(list(string), [])
    url      = optional(string, null)
    username = optional(string, null)
    password = optional(string, null)
    note     = optional(string, null)
    fields   = optional(map(string), {})
  }))
  sensitive = true

  validation {
    condition = length(distinct([
      for i in var.items : "${i.vault}/${i.title}"
    ])) == length(var.items)
    error_message = "Each (vault, title) pair must be unique."
  }
}
