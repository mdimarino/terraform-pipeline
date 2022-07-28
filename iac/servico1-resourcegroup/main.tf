terraform {
  required_version = ">=1.2.6"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.23.0"
    }
  }

  backend "s3" {
    encrypt = true
  }
}

locals {
  service      = "servico1"
  environment  = "desenvolvimento"
}

provider "aws" {}

module "resourcegroup" {
  source = "../../modules/resourcegroup"

  service     = local.service
  environment = local.environment
}
