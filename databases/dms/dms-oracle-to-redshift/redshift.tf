resource "aws_redshift_cluster" "default" {
  cluster_identifier          = "redshift-vendasdb-app"
  master_username             = "exampleuser"
  master_password             = "Mustbe8characters"
  node_type                   = "dc2.large"  # ou outro tipo de nó disponível
  cluster_type                = "single-node"
  database_name               = "vendasdb"
  encrypted                   = true
  number_of_nodes             = 1
  kms_key_id                  = aws_kms_key.dms_kms_key.arn
  cluster_subnet_group_name   = aws_redshift_subnet_group.subnet_redshift.name
  publicly_accessible         = false
  enhanced_vpc_routing        = true
  skip_final_snapshot         = false
  final_snapshot_identifier   = "redshift-vendasdb-app-snapshot"

  vpc_security_group_ids = [aws_security_group.dms_sg.id]


  automated_snapshot_retention_period = 1
  preferred_maintenance_window        = "Mon:00:30-Mon:01:00"
  logging {
    enable = true
    bucket_name = module.s3_logs.s3_bucket_id //aws_s3_bucket.redshift_s3_bucket.bucket
    s3_key_prefix = "redshift/"
  }
}


resource "aws_redshift_subnet_group" "subnet_redshift" {
  name       = "my-redshift-subnet-group"
  subnet_ids = [module.criar_vpcA_regiao1.subnet_a_id,module.criar_vpcA_regiao1.subnet_b_id,module.criar_vpcA_regiao1.subnet_c_id]

  tags = {
    Name = "My Redshift Subnet Group"
  }
}


module "s3_logs" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "~> 3.0"

  bucket = "meu-redshift-bucket-${random_string.bucket_suffix.result}"
  acl           = "log-delivery-write"

  control_object_ownership = true
  object_ownership         = "ObjectWriter"

  attach_policy = true
  policy        = data.aws_iam_policy_document.s3_redshift.json

  attach_deny_insecure_transport_policy = true
  force_destroy                         = true
}


resource "random_string" "bucket_suffix" {
  length  = 8
  special = false
  upper   = false
  numeric = true
}

data "aws_iam_policy_document" "s3_redshift" {
  statement {
    sid       = "RedshiftAcl"
    actions   = ["s3:GetBucketAcl"]
    resources = [module.s3_logs.s3_bucket_arn]

    principals {
      type        = "Service"
      identifiers = ["redshift.amazonaws.com"]
    }
  }

  statement {
    sid       = "RedshiftWrite"
    actions   = ["s3:PutObject"]
    resources = ["${module.s3_logs.s3_bucket_arn}/*"]
    condition {
      test     = "StringEquals"
      values   = ["bucket-owner-full-control"]
      variable = "s3:x-amz-acl"
    }

    principals {
      type        = "Service"
      identifiers = ["redshift.amazonaws.com"]
    }
  }
}
