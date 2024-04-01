output "api_gateway_arn" {
  value = aws_api_gateway_rest_api.rest_api_lambda_mgr.execution_arn
}