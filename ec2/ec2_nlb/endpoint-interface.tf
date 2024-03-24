
# for ssm endpoint Interface
resource "aws_vpc_endpoint" "ssm" {
  vpc_id             = data.aws_vpc.default.id
  service_name       = "com.amazonaws.${data.aws_region.current.name}.ssm"
  vpc_endpoint_type  = "Interface"
  subnet_ids         = data.aws_subnets.default.ids// [element(sort(data.aws_subnets.default.ids), 0), element(sort(data.aws_subnets.default.ids), 1),element(sort(data.aws_subnets.default.ids), 2)]
  security_group_ids = [aws_security_group.allow_ssh_vpcA_regiao1.id]

  private_dns_enabled = true
}

# for ec2messages endpoint Interface
resource "aws_vpc_endpoint" "ec2messages" {
  vpc_id             = data.aws_vpc.default.id
  service_name       = "com.amazonaws.${data.aws_region.current.name}.ec2messages"
  vpc_endpoint_type  = "Interface"
  subnet_ids         = data.aws_subnets.default.ids// [element(sort(data.aws_subnets.default.ids), 0), element(sort(data.aws_subnets.default.ids), 1),element(sort(data.aws_subnets.default.ids), 2)]
  security_group_ids = [aws_security_group.allow_ssh_vpcA_regiao1.id]


  private_dns_enabled = true
}

# for ssmmessages endpoint Interface
resource "aws_vpc_endpoint" "ssmmessages" {
  vpc_id             = data.aws_vpc.default.id
  service_name       = "com.amazonaws.${data.aws_region.current.name}.ssmmessages"
  vpc_endpoint_type  = "Interface"
  subnet_ids         = data.aws_subnets.default.ids// [element(sort(data.aws_subnets.default.ids), 0), element(sort(data.aws_subnets.default.ids), 1),element(sort(data.aws_subnets.default.ids), 2)]
  security_group_ids = [aws_security_group.allow_ssh_vpcA_regiao1.id]

  private_dns_enabled = true
}


# for logs endpoint Interface
resource "aws_vpc_endpoint" "logs" {
  vpc_id             = data.aws_vpc.default.id
  service_name       = "com.amazonaws.${data.aws_region.current.name}.logs"
  vpc_endpoint_type  = "Interface"
  subnet_ids         = data.aws_subnets.default.ids// [element(sort(data.aws_subnets.default.ids), 0), element(sort(data.aws_subnets.default.ids), 1),element(sort(data.aws_subnets.default.ids), 2)]
  security_group_ids = [aws_security_group.allow_ssh_vpcA_regiao1.id]

  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "s3" {
  service_name = "com.amazonaws.${data.aws_region.current.name}.s3"
  vpc_id       = data.aws_vpc.default.id
  vpc_endpoint_type = "Gateway"

  route_table_ids = [data.aws_vpc.default.main_route_table_id]
}


