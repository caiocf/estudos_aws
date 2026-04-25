variable "aws_region" {
  description = "AWS Region where the buckets and Batch Operations job will be created."
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Prefix used to name resources."
  type        = string
  default     = "s3-inventory-batch-copy-demo"
}

variable "inventory_frequency" {
  description = "S3 Inventory frequency. Valid values: Daily or Weekly."
  type        = string
  default     = "Daily"

  validation {
    condition     = contains(["Daily", "Weekly"], var.inventory_frequency)
    error_message = "inventory_frequency must be Daily or Weekly."
  }
}

variable "object_count" {
  description = "Number of sample objects to create in the source bucket."
  type        = number
  default     = 3
}

variable "enable_batch_job" {
  description = "When true, Terraform creates the S3 Batch Operations job. Enable only after the Inventory manifest exists."
  type        = bool
  default     = false
}

variable "inventory_manifest_key" {
  description = "S3 key of the inventory manifest.json file. Required when enable_batch_job = true."
  type        = string
  default     = ""
}
