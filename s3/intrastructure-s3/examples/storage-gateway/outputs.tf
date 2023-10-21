output "s3_bucket_id" {
  description = "Id do Bucket"
  value = module.bucket_s3_storage_gateway.s3_bucket_id
}

output "s3_bucket_arn" {
  description = "ARN do Bucket"
  value = module.bucket_s3_storage_gateway.s3_bucket_arn
}

output "arn_role" {
  value = module.iam_trust_iam_storage_s3.arn_role
}