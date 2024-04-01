resource "aws_api_gateway_resource" "resource" {
  rest_api_id = var.restapi_id
  parent_id = var.resource_id
  path_part = var.passed_path
}