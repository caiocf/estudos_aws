
resource "aws_instance" "web_ec2_windows" {
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.allow_rdp_vpcA_regiao1.id]
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

  provider = aws.primary
  tags = {
    Name = "web_Vpc_A_Private"
  }
}

resource "aws_ebs_volume" "sc1" {
  provider = aws.primary
  availability_zone = aws_instance.web_ec2_windows.availability_zone
  size =  125
  type = "sc1"  # Tipo de volume SC1
  tags = {
    Name = "sc1-volume"
  }
}

resource "aws_volume_attachment" "ebs_attachment_sc1" {
  device_name = "/dev/sdb"
  instance_id = aws_instance.web_ec2_windows.id
  volume_id   = aws_ebs_volume.sc1.id
  provider = aws.primary
}

resource "aws_ebs_volume" "gp3" {
  provider = aws.primary
  availability_zone = aws_instance.web_ec2_windows.availability_zone
  size =  125
  type = "gp3"  # Tipo de volume GP3
  throughput = 250  # Define o throughput em MiB/s (megabytes por segundo)

  iops = 3000
  tags = {
    Name = "gp3-volume"
  }
}

resource "aws_volume_attachment" "ebs_attachment_gp3" {
  device_name = "/dev/sdc"
  instance_id = aws_instance.web_ec2_windows.id
  volume_id   = aws_ebs_volume.gp3.id
  provider = aws.primary
}
