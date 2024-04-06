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

  provider = aws.primary

  xray_tracing_enabled = true
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


resource "aws_lambda_permission" "api_gateway_gets_pets_invoke" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_get_pets.function_name
  principal     = "apigateway.amazonaws.com"
  // The following source_arn should be adjusted to match your API Gateway ARN structure
  source_arn    = "${aws_api_gateway_rest_api.petstore_api.execution_arn}/*/*"
}

resource "aws_lambda_permission" "api_gateway_get_pet_invoke" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_get_pet.function_name
  principal     = "apigateway.amazonaws.com"
  // The following source_arn should be adjusted to match your API Gateway ARN structure
  source_arn    = "${aws_api_gateway_rest_api.petstore_api.execution_arn}/*/*"
}

resource "aws_lambda_permission" "api_gateway_create_pet_invoke" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_create_pet.function_name
  principal     = "apigateway.amazonaws.com"
  // The following source_arn should be adjusted to match your API Gateway ARN structure
  source_arn    = "${aws_api_gateway_rest_api.petstore_api.execution_arn}/*/*"
}

resource "aws_lambda_permission" "api_gateway_delete_pet_invoke" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_delete_pet.function_name
  principal     = "apigateway.amazonaws.com"
  // The following source_arn should be adjusted to match your API Gateway ARN structure
  source_arn    = "${aws_api_gateway_rest_api.petstore_api.execution_arn}/*/*"
}

