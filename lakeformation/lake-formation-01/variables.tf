variable "aws_region" {
  description = "AWS Region where resources will be created"
  type        = string
  default     = "us-east-1"
}

variable "bucket_name" {
  description = "S3 bucket name for Data Lake"
  type        = string
  default     = "meu-glue-lake-02"
}

variable "database_name" {
  description = "Glue Catalog database name"
  type        = string
  default     = "meu-database"
}

variable "iam_user_name" {
  description = "IAM user name for Lake Formation admin"
  type        = string
  default     = "aws-user"
}

variable "existing_admin_user" {
  description = "Existing IAM user to grant Lake Formation permissions"
  type        = string
  default     = "usuario"
}

variable "workgroup_name" {
  description = "Athena workgroup name"
  type        = string
  default     = "meu-workgroup"
}
