variable "lambda_security_group" {}
variable "public_subnet_1_id" {}

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

resource "aws_iam_role_policy_attachment" "lambda-secrets-access" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = data.aws_iam_policy.SecretsAccess.arn
}

resource "aws_iam_role_policy_attachment" "lambda-vpc-exec-access" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = data.aws_iam_policy.AWSLambdaVPCAccessExecutionRole.arn
}

data "archive_file" "lambda" {
  type        = "zip"
  source_file = "lambda_source/admin/admin.py"
  output_path = "lambda_function_admin.zip"
}

resource "aws_lambda_function" "lambda_admin" {
  # If the file is not in the current working directory you will need to include a
  # path.module in the filename.
  filename      = "lambda_function_admin.zip"
  function_name = "pj-mgr-admin"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "admin.lambda_handler"

  source_code_hash = data.archive_file.lambda.output_base64sha256

  vpc_config {
    subnet_ids         = ["${var.public_subnet_1_id}"]
    security_group_ids = ["${var.lambda_security_group}"]
  }

  runtime = "python3.10"
}