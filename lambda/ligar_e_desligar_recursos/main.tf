resource "aws_cloudwatch_event_rule" "shutdown_schedule" {
  name                = "shutdown_schedule"
  schedule_expression = "cron(0 18 * * ? *)"
}

resource "aws_cloudwatch_event_rule" "start_schedule" {
  name                = "start_schedule"
  schedule_expression = "cron(0 8 * * ? *)"
}

resource "aws_cloudwatch_event_target" "shutdown_target" {
  rule = aws_cloudwatch_event_rule.shutdown_schedule.name
  arn  = aws_lambda_function.shutdown_lambda.arn
}

resource "aws_cloudwatch_event_target" "start_target" {
  rule = aws_cloudwatch_event_rule.start_schedule.name
  arn  = aws_lambda_function.start_lambda.arn
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_shutdown" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.shutdown_lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.shutdown_schedule.arn
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_start" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.start_lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.start_schedule.arn
}
