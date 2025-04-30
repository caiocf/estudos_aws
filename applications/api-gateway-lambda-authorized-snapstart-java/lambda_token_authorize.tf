
resource "aws_lambda_function" "token_authorizer_lambda" {
  #filename         = data.archive_file.token_authorizer_lambda_zip.output_path
  filename         = "${path.module}/lambda_autorization/target/lambda-authorization-1.0.0.jar"
  function_name    = var.name_token_authorizer_lambda
  role             = aws_iam_role.lambda_role.arn
  handler          = "com.example.TokenAuthorizerLambda::handleRequest"
  runtime          = "java21"
  publish          = true  # Obrigatório para SnapStart e versionamento

  snap_start {
    apply_on = "PublishedVersions"
  }

  depends_on = [aws_api_gateway_rest_api.petstore_api]

  tracing_config {
    mode = "Active"
  }


  provider = aws.primary
}

resource "aws_lambda_alias" "snapstart_alias" {
  name             = var.alias_name_lambda_authorizer
  function_name    = aws_lambda_function.token_authorizer_lambda.function_name
  function_version = aws_lambda_function.token_authorizer_lambda.version
  description      = "Alias apontando para versão com SnapStart"
}

resource "aws_iam_role_policy_attachment" "lambda_xray" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSXRayDaemonWriteAccess"
}

resource "aws_lambda_permission" "api_gateway_token_authorizer_lambda_invoke" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  qualifier = aws_lambda_alias.snapstart_alias.name
  function_name = aws_lambda_alias.snapstart_alias.function_name
  principal     = "apigateway.amazonaws.com"
  // The following source_arn should be adjusted to match your API Gateway ARN structure
  source_arn    = "${aws_api_gateway_rest_api.petstore_api.execution_arn}/*/*"

  provider = aws.primary
}