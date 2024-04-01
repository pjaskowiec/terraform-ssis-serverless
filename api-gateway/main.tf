variable "lambda_admin_uri" {}

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

resource "aws_api_gateway_resource" "admin_login" {
  rest_api_id = aws_api_gateway_rest_api.rest_api_lambda_mgr.id
  parent_id = aws_api_gateway_resource.admin.id
  path_part = "check-user"
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

resource "aws_api_gateway_method" "login_method" {
  rest_api_id   = aws_api_gateway_rest_api.rest_api_lambda_mgr.id
  resource_id   = aws_api_gateway_resource.admin_login.id
  http_method   = "POST"
  authorization = "NONE"
  request_models = {"application/json": "Empty"}
}

resource "aws_api_gateway_integration" "admin_integration" {
  rest_api_id             = aws_api_gateway_rest_api.rest_api_lambda_mgr.id
  resource_id             = aws_api_gateway_resource.admin_login.id
  http_method             = aws_api_gateway_method.login_method.http_method
  integration_http_method = "POST"
  type                    = "AWS"
  uri                     = var.lambda_admin_uri
}

resource "aws_api_gateway_method_response" "response_200" {
  rest_api_id = aws_api_gateway_rest_api.rest_api_lambda_mgr.id
  resource_id = aws_api_gateway_resource.admin_login.id
  http_method = aws_api_gateway_method.login_method.http_method
  status_code = "200"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
  response_models = {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_integration_response" "admin_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.rest_api_lambda_mgr.id
  resource_id = aws_api_gateway_resource.admin_login.id
  http_method = aws_api_gateway_method.login_method.http_method
  status_code = aws_api_gateway_method_response.response_200.status_code

  depends_on = [
    aws_api_gateway_integration.admin_integration
  ]
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = "'*'",
  }
}

resource "aws_api_gateway_deployment" "deployment" {
  depends_on = [
    aws_api_gateway_integration.admin_integration,
  ]

  rest_api_id = aws_api_gateway_rest_api.rest_api_lambda_mgr.id
  stage_name = "prod"
  lifecycle {
    create_before_destroy = true
  }

  variables = {
    random = uuid()
  }
}

resource "aws_api_gateway_method" "cors_method" {
  rest_api_id   = aws_api_gateway_rest_api.rest_api_lambda_mgr.id
  resource_id   = aws_api_gateway_resource.admin_login.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "cors_integration" {
  rest_api_id          = aws_api_gateway_rest_api.rest_api_lambda_mgr.id
  resource_id          = aws_api_gateway_resource.admin_login.id
  http_method          = aws_api_gateway_method.cors_method.http_method
  type                 = "MOCK"
  passthrough_behavior = "WHEN_NO_MATCH"
  content_handling     = "CONVERT_TO_TEXT"
  request_templates    = {
    "application/json" = jsonencode({
      statusCode = 200
    })
  }
}

resource "aws_api_gateway_method_response" "cors" {
  depends_on          = [aws_api_gateway_method.cors_method]
  rest_api_id         = aws_api_gateway_rest_api.rest_api_lambda_mgr.id
  resource_id         = aws_api_gateway_resource.admin_login.id
  http_method         = aws_api_gateway_method.cors_method.http_method
  status_code         = 200
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = true,
    "method.response.header.Access-Control-Allow-Methods" = true,
    "method.response.header.Access-Control-Allow-Headers" = true
  }
  response_models = {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_integration_response" "cors" {
  depends_on          = [aws_api_gateway_integration.cors_integration, aws_api_gateway_method_response.cors]
  rest_api_id         = aws_api_gateway_rest_api.rest_api_lambda_mgr.id
  resource_id         = aws_api_gateway_resource.admin_login.id
  http_method         = aws_api_gateway_method.cors_method.http_method
  status_code         = 200

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = "'*'",
    "method.response.header.Access-Control-Allow-Headers" =	"'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",
    "method.response.header.Access-Control-Allow-Methods" =	"'OPTIONS,POST'"
  }
}
