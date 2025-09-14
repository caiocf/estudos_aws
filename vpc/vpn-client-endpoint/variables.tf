variable "region" {
  description = "AWS Region"
  default     = "us-east-1"
}


variable "config_dir" {
  type        = string
  description = "Local storage location for downloaded VPN config. Relative to module root."
  default     = "config"
}