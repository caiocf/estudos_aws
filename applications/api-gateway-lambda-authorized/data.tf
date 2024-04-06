data "template_file" "openapi_petstore" {
  template = file("${path.module}/openapi_3/openapi-petstore.yaml")

  vars = {
    lambda_get_pets_arn = aws_lambda_function.lambda_get_pets.invoke_arn
    //lambda_authorizer_arn = aws_iam_role.custom_gateway_invoke_authorizer_role.arn
    lambda_authorizer_arn = "arn:aws:apigateway:us-east-1:lambda:path/2015-03-31/functions/arn:aws:lambda:us-east-1:975049978641:function:token-authorizer-lambda/invocations" // aws_api_gateway_authorizer.token_authorizer.authorizer_uri
    region  = var.region
  }
}
