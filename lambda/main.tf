variable "lambda_security_group" {}
variable "public_subnet_1_id" {}
variable "api_gateway_arn" {}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "iam_for_lambda" {
  name               = "iam_for_lambda"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

data "aws_iam_policy" "SecretsAccess" {
  arn = "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
}

data "aws_iam_policy" "AWSLambdaVPCAccessExecutionRole" {
  arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_iam_role_policy_attachment" "lambda_basic" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role = aws_iam_role.iam_for_lambda.name
}

resource "aws_lambda_permission" "apigw_lambda_admin" {
  statement_id = "AllowExecutionFromAPIGateway"
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_admin.function_name
  principal = "apigateway.amazonaws.com"

  source_arn = "${var.api_gateway_arn}/*/*"
}

resource "aws_lambda_permission" "apigw_lambda_college" {
  statement_id = "AllowExecutionFromAPIGateway"
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_college.function_name
  principal = "apigateway.amazonaws.com"

  source_arn = "${var.api_gateway_arn}/*/*"
}

resource "aws_lambda_permission" "apigw_lambda_student" {
  statement_id = "AllowExecutionFromAPIGateway"
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_studnet.function_name
  principal = "apigateway.amazonaws.com"

  source_arn = "${var.api_gateway_arn}/*/*"
}

resource "aws_lambda_permission" "apigw_lambda_course" {
  statement_id = "AllowExecutionFromAPIGateway"
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_course.function_name
  principal = "apigateway.amazonaws.com"

  source_arn = "${var.api_gateway_arn}/*/*"
}

resource "aws_iam_role_policy_attachment" "lambda-secrets-access" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = data.aws_iam_policy.SecretsAccess.arn
}

resource "aws_iam_role_policy_attachment" "lambda-vpc-exec-access" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = data.aws_iam_policy.AWSLambdaVPCAccessExecutionRole.arn
}

resource "aws_lambda_layer_version" "lambda_layer" {
  filename   = "lambda_layer_1_payload.zip"
  layer_name = "layer_1_python"

  compatible_runtimes = ["python3.10"]
}

data "archive_file" "lambda_admin_zip" {
  type        = "zip"
  source_file = "lambda_source/admin.py"
  output_path = "lambda_function_admin.zip"
}

data "archive_file" "lambda_student_zip" {
  type        = "zip"
  source_file = "lambda_source/student.py"
  output_path = "lambda_function_student.zip"
}

data "archive_file" "lambda_course_zip" {
  type        = "zip"
  source_file = "lambda_source/course.py"
  output_path = "lambda_function_course.zip"
}

data "archive_file" "lambda_college_zip" {
  type        = "zip"
  source_file = "lambda_source/college.py"
  output_path = "lambda_function_college.zip"
}

data "archive_file" "lambda_layer_1" {
  type        = "zip"
  source_dir  = "lambda_source/python"
  output_path = "lambda_layer_1_payload.zip"
}

resource "aws_lambda_function" "lambda_admin" {
  filename      = "lambda_function_admin.zip"
  function_name = "pj-mgr-admin"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "admin.lambda_handler"
  layers        = [aws_lambda_layer_version.lambda_layer.arn]

  source_code_hash = data.archive_file.lambda_admin_zip.output_base64sha256

  vpc_config {
    subnet_ids         = ["${var.public_subnet_1_id}"]
    security_group_ids = ["${var.lambda_security_group}"]
  }

  runtime = "python3.10"
}

resource "aws_lambda_function" "lambda_studnet" {
  filename      = "lambda_function_student.zip"
  function_name = "pj-mgr-student"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "student.lambda_handler"
  layers        = [aws_lambda_layer_version.lambda_layer.arn]

  source_code_hash = data.archive_file.lambda_student_zip.output_base64sha256

  vpc_config {
    subnet_ids         = ["${var.public_subnet_1_id}"]
    security_group_ids = ["${var.lambda_security_group}"]
  }

  runtime = "python3.10"
}

resource "aws_lambda_function" "lambda_course" {
  # If the file is not in the current working directory you will need to include a
  # path.module in the filename.
  filename      = "lambda_function_course.zip"
  function_name = "pj-mgr-course"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "course.lambda_handler"
  layers        = [aws_lambda_layer_version.lambda_layer.arn]

  source_code_hash = data.archive_file.lambda_course_zip.output_base64sha256

  vpc_config {
    subnet_ids         = ["${var.public_subnet_1_id}"]
    security_group_ids = ["${var.lambda_security_group}"]
  }

  runtime = "python3.10"
}

resource "aws_lambda_function" "lambda_college" {
  # If the file is not in the current working directory you will need to include a
  # path.module in the filename.
  filename      = "lambda_function_college.zip"
  function_name = "pj-mgr-college"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "college.lambda_handler"
  layers        = [aws_lambda_layer_version.lambda_layer.arn]

  source_code_hash = data.archive_file.lambda_college_zip.output_base64sha256

  vpc_config {
    subnet_ids         = ["${var.public_subnet_1_id}"]
    security_group_ids = ["${var.lambda_security_group}"]
  }

  runtime = "python3.10"
}

resource "aws_cloudwatch_log_group" "function_log_group" {
  name              = "/aws/lambda/${aws_lambda_function.lambda_studnet.function_name}"
  retention_in_days = 7
}

data "aws_iam_policy" "CloudWatchAccess" {
  arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}

resource "aws_iam_role_policy_attachment" "lambda-cloudwatch-access" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = data.aws_iam_policy.CloudWatchAccess.arn
}

resource "aws_cloudwatch_query_definition" "example" {
  name = "custom_query"

  log_group_names = [
    aws_cloudwatch_log_group.function_log_group.name
  ]

  query_string = <<EOF
filter @type = "REPORT"
| stats avg(@duration) as AvgExecutionTime
EOF
}