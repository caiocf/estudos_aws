resource "aws_efs_file_system" "example" {
  creation_token = "my-efs"

  throughput_mode = "bursting" #  O modo padrão, otimizado para latência
  performance_mode = "generalPurpose" # o throughput disponível para o sistema de arquivos aumenta automaticamente conforme o tamanho do EFS cresce


  # throughput_mode  = "provisioned"
  # provisioned_throughput_in_mibps = 10

  provider = aws.primary

  tags = {
    Name = "MyEFS"
  }
}

resource "aws_efs_mount_target" "example" {
  for_each         = toset(data.aws_subnets.default.ids)
  file_system_id   = aws_efs_file_system.example.id
  subnet_id        = each.value # pelo ID da subnet correspondente
  security_groups  = [aws_security_group.allow_ssh_efs_vpcA_regiao1.id]

  provider = aws.primary
}


resource "aws_instance" "web_ec2" {
  count =  2

  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.allow_ssh_efs_vpcA_regiao1.id]
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

  user_data = <<EOF
              #!/bin/bash
              # Instalação do SSM Agent e Apache
              yum install -y https://s3.amazonaws.com/session-manager-downloads/plugin/latest/linux_64bit/session-manager-plugin.rpm  httpd

              yum install -y amazon-efs-utils
              mkdir /mnt/efs
              mount -t efs ${aws_efs_file_system.example.id}:/ /mnt/efs
              echo "${aws_efs_file_system.example.id}:/ /mnt/efs efs defaults,_netdev 0 0" >> /etc/fstab

              # Altera as permissões do diretório de montagem para permitir a escrita pelo usuário ec2-user
              chown ec2-user:ec2-user /mnt/efs
              chmod 700 /mnt/efs
              EOF
  tags = {
    Name = "web_Vpc_A_Private_${count.index}"
  }
}