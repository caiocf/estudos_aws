resource "aws_cloudwatch_log_group" "api_gateway_logs" {
  name = "/aws/api_gateway/${aws_api_gateway_rest_api.petstore_api.name}-${var.ambiente_stage}"
  retention_in_days = 7

  provider = aws.primary
}


resource "aws_api_gateway_account" "gateway_account" {
  cloudwatch_role_arn = aws_iam_role.role_gateway_log.arn

  provider = aws.primary
}
