resource "aws_cloudwatch_log_group" "apigw_access" {
  provider          = aws.source
  name              = var.access_log_group_name
  retention_in_days = var.retention_in_days

  tags = merge(var.tags, {
    Name    = var.access_log_group_name
    Account = "source"
  })
}

resource "aws_apigatewayv2_api" "http_api" {
  provider      = aws.source
  name          = "${var.project_name}-http-api"
  protocol_type = "HTTP"

  tags = merge(var.tags, {
    Name    = "${var.project_name}-http-api"
    Account = "source"
  })
}

resource "aws_apigatewayv2_integration" "lambda_proxy" {
  provider               = aws.source
  api_id                 = aws_apigatewayv2_api.http_api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.hello_api.invoke_arn
  payload_format_version = "2.0"
  integration_method     = "POST"
}

resource "aws_apigatewayv2_route" "default_route" {
  provider  = aws.source
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "GET /hello"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_proxy.id}"
}

resource "aws_apigatewayv2_stage" "default" {
  provider    = aws.source
  api_id      = aws_apigatewayv2_api.http_api.id
  name        = var.source_stage_name
  auto_deploy = true

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.apigw_access.arn
    format = jsonencode({
      requestId          = "$context.requestId"
      extendedRequestId  = "$context.extendedRequestId"
      ip                 = "$context.identity.sourceIp"
      requestTime        = "$context.requestTime"
      httpMethod         = "$context.httpMethod"
      routeKey           = "$context.routeKey"
      status             = "$context.status"
      protocol           = "$context.protocol"
      responseLength     = "$context.responseLength"
      integrationError   = "$context.integrationErrorMessage"
    })
  }

  tags = merge(var.tags, {
    Name    = var.source_stage_name
    Account = "source"
  })
}

resource "aws_lambda_permission" "allow_apigw_invoke" {
  provider      = aws.source
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.hello_api.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.http_api.execution_arn}/*/*"
}

# The sending account principal that creates the subscription filter
# needs permission to reference the cross-account destination.
resource "aws_cloudwatch_log_subscription_filter" "to_destination" {
  provider        = aws.source
  name            = "send-apigw-access-logs-to-destination-account"
  log_group_name  = aws_cloudwatch_log_group.apigw_access.name
  filter_pattern  = var.subscription_filter_pattern
  destination_arn = aws_cloudwatch_log_destination.cross_account.arn

  depends_on = [
    aws_cloudwatch_log_destination_policy.allow_source_account
  ]
}
