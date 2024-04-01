output "api-gateway-id" {
  value = aws_api_gateway_rest_api.rest_api_lambda_mgr.id
}

output "parent-api-gateway-id" {
  value = aws_api_gateway_rest_api.rest_api_lambda_mgr.root_resource_id
}

output "student-resource" {
  value = aws_api_gateway_resource.student.id
}

output "admin-resource" {
  value = aws_api_gateway_resource.admin.id
}

output "course-resource" {
  value = aws_api_gateway_resource.course.id
}

output "college-resource" {
  value = aws_api_gateway_resource.college.id
}

output "api_gateway_arn" {
  value = aws_api_gateway_rest_api.rest_api_lambda_mgr.execution_arn
}