# Required providers.
terraform {
  backend "s3" {
    bucket                      = "terraform-backend-demo"
    key                         = "state.json"
    region                      = "us-east-1"
    endpoint                    = "us-east-1.linodeobjects.com"
    skip_credentials_validation = true
  }
  required_providers {
    linode = {
      source  = "linode/linode"
    }
    akamai = {
      source = "akamai/akamai"
    }
  }
}