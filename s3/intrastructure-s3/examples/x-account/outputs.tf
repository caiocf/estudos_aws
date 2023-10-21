output "s3_bucket_id" {
  description = "Id do Bucket"
  value = module.s3_bucket_x_account.s3_bucket_id
}

output "s3_bucket_arn" {
  description = "ARN do Bucket"
  value = module.s3_bucket_x_account.s3_bucket_arn
}