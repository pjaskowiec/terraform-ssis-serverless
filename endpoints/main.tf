variable "vpc_id" {}
variable "lambda_security_group" {}
variable "public_subnet_1_id" {}

resource "aws_vpc_endpoint" "ec2" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.eu-north-1.secretsmanager"
  vpc_endpoint_type = "Interface"
  private_dns_enabled = true
  subnet_ids        = ["${var.public_subnet_1_id}"]
  security_group_ids = ["${var.lambda_security_group}"]
}