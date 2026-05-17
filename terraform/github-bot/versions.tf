terraform {
  required_version = ">= 1.6.0"

  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
    sops = {
      source  = "carlpett/sops"
      version = "~> 1.0"
    }
  }

  backend "s3" {
    bucket = "home-ops-tfstate"
    key    = "github-bot/terraform.tfstate"
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
