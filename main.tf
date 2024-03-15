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

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.4.0"

  name = "pj-mgr-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["eu-north-1a", "eu-north-1b"]
  private_subnets = ["10.0.2.0/24", "10.0.4.0/24", "10.0.6.0/24"]
  public_subnets  = ["10.0.0.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true

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

data "aws_secretsmanager_secret" "db-secrets" {
  name = "student-app/db-local-creds"
}

data "aws_secretsmanager_secret_version" "secret-version" {
  secret_id = data.aws_secretsmanager_secret.db-secrets.id
}

module "rds" {
  source = "./rds"
  username = jsondecode(data.aws_secretsmanager_secret_version.secret-version.secret_string)["username"]
  password = jsondecode(data.aws_secretsmanager_secret_version.secret-version.secret_string)["password"]
  dbname = jsondecode(data.aws_secretsmanager_secret_version.secret-version.secret_string)["dbname"]
  private_subnet_2_id = module.vpc.private_subnets[1]
  private_subnet_3_id = module.vpc.private_subnets[2]
  db_security_group = module.security-groups.db-security-group
  
}

module "bastion_ec2_instance" {
  source = "terraform-aws-modules/ec2-instance/aws"

  name = "pj-bastion-host"

  # Docker on Ubuntu 20
  ami                         = "ami-0506d6d51f1916a96"
  instance_type               = "t3.micro"
  key_name                    = "pj-webhost-keys"
  monitoring                  = false
  associate_public_ip_address = true
  vpc_security_group_ids      = ["${module.security-groups.bastion-sg}"]
  subnet_id                   = module.vpc.public_subnets[0]
  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

data "template_file" "user_data_web_app" {
  template = "${file("init-app.sh")}"

  vars = {
    db_host = "${module.rds.db-host}"
  }
}

# gunicorn
module "ec2_instance" {
  source = "terraform-aws-modules/ec2-instance/aws"

  name = "pj-web-host"

  # Docker on Ubuntu 20
  ami                         = "ami-0506d6d51f1916a96"
  instance_type               = "t3.micro"
  key_name                    = "pj-webhost-keys"
  monitoring                  = false
  associate_public_ip_address = false
  vpc_security_group_ids      = ["${module.security-groups.webhost-sg}"]
  subnet_id                   = module.vpc.private_subnets[0]
  iam_instance_profile        = "ecr-pull-policy"
  user_data                   = "${data.template_file.user_data_web_app.rendered}"
  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

module "lb" {
  source = "./lb"

  instance_id = module.ec2_instance.id
  lb-sg       = module.security-groups.lb-sg
  public_subnet_1 = module.vpc.public_subnets[0]
}


