module "s3_bucket_private" {
  source = "../../modules/cloudfront"
  name = "meucloudfrontabafasf"
  name_suffix = var.env
  s3_data_classification = "Interna"
}