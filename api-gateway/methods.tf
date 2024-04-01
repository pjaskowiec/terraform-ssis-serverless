//---------------------------admin--------------------
resource "aws_api_gateway_method" "method" {
  rest_api_id   = var.restapi_id
  resource_id   = aws_api_gateway_resource.resource.id
  http_method   = "POST"
  authorization = "NONE"
  request_models = {"application/json": "Empty"}
}

resource "aws_api_gateway_method_response" "method_response_200" {
  rest_api_id = var.restapi_id
  resource_id = aws_api_gateway_resource.resource.id
  http_method = aws_api_gateway_method.method.http_method
  status_code = "200"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
  response_models = {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_method" "cors_method" {
  rest_api_id   = var.restapi_id
  resource_id   = aws_api_gateway_resource.resource.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_method_response" "cors" {
  depends_on          = [aws_api_gateway_method.cors_method]
  rest_api_id         = var.restapi_id
  resource_id         = aws_api_gateway_resource.resource.id
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
//---------------------------student--------------------
//---------------------------college--------------------
//---------------------------course--------------------
