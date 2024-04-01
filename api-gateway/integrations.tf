//---------------------------admin--------------------
resource "aws_api_gateway_integration" "integration" {
  rest_api_id             = var.restapi_id
  resource_id             = aws_api_gateway_resource.resource.id
  http_method             = aws_api_gateway_method.method.http_method
  integration_http_method = "POST"
  type                    = "AWS"
  uri                     = var.lambda_uri
}

resource "aws_api_gateway_integration_response" "integration_response" {
  rest_api_id = var.restapi_id
  resource_id = aws_api_gateway_resource.resource.id
  http_method = aws_api_gateway_method.method.http_method
  status_code = aws_api_gateway_method_response.method_response_200.status_code

  depends_on = [
    aws_api_gateway_integration.integration
  ]
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = "'*'",
  }
}

resource "aws_api_gateway_integration" "cors_integration" {
  rest_api_id          = var.restapi_id
  resource_id          = aws_api_gateway_resource.resource.id
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

resource "aws_api_gateway_integration_response" "cors" {
  depends_on          = [aws_api_gateway_integration.cors_integration, aws_api_gateway_method_response.cors]
  rest_api_id         = var.restapi_id
  resource_id         = aws_api_gateway_resource.resource.id
  http_method         = aws_api_gateway_method.cors_method.http_method
  status_code         = 200

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = "'*'",
    "method.response.header.Access-Control-Allow-Headers" =	"'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",
    "method.response.header.Access-Control-Allow-Methods" =	"'OPTIONS,POST'"
  }
}
