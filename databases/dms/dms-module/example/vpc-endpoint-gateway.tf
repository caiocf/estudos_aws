// https://dataintegration.info/use-a-sql-server-secondary-replica-in-an-availability-group-as-a-source-to-migrate-data-into-amazon-redshift-with-aws-dms
/*
 It’s also a mandate requirement if your AWS DMS instance is not publicly accessible
  and your AWS DMS version is 3.4.7 and higher.
*/
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