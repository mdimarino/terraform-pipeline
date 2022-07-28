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

module "kubernetes" {
  source = "../../modules/eks"

  service                    = local.service
  environment                = local.environment
  kubernetes_version         = "1.22"
  vpc_id                     = module.network.vpc_id
  endpoint_private_access    = true
  endpoint_public_access     = true
  public_access_cidrs        = ["0.0.0.0/0"]
  enabled_cluster_log_types  = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
  service_ipv4_cidr          = "192.168.0.0/16"
  public_subnets_ids         = module.network.public_subnets_ids
  private_subnets_ids        = module.network.private_subnets_ids
  fargate_profile_namespaces = ["default", "kube-system", "${local.service}-${local.environment}"]
  eks_node_groups            = []
}
