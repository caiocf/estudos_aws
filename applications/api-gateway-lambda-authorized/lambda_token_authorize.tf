data "archive_file" "token_authorizer_lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda_autorization/token_authorizer_lambda.py"
  output_path = "${path.module}/lambda_autorization/token_authorizer_lambda.zip"
}

resource "aws_lambda_function" "token_authorizer_lambda" {
  filename         = data.archive_file.token_authorizer_lambda_zip.output_path
  function_name    = "token-authorizer-lambda"
  role             = aws_iam_role.lambda_role.arn
  handler          = "token_authorizer_lambda.lambda_handler"
  source_code_hash = data.archive_file.token_authorizer_lambda_zip.output_base64sha256
  runtime          = "python3.8"

  depends_on = [aws_api_gateway_rest_api.petstore_api]

  provider = aws.primary
}


resource "aws_lambda_permission" "api_gateway_token_authorizer_lambda_invoke" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.token_authorizer_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  // The following source_arn should be adjusted to match your API Gateway ARN structure
  source_arn    = "${aws_api_gateway_rest_api.petstore_api.execution_arn}/*/*"

  provider = aws.primary
}