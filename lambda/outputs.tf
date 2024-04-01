output "lambda_admin_uri" {
  value = aws_lambda_function.lambda_admin.invoke_arn
}