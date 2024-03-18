data "aws_caller_identity" "current" {}

data "aws_storagegateway_local_disk" "sgw_disk_b" {
  depends_on = [aws_storagegateway_gateway.storage-gateway]
  disk_path   = var.disk_path_b
  gateway_arn = aws_storagegateway_gateway.storage-gateway.arn
  provider    = aws.primary
}

data "aws_storagegateway_local_disk" "sgw_disk_c" {
  depends_on = [aws_storagegateway_gateway.storage-gateway]
  disk_path   = var.disk_path_c
  gateway_arn = aws_storagegateway_gateway.storage-gateway.arn
  provider    = aws.primary
}