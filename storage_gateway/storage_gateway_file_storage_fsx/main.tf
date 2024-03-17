resource "aws_storagegateway_gateway" "storage-gateway" {
  gateway_ip_address = var.gateway_ip_address
  gateway_name       = "gateway_dados"
  gateway_timezone   = "GMT-3:00"
  gateway_type       = "FILE_S3"

  provider = aws.primary

  lifecycle {
    ignore_changes = [gateway_ip_address]
  }

  tags = {
    Storage="Storage_Brazil",
    Type="LocalStorage"
  }
}


resource "aws_storagegateway_cache" "this" {
  disk_id     = data.aws_storagegateway_local_disk.sgw_disk.disk_id
  gateway_arn = aws_storagegateway_gateway.storage-gateway.arn

  provider = aws.primary

  lifecycle {
    ignore_changes = [
      disk_id
    ]
  }
}


resource "aws_storagegateway_nfs_file_share" "nfs-file" {
  client_list  = ["0.0.0.0/0"]
  default_storage_class = "S3_STANDARD"


  file_share_name = "cloud_dados_storage_share"
  gateway_arn  = aws_storagegateway_gateway.storage-gateway.arn
  location_arn = aws_s3_bucket.bucket.arn
  role_arn     = aws_iam_role.gateway.arn

  squash = "NoSquash" # see https://forums.aws.amazon.com/thread.jspa?messageID=886347&tstart=0 and https://docs.aws.amazon.com/storagegateway/latest/userguide/managing-gateway-file.html#edit-nfs-client

  nfs_file_share_defaults {
    directory_mode = "0777"
    file_mode      = "0666"
    group_id       = "65534"
    owner_id       = "65534"
  }

  cache_attributes {
    cache_stale_timeout_in_seconds = "300" ## refresh cache from s3 to nf2 local
  }

  timeouts {
    create = "15m0s"
    delete = "15m0s"
  }

  provider = aws.primary
}

/*

##########################
## Create VPC Endpoint
##########################

data "aws_region" "current" {}

resource "aws_vpc_endpoint" "sgw_vpce" {

  for_each = var.create_vpc_endpoint ? toset(["sgw_vpce"]) : toset([])

  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${data.aws_region.current.name}.storagegateway"
  vpc_endpoint_type = "Interface"

  security_group_ids = [
    var.create_vpc_endpoint_security_group ? aws_security_group.vpce_sg["vpce_sg"].id : var.vpc_endpoint_security_group_id
  ]

  subnet_ids = var.vpc_endpoint_subnet_ids

  private_dns_enabled = var.vpc_endpoint_private_dns_enabled

  tags = {
    Name = "storage-gateway-endpoint"
  }

  lifecycle {
    # VPC Subnet IDs must be non empty
    precondition {
      condition     = try(length(var.vpc_endpoint_subnet_ids[0]) > 7, false)
      error_message = "Variable vpc_endpoint_subnet_ids must contain at least one valid subnet to create VPC Endpoint Security Group"
    }
  }

}
*/


