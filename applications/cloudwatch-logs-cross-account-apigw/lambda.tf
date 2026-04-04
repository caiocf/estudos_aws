data "archive_file" "hello_world_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda-src/index.py"
  output_path = "${path.module}/build/lambda_function.zip"
}

resource "aws_iam_role" "lambda_exec" {
  provider = aws.source
  name     = "LambdaExecutionRole-${replace(var.project_name, "_", "-")}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = merge(var.tags, {
    Name    = "LambdaExecutionRole"
    Account = "source"
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  provider   = aws.source
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_function" "hello_api" {
  provider         = aws.source
  function_name    = "${var.project_name}-hello-api"
  role             = aws_iam_role.lambda_exec.arn
  handler          = "index.handler"
  runtime          = "python3.12"
  filename         = data.archive_file.hello_world_zip.output_path
  source_code_hash = data.archive_file.hello_world_zip.output_base64sha256
  timeout          = 10

  tags = merge(var.tags, {
    Name    = "${var.project_name}-hello-api"
    Account = "source"
  })
}
