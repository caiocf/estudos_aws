output "s3_bucket_id" {
  description = "Id do Bucket"
  value = aws_s3_bucket.bucket.id
}

output "s3_bucket_arn" {
  description = "ARN do Bucket"
  value = aws_s3_bucket.bucket.arn
}