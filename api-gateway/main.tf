variable "lambda_uri" {}
variable "restapi_id" {}
variable "parent_api_gateway_id" {}
variable "passed_path" {}
variable "resource_id" {}

resource "aws_api_gateway_deployment" "deployment" {
  depends_on = [
    aws_api_gateway_integration.integration,
  ]

  rest_api_id = var.restapi_id
  stage_name = "prod"
  lifecycle {
    create_before_destroy = true
  }
}