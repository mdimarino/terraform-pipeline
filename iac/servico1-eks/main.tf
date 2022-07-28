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
  applications = ["aplicacao1", "aplicacao2"]
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

module "eks" {
  source = "../../modules/eks"

  service                    = local.service
  environment                = local.environment
  kubernetes_version         = "1.22"
  vpc_id                     = "vpc-0f217e14ca4ec73f5"
  endpoint_private_access    = true
  endpoint_public_access     = true
  public_access_cidrs        = ["0.0.0.0/0"]
  enabled_cluster_log_types  = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
  service_ipv4_cidr          = "192.168.0.0/16"
  public_subnets_ids         = ["subnet-0c26a41cfc091b700", "subnet-03d5a12462dd75543", "subnet-090a031027cc88aaa"]
  private_subnets_ids        = ["subnet-011054cc43dad6582", "subnet-0e1417416e150dbdb", "subnet-024dececd3160a535"]
  fargate_profile_namespaces = ["default", "kube-system", "${local.service}-${local.environment}"]
  eks_node_groups            = []
}
