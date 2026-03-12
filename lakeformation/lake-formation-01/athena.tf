# Athena Workgroup para execução de queries
resource "aws_athena_workgroup" "main" {
  name = var.workgroup_name

  configuration {
    result_configuration {
      output_location = "s3://${aws_s3_bucket.glue_lake.bucket}/athena/"
    }

    enforce_workgroup_configuration    = true
    publish_cloudwatch_metrics_enabled = true
  }

  force_destroy = true

  tags = {
    Name        = "Data Lake Workgroup"
    Environment = "Development"
    ManagedBy   = "Terraform"
  }
}
