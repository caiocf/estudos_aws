# AWS KMS Key
resource "aws_kms_key" "dms_kms_key" {
  description             = "KMS Key for DMS encryption"
  deletion_window_in_days = 10
  policy                  = <<POLICY
{
  "Version": "2012-10-17",
  "Id": "key-default-1",
  "Statement": [
    {
      "Sid": "Enable IAM User Permissions",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
      },
      "Action": "kms:*",
      "Resource": "*"
    }
  ]
}
POLICY
}


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
  skip_final_snapshot         = true
  #final_snapshot_identifier   = "redshift-vendasdb-app-snapshot-${random_string.bucket_suffix.result}"

  vpc_security_group_ids = [aws_security_group.dms_sg.id]


  automated_snapshot_retention_period = 1
  preferred_maintenance_window        = "Mon:00:30-Mon:01:00"
  logging {
    enable = true
    //bucket_name = aws_s3_bucket.redshift_logs.bucket //aws_s3_bucket.redshift_s3_bucket.bucket
    bucket_name = aws_s3_bucket.redshift_logs.bucket //aws_s3_bucket.redshift_s3_bucket.bucket
  }

  //iam_roles = [aws_iam_role.redshift_s3_access.arn]
}


resource "aws_redshift_subnet_group" "subnet_redshift" {
  name       = "my-redshift-subnet-group"
  subnet_ids = [module.criar_vpcA_regiao1.subnet_a_id,module.criar_vpcA_regiao1.subnet_b_id,module.criar_vpcA_regiao1.subnet_c_id]

  tags = {
    Name = "My Redshift Subnet Group"
  }
}


resource "aws_s3_bucket" "redshift_logs" {
  bucket = "dms-redshift-logs-${random_string.bucket_suffix.result}"
  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "log_bucket_public_access_block" {
  bucket = aws_s3_bucket.redshift_logs.id

  block_public_acls   = true
  block_public_policy = true
  ignore_public_acls  = true
  restrict_public_buckets = true
}


resource "aws_s3_bucket_policy" "redshift_logs_policy" {
  bucket = aws_s3_bucket.redshift_logs.id

  //policy = data.aws_iam_policy_document.s3_redshift.json
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "redshift.amazonaws.com"
        },
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket",
          "s3:PutBucketPolicy",
          "s3:GetBucketAcl"
        ],
        Resource = [
          "${aws_s3_bucket.redshift_logs.arn}/*",
          aws_s3_bucket.redshift_logs.arn
        ]
      },
      {
        Effect    = "Allow",
        Principal = {"Service": "delivery.logs.amazonaws.com"},
        Action    = ["s3:PutObject"],
        Resource  = "${aws_s3_bucket.redshift_logs.arn}/*",
        Condition = {
          StringEquals = {"s3:x-amz-acl": "bucket-owner-full-control"}
        }
      }/*,
      {
        Effect = "Allow",
        Principal = {"Service": "cloudfront.amazonaws.com"},
        Action = ["s3:GetBucketAcl", "s3:PutObject"],
        Resource = [
          aws_s3_bucket.redshift_logs.arn,
          "${aws_s3_bucket.redshift_logs.arn}*//*"
        ],
        Condition = {
          StringEquals = {"s3:x-amz-acl": "bucket-owner-full-control"}
        }
      },
      {
        "Effect": "Allow",
        "Principal": {
          "Service": "dms.amazonaws.com"
        },
        "Action": [
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket"
        ],
        Resource = [
          "${aws_s3_bucket.redshift_logs.arn}*//*",
          aws_s3_bucket.redshift_logs.arn
        ]
      }*/
    ]
  })
}

/*
module "s3_logs" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "~> 3.0"

  bucket = "dms-redshift-bucket-${random_string.bucket_suffix.result}"
  acl           = "log-delivery-write"

  control_object_ownership = true
  object_ownership         = "ObjectWriter"

  attach_policy = true
  policy        = data.aws_iam_policy_document.s3_redshift.json

  attach_deny_insecure_transport_policy = true
  force_destroy                         = true
}
*/


resource "random_string" "bucket_suffix" {
  length  = 8
  special = false
  upper   = false
  numeric = true
}

resource "aws_iam_role" "redshift_s3_access" {
  name = "RedshiftS3AccessRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "redshift.amazonaws.com"
        }
      }/*,
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "dms.amazonaws.com"
        }
      },*/
    ]
  })
}

data "aws_iam_policy_document" "s3_redshift" {
  statement {
    sid       = "RedshiftAcl"
    actions   = ["s3:GetBucketAcl"]
    resources = ["${aws_s3_bucket.redshift_logs.arn}/*"]

    principals {
      type        = "Service"
      identifiers = ["redshift.amazonaws.com"]
    }
  }

  statement {
    sid       = "RedshiftWrite"
    actions   = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.redshift_logs.arn}/*"]
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


resource "aws_iam_role_policy_attachment" "redshift_s3_access_policy_attachment" {
  role       = aws_iam_role.redshift_s3_access.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_role_policy_attachment" "dms-access-for-endpoint-AmazonDMSRedshiftS3Role" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonDMSRedshiftS3Role"
  role       = aws_iam_role.redshift_s3_access.name
}

/*
resource "aws_iam_role_policy_attachment" "dms-access-for-endpoint-AmazonRedshiftAllCommandsFullAccess" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonRedshiftAllCommandsFullAccess"
  role       = aws_iam_role.redshift_s3_access.name
}
*/

