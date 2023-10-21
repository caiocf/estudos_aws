module "bucket_s3_storage_gateway" {
  source = "../../modules/storage-gateway"
  name = "meubucketxptyasdfasd-storage"
  name_suffix = var.env
  s3_data_classification = "Interna"
}

module "iam_trust_iam_storage_s3" {
  depends_on = [module.bucket_s3_storage_gateway]

  source = "../../../../iam/s3_trust_vault_iam"
  arn_bucket = module.bucket_s3_storage_gateway.s3_bucket_arn
  role_name = "minharoledeacesso"
  user_name = "caiocf"
}