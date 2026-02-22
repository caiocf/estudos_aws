locals {
  passwordMaster8Character = "A${random_string.passwordRedshift.result}1a"
}

# AWS KMS Key
resource "aws_kms_key" "redshift_kms_key" {
  description             = "KMS Key for Redshift encryption"
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
  master_username             = "usuario"
  master_password             = local.passwordMaster8Character
  node_type                   = var.redshift_node_type # "ra3.large"  ou outro tipo de nó disponível
  cluster_type                = "single-node"
  database_name               = "vendasdb"
  encrypted                   = true
  number_of_nodes             = 1
  kms_key_id                  = aws_kms_key.redshift_kms_key.arn
  cluster_subnet_group_name   = aws_redshift_subnet_group.subnet_redshift.name
  publicly_accessible         = false
  enhanced_vpc_routing        = false
  skip_final_snapshot         = true

  vpc_security_group_ids = [aws_security_group.redshift_sg.id]

  iam_roles      = [aws_iam_role.redshift_s3_role.arn]
  automated_snapshot_retention_period = 1
  preferred_maintenance_window        = "Mon:00:30-Mon:01:00"

}

resource "aws_redshift_logging" "example" {
  cluster_identifier = aws_redshift_cluster.default.id
  bucket_name        = aws_s3_bucket.redshift_logs.id
  s3_key_prefix      = "redshift-logs/"
}

resource "aws_redshift_subnet_group" "subnet_redshift" {
  name       = "my-redshift-subnet-group"
  subnet_ids = [data.aws_subnet.a.id,data.aws_subnet.b.id,data.aws_subnet.c.id]

  tags = {
    Name = "My Redshift Subnet Group"
  }
}


resource "random_string" "passwordRedshift" {
  length  = 8
  special = false
  upper   = true
  numeric = true
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

