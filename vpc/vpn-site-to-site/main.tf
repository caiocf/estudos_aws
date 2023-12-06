resource "aws_customer_gateway" "cgw_main" {
  bgp_asn    = 65000
  ip_address = "177.106.115.194" // Address your Firewall side client.
  type       = "ipsec.1"

  provider = aws.primary

  tags = {
    Name = "main-customer-gateway"
  }
}

resource "aws_vpn_gateway" "vpg_main" {
  vpc_id = module.criar_vpcA_regiao1.vpc_id

  provider = aws.primary
}

resource "aws_vpn_connection" "vpn_mkcf_main" {
  depends_on = [ aws_customer_gateway.cgw_main,aws_vpn_gateway.vpg_main]

  customer_gateway_id = aws_customer_gateway.cgw_main.id
  vpn_gateway_id = aws_vpn_gateway.vpg_main.id
  type                = "ipsec.1"
  static_routes_only = true

  provider = aws.primary
}

resource "aws_vpn_connection_route" "route1" {
  destination_cidr_block = "192.168.24.0/24" ## rede PF sense, do lado cliente.
  vpn_connection_id      = aws_vpn_connection.vpn_mkcf_main.id
}
//// DUAS FORMA DE ROTEAR

// primeira manual
resource "aws_route" "vpn_route" {
  depends_on = [aws_vpn_gateway.vpg_main]

  route_table_id         =  module.criar_vpcA_regiao1.default_route_table_id
  destination_cidr_block = "192.168.24.0/24"
  gateway_id             = aws_vpn_gateway.vpg_main.id
}

// automatico via propagação interna da AWS
/*resource "aws_vpn_gateway_route_propagation" "example" {
  vpn_gateway_id      = aws_vpn_gateway.vpg_main.id
  route_table_id      =module.criar_vpcA_regiao1.default_route_table_id
}*/
