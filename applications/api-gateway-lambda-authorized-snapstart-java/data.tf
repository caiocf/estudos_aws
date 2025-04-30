data "aws_caller_identity" "current" {}

data "template_file" "openapi_petstore" {
  template = file("${path.module}/openapi_3/openapi-petstore.yaml")

  vars = {
    lambda_get_pets_arn = aws_lambda_function.lambda_get_pets.invoke_arn
    lambda_authorizer_arn = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/arn:aws:lambda:${var.region}:${local.account_id}:function:${var.name_token_authorizer_lambda}:${var.alias_name_lambda_authorizer}/invocations"
  }
}
