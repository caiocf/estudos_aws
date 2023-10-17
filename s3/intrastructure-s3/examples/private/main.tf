module "s3_bucket_private" {
  source = "../../modules/private"
  name = "meubucketxptyasdfasd"
  name_suffix = var.env
  s3_data_classification = "Interna"
}