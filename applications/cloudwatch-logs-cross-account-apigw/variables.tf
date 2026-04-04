variable "project_name" {
  description = "Prefix used in resource names."
  type        = string
  default     = "study-apigw-cross-account-logs"
}

variable "region" {
  description = "AWS region used in both accounts."
  type        = string
  default     = "us-east-1"
}

variable "source_profile" {
  description = "AWS CLI profile for the source account."
  type        = string
}

variable "destination_profile" {
  description = "AWS CLI profile for the destination account."
  type        = string
}

variable "source_account_id" {
  description = "AWS account ID of the source account."
  type        = string
}

variable "destination_account_id" {
  description = "AWS account ID of the destination account."
  type        = string
}

variable "source_stage_name" {
  description = "API Gateway stage name in the source account."
  type        = string
  default     = "$default"
}

variable "stream_name" {
  description = "Kinesis Data Stream name in the destination account."
  type        = string
  default     = "central-apigw-access-logs"
}

variable "destination_name" {
  description = "CloudWatch Logs Destination name in the destination account."
  type        = string
  default     = "central-apigw-access-logs-destination"
}

variable "access_log_group_name" {
  description = "CloudWatch Logs log group that stores API Gateway access logs in the source account."
  type        = string
  default     = "/aws/apigateway/study-http-api/access"
}

variable "retention_in_days" {
  description = "Retention period for the API Gateway access log group."
  type        = number
  default     = 7
}

variable "subscription_filter_pattern" {
  description = "CloudWatch Logs filter pattern. Empty string forwards every log event."
  type        = string
  default     = ""
}

variable "tags" {
  description = "Common tags to apply to resources."
  type        = map(string)
  default = {
    Project = "study-apigw-cross-account-logs"
    Owner   = "github-study-repo"
    Purpose = "academic"
  }
}
