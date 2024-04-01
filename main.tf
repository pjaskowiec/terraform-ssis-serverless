terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.4.0"
    }
  }
}

provider "aws" {
  region = "eu-north-1"
}

# endpoint do secretmanagera
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.4.0"

  name = "pj-mgr-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["eu-north-1a", "eu-north-1b"]
  private_subnets = ["10.0.8.0/24"]
  public_subnets  = ["10.0.0.0/24", "10.0.4.0/24", "10.0.6.0/24"]

  enable_dns_hostnames = true
  enable_dns_support   = true

  # enable_nat_gateway = true
  # single_nat_gateway = true

  enable_vpn_gateway = true

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

module "security-groups" {
  source = "./security-groups"
  vpc_id = module.vpc.vpc_id
}

# IAM role to read and write in secrets manager - SecretsManagerReadWrite
# evenutally extra deps in zip
# Lambda in VPC
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function
module "lambda" {
  source                = "./lambda"
  lambda_security_group = module.security-groups.lambda-security-group
  public_subnet_1_id    = module.vpc.private_subnets[0]
  api_gateway_arn = module.api-gateway.api_gateway_arn
}

module "endpoints" {
  source                = "./endpoints"
  vpc_id                = module.vpc.vpc_id
  lambda_security_group = module.security-groups.endpoints-security-group
  public_subnet_1_id    = module.vpc.private_subnets[0]
}

module "api-gateway" {
  source = "./api-gateway"

  lambda_admin_uri = module.lambda.lambda_admin_uri
}

data "aws_secretsmanager_secret" "db-secrets" {
  name = "student-app/db-local-creds"
}

data "aws_secretsmanager_secret_version" "secret-version" {
  secret_id = data.aws_secretsmanager_secret.db-secrets.id
}

module "rds" {
  source              = "./rds"
  username            = jsondecode(data.aws_secretsmanager_secret_version.secret-version.secret_string)["username"]
  password            = jsondecode(data.aws_secretsmanager_secret_version.secret-version.secret_string)["password"]
  dbname              = jsondecode(data.aws_secretsmanager_secret_version.secret-version.secret_string)["dbname"]
  private_subnet_2_id = module.vpc.public_subnets[1]
  private_subnet_3_id = module.vpc.public_subnets[2]
  db_security_group   = module.security-groups.db-security-group
}

resource "null_resource" "db_setup" {
  provisioner "local-exec" {

    command = "mysql -h ${module.rds.db-host} -P 3306 -u \"${module.rds.db-username}\" -D \"${module.rds.db-dbname}\" < script.sql"

    environment = {
      MYSQL_PWD = "${module.rds.db-password}"
    }
  }
}
# pip install --target ./python -r req.txt 
resource "aws_secretsmanager_secret_version" "secret-version-update" {
  secret_id = data.aws_secretsmanager_secret.db-secrets.id
  secret_string = jsonencode(
    {
      host     = module.rds.db-host
      password = module.rds.db-password
      username = module.rds.db-username
      dbname   = module.rds.db-dbname
    }
  )
  depends_on = [
    module.rds
  ]
}