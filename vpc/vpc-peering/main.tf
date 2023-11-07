resource "aws_instance" "web_A" {
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.allow_ssh_regiao1.id]
  subnet_id = module.criar_vpcA_regiao1.subnet_a_id
  ami = data.aws_ami.amazonLinux_regiao1.id

  key_name = aws_key_pair.keyPairSSH_1.key_name

  iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.name

  provider = aws.primary

  user_data = <<EOF
              #!/bin/bash
              # Instalação do SSM Agent
              yum install -y https://s3.amazonaws.com/session-manager-downloads/plugin/latest/linux_64bit/session-manager-plugin.rpm
              EOF
}

resource "aws_instance" "web_B" {
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.allow_ssh_regiao2.id]
  subnet_id = module.criar_vpcB_regiao2.subnet_a_id

  ami = data.aws_ami.amazonLinux_regiao2.id
  iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.name

  key_name = aws_key_pair.keyPairSSH_2.key_name

  provider = aws.secondary

  user_data = <<EOF
              #!/bin/bash
              # Instalação do SSM Agent
              yum install -y https://s3.amazonaws.com/session-manager-downloads/plugin/latest/linux_64bit/session-manager-plugin.rpm
              EOF
}



data "aws_caller_identity" "peer" {
  provider = aws.secondary
}

resource "aws_vpc_peering_connection" "peer" {
  provider = aws.primary

  vpc_id        =  module.criar_vpcA_regiao1.vpc_id
  peer_vpc_id   = module.criar_vpcB_regiao2.vpc_id
  peer_owner_id = data.aws_caller_identity.peer.account_id
  peer_region = "us-east-2"
  auto_accept   = false

  tags = {
    Side = "Requester"
  }
}


# Accepter's side of the connection.
resource "aws_vpc_peering_connection_accepter" "peer" {
  provider = aws.secondary

  vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
  auto_accept               = true

  tags = {
    Side = "Accepter"
  }
}

resource "aws_vpc_peering_connection_options" "requester" {
  provider = aws.primary

  # As options can't be set until the connection has been accepted
  # create an explicit dependency on the accepter.
  vpc_peering_connection_id = aws_vpc_peering_connection_accepter.peer.id

  requester {
    allow_remote_vpc_dns_resolution = true
  }
}


resource "aws_vpc_peering_connection_options" "accepter" {
  provider = aws.secondary

  vpc_peering_connection_id = aws_vpc_peering_connection_accepter.peer.id

  accepter {
    allow_remote_vpc_dns_resolution = true
  }
}


resource "aws_route" "public_A_para_B" {
  provider = aws.primary

  depends_on = [aws_vpc_peering_connection.peer]
  route_table_id         =  module.criar_vpcA_regiao1.default_route_table_id
  destination_cidr_block = module.criar_vpcB_regiao2.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
}


resource "aws_route" "public_B_para_A" {
  provider = aws.secondary

  depends_on = [aws_vpc_peering_connection.peer]
  route_table_id         =  module.criar_vpcB_regiao2.default_route_table_id
  destination_cidr_block = module.criar_vpcA_regiao1.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection_accepter.peer.id
}
