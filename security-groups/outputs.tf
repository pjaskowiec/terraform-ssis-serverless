output "db-security-group" {
  value = aws_security_group.db_security_group.id
}

output "lambda-security-group" {
  value = aws_security_group.lambda_sg.id
}