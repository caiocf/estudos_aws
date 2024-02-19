# for s3 endpoint Gateway
resource "aws_vpc_endpoint" "s3" {
  service_name = "com.amazonaws.${module.criar_vpcA_regiao1.region}.s3"
  vpc_id       = module.criar_vpcA_regiao1.vpc_id
  vpc_endpoint_type = "Gateway"
}

resource "aws_vpc_endpoint_route_table_association" "route_table_association_s3" {
  route_table_id  = module.criar_vpcA_regiao1.default_route_table_id
  vpc_endpoint_id = aws_vpc_endpoint.s3.id
}


# for dynamodb  endpoint Gateway
resource "aws_vpc_endpoint" "dynamodb" {
  service_name = "com.amazonaws.${module.criar_vpcA_regiao1.region}.dynamodb"
  vpc_id       = module.criar_vpcA_regiao1.vpc_id
  vpc_endpoint_type = "Gateway"
}

resource "aws_vpc_endpoint_route_table_association" "route_table_association_dynamodb" {
  route_table_id  = module.criar_vpcA_regiao1.default_route_table_id
  vpc_endpoint_id = aws_vpc_endpoint.dynamodb.id
}
