variable "region" {
  description = "AWS Region"
  default     = "us-east-1"
}

variable "domain_to_resolve" {
  description = "Domain name to configure DNS forwarding for"
  default     = "example.com."
}
