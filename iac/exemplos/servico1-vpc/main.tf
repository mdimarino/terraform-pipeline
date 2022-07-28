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
  region       = "us-east-1"
  service      = "servico1"
  environment  = "desenvolvimento"
}

provider "aws" {
  default_tags {
    tags = {
      Service       = local.service
      Environment   = local.environment
      Billing       = "infrastructure"
      Provisioner   = "Terraform"
      ResourceGroup = "${local.service}-${local.environment}"
    }
  }
}

module "vpc" {
  source = "../../modules/vpc"

  service                     = local.service
  environment                 = local.environment
  vpc-cidr-block              = "172.18.0.0/16"
  public-subnet-cidr-blocks   = ["172.18.0.0/21", "172.18.16.0/21", "172.18.32.0/21"]
  private-subnet-cidr-blocks  = ["172.18.8.0/21", "172.18.24.0/21", "172.18.40.0/21"]
  database-subnet-cidr-blocks = ["172.18.96.0/21", "172.18.104.0/21", "172.18.112.0/21"]
  availability-zones          = ["${local.region}a", "${local.region}b", "${local.region}c"]
  create-nat-gateways         = true
  create-database-subnets     = true
}
