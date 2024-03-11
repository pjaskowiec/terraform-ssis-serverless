terraform {
 required_providers {
   aws = {
     source  = "hashicorp/aws"
     version = "~> 5.4.0"
   }
 }
}

provider "aws" {
  region  = "eu-north-1"
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "5.4.0"

  name = "pj-mgr-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["eu-north-1a"]
  private_subnets = ["10.0.2.0/24", "10.0.4.0/24"]
  public_subnets  = ["10.0.0.0/24"]

  # enable_nat_gateway = true
  enable_vpn_gateway = true

  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}

# registry_url = "012602196656.dkr.ecr.eu-north-1.amazonaws.com"
# image_name = "pj-mgr-registry:latest"

