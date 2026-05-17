# Org-wide groups, mapped to app-specific roles via each app's
# role_attribute_path / authorization rules. Add app-specific groups here
# only when a user needs a permission in one app that doesn't fit the
# org-wide model.

data "authentik_user" "oscar" {
  username = "oscar"
}

resource "authentik_group" "admins" {
  name  = "admins"
  users = [data.authentik_user.oscar.id]
}

resource "authentik_group" "viewers" {
  name = "viewers"
}

# Address renames preserved from the previous per-app group layout.
moved {
  from = authentik_group.grafana_admin
  to   = authentik_group.admins
}

moved {
  from = authentik_group.grafana_viewer
  to   = authentik_group.viewers
}
