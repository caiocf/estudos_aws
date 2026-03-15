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

variable "athena_results_bucket_name" {
  description = "S3 bucket name dedicated to Athena query results"
  type        = string
  default     = "meu-athena-workgroup-results-02"
}

variable "iam_user_name" {
  description = "IAM user name for minimal Athena access with column-level permissions"
  type        = string
  default     = "aws-user"
}

variable "iam_user_2_name" {
  description = "IAM user name for filtered Athena access"
  type        = string
  default     = "aws-user-2"
}

variable "iam_user_3_name" {
  description = "IAM user name with SELECT on all tables in the database"
  type        = string
  default     = "aws-user-3"
}

variable "workgroup_name" {
  description = "Athena workgroup name"
  type        = string
  default     = "meu-workgroup"
}
