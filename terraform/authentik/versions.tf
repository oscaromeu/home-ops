terraform {
  required_version = ">= 1.6.0"

  required_providers {
    authentik = {
      source  = "goauthentik/authentik"
      version = "~> 2024.10"
    }
  }

  backend "s3" {
    bucket = "home-ops-tfstate"
    key    = "authentik/terraform.tfstate"
    region = "us-east-1"

    endpoints = {
      s3 = "https://s3.oscaromeu.io"
    }

    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    skip_requesting_account_id  = true
    skip_s3_checksum            = true
    use_path_style              = true
  }
}
