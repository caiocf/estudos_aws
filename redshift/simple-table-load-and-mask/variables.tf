variable "aws_region" {
  description = "AWS Region para provisionar os recursos"
  type        = string
  default     = "us-east-1"
}

variable "redshift_node_type" {
  description = "Tipo de nó do cluster Redshift"
  type        = string
  default     = "ra3.large"
}