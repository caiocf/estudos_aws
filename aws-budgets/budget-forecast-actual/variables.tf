variable "aws_region" {
  type    = string
  default = "us-east-1"
}


variable "budget_name" {
  type    = string
  default = "Budget-cost"
}

variable "budget_amount_usd" {
  type    = string
  default = "10"
}

variable "subscriber_emails" {
  type    = list(string)
  default = ["email@hotmail.com"]
}