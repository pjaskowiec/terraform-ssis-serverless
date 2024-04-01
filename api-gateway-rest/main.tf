resource "aws_api_gateway_rest_api" "rest_api_lambda_mgr" {
  name = "api-pj-mgr"
  description = "The API Gateway to Lambdas of PJ Bachelor degree."

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_resource" "admin" {
  rest_api_id = aws_api_gateway_rest_api.rest_api_lambda_mgr.id
  parent_id = aws_api_gateway_rest_api.rest_api_lambda_mgr.root_resource_id
  path_part = "admin"
}

resource "aws_api_gateway_resource" "student" {
  rest_api_id = aws_api_gateway_rest_api.rest_api_lambda_mgr.id
  parent_id = aws_api_gateway_rest_api.rest_api_lambda_mgr.root_resource_id
  path_part = "student"
}

resource "aws_api_gateway_resource" "course" {
  rest_api_id = aws_api_gateway_rest_api.rest_api_lambda_mgr.id
  parent_id = aws_api_gateway_rest_api.rest_api_lambda_mgr.root_resource_id
  path_part = "course"
}

resource "aws_api_gateway_resource" "college" {
  rest_api_id = aws_api_gateway_rest_api.rest_api_lambda_mgr.id
  parent_id = aws_api_gateway_rest_api.rest_api_lambda_mgr.root_resource_id
  path_part = "college"
}
