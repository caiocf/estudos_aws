# Bucket dedicado para os resultados do Athena.
resource "aws_s3_bucket" "athena_results" {
  bucket = var.athena_results_bucket_name

  force_destroy = true

  tags = {
    Name        = "Athena Results Bucket"
    Environment = "Development"
    ManagedBy   = "Terraform"
  }
}

resource "aws_s3_object" "athena_results_folder" {
  bucket = aws_s3_bucket.athena_results.id
  key    = "${var.workgroup_name}/"

  tags = {
    Name      = "Athena Workgroup Results Folder"
    ManagedBy = "Terraform"
  }
}

# Workgroup customizado do Athena para gravar resultados
# apenas no bucket dedicado.
resource "aws_athena_workgroup" "main" {
  name = var.workgroup_name

  configuration {
    result_configuration {
      output_location = "s3://${aws_s3_bucket.athena_results.bucket}/${var.workgroup_name}/"
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
