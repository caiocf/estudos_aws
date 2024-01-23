module "s3_logs" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "~> 3.0"

  bucket = var.logging.bucket_name
  acl           = "log-delivery-write"

  control_object_ownership = true
  object_ownership         = "ObjectWriter"

  attach_policy = true
  policy        = data.aws_iam_policy_document.s3_redshift.json

  attach_deny_insecure_transport_policy = true
  force_destroy                         = true

  tags = local.tags
}

