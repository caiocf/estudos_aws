/*
Somente necessario quando tiver rede privada e as instancia sem IP publico e nao tiver uma NAT-GW ou NAT-INSTANCE habilitado.
# for ssm endpoint Interface
resource "aws_vpc_endpoint" "ssm" {
  vpc_id             = module.criar_vpcA_regiao1.vpc_id
  service_name       = "com.amazonaws.${module.criar_vpcA_regiao1.region}.ssm"
  vpc_endpoint_type  = "Interface"
  subnet_ids         = [module.criar_vpcA_regiao1.subnet_a_id,module.criar_vpcA_regiao1.subnet_b_id,module.criar_vpcA_regiao1.subnet_c_id ]
  security_group_ids = [aws_security_group.regra_http_ssh.id]

  private_dns_enabled = true
}

# for ec2messages endpoint Interface
resource "aws_vpc_endpoint" "ec2messages" {
  vpc_id             = module.criar_vpcA_regiao1.vpc_id
  service_name       = "com.amazonaws.${module.criar_vpcA_regiao1.region}.ec2messages"
  vpc_endpoint_type  = "Interface"
  subnet_ids         = [module.criar_vpcA_regiao1.subnet_a_id,module.criar_vpcA_regiao1.subnet_b_id,module.criar_vpcA_regiao1.subnet_c_id ]
  security_group_ids = [aws_security_group.regra_http_ssh.id]

  private_dns_enabled = true
}

# for ssmmessages endpoint Interface
resource "aws_vpc_endpoint" "ssmmessages" {
  vpc_id             = module.criar_vpcA_regiao1.vpc_id
  service_name       = "com.amazonaws.${module.criar_vpcA_regiao1.region}.ssmmessages"
  vpc_endpoint_type  = "Interface"
  subnet_ids         = [module.criar_vpcA_regiao1.subnet_a_id,module.criar_vpcA_regiao1.subnet_b_id,module.criar_vpcA_regiao1.subnet_c_id ]
  security_group_ids = [aws_security_group.regra_http_ssh.id]

  private_dns_enabled = true
}
*/
