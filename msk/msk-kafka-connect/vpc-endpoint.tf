resource "aws_vpc_endpoint" "secretsmanager" {
  vpc_id              = data.aws_vpc.default.id
  service_name        = "com.amazonaws.${var.region}.secretsmanager"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [data.aws_subnet.a.id, data.aws_subnet.b.id, data.aws_subnet.c.id]
  security_group_ids  = [aws_security_group.msk.id]  # <= SG do endpoint (443)
  private_dns_enabled = true
}




# KMS (Interface)
resource "aws_vpc_endpoint" "kms" {
  vpc_id              = data.aws_vpc.default.id
  service_name        = "com.amazonaws.us-east-1.kms"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [data.aws_subnet.a.id, data.aws_subnet.b.id, data.aws_subnet.c.id]
  security_group_ids  = [aws_security_group.msk.id]
  private_dns_enabled = true
}

# CloudWatch Logs (Interface) - recomendado
resource "aws_vpc_endpoint" "logs" {
  vpc_id              = data.aws_vpc.default.id
  service_name        = "com.amazonaws.us-east-1.logs"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [data.aws_subnet.a.id, data.aws_subnet.c.id]
  security_group_ids  = [aws_security_group.msk.id]
  private_dns_enabled = true
}
