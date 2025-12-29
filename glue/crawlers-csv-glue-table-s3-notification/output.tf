output "bucket_name" {
  value = aws_s3_bucket.sor_bucket.bucket
}

output "queue_url" {
  value = aws_sqs_queue.s3_sqs_events.id
}

output "queue_arn" {
  value = aws_sqs_queue.s3_sqs_events.arn
}