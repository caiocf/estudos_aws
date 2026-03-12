resource "aws_vpc_endpoint" "s3" {
  vpc_id            = data.aws_vpc.default.id
  service_name      = "com.amazonaws.${var.aws_region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [data.aws_route_table.default.id]

  policy = jsonencode({
    Version = "2008-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = "*"
        Action    = "*"
        Resource  = "*"
      }
    ]
  })
}

resource "aws_vpc_endpoint" "glue" {
  vpc_id              = data.aws_vpc.default.id
  service_name        = "com.amazonaws.${var.aws_region}.glue"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = data.aws_subnets.default.ids
  security_group_ids  = [data.aws_security_group.default.id]
  private_dns_enabled = true

  policy = jsonencode({
    Statement = [
      {
        Action    = "*"
        Effect    = "Allow"
        Principal = "*"
        Resource  = "*"
      }
    ]
  })
}
