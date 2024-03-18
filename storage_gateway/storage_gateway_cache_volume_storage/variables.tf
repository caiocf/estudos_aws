variable "region" {
  description = "AWS Regio.n"
  default     = "us-east-1"
}

variable "gateway_ip_address" {
  description = "IP address of the gateway"
  type        = string

  default = "172.28.57.207"

  validation {
    condition     = can(regex("^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$", var.gateway_ip_address))
    error_message = "The gateway IP address must be a valid IPv4 address."
  }
}


variable "disk_path_b" {
  description = "Disk path of the EBS volume used for cache"
  default = "/dev/sdb"
}

variable "disk_path_c" {
  description = "Disk path of the EBS volume used for cache"
  default = "/dev/sdc"
}
