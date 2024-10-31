variable "aws_region" {
  default = "us-east-1"
}

variable "trusted_account_id" {
  description = "ID da conta que poderá assumir a role"
  type        = string
}