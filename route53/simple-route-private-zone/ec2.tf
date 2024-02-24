
resource "aws_instance" "web_Vpc_A_Private" {
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.allow_ssh_vpcA_regiao1.id]
  ami = data.aws_ami.amazonLinux_regiao1.id
  subnet_id = element(sort(data.aws_subnets.default.ids), 0)

  key_name = aws_key_pair.keyPairSSH_regiao_1.key_name

  iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.name
  associate_public_ip_address =  true

  provider = aws.primary

  user_data = <<EOF
              #!/bin/bash
              # Instalação do SSM Agent e Apache
              yum install -y https://s3.amazonaws.com/session-manager-downloads/plugin/latest/linux_64bit/session-manager-plugin.rpm  httpd
              systemctl enable httpd
              systemctl start httpd
              echo "web_Vpc_A_Private" > /var/www/html/index.html
              EOF
  tags = {
    Name = "web_Vpc_A_Private"
  }
}

