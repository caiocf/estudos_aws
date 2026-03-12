resource "aws_s3_bucket" "glue_lake" {
  bucket = var.bucket_name

  force_destroy = true

  tags = {
    Name        = "Data Lake Bucket"
    Environment = "Development"
    ManagedBy   = "Terraform"
  }
}

resource "aws_s3_object" "customers_csv" {
  bucket = aws_s3_bucket.glue_lake.id
  key    = "customers/customers.csv"
  source = "${path.module}/customers.csv"
  etag   = filemd5("${path.module}/customers.csv")

  tags = {
    Name      = "Customers Data"
    ManagedBy = "Terraform"
  }
}

resource "aws_s3_object" "athena_folder" {
  bucket = aws_s3_bucket.glue_lake.id
  key    = "athena/"

  tags = {
    Name      = "Athena Results Folder"
    ManagedBy = "Terraform"
  }
}

resource "aws_s3_object" "scripts_folder" {
  bucket = aws_s3_bucket.glue_lake.id
  key    = "scripts/"

  tags = {
    Name      = "Scripts Folder"
    ManagedBy = "Terraform"
  }
}
