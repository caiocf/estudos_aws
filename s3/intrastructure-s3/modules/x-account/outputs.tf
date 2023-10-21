output "s3_bucket_id" {
  description = "ID do Bucket"
  value =module.bucket_s3_x_account.s3_bucket_id
}

output "s3_bucket_arn" {
  description = "ARN do Bucket"
  value = module.bucket_s3_x_account.s3_bucket_arn
}