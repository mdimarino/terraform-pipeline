terraform {
  required_version = ">=1.2.6"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.23.0"
    }
  }

  # terraform init -backend-config='bucket=471807755212-us-east-1-terraform-remote-backend-state' -backend-config='key=dummy/terraform.tfstate' -backend-config='region=us-east-1' -backend-config='dynamodb_table=471807755212-us-east-1-terraform-remote-backend-state'

  # backend "s3" {
  #   bucket         = "471807755212-us-east-1-terraform-remote-backend-state"
  #   key            = "dummy/terraform.tfstate"
  #   region         = "us-east-1"
  #   encrypt        = true
  #   dynamodb_table = "471807755212-us-east-1-terraform-remote-backend-state"
  # }

  backend "s3" {
    encrypt = true
  }
}

provider "aws" {}

data "aws_caller_identity" "current" {}

output "aws_caller_identity" {
  description = "O ID da conta na aWS"
  value       = data.aws_caller_identity.current
}
