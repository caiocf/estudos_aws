output "arn_lambda_pets" {
  value = aws_lambda_function.lambda_get_pets.invoke_arn
}

output "url_api_gateway" {
  value = "${aws_api_gateway_deployment.petstore_deployment.invoke_url}${aws_api_gateway_stage.stage.stage_name}"
}

output "token_authorizer_lambda_arn" {
  value = aws_lambda_function.token_authorizer_lambda.arn
}