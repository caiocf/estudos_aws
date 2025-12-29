resource "aws_sqs_queue" "s3_sqs_events" {
  name                      = "s3-events-standard"
  delay_seconds             = 0
  max_message_size          = 2048
  message_retention_seconds = 86400
  receive_wait_time_seconds = 0

  tags = {
    Name = "Ccsv-queue"
  }
}


resource "aws_sqs_queue_policy" "s3_events_policy" {
  queue_url = aws_sqs_queue.s3_sqs_events.id
  policy    = data.aws_iam_policy_document.allow_s3_sendmessage.json
}