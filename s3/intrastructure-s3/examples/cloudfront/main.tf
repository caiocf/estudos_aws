module "s3_bucket_private" {
  source = "../../modules/cloudfront"
  name = "meucloudfrontabafasf"
  name_suffix = var.env
  s3_data_classification = "Interna"
}


resource "aws_s3_bucket_cors_configuration" "cors" {
  bucket = module.s3_bucket_private.s3_bucket_id

  cors_rule {
    allowed_headers = []
    allowed_methods = ["GET"]
    allowed_origins = ["*"]
    expose_headers = []
    max_age_seconds = 0
  }
}