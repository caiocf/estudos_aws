module "s3_bucket_x_account" {
  source = "../../modules/x-account"
  name = "meubucketxaccount"
  name_suffix = var.env
  s3_data_classification = "Interna"
  cross_account_policy = var.cross_account_policy
}