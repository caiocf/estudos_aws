output "arn_sqs_padrao" {
  value = aws_sqs_queue.my_queue.url
}

output "arn_sqs_dlq" {
  value = aws_sqs_queue.terraform_queue_deadletter.url
}