terraform {
  required_version = ">=1.2.6"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.23.0"
    }
  }
}

locals {
  region         = "us-east-1"
#   profile        = "acg"
  resource_group = "terraform-remote-backend-state"
}

provider "aws" {
#   region  = local.region
#   profile = local.profile

#   shared_credentials_files = ["~/.aws/credentials"]

  default_tags {
    tags = {
      Environment   = "global"
      Billing       = "infrastructure"
      Provisioner   = "Terraform"
      ResourceGroup = local.resource_group
    }
  }
}

module "terraform-remote-state" {
  source = "../../modules/terraform-remote-backend-state"

  region                           = local.region
  resource-group                   = local.resource_group
  dynamodb-lock-table              = "terraform-remote-backend-state"
  s3-terraform-remote-state-bucket = "terraform-remote-backend-state"
  s3-versioning-lifecycle-days     = 90
}
