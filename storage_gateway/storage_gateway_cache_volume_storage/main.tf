resource "aws_storagegateway_gateway" "storage-gateway" {
  gateway_ip_address = var.gateway_ip_address
  gateway_name       = "gateway_dados"
  gateway_timezone   = "GMT-3:00"
  gateway_type       = "CACHED" // STORED ou CACHED

  provider = aws.primary

  lifecycle {
    ignore_changes = [gateway_ip_address]
  }

  tags = {
    Storage="Storage_Brazil",
    Type="LocalStorage"
  }
}


resource "aws_storagegateway_cache" "this_cache" {
  disk_id     = data.aws_storagegateway_local_disk.sgw_disk_b.disk_id
  gateway_arn = aws_storagegateway_gateway.storage-gateway.arn

  provider = aws.primary

  lifecycle {
    ignore_changes = [
      disk_id
    ]
  }
}

resource "aws_storagegateway_upload_buffer" "this_upload" {
  disk_id     = data.aws_storagegateway_local_disk.sgw_disk_c.disk_id
  gateway_arn = aws_storagegateway_gateway.storage-gateway.arn

  provider = aws.primary

  lifecycle {
    ignore_changes = [
      disk_id
    ]
  }
}


resource "aws_storagegateway_cached_iscsi_volume" "this_iscsi_volume" {
  depends_on = [aws_storagegateway_gateway.storage-gateway]

  gateway_arn          = aws_storagegateway_gateway.storage-gateway.arn
  network_interface_id = var.gateway_ip_address
  target_name          = "target"
  volume_size_in_bytes = 10 * 1024 * 1024 * 1024 # 150 GB

   # Configuração CHAP
  chap_enabled         = false
/*  chap_in_initiator_secret = "yourinitisecret"  # Senha para o iniciador se conectar
  chap_in_target_secret   = "yourtargetsecret"      # Senha para o alvo se autenticar ao iniciador
  chap_in_initiator_name  = "yourinitiatorname"     # Nome do iniciador CHAP*/

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


