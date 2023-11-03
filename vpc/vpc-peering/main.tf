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


