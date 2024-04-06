data "archive_file" "lambda_get_pets_zip" {
  type        = "zip"
  source_file = "${path.module}/backend/lambda_get_pets.py"
  output_path = "${path.module}/backend/lambda_get_pets.zip"
}

resource "aws_lambda_function" "lambda_get_pets" {
  filename         = data.archive_file.lambda_get_pets_zip.output_path
  function_name    = "listPetsLambda"
  role             = aws_iam_role.lambda_role.arn
  handler          = "lambda_get_pets.lambda_handler"
  source_code_hash = data.archive_file.lambda_get_pets_zip.output_base64sha256
  runtime          = "python3.8"

  depends_on = [aws_iam_role.lambda_role]

  provider = aws.primary
}