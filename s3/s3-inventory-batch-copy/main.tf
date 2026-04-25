resource "random_id" "suffix" {
  byte_length = 4
}

locals {
  name_suffix           = "${var.project_name}-${random_id.suffix.hex}"
  source_bucket_name    = "${local.name_suffix}-source"
  dest_bucket_name      = "${local.name_suffix}-destination"
  inventory_bucket_name = "${local.name_suffix}-inventory"
  report_bucket_name    = "${local.name_suffix}-reports"

  inventory_prefix = "inventory"
  report_prefix    = "batch-reports"
}

# -----------------------------
# S3 buckets
# -----------------------------

resource "aws_s3_bucket" "source" {
  bucket        = local.source_bucket_name
  force_destroy = true
}

resource "aws_s3_bucket" "destination" {
  bucket        = local.dest_bucket_name
  force_destroy = true
}

resource "aws_s3_bucket" "inventory" {
  bucket        = local.inventory_bucket_name
  force_destroy = true
}

resource "aws_s3_bucket" "reports" {
  bucket        = local.report_bucket_name
  force_destroy = true
}

resource "aws_s3_bucket_versioning" "source" {
  bucket = aws_s3_bucket.source.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_versioning" "destination" {
  bucket = aws_s3_bucket.destination.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "all" {
  for_each = {
    source      = aws_s3_bucket.source.id
    destination = aws_s3_bucket.destination.id
    inventory   = aws_s3_bucket.inventory.id
    reports     = aws_s3_bucket.reports.id
  }

  bucket = each.value

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Sample objects for the demo.
resource "aws_s3_object" "sample" {
  count  = var.object_count
  bucket = aws_s3_bucket.source.id
  key    = "raw/events/sample-${count.index + 1}.json"

  content = jsonencode({
    id      = count.index + 1
    source  = "terraform-demo"
    message = "Object copied later by S3 Batch Operations"
  })

  content_type = "application/json"
}

# -----------------------------
# S3 Inventory
# -----------------------------
# S3 Inventory generates a manifest/list of existing objects.
# That manifest will be used as the input for S3 Batch Operations.

resource "aws_s3_bucket_inventory" "source_inventory" {
  bucket = aws_s3_bucket.source.id
  name   = "all-objects-inventory"

  included_object_versions = "Current"

  schedule {
    frequency = var.inventory_frequency
  }

  destination {
    bucket {
      format     = "CSV"
      bucket_arn = aws_s3_bucket.inventory.arn
      prefix     = local.inventory_prefix

      encryption {
        sse_s3 {}
      }
    }
  }

  optional_fields = [
    "Size",
    "LastModifiedDate",
    "StorageClass",
    "ETag"
  ]

  depends_on = [aws_s3_bucket_policy.inventory_destination]
}

# Allows Amazon S3 Inventory to write reports to the inventory bucket.
data "aws_iam_policy_document" "inventory_destination" {
  statement {
    sid    = "AllowS3InventoryDelivery"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }

    actions = [
      "s3:PutObject"
    ]

    resources = [
      "${aws_s3_bucket.inventory.arn}/${local.inventory_prefix}/*"
    ]

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }

    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values   = [aws_s3_bucket.source.arn]
    }
  }
}

resource "aws_s3_bucket_policy" "inventory_destination" {
  bucket = aws_s3_bucket.inventory.id
  policy = data.aws_iam_policy_document.inventory_destination.json
}

data "aws_caller_identity" "current" {}

# -----------------------------
# IAM role for S3 Batch Operations
# -----------------------------

data "aws_iam_policy_document" "batch_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["batchoperations.s3.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "s3_batch_operations" {
  name               = "${local.name_suffix}-s3-batch-role"
  assume_role_policy = data.aws_iam_policy_document.batch_assume_role.json
}

data "aws_iam_policy_document" "s3_batch_operations" {
  statement {
    sid    = "ReadSourceObjects"
    effect = "Allow"

    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:GetBucketLocation"
    ]

    resources = [
      aws_s3_bucket.source.arn,
      "${aws_s3_bucket.source.arn}/*"
    ]
  }

  statement {
    sid    = "WriteDestinationObjects"
    effect = "Allow"

    actions = [
      "s3:PutObject",
      "s3:PutObjectAcl",
      "s3:PutObjectTagging",
      "s3:GetBucketLocation"
    ]

    resources = [
      aws_s3_bucket.destination.arn,
      "${aws_s3_bucket.destination.arn}/*"
    ]
  }

  statement {
    sid    = "ReadInventoryManifest"
    effect = "Allow"

    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:GetBucketLocation"
    ]

    resources = [
      aws_s3_bucket.inventory.arn,
      "${aws_s3_bucket.inventory.arn}/*"
    ]
  }

  statement {
    sid    = "WriteCompletionReport"
    effect = "Allow"

    actions = [
      "s3:PutObject",
      "s3:GetBucketLocation"
    ]

    resources = [
      aws_s3_bucket.reports.arn,
      "${aws_s3_bucket.reports.arn}/*"
    ]
  }
}

resource "aws_iam_role_policy" "s3_batch_operations" {
  name   = "${local.name_suffix}-s3-batch-policy"
  role   = aws_iam_role.s3_batch_operations.id
  policy = data.aws_iam_policy_document.s3_batch_operations.json
}

# -----------------------------
# S3 Batch Operations job
# -----------------------------
# Important:
# S3 Inventory is not generated immediately. Wait until AWS creates the inventory
# manifest.json, then re-apply Terraform with:
#
# terraform apply \
#   -var="enable_batch_job=true" \
#   -var="inventory_manifest_key=<key-to-manifest.json>"
#
# Example manifest key:
# inventory/source-bucket/all-objects-inventory/2024-01-01T00-00Z/manifest.json

resource "aws_s3control_job" "copy_existing_objects" {
  count = var.enable_batch_job ? 1 : 0

  account_id = data.aws_caller_identity.current.account_id

  operation {
    s3_put_object_copy {
      target_resource = aws_s3_bucket.destination.arn
      # MetadataDirective COPY preserves source metadata.
      metadata_directive = "COPY"
    }
  }

  manifest {
    spec {
      format = "S3InventoryReport_CSV_20211130"

      fields = [
        "Bucket",
        "Key",
        "VersionId"
      ]
    }

    location {
      object_arn = "${aws_s3_bucket.inventory.arn}/${var.inventory_manifest_key}"
      etag       = data.aws_s3_object.inventory_manifest[0].etag
    }
  }

  report {
    bucket      = aws_s3_bucket.reports.arn
    format      = "Report_CSV_20180820"
    enabled     = true
    prefix      = local.report_prefix
    report_scope = "AllTasks"
  }

  priority = 10
  role_arn = aws_iam_role.s3_batch_operations.arn

  description = "One-time copy of existing S3 objects from source bucket to destination bucket using S3 Inventory manifest."
  confirmation_required = false

  depends_on = [aws_iam_role_policy.s3_batch_operations]
}

data "aws_s3_object" "inventory_manifest" {
  count  = var.enable_batch_job ? 1 : 0
  bucket = aws_s3_bucket.inventory.id
  key    = var.inventory_manifest_key
}
