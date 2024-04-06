resource "aws_api_gateway_rest_api" "petstore_api" {
  name        = "PetstoreAPI"
  description = "This is a sample Pet Store Server based on the OpenAPI 3.0 specification"
  body        = data.template_file.openapi_petstore.rendered

  provider = aws.primary
}


resource "aws_api_gateway_stage" "stage" {
  deployment_id = aws_api_gateway_deployment.petstore_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.petstore_api.id
  stage_name    = var.ambiente_stage

  xray_tracing_enabled = true

  provider = aws.primary
}

resource "aws_api_gateway_method_settings" "example" {
  rest_api_id = aws_api_gateway_rest_api.petstore_api.id
  stage_name  = aws_api_gateway_stage.stage.stage_name
  method_path = "*/*"

  provider = aws.primary

  settings {
    metrics_enabled = true
    logging_level   = "INFO"
    data_trace_enabled = true
  }
}


resource "aws_api_gateway_deployment" "petstore_deployment" {
  rest_api_id = aws_api_gateway_rest_api.petstore_api.id

  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.petstore_api.body))
  }

  lifecycle {
    create_before_destroy = true
  }

  provider = aws.primary
}

/*resource "aws_api_gateway_authorizer" "token_authorizer" {
  #depends_on = [aws_api_gateway_rest_api.petstore_api, aws_lambda_function.token_authorizer_lambda]
  name                   = "token-authorizer"
  rest_api_id            = aws_api_gateway_rest_api.petstore_api.id
  type                   = "TOKEN"
  authorizer_uri         =  aws_lambda_function.token_authorizer_lambda.invoke_arn

  identity_source = "method.request.header.authorizationToken"  # Defina a origem da identidade como o cabeçalho Authorization

  authorizer_result_ttl_in_seconds = 0
  provider = aws.primary
}*/


resource "aws_lambda_permission" "api_gateway_gets_pets_invoke" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_get_pets.function_name
  principal     = "apigateway.amazonaws.com"
  // The following source_arn should be adjusted to match your API Gateway ARN structure
  source_arn    = "${aws_api_gateway_rest_api.petstore_api.execution_arn}/*/*"

  provider = aws.primary
}
