resource "aws_instance" "web_A" {
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.allow_ssh_regiao1.id]
  subnet_id = module.criar_vpcA_regiao1.subnet_private_a_id
  ami = data.aws_ami.amazonLinux_regiao1.id

  key_name = aws_key_pair.keyPairSSH_1.key_name

  iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.name
  associate_public_ip_address =  false

  provider = aws.primary

  user_data = <<EOF
              #!/bin/bash
              # Instalação do SSM Agent
              yum install -y https://s3.amazonaws.com/session-manager-downloads/plugin/latest/linux_64bit/session-manager-plugin.rpm
              EOF
}

# for s3
resource "aws_vpc_endpoint" "s3" {
  service_name = "com.amazonaws.${module.criar_vpcA_regiao1.region}.s3"
  vpc_id       = module.criar_vpcA_regiao1.vpc_id
}

resource "aws_vpc_endpoint_route_table_association" "route_table_association_s3" {
  route_table_id  = module.criar_vpcA_regiao1.default_route_table_id
  vpc_endpoint_id = aws_vpc_endpoint.s3.id
}


# for dynamodb
resource "aws_vpc_endpoint" "dynamodb" {
  service_name = "com.amazonaws.${module.criar_vpcA_regiao1.region}.dynamodb"
  vpc_id       = module.criar_vpcA_regiao1.vpc_id
}

resource "aws_vpc_endpoint_route_table_association" "route_table_association_dynamodb" {
  route_table_id  = module.criar_vpcA_regiao1.default_route_table_id
  vpc_endpoint_id = aws_vpc_endpoint.dynamodb.id
}


# for ssm, ssmmessages, ec2messages
resource "aws_vpc_endpoint" "ssm" {
  vpc_id             = module.criar_vpcA_regiao1.vpc_id
  service_name       = "com.amazonaws.${module.criar_vpcA_regiao1.region}.ssm"
  vpc_endpoint_type  = "Interface"
  subnet_ids         = [module.criar_vpcA_regiao1.subnet_private_a_id,module.criar_vpcA_regiao1.subnet_private_b_id,module.criar_vpcA_regiao1.subnet_private_c_id ]
  security_group_ids = [aws_security_group.allow_ssh_regiao1.id]

  private_dns_enabled = true
}


resource "aws_vpc_endpoint" "ec2messages" {
  vpc_id             = module.criar_vpcA_regiao1.vpc_id
  service_name       = "com.amazonaws.${module.criar_vpcA_regiao1.region}.ec2messages"
  vpc_endpoint_type  = "Interface"
  subnet_ids         = [module.criar_vpcA_regiao1.subnet_private_a_id,module.criar_vpcA_regiao1.subnet_private_b_id,module.criar_vpcA_regiao1.subnet_private_c_id ]
  security_group_ids = [aws_security_group.allow_ssh_regiao1.id]

  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "ssmmessages" {
  vpc_id             = module.criar_vpcA_regiao1.vpc_id
  service_name       = "com.amazonaws.${module.criar_vpcA_regiao1.region}.ssmmessages"
  vpc_endpoint_type  = "Interface"
  subnet_ids         = [module.criar_vpcA_regiao1.subnet_private_a_id,module.criar_vpcA_regiao1.subnet_private_b_id,module.criar_vpcA_regiao1.subnet_private_c_id ]
  security_group_ids = [aws_security_group.allow_ssh_regiao1.id]

  private_dns_enabled = true
}
