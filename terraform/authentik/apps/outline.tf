############################
# APPLICATION
############################

module "outline" {
  source = "../modules/oidc_app"

  authentik_url = var.authentik_url
  name          = "Outline"
  slug          = "outline"
  client_id     = var.outline_client_id # preserved from pre-TF state
  sub_mode      = "user_username"       # preserves existing sub mapping for Outline users
  launch_url    = var.outline_url
  description   = "Team knowledge base"

  redirect_uris = [
    {
      matching_mode = "strict"
      url           = "${var.outline_url}/auth/oidc.callback"
    }
  ]
}
