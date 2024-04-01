output "lambda_admin_uri" {
  value = aws_lambda_function.lambda_admin.invoke_arn
}

output "lambda_student_uri" {
  value = aws_lambda_function.lambda_studnet.invoke_arn
}

output "lambda_college_uri" {
  value = aws_lambda_function.lambda_college.invoke_arn
}

output "lambda_course_uri" {
  value = aws_lambda_function.lambda_course.invoke_arn
}
