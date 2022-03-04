# Specify the provider and access details
provider "aws" {
  region = "${var.aws_region}"
  profile = "dev"
  shared_credentials_files = [ "$HOME/.aws/credentials" ]
}
provider "dns" {
  # Configuration options
}

terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "4.3.0"
    }
    dns = {
      source = "hashicorp/dns"
      version = "3.2.1"
    }
  }
  backend "s3" {
    bucket         = "wilton-terraform-state-backend"
    key            = "terraform.tfstate"
    dynamodb_table = "terraform_state"
    encrypt        = true
    region         = "sa-east-1"
    profile        = "dev"
    shared_credentials_file = "$HOME/.aws/credentials"
  }
}