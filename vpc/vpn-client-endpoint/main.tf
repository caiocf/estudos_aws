
locals {
  split_tunnel = false
  auth_destinations = toset(
      local.split_tunnel
      ? [ data.aws_vpc.default.cidr_block ]                                # só VPC (túnel dividido)
      : [ data.aws_vpc.default.cidr_block, "0.0.0.0/0" ]                    # VPC + Internet (túnel cheio)
  )
}

resource "aws_security_group" "sg_vpn" {

  vpc_id = data.aws_vpc.default.id
  description = "SG_VPN"
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"          # "-1" representa todos os protocolos
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name="SG_VPN"
  }

}


resource "aws_acm_certificate" "vpn_server_cert" {
  private_key      = file("${path.module}/custom_folder/server.key")
  certificate_body = file("${path.module}/custom_folder/server.crt")
  certificate_chain = file("${path.module}/custom_folder/ca.crt")

}



resource "aws_acm_certificate" "client_certificate" {
  private_key      = file("${path.module}/custom_folder/client1.domain.tld.key")
  certificate_body = file("${path.module}/custom_folder/client1.domain.tld.crt")
  certificate_chain = file("${path.module}/custom_folder/ca.crt")

}


resource "aws_ec2_client_vpn_endpoint" "client_vpn" {
  depends_on = [ aws_acm_certificate.client_certificate]

  server_certificate_arn = aws_acm_certificate.vpn_server_cert.arn
  client_cidr_block      = "10.0.0.0/16" # Defina a faixa de IP para os clientes

  authentication_options {
    type                       = "certificate-authentication"
    root_certificate_chain_arn =  aws_acm_certificate.client_certificate.arn
  }

  connection_log_options {
    enabled = false
  }

  client_login_banner_options {
    banner_text = "Todo sua navegacao é monitorado e qualquer uso indevido sera penalizado!"
    enabled = true
  }

  split_tunnel = local.split_tunnel
  security_group_ids = [aws_security_group.sg_vpn.id]
  vpc_id = data.aws_vpc.default.id

}

/*
resource "aws_ec2_client_vpn_authorization_rule" "authorization_cidr_vpc" {
  depends_on = [ aws_ec2_client_vpn_endpoint.client_vpn]

  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.client_vpn.id
  target_network_cidr    = "0.0.0.0/0" # Rede que os clientes podem acessar
  authorize_all_groups   = true

}

resource "aws_ec2_client_vpn_authorization_rule" "authorization_internet" {
  depends_on = [ aws_ec2_client_vpn_endpoint.client_vpn]

  count = aws_ec2_client_vpn_endpoint.client_vpn.split_tunnel ? 0 : 1
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.client_vpn.id
  target_network_cidr    = "0.0.0.0/0" # Passa tudo pela VPN e pelo nat gateway
  authorize_all_groups   = true

}
*/

resource "aws_ec2_client_vpn_authorization_rule" "auth" {
  for_each               = local.auth_destinations
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.client_vpn.id
  target_network_cidr    = each.key
  authorize_all_groups   = true
}

## Associao subnets
resource "aws_ec2_client_vpn_network_association" "network_association_subnet_a" {
  depends_on = [ aws_ec2_client_vpn_endpoint.client_vpn]

  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.client_vpn.id
  subnet_id              = data.aws_subnet.a.id

}

resource "aws_ec2_client_vpn_network_association" "network_association_subnet_b" {
  depends_on = [ aws_ec2_client_vpn_endpoint.client_vpn]

  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.client_vpn.id
  subnet_id              = data.aws_subnet.b.id

}

resource "aws_ec2_client_vpn_network_association" "network_association_subnet_c" {
  depends_on = [ aws_ec2_client_vpn_endpoint.client_vpn]

  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.client_vpn.id
  subnet_id              = data.aws_subnet.c.id

}

## rota para internet
resource "aws_ec2_client_vpn_route" "route_a" {
  depends_on = [ aws_ec2_client_vpn_endpoint.client_vpn]
  count                  = local.split_tunnel ? 0 : 1

  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.client_vpn.id
  destination_cidr_block = "0.0.0.0/0"
  target_vpc_subnet_id   = data.aws_subnet.a.id # Substitua pelo ID da sua sub-rede

}

resource "aws_ec2_client_vpn_route" "route_b" {
  depends_on = [ aws_ec2_client_vpn_endpoint.client_vpn]
  count                  = local.split_tunnel ? 0 : 1

  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.client_vpn.id
  destination_cidr_block = "0.0.0.0/0"
  target_vpc_subnet_id   = data.aws_subnet.b.id # Substitua pelo ID da sua sub-rede

}

resource "aws_ec2_client_vpn_route" "route_c" {
  depends_on = [ aws_ec2_client_vpn_endpoint.client_vpn]
  count                  = local.split_tunnel ? 0 : 1

  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.client_vpn.id
  destination_cidr_block = "0.0.0.0/0"
  target_vpc_subnet_id   = data.aws_subnet.c.id # Substitua pelo ID da sua sub-rede

}



resource "null_resource" "export-client-config" {
  provisioner "local-exec" {
    command = "aws --region ${var.region} ec2 export-client-vpn-client-configuration --client-vpn-endpoint-id ${aws_ec2_client_vpn_endpoint.client_vpn.id} --output text > client-config.ovpn && sh update_vpn_config.sh client-config.ovpn"
  }
  # Trigger que muda a cada apply
  triggers = {
    always_run = "${timestamp()}"
  }
  depends_on = [
    aws_ec2_client_vpn_endpoint.client_vpn,
    aws_ec2_client_vpn_network_association.network_association_subnet_a,
    aws_ec2_client_vpn_network_association.network_association_subnet_b,
    aws_ec2_client_vpn_network_association.network_association_subnet_c
  ]
}



