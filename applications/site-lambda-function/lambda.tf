data "archive_file" "lambda_get_site_text_zip" {
  type        = "zip"
  source_file = "${path.module}/backend/lambda_get_site_text.py"
  output_path = "${path.module}/backend/lambda_get_site_text.zip"
}


resource "aws_lambda_function" "site-lambda-function" {
  filename         = data.archive_file.lambda_get_site_text_zip.output_path
  function_name    = "site-lambda-function"
  role             = aws_iam_role.lambda_role.arn
  handler          = "lambda_get_site_text.lambda_handler"
  source_code_hash = data.archive_file.lambda_get_site_text_zip.output_base64sha256
  runtime          = "python3.8"

  memory_size = 128
  timeout = 3

  layers = [
    // "arn:aws:lambda:us-east-1:580247275435:layer:LambdaInsightsExtension:14"
    local.lambdaInsightsLayers[local.aws_region]
  ]

  tracing_config {
    mode = "Active"
  }

  architectures = ["x86_64"]
  ephemeral_storage {
    size = 1024 # Min 512 MB and the Max 10240 MB
  }

  depends_on = [aws_iam_role.lambda_role]

  environment {
    variables = {
      MEU_AMBIENTE: "dev",
      ENDPOINT_ABC: "http://www.bol.com.br"
    }
  }

  provider = aws.primary
}

