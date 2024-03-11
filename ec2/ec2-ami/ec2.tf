
resource "aws_instance" "web_ec2" {
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.allow_ssh_http_vpcA_regiao1.id]
  ami = data.aws_ami.amazon_regiao1.id
  subnet_id = element(sort(data.aws_subnets.default.ids), 0)

  key_name = aws_key_pair.keyPair_regiao_1.key_name

  iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.name
  associate_public_ip_address =  true

  root_block_device {
   delete_on_termination = true
   encrypted             = false
   tags                  = {}
   tags_all              = {}
   volume_size           = 30
   volume_type           = "gp2"
  }

  ebs_block_device {
    device_name           = "/dev/xvdb"
    volume_size           = 125
    volume_type           = "sc1"
    delete_on_termination = true
    tags = {
      Name = "sc1-volume"
    }
  }

  user_data = <<EOF
              #!/bin/bash
              # Instalação do SSM Agent e Apache
              yum install -y https://s3.amazonaws.com/session-manager-downloads/plugin/latest/linux_64bit/session-manager-plugin.rpm  httpd
              systemctl enable httpd
              systemctl start httpd
              echo "web_Vpc_A_Private" > /var/www/html/index.html
              EOF

  provider = aws.primary
  tags = {
    Name = "web_Vpc_A_Private"
  }
}