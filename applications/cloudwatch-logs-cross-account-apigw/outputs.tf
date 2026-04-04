output "api_invoke_url" {
  description = "Invoke URL of the HTTP API."
  value       = aws_apigatewayv2_stage.default.invoke_url
}

output "api_test_route" {
  description = "Helpful URL to trigger access logs."
  value       = "${aws_apigatewayv2_stage.default.invoke_url}/hello"
}

output "source_log_group_name" {
  description = "Access log group in the source account."
  value       = aws_cloudwatch_log_group.apigw_access.name
}

output "destination_stream_name" {
  description = "Kinesis Data Stream receiving the logs in the destination account."
  value       = aws_kinesis_stream.apigw_logs.name
}

output "destination_stream_arn" {
  description = "Kinesis Data Stream ARN."
  value       = aws_kinesis_stream.apigw_logs.arn
}

output "cross_account_destination_arn" {
  description = "CloudWatch Logs Destination ARN used by the subscription filter."
  value       = aws_cloudwatch_log_destination.cross_account.arn
}

output "cwl_assume_role_arn" {
  description = "IAM role assumed by CloudWatch Logs in the destination account."
  value       = aws_iam_role.cwl_to_kinesis.arn
}
