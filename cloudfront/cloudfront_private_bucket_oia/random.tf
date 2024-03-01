resource "random_string" "bucket_suffix" {
  length  = 16
  special = false
  upper   = false
  numeric = true
}