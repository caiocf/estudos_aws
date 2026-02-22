# S3 Gateway endpoint (para acessar S3 sem NAT)
resource "aws_vpc_endpoint" "s3" {
  vpc_id            = data.aws_vpc.default.id
  service_name      = "com.amazonaws.${var.aws_region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [data.aws_vpc.default.main_route_table_id]
}


# Glue Interface endpoint
resource "aws_vpc_endpoint" "glue" {
  vpc_id              = data.aws_vpc.default.id
  service_name        = "com.amazonaws.${var.aws_region}.glue"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [data.aws_subnet.a.id, data.aws_subnet.b.id, data.aws_subnet.c.id]
  security_group_ids  = [aws_security_group.vpc_endpoints_sg.id]
  private_dns_enabled = true
}

# STS Interface endpoint (evita chamadas saírem pra internet)
resource "aws_vpc_endpoint" "sts" {
  vpc_id              = data.aws_vpc.default.id
  service_name        = "com.amazonaws.${var.aws_region}.sts"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [data.aws_subnet.a.id, data.aws_subnet.b.id, data.aws_subnet.c.id]
  security_group_ids  = [aws_security_group.vpc_endpoints_sg.id]
  private_dns_enabled = true
}