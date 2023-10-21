output "arn_role" {
  description = "ARN da role"
  value = aws_iam_role.s3_storage_role.arn
}

output "name_role" {
  description = "Nome da role"
  value = aws_iam_role.s3_storage_role.name
}