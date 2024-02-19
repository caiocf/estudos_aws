resource "random_id" "id" {
  byte_length = 8
}

resource "aws_dms_replication_subnet_group" "replication-subnet-group" {
  replication_subnet_group_description = "Replication subnet group for ${var.application}"
  replication_subnet_group_id          = lower("dms-subnet-group-${var.application}")
  subnet_ids                           = var.dms_vpc_subnet_ids

  tags = local.tags
}

resource "aws_dms_replication_instance" "replication-instance" {
  depends_on = [aws_dms_replication_subnet_group.replication-subnet-group]

  allocated_storage = var.replication_instance_storage
  apply_immediately = true
  auto_minor_version_upgrade = true
  engine_version = var.replication_instance_version
  multi_az = false
  publicly_accessible = false
  kms_key_arn                      = aws_kms_key.dms_kms_key.arn
  replication_instance_class = var.replication_instance_class
  replication_instance_id    = "dms-replication-instance-tf-${var.application}"
  replication_subnet_group_id = aws_dms_replication_subnet_group.replication-subnet-group.id
  vpc_security_group_ids = var.dms_vpc_security_group_ids

  tags = local.tags
}

# Create a new source endpoint
resource "aws_dms_endpoint" "source" {
  endpoint_id   = "dms-source-endpoint-${var.application}"
  endpoint_type = "source"
  engine_name   = var.source_database_engine
  extra_connection_attributes = var.source_database_extra_connection_attributes
  server_name = var.source_database_host
  database_name = var.source_database_name
  username = var.source_database_username
  password = var.source_database_password
  port = var.source_database_port

  tags = local.tags
}

resource "random_string" "bucket_suffix" {
  length  = 8
  special = false
  upper   = false
  numeric = true
}

# Create a new target endpoint
resource "aws_dms_endpoint" "target" {
  endpoint_id   = "dms-target-endpoint-${var.application}"
  endpoint_type = "target"
  engine_name   = var.target_database_engine
  extra_connection_attributes = var.target_database_extra_connection_attributes
  server_name = var.target_database_host
  database_name = var.target_database_name
  username = var.target_database_username
  password = var.target_database_password
  port = var.target_database_port

  dynamic "redshift_settings" {
    for_each = var.target_database_engine == "redshift" ? [1] : []
    content {
      service_access_role_arn = aws_iam_role.dms-access-for-endpoint.arn
      bucket_name             = aws_s3_bucket.redshift_logs.bucket
      encryption_mode         = "SSE_S3"
    }
  }
  tags = local.tags
}

resource "aws_s3_bucket" "redshift_logs" {
  bucket = "dms-redshift-bucket-upload-${random_string.bucket_suffix.result}"

  force_destroy = true
}

resource "aws_s3_bucket_policy" "redshift_logs_policy" {
  bucket = aws_s3_bucket.redshift_logs.id

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
          "s3:ListBucket"
        ],
        Resource = [
          "${aws_s3_bucket.redshift_logs.arn}/*",
          aws_s3_bucket.redshift_logs.arn
        ]
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
          "${aws_s3_bucket.redshift_logs.arn}/*",
          aws_s3_bucket.redshift_logs.arn
        ]
      }
    ]
  })
}


# Create a new application task
resource "aws_dms_replication_task" "replication-task" {
  depends_on = [aws_dms_replication_instance.replication-instance,aws_dms_endpoint.source, aws_dms_endpoint.target]
  migration_type           = var.dms_task_migration_type
  replication_instance_arn = aws_dms_replication_instance.replication-instance.replication_instance_arn
  replication_task_id      = "dms-replication-task-${var.application}"

  source_endpoint_arn      = aws_dms_endpoint.source.endpoint_arn
  target_endpoint_arn      = aws_dms_endpoint.target.endpoint_arn

  table_mappings               = file("table-mappings.json") # Arquivo de mapeamento de tabelas
  replication_task_settings    = file("task-settings.json") # Arquivo de configurações da tarefa
  //table_mappings               = file("${path.module}/table-mappings.json") # Arquivo de mapeamento de tabelas
  //replication_task_settings    = file("${path.module}/task-settings.json") # Arquivo de configurações da tarefa

  tags = local.tags

}
