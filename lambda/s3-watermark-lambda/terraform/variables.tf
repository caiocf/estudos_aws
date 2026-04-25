variable "aws_region" {
  description = "AWS region for all resources."
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project prefix for resource naming."
  type        = string
  default     = "s3-watermark-demo"
}

variable "environment" {
  description = "Environment tag."
  type        = string
  default     = "study"
}

variable "bucket_name" {
  description = "Optional custom bucket name. Leave empty to generate one."
  type        = string
  default     = ""
}

variable "source_prefix" {
  description = "Prefix monitored for uploads."
  type        = string
  default     = "uploads"
}

variable "destination_prefix" {
  description = "Prefix where watermarked files are written."
  type        = string
  default     = "watermarked"
}

variable "watermark_text" {
  description = "Watermark text to stamp on images."
  type        = string
  default     = "CONFIDENTIAL"
}

variable "watermark_opacity" {
  description = "Watermark text opacity, 0-255."
  type        = number
  default     = 90
}

variable "output_format" {
  description = "ORIGINAL, JPEG, PNG or WEBP."
  type        = string
  default     = "ORIGINAL"
}

variable "lambda_runtime" {
  description = "Lambda runtime."
  type        = string
  default     = "python3.12"
}

variable "lambda_timeout_seconds" {
  description = "Lambda timeout in seconds."
  type        = number
  default     = 30
}

variable "lambda_memory_mb" {
  description = "Lambda memory size in MB."
  type        = number
  default     = 512
}

variable "log_retention_in_days" {
  description = "CloudWatch Logs retention."
  type        = number
  default     = 14
}

variable "tags" {
  description = "Additional tags."
  type        = map(string)
  default     = {}
}
