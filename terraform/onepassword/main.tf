locals {
  by_key      = nonsensitive(toset([for i in var.items : "${i.vault}/${i.title}"]))
  spec_by_key = { for i in var.items : "${i.vault}/${i.title}" => i }
  vault_names = nonsensitive(toset([for i in var.items : i.vault]))
}

data "onepassword_vault" "vaults" {
  for_each = local.vault_names
  name     = each.value
}

resource "onepassword_item" "this" {
  for_each = local.by_key

  vault    = data.onepassword_vault.vaults[nonsensitive(local.spec_by_key[each.value].vault)].uuid
  title    = local.spec_by_key[each.value].title
  category = local.spec_by_key[each.value].category
  tags     = local.spec_by_key[each.value].tags
  url      = local.spec_by_key[each.value].url

  username   = local.spec_by_key[each.value].username
  password   = local.spec_by_key[each.value].password
  note_value = local.spec_by_key[each.value].note

  dynamic "section" {
    for_each = length(nonsensitive(local.spec_by_key[each.value].fields)) > 0 ? [1] : []
    content {
      label = "Custom"
      dynamic "field" {
        for_each = nonsensitive(local.spec_by_key[each.value].fields)
        content {
          label = field.key
          value = field.value
        }
      }
    }
  }
}

output "items" {
  description = "Map of <vault>/<title> -> 1Password item UUID."
  value       = { for k, item in onepassword_item.this : k => item.uuid }
}
