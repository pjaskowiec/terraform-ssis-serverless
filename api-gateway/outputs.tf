output "lambda_url" {
  value = aws_api_gateway_deployment.deployment.invoke_url
}

output "lambda_path" {
  value = aws_api_gateway_resource.resource.path
}