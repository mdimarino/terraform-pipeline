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
  vpc_id                     = "vpc-03ed1ad5c50ebc8de"
  endpoint_private_access    = true
  endpoint_public_access     = true
  public_access_cidrs        = ["0.0.0.0/0"]
  enabled_cluster_log_types  = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
  service_ipv4_cidr          = "192.168.0.0/16"
  public_subnets_ids         = ["subnet-08b3d79d7e9cb5769", "subnet-0ec5480126fab209c", "subnet-070341abe45a40162"]
  private_subnets_ids        = ["subnet-0e410448dd031cf89", "subnet-01247b9cc4c06974e", "subnet-0efa14b4682dcb0cb"]
  fargate_profile_namespaces = ["default", "kube-system", "${local.service}-${local.environment}"]
  eks_node_groups            = []
}
