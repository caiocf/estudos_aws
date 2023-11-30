resource "aws_security_group" "sg_vpn" {
  depends_on = [ module.criar_vpcA_regiao1]

  vpc_id = module.criar_vpcA_regiao1.vpc_id
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
  private_key      = file("${path.module}/easy-rsa/easyrsa3/pki/private/server.key")
  certificate_body = file("${path.module}/easy-rsa/easyrsa3/pki/issued/server.crt")
  certificate_chain = file("${path.module}/easy-rsa/easyrsa3/pki/ca.crt")
}



resource "aws_acm_certificate" "client_certificate" {
  private_key      = file("${path.module}/easy-rsa/easyrsa3/pki/private/client1.domain.tld.key")
  certificate_body = file("${path.module}/easy-rsa/easyrsa3/pki/issued/client1.domain.tld.crt")
  certificate_chain = file("${path.module}/easy-rsa/easyrsa3/pki/ca.crt")
}


resource "aws_ec2_client_vpn_endpoint" "client_vpn" {
  depends_on = [ module.criar_vpcA_regiao1]

  server_certificate_arn = aws_acm_certificate.vpn_server_cert.arn
  client_cidr_block      = "10.0.0.0/16" # Defina a faixa de IP para os clientes

  authentication_options {
    type                       = "certificate-authentication"
    root_certificate_chain_arn = aws_acm_certificate.client_certificate.arn
  }

  connection_log_options {
    enabled = false
  }

  client_login_banner_options {
    banner_text = "Todo sua navegacao é monitorado e qualquer uso indevido sera penalizado!"
    enabled = true
  }
  split_tunnel = true
  security_group_ids = [aws_security_group.sg_vpn.id]
  vpc_id = module.criar_vpcA_regiao1.vpc_id
}

resource "aws_ec2_client_vpn_authorization_rule" "example" {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.client_vpn.id
  target_network_cidr    = module.criar_vpcA_regiao1.cidr_block # Rede que os clientes podem acessar
  authorize_all_groups   = true
}

## Associao subnets
resource "aws_ec2_client_vpn_network_association" "example_association_a" {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.client_vpn.id
  subnet_id              = module.criar_vpcA_regiao1.subnet_private_a_id
}

resource "aws_ec2_client_vpn_network_association" "example_association_b" {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.client_vpn.id
  subnet_id              = module.criar_vpcA_regiao1.subnet_private_b_id
}

resource "aws_ec2_client_vpn_network_association" "example_association_c" {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.client_vpn.id
  subnet_id              = module.criar_vpcA_regiao1.subnet_private_c_id
}

## rota para internet
resource "aws_ec2_client_vpn_route" "route_a" {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.client_vpn.id
  destination_cidr_block = "0.0.0.0/0"
  target_vpc_subnet_id   =module.criar_vpcA_regiao1.subnet_private_a_id # Substitua pelo ID da sua sub-rede
}

resource "aws_ec2_client_vpn_route" "route_b" {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.client_vpn.id
  destination_cidr_block = "0.0.0.0/0"
  target_vpc_subnet_id   =module.criar_vpcA_regiao1.subnet_private_b_id # Substitua pelo ID da sua sub-rede
}

resource "aws_ec2_client_vpn_route" "route_c" {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.client_vpn.id
  destination_cidr_block = "0.0.0.0/0"
  target_vpc_subnet_id   =module.criar_vpcA_regiao1.subnet_private_c_id # Substitua pelo ID da sua sub-rede
}

data "aws_region" "current" {}

resource "null_resource" "export-client-config" {
  provisioner "local-exec" {
    command = "aws --region ${data.aws_region.current.name} ec2 export-client-vpn-client-configuration --client-vpn-endpoint-id ${aws_ec2_client_vpn_endpoint.client_vpn.id} --output text > client-config.ovpn && sh update_vpn_config.sh client-config.ovpn"
  }
  # Trigger que muda a cada apply
  triggers = {
    always_run = "${timestamp()}"
  }
  depends_on = [
    aws_ec2_client_vpn_network_association.example_association_a, aws_ec2_client_vpn_network_association.example_association_b, aws_ec2_client_vpn_network_association.example_association_c
  ]
}



