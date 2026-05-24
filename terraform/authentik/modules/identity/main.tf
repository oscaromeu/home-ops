############################
# USERS
############################

# Looked up by username, not managed declaratively yet.
# Password and TOTP cannot be set via TF; the user is created
# manually in Authentik (or via bootstrap flows).
data "authentik_user" "oscar" {
  username = "oscar"
}

############################
# GROUPS
############################

resource "authentik_group" "admins" {
  name  = "admins"
  users = [data.authentik_user.oscar.id]
}

resource "authentik_group" "viewers" {
  name = "viewers"
}
