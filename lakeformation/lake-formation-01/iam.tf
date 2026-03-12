# IAM User para administração do Lake Formation
resource "aws_iam_user" "aws_user" {
  name = var.iam_user_name

  tags = {
    Name        = "Lake Formation Admin User"
    Environment = "Development"
    ManagedBy   = "Terraform"
  }
}
