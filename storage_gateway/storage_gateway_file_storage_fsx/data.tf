data "aws_caller_identity" "current" {}

data "aws_storagegateway_local_disk" "sgw_disk" {

  disk_path   = var.disk_path
  gateway_arn = aws_storagegateway_gateway.storage-gateway.arn
  provider    = aws.primary
}