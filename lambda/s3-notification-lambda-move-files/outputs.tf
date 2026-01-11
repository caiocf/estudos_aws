output "source_bucket" {
  value = aws_s3_bucket.source.bucket
}

output "destination_bucket" {
  value = aws_s3_bucket.destination.bucket
}

output "lambda_name" {
  value = aws_lambda_function.s3_move.function_name
}
